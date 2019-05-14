//
//  Replies.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/6.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import SwiftDate
import Alamofire

class CNParticipatedRepliesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var recent_replies:[CNPersonCenterTopic] = [];
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recent_replies.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CNParticipatedRepliesCell", for: indexPath) as! CNParticipatedRepliesCell;
        let data = self.recent_replies[indexPath.item]
        cell.title.text = data.title
        if let lastReplyTime = data.lastReplyAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese) {
            cell.lastAnswer.text = "最后回复:\(lastReplyTime)";
        }
        cell.avator.af_setImage(withURL: URL.init(string: data.author.avatarUrl)!)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let topic = recent_replies[indexPath.item]
        let controller = CNTopicViewController()
        controller.topicId = topic.id
        self.navigationController?.pushViewController(controller, animated: true);
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationItem.title = "我的评论"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.white;
        
        let tableView = UITableView();
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 60;
        tableView.tableFooterView = UIView();
        tableView.register(CNParticipatedRepliesCell.self, forCellReuseIdentifier: "CNParticipatedRepliesCell");
        
        self.view.addSubview(tableView);
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view);
        }
        if let loginname = CNUserService.shared.loginname {
            Alamofire.request("https://cnodejs.org/api/v1/user/\(loginname)")
                .responseJSON { [unowned self] (response) in
                switch response.result {
                case .success(_):
                    let decoder = JSONDecoder();
                    decoder.dateDecodingStrategy = .iso8601;
                    decoder.keyDecodingStrategy = .convertFromSnakeCase;
                    guard let res = try? decoder.decode(CNPersonCenterResponse.self, from: response.data!), res.success == true else { return }
                    let model = res.data;
                    self.recent_replies = model.recentReplies;
                    tableView.reloadData();
                case .failure(_):
                    ()
                }
            }
        }
    }
}
