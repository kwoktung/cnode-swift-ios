//
//  CNCreatedTopics.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/6.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import SwiftDate
import Alamofire
import SwiftSoup

class CNCreatedTopicsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var recent_topics:[CNPersonCenterTopic] = [];
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationItem.title = "最近主题"
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction.init(style: .destructive, title: "删除") { (action: UIContextualAction, view: UIView, completionHandler: @escaping (Bool)->Void) in
            let topicId = self.recent_topics[indexPath.item].id
            self.onTopicDelete(topicId, with: completionHandler);
        }
        let config = UISwipeActionsConfiguration.init(actions: [action]);
        return config;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recent_topics.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CNCreatedTopicsCell", for: indexPath) as! CNCreatedTopicsCell;
        let data = self.recent_topics[indexPath.item]
        cell.title.text = data.title
        if let lastReplyTime = data.lastReplyAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
            cell.lastAnswer.text = "最后回复:\(lastReplyTime)";
        }
        cell.avator.af_setImage(withURL: URL.init(string: data.author.avatarUrl)!)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        var parameters: Dictionary = ["mdrender": "false"]
        if(CNUserService.shared.isLogin) {
            parameters["accesstoken"] = CNUserService.shared.accesstoken
        }
        let topic = recent_topics[indexPath.item]
        let controller = CNTopicViewController()
        controller.topicId = topic.id;
        self.navigationController?.pushViewController(controller, animated: true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.white;

        if let loginname = CNUserService.shared.loginname {
            Alamofire.request("https://cnodejs.org/api/v1/user/\(loginname)")
                .responseJSON { [unowned self] (response) in
                    guard case .success(_) = response.result else { return; }
                    let decoder = JSONDecoder();
                    decoder.dateDecodingStrategy = .iso8601;
                    decoder.keyDecodingStrategy = .convertFromSnakeCase;
                    guard let res = try? decoder.decode(CNPersonCenterResponse.self, from: response.data!), res.success == true else { return }
                    self.recent_topics = res.data.recentTopics
                    if(res.data.recentTopics.count > 0) {
                        let tableView = UITableView();
                        self.view.addSubview(tableView);
                        tableView.dataSource = self;
                        tableView.delegate = self;
                        tableView.rowHeight = 60;
                        tableView.tableFooterView = UIView();
                        tableView.register(CNCreatedTopicsCell.self, forCellReuseIdentifier: "CNCreatedTopicsCell");
                        tableView.snp.makeConstraints { (make) in
                            make.edges.equalTo(self.view);
                        }
                        tableView.reloadData();
                    } else  {
                        let label = UILabel();
                        self.view.addSubview(label);
                        label.text = "你没有创建过主题"
                        label.snp.makeConstraints({ (make) in
                            make.center.equalTo(self.view);
                        })
                    }
            }
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
                            switch data.result {
                            case .success(_):
                                completionHandler(true)
                            case .failure(_):
                                completionHandler(false)
                            }
                        })
                }
            }
        }
    }
}
