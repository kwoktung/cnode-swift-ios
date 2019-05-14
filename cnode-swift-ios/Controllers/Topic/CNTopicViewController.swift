//
//  CNPageViewController.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/29.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftDate
import WebKit

private var heightCache:[String: CGFloat] = [:];

class CNTopicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate {
    let tableView = UITableView();
    let isCollect = UIButton();
    
    var topicId: String!;
    var topic: CNTopicModel!;
    var replyArr:[CNTopicReply] = [];
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = [];
        if (!CNUserService.shared.isLogin) { return UISwipeActionsConfiguration.init(actions: actions); }
        if (indexPath.section == 1) {
            let reply = replyArr[indexPath.item];
            let replyId = reply.id
            let username = reply.author.loginname
            if(username == CNUserService.shared.loginname) {
                let action = UIContextualAction.init(style: .destructive, title: "删除") { (_ UIContextualAction, _ UIView, handler: @escaping (Bool) -> Void) in
                    self.onDeleteReply(replyId, with: handler);
                }
                actions.append(action);
            }
        }
        return UISwipeActionsConfiguration.init(actions: actions);
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return replyArr.count == 0 ? 1 : 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : replyArr.count;
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "全部评论": nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 50 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0 && indexPath.item == 1) {
            return heightCache[topic.id] ?? UITableView.automaticDimension;
        }
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0) {
            if(indexPath.item == 0) {
                var headerCell = tableView.dequeueReusableCell(withIdentifier: "CNTopicContentCell", for: indexPath) as? CNTopicContentCell;
                if(headerCell==nil) {
                    headerCell = CNTopicContentCell.init(style: .default, reuseIdentifier: "CNTopicContentCell");
                }
                if let content = self.topic {
                    headerCell?.authorName.text = content.author.loginname;
                    headerCell?.headingTitile.text = content.title;
                    headerCell?.avator.af_setImage(withURL: URL.init(string: content.author.avatarUrl)!)
                    if let createdAtTime = content.createAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
                        headerCell?.createdAt.text = "创建于\(createdAtTime)";
                    }
                }
                return headerCell!
            } else {
                var webviewCell = tableView.dequeueReusableCell(withIdentifier: "CNTopicContentWebViewCell", for: indexPath) as? CNTopicContentWebViewCell;
                if (webviewCell == nil) {
                    webviewCell = CNTopicContentWebViewCell.init(style: .default, reuseIdentifier: "CNTopicContentWebViewCell");
                }
                if(!webviewCell!.loaded) {
                    let topic = self.topic!;
                    let html = """
                    <!DOCTYPE html>
                    <html lang="en">
                    <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <meta http-equiv="X-UA-Compatible" content="ie=edge">
                    <title>Document</title>
                      <link rel="stylesheet" href="https://raw.githubusercontent.com/sindresorhus/github-markdown-css/gh-pages/github-markdown.css">
                    </head>
                    <body>
                      <div class="markdown-body">\(topic.content)</div>
                    </body>
                    </html>
                    """;
                    webviewCell?.webView.loadHTMLString(html, baseURL: nil);
                    webviewCell?.refresh = {(_ height: CGFloat) -> () in
                        heightCache[topic.id] = height;
                        self.tableView.reloadRows(at: [indexPath], with: .none);
                    };
                }

                return webviewCell!
            }
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CNTopicReplyCell", for: indexPath) as? CNTopicReplyCell;
            if (cell == nil) {
                cell = CNTopicReplyCell.init(style: .default, reuseIdentifier: "CNTopicReplyCell");
            }
            let replyItem = replyArr[indexPath.item]
            cell?.authorName.text = replyItem.author.loginname;
            cell?.avator.af_setImage(withURL: URL.init(string: replyItem.author.avatarUrl)!);
            cell?.replyContent.text = replyItem.content;
            if let _replyAt = replyItem.createAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
                cell?.replyAt.text = "\(_replyAt)";
            }
            return cell!
        }
    }
    
    func loadData(_ mdrender: String, with callback: @escaping (CNTopicModel) -> Void) {
        var parameters: Dictionary = ["mdrender": mdrender]
        if(CNUserService.shared.isLogin) {
            parameters["accesstoken"] = CNUserService.shared.accesstoken
        }
        Alamofire.request(
            "https://cnodejs.org/api/v1/topic/\(self.topicId!)",
            parameters: parameters)
            .responseJSON { (response) in
                switch response.result {
                case .success(_):
                    let decoder = JSONDecoder();
                    decoder.keyDecodingStrategy = .convertFromSnakeCase;
                    guard let res = try? decoder.decode(CNTopicModelResponse.self, from: response.data!), res.success == true else { return }
                    callback(res.data)
                case .failure(_):
                    self.navigationController?.popViewController(animated: true);
                }
        }
    }
    
    func refreshView() {
        tableView.tableFooterView = UIView();
        tableView.separatorStyle = .none
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.estimatedRowHeight = 200;
        tableView.allowsSelection = false;
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.register(CNTopicReplyCell.self, forCellReuseIdentifier: "CNTopicReplyCell");
        tableView.register(CNTopicContentCell.self, forCellReuseIdentifier: "CNTopicContentCell");
        tableView.register(CNTopicContentWebViewCell.self, forCellReuseIdentifier: "CNTopicContentWebViewCell")
        view.addSubview(tableView);

        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view);
        }
        
        if(CNUserService.shared.isLogin) {
            let comment = UIButton();
            view.addSubview(comment);
            comment.layer.cornerRadius = 30;
            comment.layer.masksToBounds = true;
            comment.setTitleColor(UIColor.init(red: 0/255, green: 127/255, blue: 255/255, alpha: 1), for: .normal);
            comment.setTitle("\u{e617}", for: .normal);
            comment.titleLabel?.font = UIFont.init(name: "iconfont", size: 40)
            comment.snp.makeConstraints { (make) in
                make.width.height.equalTo(60);
                make.right.equalTo(view).offset(-20);
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20);
            }
            comment.addTarget(self, action: #selector(onComment), for: .touchUpInside);
            
            view.addSubview(isCollect);
            isCollect.setTitle("\u{e62c}", for: .normal);
            isCollect.titleLabel?.font = UIFont.init(name: "iconfont", size: 50);
            isCollect.layer.cornerRadius = 30;
            isCollect.layer.masksToBounds = true;
            if(topic.isCollect) {
                isCollect.setTitleColor(UIColor.init(red: 0/255, green: 127/255, blue: 255/255, alpha: 1), for: .normal);
            } else {
                isCollect.setTitleColor(UIColor.init(red: 152/255, green: 152/255, blue: 152/255, alpha: 1), for: .normal);
            }

            isCollect.snp.makeConstraints { (make) in
                make.width.height.equalTo(60);
                make.left.equalTo(view).offset(20);
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20);
            }
            isCollect.addTarget(self, action: #selector(onCollect), for: .touchUpInside);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.white;
        let group = DispatchGroup.init();
        group.enter()
        DispatchQueue.global().async(group: group, qos: .default, flags: .inheritQoS) {
            self.loadData("false", with: { (topic) in
                self.replyArr = topic.replies
                group.leave();
            })
        }
        group.enter();
        DispatchQueue.global().async(group: group, qos: .default, flags: .inheritQoS) {
            self.loadData("true", with: { (topic) in
                self.topic = topic;
                group.leave();
            })
        }
        group.notify(queue: DispatchQueue.main) {
            self.refreshView();
        }
        NotificationCenter.default.addObserver(self, selector: #selector(onTopicNeedUpdateReplies), name: NSNotification.Name(rawValue: "TopicNeedUpdateReplies"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    @objc
    func onDeleteReply(_ replyId: String, with completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            CNCSRFTokenService.standard.getCSRFToken({ (csrf :String) in
                Alamofire.request(
                    "https://cnodejs.org/reply/\(replyId)/delete",
                    method: .post,
                    parameters: ["reply_id": replyId, "_csrf": csrf]
                )
                .validate()
                .responseData(completionHandler: { (response) in
                    switch response.result {
                    case .success(_):
                         completionHandler(true);
                    case .failure(_):
                        ()
                    }
                })
            })
        }
    }
    
    @objc
    func onTopicNeedUpdateReplies() {
        DispatchQueue.global().async {
            self.loadData("false", with: { (topic) in
                let len = self.replyArr.count;
                self.replyArr = topic.replies
                DispatchQueue.main.async {
                    if (len == 0) {
                        self.tableView.reloadData();
                    } else {
                        self.tableView.reloadSections(IndexSet.init(integer: 1), with: .none);
                    }
                }
            })
        }
    }
    
    @objc func onCollect() {
        if(topic.isCollect) {
            self.topicDecollect {
                self.topic.isCollect = false;
                self.isCollect.setTitleColor(UIColor.init(red: 152/255, green: 152/255, blue: 152/255, alpha: 1), for: .normal);
            }
        } else {
            self.topicCollect {
                self.topic.isCollect = true
                self.isCollect.setTitleColor(UIColor.init(red: 0/255, green: 127/255, blue: 255/255, alpha: 1), for: .normal);
            }
        }
    }
    
    @objc
    func onComment() {
        let controller = CNTopicCommentViewController();
        controller.topicId = topicId;
        self.navigationController?.pushViewController(controller, animated: true);
    }
    
    func topicCollect(_ handler: (() -> Void)?) {
        if let accesstoken = CNUserService.shared.accesstoken {
            Alamofire.request(
                "https://cnodejs.org/api/v1/topic_collect/collect",
                method: .post,
                parameters: ["accesstoken": accesstoken, "topic_id": topic.id]
                )
                .validate()
                .responseJSON { (make) in
                    handler?()
            }
        }
    }
    
    func topicDecollect(_ handler: (() -> Void)?) {
        if let accesstoken = CNUserService.shared.accesstoken {
            Alamofire.request(
                "https://cnodejs.org/api/v1/topic_collect/de_collect",
                method: .post,
                parameters: ["accesstoken": accesstoken, "topic_id": topic.id]
                )
                .validate()
                .responseJSON { (make) in
                    handler?();
            }
        }
    }
}
