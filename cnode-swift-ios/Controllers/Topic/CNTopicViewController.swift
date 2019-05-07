//
//  CNPageViewController.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/29.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage
import SwiftDate
import WebKit

private var heightCache:[String: CGFloat] = [:];

class CNTopicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate {
    let tableView = UITableView();
    let isCollect = UIButton();
    
    var topicId: String!;
    var topic: JSON!;
    var replyArr:[JSON] = [];
    
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
            return heightCache[topic["id"].stringValue] ?? UITableView.automaticDimension;
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
                    headerCell?.authorName.text = content["author"]["loginname"].string;
                    headerCell?.headingTitile.text = content["title"].string;
                    headerCell?.avator.af_setImage(withURL: URL.init(string: content["author"]["avatar_url"].string!)!)
                    if let createdAt = content["create_at"].string,
                        let createdAtTime = createdAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
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
                      <div class="markdown-body">\(topic["content"].string!)</div>
                    </body>
                    </html>
                    """;
                    webviewCell?.webView.loadHTMLString(html, baseURL: nil);
                    webviewCell?.refresh = {(_ height: CGFloat) -> () in
                        heightCache[topic["id"].stringValue] = height;
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
            cell?.authorName.text = replyItem["author"]["loginname"].string;
            cell?.avator.af_setImage(withURL: URL.init(string: replyItem["author"]["avatar_url"].string!)!);
            cell?.replyContent.text = replyItem["content"].string;
            if let replyAt = replyItem["create_at"].string,
                let _replyAt = replyAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
                cell?.replyAt.text = "\(_replyAt)";
            }
            return cell!
        }
    }
    
    func loadData(_ mdrender: String, with callback: @escaping (JSON) -> Void) {
        var parameters: Dictionary = ["mdrender": mdrender]
        if(CNUserService.shared.isLogin) {
            parameters["accesstoken"] = CNUserService.shared.accesstoken
        }
        Alamofire.request(
            "https://cnodejs.org/api/v1/topic/\(self.topicId!)",
            parameters: parameters)
            .validate()
            .responseJSON { (response) in
                let json = JSON(response.result.value!);
                callback(json["data"])
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
        
        let inset: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: CNUserService.shared.isLogin ? 56 : 0, right: 0);
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide).inset(inset);
        }
        
        if(CNUserService.shared.isLogin) {
            let toolbar = UIView();
            toolbar.backgroundColor = UIColor.white;
            toolbar.layer.shadowColor = UIColor.init(red: 26/255, green: 26/255, blue: 26/255, alpha: 1).cgColor;
            toolbar.layer.shadowOpacity = 0.1;
            toolbar.layer.shadowOffset = CGSize(width: 0, height: -3)
            
            view.addSubview(toolbar);
            toolbar.snp.makeConstraints { (make) in
                make.width.equalTo(self.view);
                make.height.equalTo(50);
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom);
                make.left.equalTo(self.view);
            }
            
            let comment = UIButton();
            toolbar.addSubview(comment);
            comment.setTitleColor(UIColor.init(red: 152/255, green: 152/255, blue: 152/255, alpha: 1), for: .normal);
            comment.setTitle("\u{e6fb}添加评论", for: .normal);
            comment.titleLabel?.font = UIFont.init(name: "iconfont", size: 18)
            comment.snp.makeConstraints { (make) in
                make.centerY.equalTo(toolbar);
                make.left.equalTo(toolbar).offset(15);
            }
            
            if(topic["is_collect"].boolValue) {
                isCollect.setTitle("\u{e62c}取消收藏", for: .normal);
                isCollect.setTitleColor(UIColor.init(red: 0/255, green: 127/255, blue: 255/255, alpha: 1), for: .normal);
            } else {
                isCollect.setTitle("\u{e62c}收藏", for: .normal);
                isCollect.setTitleColor(UIColor.init(red: 152/255, green: 152/255, blue: 152/255, alpha: 1), for: .normal);
            }
            
            isCollect.titleLabel?.font = UIFont.init(name: "iconfont", size: 19);
            toolbar.addSubview(self.isCollect);
            isCollect.snp.makeConstraints { (make) in
                make.centerY.equalTo(toolbar);
                make.left.equalTo(comment.snp.right).offset(10);
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
            self.loadData("false", with: { (json) in
                self.replyArr = json["replies"].arrayValue;
                group.leave();
            })
        }
        group.enter();
        DispatchQueue.global().async(group: group, qos: .default, flags: .inheritQoS) {
            self.loadData("true", with: { (json) in
                self.topic = json;
                group.leave();
            })
        }
        group.notify(queue: DispatchQueue.main) {
            self.refreshView();
        }
    }
    
    @objc func onCollect() {
        if(topic["is_collect"].boolValue) {
            self.topicDecollect {
                self.topic["is_collect"] = JSON(false);
                self.isCollect.setTitle("\u{e62c}收藏", for: .normal);
                self.isCollect.setTitleColor(UIColor.init(red: 152/255, green: 152/255, blue: 152/255, alpha: 1), for: .normal);
            }
        } else {
            self.topicCollect {
                self.topic["is_collect"] = JSON(true);
                self.isCollect.setTitle("\u{e62c}取消收藏", for: .normal);
                self.isCollect.setTitleColor(UIColor.init(red: 0/255, green: 127/255, blue: 255/255, alpha: 1), for: .normal);
            }
        }
    }
    
    func topicCollect(_ handler: (() -> Void)?) {
        if let accesstoken = CNUserService.shared.accesstoken {
            Alamofire.request(
                "https://cnodejs.org/api/v1/topic_collect/collect",
                method: .post,
                parameters: ["accesstoken": accesstoken, "topic_id": topic["id"].stringValue]
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
                parameters: ["accesstoken": accesstoken, "topic_id": topic["id"].stringValue]
                )
                .validate()
                .responseJSON { (make) in
                    handler?();
            }
        }
    }
}
