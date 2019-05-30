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
import SVProgressHUD

private var heightCache:[String: CGFloat] = [:];

class CNTopicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate {
    let tableView = UITableView();
    let isCollect = UIButton();
    
    var topicId: String!;
    var topic: CNTopicModel!;
    var replyArr:[CNTopicReply] = [];
    var tabsMap:[String: String] =  ["good":"精华", "share":"分享", "ask":"问答", "job":"招聘", "dev": "客服端测试"];
    var error: Error?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        navigationController?.setNavigationBarHidden(true, animated: false);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        navigationController?.setNavigationBarHidden(false, animated: false);
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
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
                    headerCell?.headingTitile.text = content.title;
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
                    <style>
                    /* markdown editor */
                    blockquote {
                    padding: 0 0 0 15px;
                    margin: 0 0 20px;
                    border-left: 5px solid #eee;
                    }
                    img {
                    height: auto;
                    max-width: 100%;
                    vertical-align: middle;
                    border: 0;
                    -ms-interpolation-mode: bicubic;
                    }
                    .markdown-text a {
                    color: #08c;
                    }
                    .markdown-text p, .preview p {
                    white-space: pre-wrap; /* CSS3 */
                    white-space: -moz-pre-wrap; /* Mozilla, since 1999 */
                    white-space: -pre-wrap; /* Opera 4-6 */
                    white-space: -o-pre-wrap; /* Opera 7 */
                    word-wrap: break-word; /* Internet Explorer 5.5+ */
                    line-height: 2em;
                    margin: 1em 0;
                    }
                    
                    .markdown-text > *:first-child, .preview > *:first-child {
                    margin-top: 0;
                    }
                    
                    .markdown-text > *:last-child, .preview > *:last-child {
                    margin-bottom: 1em;
                    }
                    
                    .markdown-text li, .preview li {
                    font-size: 14px;
                    line-height: 2em;
                    }
                    pre code {
                    white-space: pre-wrap;
                    }
                    ol, ul {
                    padding: 0;
                    margin: 0 0 10px 25px;
                    }
                    div pre.prettyprint {
                    font-size: 14px;
                    border-radius: 0;
                    padding: 0 15px;
                    border: none;
                    margin: 20px -10px;
                    border-width: 1px 0;
                    background: #f7f7f7;
                    -o-tab-size: 4;
                    -moz-tab-size: 4;
                    tab-size: 4;
                    }
                    
                    .markdown-text p code, .preview p code,
                    .markdown-text li code, .preview li code {
                    color: black;
                    background-color: #fcfafa;
                    padding: 4px 6px;
                    }
                    .markdown-text img {
                    cursor: pointer;
                    }
                    
                    .markdown-text {
                    h1 code, h2 code, h3 code, h4 code, h5 code, h6 code {
                    font-size: inherit;
                    color: inherit;
                    }
                    }
                    
