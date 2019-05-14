//
//  CNHomeContentViewController.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/28.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import Alamofire
import SwiftDate

typealias LoadDataCallback = ([CNHomeTopicModel]) -> Void;

class CNHomeContentViewControlelr: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var type: String!;
    var limit: Int = 20;
    var page: Int = 0;
    var dataArr:[CNHomeTopicModel] = [];
    var tableView: UITableView!;
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CNHomeTableViewCell", for: indexPath) as! CNHomeTableViewCell;
        let topic = dataArr[indexPath.item];
        cell.title.text = topic.title;
        cell.avator.af_setImage(withURL: URL.init(string: topic.author.avatarUrl)!);
        cell.visitCount.text = "\(topic.visitCount)次浏览";
        cell.replyCount.text = "\(topic.replyCount)";
        if let lastReplyTime = topic.lastReplyAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
            cell.lastAnswer.text = "最后回复:\(lastReplyTime)";
        }
        if(indexPath.item == dataArr.count - 1) {
            self.loadMoreData();
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let topic = dataArr[indexPath.item];
        let controller = CNTopicViewController();
        controller.topicId = topic.id;
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
                    switch response.result {
                    case .success(_):
                        guard let res = try? JSONDecoder().decode(CNHomeTopicResponse.self, from: response.data!) else { return }
                        DispatchQueue.main.async { callback(res.topicArr);}
                    case .failure(_):
                        ()
                    }
            }
        }
    }
    
    func loadMoreData() {
        self.page += 1
        self.loadData { (topicArr) in
            self.dataArr.append(contentsOf: topicArr);
            self.tableView.reloadData();
        }
    }
    
    @objc
    func pullRefresh() {
        self.page = 1;
        self.loadData { (topicArr) in
            self.dataArr = topicArr;
            self.tableView.reloadData();
            self.tableView.refreshControl?.endRefreshing();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.white;
        self.loadData {[unowned self] (topicArr) in
            self.dataArr = topicArr
            self.tableView = UITableView();
            self.tableView.refreshControl = UIRefreshControl();
            self.tableView.refreshControl?.addTarget(self, action: #selector(self.pullRefresh), for: .valueChanged)
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
