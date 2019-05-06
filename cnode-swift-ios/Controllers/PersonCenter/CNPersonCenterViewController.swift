//
//  PersonCenter.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/28.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftDate

let dataArr = [
    [ "text": "我的主题", "value": 0 ],
    [ "text": "我的评论", "value": 1 ],
    [ "text": "我的收藏", "value": 2 ],
    [ "text": "设置", "value": 3 ]];

class CNPersonCenterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var loginname: String?;
    var avatar_url: String?
    var create_at: String?
    var recent_topics:[JSON]? = [];
    var recent_replies:[JSON]? = [];
    
    private var headerView: UIView!;
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentViewCell", for: indexPath);
        let item = dataArr[indexPath.item];
        cell.textLabel?.text = item["text"] as? String
        cell.accessoryType = .disclosureIndicator;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataArr[indexPath.item];
        tableView.deselectRow(at: indexPath, animated: false);
        switch item["value"] as! Int {
        case 0:
            let controller = CNCreatedTopicsViewController();
            controller.recent_topics = self.recent_topics;
            self.navigationController?.pushViewController(controller, animated: true);
        case 1:
            let controller = CNRepliesViewController();
            controller.recent_replies = self.recent_replies;
            self.navigationController?.pushViewController(controller, animated: true);
        case 2:
            let controller = CNCollectionListViewController();
            self.navigationController?.pushViewController(controller, animated: true);
        case 3:
            let controller = CNSettingViewController();
            self.navigationController?.pushViewController(controller, animated: true);
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = UIView();
        headerView.backgroundColor = UIColor.gray;
        self.view.addSubview(headerView);
        headerView.snp.makeConstraints { (make) in
            make.width.equalToSuperview();
            make.height.equalTo(self.view).multipliedBy(0.4);
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
        }

        let contentView = UITableView();
        contentView.dataSource = self;
        contentView.delegate = self;
        contentView.rowHeight = 60;
        contentView.isScrollEnabled = false;
        contentView.register(UITableViewCell.self, forCellReuseIdentifier: "ContentViewCell")
        self.view.addSubview(contentView);
        
        contentView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view);
            make.top.equalTo(headerView.snp.bottom);
            make.left.equalTo(self.view)
            make.height.equalTo(60*dataArr.count);
        }
        self.loadData();
    }
    
    func loadData() {
        if let loginname = CNUserService.shared.loginname {
            Alamofire.request("https://cnodejs.org/api/v1/user/\(loginname)").responseJSON { (response) in
                let json = JSON(response.result.value!)
                if(json["success"].boolValue) {
                    guard let data = json["data"].dictionary else { return };
                    self.loginname = loginname;
                    self.avatar_url = data["avatar_url"]?.stringValue;
                    self.create_at = data["create_at"]?.stringValue;
                    self.recent_topics = data["recent_topics"]?.arrayValue;
                    self.recent_replies = data["recent_replies"]?.arrayValue;
                    
                    let avator = UIImageView();
                    avator.layer.cornerRadius = 50;
                    avator.layer.masksToBounds = true;
                    avator.af_setImage(withURL: URL.init(string: self.avatar_url!)!);
                    self.headerView.addSubview(avator);
                    avator.snp.makeConstraints({ (make) in
                        make.width.height.equalTo(100);
                        make.centerX.equalTo(self.headerView);
                        make.centerY.equalTo(self.headerView).offset(-25);
                    })
                    
                    let loginname = UILabel();
                    self.headerView.addSubview(loginname);
                    loginname.font = UIFont.systemFont(ofSize: 20);
                    loginname.textColor = UIColor.white;
                    loginname.text = self.loginname;
                    loginname.snp.makeConstraints({ (make) in
                        make.top.equalTo(avator.snp.bottom).offset(10);
                        make.centerX.equalTo(avator.snp.centerX);
                    });
                    
                    let create_at = UILabel();
                    create_at.font = UIFont.systemFont(ofSize: 16);
                    create_at.textColor = UIColor.white;
                    
                    self.headerView.addSubview(create_at);
                    create_at.snp.makeConstraints({ (make) in
                        make.top.equalTo(loginname.snp.bottom).offset(10);
                        make.centerX.equalTo(self.headerView);
                    })
                    if let createAt = self.create_at,
                        let createAtTime = createAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese)
                        {
                        create_at.text = "\(createAtTime)加入社区"
                    }
                    
                }
            }
        }
    }
}
