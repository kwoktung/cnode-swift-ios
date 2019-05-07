//
//  CNHomeContentViewController.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/28.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftDate

typealias LoadDataCallback = (JSON) -> Void;

class CNHomeContentViewControlelr: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var type: String!;
    var limit: Int = 20;
    var page: Int = 0;
    var dataArr:[JSON] = [];
    var tableView: UITableView!;
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CNHomeTableViewCell") as? CNHomeTableViewCell;
        if(cell == nil) {
            cell = CNHomeTableViewCell(style: .default, reuseIdentifier: "CNHomeTableViewCell");
        }
        var data = dataArr[indexPath.item];
        cell?.title.text = data["title"].string;
        cell?.avator.af_setImage(withURL: URL.init(string: data["author"]["avatar_url"].string!)!);
        cell?.visitCount.text = "\(data["visit_count"])次浏览";
        cell?.replyCount.text = "\(data["reply_count"])";
        if let lastReplyAt = data["last_reply_at"].string,
            let lastReplyTime = lastReplyAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
            cell?.lastAnswer.text = "最后回复:\(lastReplyTime)";
        }
        if(indexPath.item == dataArr.count - 1) {
            self.loadMoreData();
        }
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let topic = dataArr[indexPath.item];
        let controller = CNTopicViewController();
        controller.topicId = topic["id"].stringValue;
        self.parent?.navigationController?.pushViewController(controller, animated: true);
    }
    
    deinit {
        self.removeFromParent();
    }
    
    func loadData(_ callback: @escaping LoadDataCallback) {
        DispatchQueue.global().async {
            Alamofire.request(
                "https://cnodejs.org/api/v1/topics",
                parameters: [
                    "tab": self.type!, "mdrender": "false", "limit": self.limit, "page": self.page
                ])
                .validate()
                .responseJSON {(response) in
                    let json = JSON(response.result.value!);
                    DispatchQueue.main.async { callback(json); }
            }
        }
    }
    
    func loadMoreData() {
        self.page += 1
        self.loadData { (json) in
            let dataArr = json["data"].arrayValue;
            self.dataArr.append(contentsOf: dataArr);
            self.tableView.reloadData();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.white;
        self.loadData { (json) in
            self.dataArr = json["data"].arrayValue;
            self.tableView = UITableView();
            self.tableView.dataSource = self;
            self.tableView.delegate = self;
            self.tableView.register(CNHomeTableViewCell.self, forCellReuseIdentifier: "CNHomeTableViewCell");
            
            self.view.addSubview(self.tableView);
            self.tableView.snp.makeConstraints({ (make) in
                make.top.equalTo(self.view);
                make.bottom.equalTo(self.view);
                make.left.equalTo(self.view);
                make.right.equalTo(self.view);
            });
        }
    }
}
