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

class CNCreatedTopicsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var recent_topics:[JSON]?;
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
            Alamofire.request("https://cnodejs.org/api/v1/topic/\(topic["id"].stringValue)",
                parameters: parameters).responseJSON { (response) in
                    let json = JSON(response.result.value!)
                    if(json["success"].boolValue) {
                        let data = json["data"];
                        let controller = CNTopicViewController()
                        controller.topic = data;
                        controller.replyArr = data["replies"].arrayValue;
                        self.navigationController?.pushViewController(controller, animated: true);
                    }
            }
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
}
