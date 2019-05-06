//
//  CNCollection.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/6.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftDate
import Alamofire

class CNCollectionListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicArr.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CNCollectionListCell", for: indexPath) as! CNCollectionListCell;
        let data = self.topicArr[indexPath.item]
        cell.title.text = data["title"].stringValue
        if let lastReplyAt = data["last_reply_at"].string,
            let lastReplyTime = lastReplyAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
            cell.lastAnswer.text = "最后回复:\(lastReplyTime)";
        }
        cell.visitCount.text = "\(data["visit_count"])次浏览";
        cell.replyCount.text = "\(data["reply_count"])";
        cell.avator.af_setImage(withURL: URL.init(string: data["author"]["avatar_url"].stringValue)!)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false);
    }
    
    var topicArr: [JSON] = [];
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationItem.title = "我的收藏"
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.white;
        Alamofire.request("https://cnodejs.org/api/v1/topic_collect/\(CNUserService.shared.loginname!)").responseJSON { (response) in
            let json = JSON(response.result.value!);
            if(json["success"].boolValue) {
                self.topicArr = json["data"].arrayValue;
                let tableView = UITableView();
                tableView.delegate = self;
                tableView.dataSource = self;
                tableView.rowHeight = 60;
                tableView.tableFooterView = UIView();
                tableView.register(CNCollectionListCell.self, forCellReuseIdentifier: "CNCollectionListCell");
                
                self.view.addSubview(tableView);
                tableView.snp.makeConstraints { (make) in
                    make.edges.equalTo(self.view);
                }
            }
        }
    }
}
