//
//  CNCollection.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/6.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import SwiftDate
import Alamofire

class CNCollectionListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var topicArr: [CNCollectionListModel]?;
    var tableView:UITableView?;
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicArr?.count ?? 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CNCollectionListCell", for: indexPath) as! CNCollectionListCell;
        if let data = topicArr?[indexPath.item] {
            cell.title.text = data.title
            if let lastReplyTime = data.lastReplyAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
                cell.lastAnswer.text = "最后回复:\(lastReplyTime)";
            }
            cell.visitCount.text = "\(data.visitCount)次浏览";
            cell.replyCount.text = "\(data.replyCount)";
            cell.avator.af_setImage(withURL: URL.init(string: data.author.avatarUrl)!)
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false);
        if let topic = topicArr?[indexPath.item] {
            let controller = CNTopicViewController()
            controller.topicId = topic.id
            self.navigationController?.pushViewController(controller, animated: true);
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationItem.title = "我的收藏"
        self.refresh { (topicJSONArr) in
            if(self.topicArr == nil) {
                self.topicArr = topicJSONArr;
                let tableView = UITableView();
                self.tableView = tableView;
                tableView.delegate = self;
                tableView.dataSource = self;
                tableView.rowHeight = 60;
                tableView.tableFooterView = UIView();
                tableView.register(CNCollectionListCell.self, forCellReuseIdentifier: "CNCollectionListCell");
                
                self.view.addSubview(tableView);
                tableView.snp.makeConstraints { (make) in
                    make.edges.equalTo(self.view);
                }
            } else if (self.topicArr?.count != topicJSONArr.count) {
                self.topicArr = topicJSONArr;
                self.tableView?.reloadData();
            }
        }
    }
    
    func refresh(_ handler: (([CNCollectionListModel]) -> Void)?) {
        DispatchQueue.global().async {
            Alamofire.request(
                "https://cnodejs.org/api/v1/topic_collect/\(CNUserService.shared.loginname!)")
                .validate()
                .responseJSON { (response) in
                    guard case .success(_) = response.result else { return; }
                    let decoder = JSONDecoder();
                    decoder.keyDecodingStrategy = .convertFromSnakeCase;
                    guard let res = try? decoder.decode(CNCollectionListResponse.self, from: response.data!) else { return }
                    DispatchQueue.main.async {
                        handler?(res.data);
                    }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.white;
    }
}
