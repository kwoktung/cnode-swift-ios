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

class CNTopicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate {
    let tableView = UITableView();
    var topic: JSON!;
    var replyArr:[JSON] = [];
    var webHeight: CGFloat = UITableView.automaticDimension;
    
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
        if(section == 1) {
            return 50
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0 && indexPath.item == 1) {
            return self.webHeight;
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
                        self.webHeight = height;
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
    
    func loadData(topicId: String?) {
        if let topicId = topicId {
            Alamofire.request(
                "https://cnodejs.org/api/v1/topic/\(topicId)",
                parameters: ["mdrender": "false"
                ]).responseJSON {(response) in
                    let json = JSON(response.result.value!);
                    self.replyArr = json["data"]["replies"].arrayValue;
                    self.tableView.reloadData();
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.white;
     
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
        self.view.addSubview(tableView);
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view);
        }
        if(self.replyArr.count == 0) {
            self.loadData(topicId: topic["id"].stringValue);
        }
    }
}
