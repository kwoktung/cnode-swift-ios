//
//  PersonCenter.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/28.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import Alamofire
import SwiftDate

let dataArr = [
    [ "text": "最近主题", "value": 0 ],
    [ "text": "最近评论", "value": 1 ],
    [ "text": "我的收藏", "value": 2 ],
    [ "text": "设置", "value": 3 ]];

class CNPersonCenterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var recent_topics:[CNPersonCenterTopic] = [];
    var recent_replies:[CNPersonCenterTopic] = [];
    
    let username = UILabel();
    let datetime = UILabel();
    let avator = UIImageView();
    
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
        tableView.deselectRow(at: indexPath, animated: false);
        if(CNUserService.shared.isLogin != true) {
            self.onWithoutLogin();
            return
        }
        let item = dataArr[indexPath.item];
        switch item["value"] as! Int {
        case 0:
            let controller = CNCreatedTopicsViewController();
            controller.recent_topics = self.recent_topics;
            self.navigationController?.pushViewController(controller, animated: true);
        case 1:
            let controller = CNParticipatedRepliesViewController();
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
    
    func onWithoutLogin() {
        let controller = UIAlertController.init(title: nil, message: "请先登录", preferredStyle: .alert);
        let confirm = UIAlertAction.init(title: "确定", style: .default) { (action) in
            self.navigationController?.pushViewController(CNLoginCSRFViewController(), animated: true);
        }
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil);
        controller.addAction(confirm);
        controller.addAction(cancel);
        self.present(controller, animated: true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = UIView();
        headerView.backgroundColor = UIColor.gray;
        self.view.addSubview(headerView);
        headerView.snp.makeConstraints { (make) in
            make.width.equalToSuperview();
            make.height.equalTo(self.view).multipliedBy(0.4);
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
        }
        
        avator.layer.cornerRadius = 50;
        avator.layer.masksToBounds = true;
        
        headerView.addSubview(avator);
        avator.snp.makeConstraints({ (make) in
            make.width.height.equalTo(100);
            make.centerX.equalTo(headerView);
            make.centerY.equalTo(headerView).offset(-25);
        })
        
        headerView.addSubview(username);
        username.font = UIFont.systemFont(ofSize: 20);
        username.textColor = UIColor.white;
        username.snp.makeConstraints({ (make) in
            make.top.equalTo(avator.snp.bottom).offset(10);
            make.centerX.equalTo(avator.snp.centerX);
        });
        
        
        datetime.font = UIFont.systemFont(ofSize: 16);
        datetime.textColor = UIColor.white;
        
        headerView.addSubview(datetime);
        datetime.snp.makeConstraints({ (make) in
            make.top.equalTo(username.snp.bottom).offset(10);
            make.centerX.equalTo(headerView);
        })

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
        NotificationCenter.default.addObserver(self, selector:#selector(loadData), name: Notification.Name.init("UserLoginStatusChanged"), object: nil);
    }
    
    @objc
    func loadData() {
        if let loginname = CNUserService.shared.loginname, CNUserService.shared.isLogin == true {
            Alamofire.request("https://cnodejs.org/api/v1/user/\(loginname)")
                .validate()
                .responseJSON { [unowned self] (response) in
                    guard case .success(_) = response.result else { return; }
                    let decoder = JSONDecoder();
                    decoder.dateDecodingStrategy = .iso8601;
                    decoder.keyDecodingStrategy = .convertFromSnakeCase;
                    guard let res = try? decoder.decode(CNPersonCenterResponse.self, from: response.data!), res.success == true else { return }
                    let model = res.data;
                    self.username.text = model.loginname;
                    self.avator.af_setImage(withURL: URL.init(string: model.avatarUrl)!)
                    if let createAtTime = model.createAt.toDate()?.toRelative(since: nil, style: RelativeFormatter.defaultStyle(), locale: Locales.chinese)
                    {
                        self.datetime.text = "\(createAtTime)加入社区"
                    }
                    self.recent_topics = model.recentTopics
                    self.recent_replies = model.recentReplies
            }
        } else {
            self.username.text = "匿名";
            self.avator.image = UIImage.init(named: "logo");
            self.datetime.text = "登录后开启更多功能"
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
}
