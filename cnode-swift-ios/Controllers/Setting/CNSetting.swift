//
//  CNSetting.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/6.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import Alamofire

class CNSettingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.white;
        let button = UIButton();
        self.view.addSubview(button);
        button.layer.cornerRadius = 22.5;
        button.setTitle("退出登录", for: .normal);
        button.backgroundColor = UIColor.init(red: 0/255, green: 127/255, blue: 255/255, alpha: 1);
        button.snp.makeConstraints { (make) in
            make.height.equalTo(45);
            make.width.equalTo(280);
            make.center.equalTo(view);
        }
        button.addTarget(self, action: #selector(loggout), for: .touchUpInside);
        self.view.addSubview(button);
    }
    
    @objc func loggout() {
        let controller = UIAlertController.init(title: nil, message: "退出登录", preferredStyle: .alert);
        let confirm = UIAlertAction.init(title: "确定", style: .default) { (UIAlertAction) in
            Alamofire.request("https://cnodejs.org/signout").responseData(completionHandler: { (_) in
                CNUserService.shared.logout();
                NotificationCenter.default.post(name: Notification.Name.init("UserLoginStatusChanged"), object: nil);
                self.navigationController?.popToRootViewController(animated: true);
            })
        }
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil);
        controller.addAction(confirm);
        controller.addAction(cancel);

        self.present(controller, animated: true, completion: nil);
    }
}
