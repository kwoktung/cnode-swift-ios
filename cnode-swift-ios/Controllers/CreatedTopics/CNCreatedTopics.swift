//
//  CNCreatedTopics.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/6.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftDate
import Alamofire
import SwiftSoup

class CNCreatedTopicsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var recent_topics:[JSON]?;
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction.init(style: .destructive, title: "删除") { (action: UIContextualAction, view: UIView, completionHandler: @escaping (Bool)->Void) in
            guard let topic = self.recent_topics?[indexPath.item]["id"].string else { completionHandler(false); return }
            self.onTopicDelete(topic, with: completionHandler);
        }
        let config = UISwipeActionsConfiguration.init(actions: [action]);
        return config;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recent_topics?.count ?? 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CNCreatedTopicsCell", for: indexPath) as! CNCreatedTopicsCell;
        if let data = self.recent_topics?[indexPath.item] {
            cell.title.text = data["title"].stringValue
            if let lastReplyAt = data["last_reply_at"].string,
                let lastReplyTime = lastReplyAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
                cell.lastAnswer.text = "最后回复:\(lastReplyTime)";
            }
            cell.avator.af_setImage(withURL: URL.init(string: data["author"]["avatar_url"].stringValue)!)
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        var parameters: Dictionary = ["mdrender": "false"]
        if(CNUserService.shared.isLogin) {
            parameters["accesstoken"] = CNUserService.shared.accesstoken
        }
        if let topic = recent_topics?[indexPath.item] {
            let controller = CNTopicViewController()
            controller.topicId = topic["id"].stringValue;
            self.navigationController?.pushViewController(controller, animated: true);
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationItem.title = "我的主题"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.white;
        
        let tableView = UITableView();
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 60;
        tableView.tableFooterView = UIView();
        tableView.register(CNCreatedTopicsCell.self, forCellReuseIdentifier: "CNCreatedTopicsCell");
        
        self.view.addSubview(tableView);
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view);
        }
    }
    
    func onTopicDelete(_ topicId: String, with completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            Alamofire.request("https://cnodejs.org/signin").responseString { (response) in
                if let doc: Document = try? SwiftSoup.parse(response.result.value!),
                    let element: Element = try! doc.select("[name='_csrf']").first(),
                    let csrf = try? element.attr("value") {
                    Alamofire.request(
                        "https://cnodejs.org/topic/\(topicId)/delete",
                        method: .post,
                        parameters: ["_csrf": csrf]
                        ).validate()
                        .responseData(queue: DispatchQueue.main, completionHandler: { (data:DataResponse) in
                            completionHandler(true)
                        })
                }
            }
        }
    }
}
