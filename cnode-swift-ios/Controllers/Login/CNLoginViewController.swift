//
//  LoginViewController.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/5.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit

class CNLoginViewController: UIViewController {
    override func viewDidLoad() {
        let msg = UILabel()
        msg.font = UIFont.systemFont(ofSize: 16);
        msg.text = "登录查看更多";
        self.view.addSubview(msg);
        msg.textColor = UIColor.init(red: 152/255, green: 152/255, blue: 152/255, alpha: 1);
        msg.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view).offset(-40);
        }
        
        let submit = UIButton();
        self.view.addSubview(submit);
        submit.layer.cornerRadius = 25;
        submit.setTitle("登录", for: .normal);
        submit.backgroundColor = UIColor.init(red: 0/255, green: 127/255, blue: 255/255, alpha: 1);
        submit.snp.makeConstraints { (make) in
            make.width.equalTo(280);
            make.height.equalTo(50);
            make.centerX.equalTo(self.view);
            make.top.equalTo(msg.snp.bottom).offset(40);
        }
        submit.addTarget(self, action: #selector(onSubmit), for: .touchUpInside);
    }
    
    @objc func onSubmit() {
        CNUserService.shared.login {
            if let dashboardController = self.tabBarController as? CNDashboardViewConntroller {
                dashboardController.refreshView();
            }
        };
    }
}
