//
//  CNLoginCSRF.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/7.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup

class CNLoginCSRFViewController: UIViewController {
    private let passField = UITextField();
    private let accountField = UITextField();
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationItem.title = "登录";
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        view.backgroundColor = UIColor.white;
        
        let accountContainer = UIView();
        accountContainer.layer.borderWidth = 0.5;
        accountContainer.layer.borderColor = UIColor.gray.cgColor;
        accountContainer.backgroundColor = UIColor.white;
        view.addSubview(accountContainer);
        accountContainer.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(15);
            make.right.equalTo(view).offset(-15);
            make.centerY.equalTo(view).offset(-20);
            make.height.equalTo(60);
        }
        
        let accountLabel = UILabel();
        accountContainer.addSubview(accountLabel);
        accountLabel.text = "账号"
        accountLabel.font = UIFont.systemFont(ofSize: 16);
        accountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(accountContainer);
            make.left.equalTo(accountContainer).offset(15);
        }
        
        accountField.placeholder = "请输入你的邮箱"
        accountField.autocapitalizationType = .none;
        accountContainer.addSubview(accountField);
        accountField.snp.makeConstraints { (make) in
            make.centerY.equalTo(accountContainer);
            make.left.equalTo(accountLabel.snp.right).offset(15);
        }
        
        
        let passContainer = UIView();
        view.addSubview(passContainer)
        passContainer.backgroundColor = UIColor.white;
        passContainer.layer.borderWidth = 0.5;
        passContainer.layer.borderColor = UIColor.gray.cgColor;
        passContainer.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(15);
            make.right.equalTo(view).offset(-15);
            make.top.equalTo(accountContainer.snp.bottom).offset(10);
            make.height.equalTo(60);
        }
        
        let passLabel = UILabel();
        passContainer.addSubview(passLabel);
        passLabel.text = "密码";
        passLabel.font = UIFont.systemFont(ofSize: 16);
        passLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(passContainer);
            make.left.equalTo(passContainer).offset(15);
        }
        
        passField.isSecureTextEntry = true;
        passField.placeholder = "请输入你的密码"
        passContainer.addSubview(passField);
        passField.snp.makeConstraints { (make) in
            make.centerY.equalTo(passContainer);
            make.left.equalTo(passLabel.snp.right).offset(15);
        }
        
        let submit = UIButton()
        view.addSubview(submit);
        submit.setTitle("登录", for: .normal);
        submit.layer.cornerRadius = 10;
        submit.backgroundColor = UIColor.init(red: 0, green: 127/255, blue: 1, alpha: 1);
        submit.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(15);
            make.right.equalTo(view).offset(-15);
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20);
            make.height.equalTo(60);
        }
        submit.addTarget(self, action: #selector(onSubmit), for: .touchUpInside);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    @objc
    func onSubmit() {
        if let account = accountField.text,
            let passwd = passField.text {
            DispatchQueue.global().async {
                Alamofire.request("https://cnodejs.org/signin")
                    .responseString(completionHandler: { (response) in
                        if let doc: Document = try? SwiftSoup.parse(response.result.value!),
                            let element: Element = try! doc.select("[name='_csrf']").first(),
                            let csrf = try? element.attr("value")
                        {
                            Alamofire.request(
                                "https://cnodejs.org/signin",
                                method: .post,
                                parameters: [
                                    "name": account, "pass": passwd, "_csrf": csrf
                                ],
                                headers: [
                                    "Origin": "https://cnodejs.org",
                                    "Referer": "https://cnodejs.org/signin"
                                ])
                                .responseJSON(completionHandler: { (response) in
                                    Alamofire.request("https://cnodejs.org/setting").responseString(completionHandler: { (response) in
                                        if let doc: Document = try? SwiftSoup.parse(response.result.value!),
                                            let element: Element = try! doc.select("#accessToken").first(),
                                            let accesstoken = try? element.text() {
                                            CNUserService.shared.login(accesstoken, with: {
                                                NotificationCenter.default.post(name: Notification.Name.init("UserLoginStatusChanged"), object: nil);
                                                self.navigationController?.popViewController(animated: true);
                                            })
                                        }
                                    })
                            })
                        }
                    })
            };
        }
    }
}