                    .panel .markdown-text a {
                    color: #08c;
                    }
                    .inner.topic {
                    padding: 10px;
                    border-top: 1px solid #e5e5e5;
                    }
                    .topic_content {
                    margin: 0 10px;
                    }
                    </style>
                    </head>
                    <body>
                      <div class="inner topic">
                        <div class="topic_content">
                            \(topic.content)
                        </div>
                      </div>
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
            .validate()
            .responseJSON { [unowned self](response) in
                switch response.result {
                case .success(_):
                    let decoder = JSONDecoder();
                    decoder.keyDecodingStrategy = .convertFromSnakeCase;
                    guard let res = try? decoder.decode(CNTopicModelResponse.self, from: response.data!), res.success == true else { return }
                    callback(res.data)
                case .failure(let error):
                    if(self.error == nil) {
                        self.error = error;
                        SVProgressHUD.showInfo(withStatus: "加载失败");
                        self.navigationController?.popViewController(animated: true);
                    }
                }
        }
    }
    
    func initView() {
        view.backgroundColor = .white;
        
        let header = UIView.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200));
        header.backgroundColor = UIColor.init(red: 188/255, green: 224/255, blue: 253/255, alpha: 1);
        
        let headerTitle = UILabel();
        headerTitle.text = tabsMap[topic.tab];
        headerTitle.textColor = .white;
        headerTitle.font = .boldSystemFont(ofSize: 16);
        
        header.addSubview(headerTitle);
        headerTitle.snp.makeConstraints { (make) in
            make.bottom.equalTo(header).offset(-30);
            make.right.equalTo(header).offset(-15);
        }
        
        let backBtn = UIButton();
        header.addSubview(backBtn);
        backBtn.titleLabel?.font = UIFont.init(name: "iconfont", size: 30)
        backBtn.setTitle("\u{e720}", for: .normal);
        backBtn.snp.makeConstraints { (make) in
            make.top.equalTo(header).offset(20);
            make.left.equalTo(header).offset(15);
        }
        backBtn.addTarget(self, action: #selector(onBack), for: .touchUpInside);
        
        let avator = UIImageView();
        avator.af_setImage(withURL: URL.init(string: topic.author.avatarUrl)!)
        header.addSubview(avator);
        avator.layer.cornerRadius = 40;
        avator.layer.masksToBounds = true;
        avator.snp.makeConstraints { (make) in
            make.width.height.equalTo(80);
            make.top.equalTo(backBtn.snp.bottom).offset(17);
            make.left.equalTo(header).offset(30);
        }
        
        let createAtIcon = UILabel();
        header.addSubview(createAtIcon);
        createAtIcon.font = UIFont.init(name: "iconfont", size: 20);
        createAtIcon.text = "\u{e735}"
        createAtIcon.textColor = UIColor.white
        createAtIcon.snp.makeConstraints { (make) in
            make.top.equalTo(avator.snp.bottom).offset(6);
            make.left.equalTo(header).offset(24);
        }
        
        let createAt = UILabel();
        createAt.textColor = UIColor.white
        header.addSubview(createAt);
        if let createdAtTime = topic.createAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
            createAt.font = UIFont.init(name: "iconfont", size: 14)
            createAt.text = "\(topic.author.loginname) 创建于\(createdAtTime)";
        }
        createAt.snp.makeConstraints { (make) in
            make.centerY.equalTo(createAtIcon);
            make.left.equalTo(createAtIcon.snp.right).offset(2);
        }
        
        let footer = UIView.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20));
        footer.backgroundColor = .white;
        
        tableView.backgroundColor = .clear;
        tableView.tableHeaderView = header;
        tableView.tableFooterView = footer;
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
            make.top.equalTo(view);
            make.left.equalTo(view);
            make.size.equalTo(view);
        }
        
        if(CNUserService.shared.isLogin) {
            let comment = UIButton();
            view.addSubview(comment);
            comment.layer.cornerRadius = 30;
            comment.layer.masksToBounds = true;
            comment.setTitleColor(UIColor.init(red: 0/255, green: 127/255, blue: 255/255, alpha: 1), for: .normal);
            comment.setTitle("\u{e63c}", for: .normal);
            comment.titleLabel?.font = UIFont.init(name: "iconfont", size: 60)
            comment.snp.makeConstraints { (make) in
                make.width.height.equalTo(60);
                make.right.equalTo(view).offset(-20);
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20);
            }
            comment.addTarget(self, action: #selector(onComment), for: .touchUpInside);
            
            header.addSubview(isCollect);
            isCollect.setTitle("\u{e62c}", for: .normal);
            isCollect.titleLabel?.font = UIFont.init(name: "iconfont", size: 20);
            if(topic.isCollect) {
                isCollect.setTitleColor(UIColor.init(red: 38/255, green: 153/255, blue: 251/255, alpha: 1), for: .normal);
            } else {
                isCollect.setTitleColor(.white, for: .normal);
            }

            isCollect.snp.makeConstraints { (make) in
                make.width.height.equalTo(20);
                make.right.equalTo(headerTitle.snp.left).offset(-5);
                make.centerY.equalTo(headerTitle);
            }
            isCollect.addTarget(self, action: #selector(onCollect), for: .touchUpInside);
        }
    }
    
    @objc
    func onBack() {
        self.navigationController?.popViewController(animated: true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.white;
        let group = DispatchGroup.init();
        group.enter()
        group.enter();
        DispatchQueue.global().async(group: group, qos: .default, flags: .inheritQoS) {
            self.loadData("false", with: { (topic) in
                self.replyArr = topic.replies
                group.leave();
            })
        }
        DispatchQueue.global().async(group: group, qos: .default, flags: .inheritQoS) {
            self.loadData("true", with: { (topic) in
                self.topic = topic;
                group.leave();
            })
        }
        group.notify(queue: DispatchQueue.main) {
            self.initView();
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
                self.isCollect.setTitleColor(UIColor.init(red: 1, green: 1, blue: 1, alpha: 1), for: .normal);
            }
        } else {
            self.topicCollect {
                self.topic.isCollect = true
                self.isCollect.setTitleColor(UIColor.init(red: 38/255, green: 153/255, blue: 251/255, alpha: 1), for: .normal);
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
                .responseJSON { (response) in
                    guard case .success(_) = response.result else { return }
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
                .responseJSON { (response) in
                    guard case .success(_) = response.result else { return }
                    handler?();
            }
        }
    }
}
