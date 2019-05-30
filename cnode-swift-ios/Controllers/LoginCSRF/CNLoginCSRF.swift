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
import SVProgressHUD

class CNLoginCSRFViewController: UIViewController {
    private let passField = UITextField();
    private let accountField = UITextField();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        view.backgroundColor = UIColor.white;
        
        let header = UIView();
        view.addSubview(header);
        header.backgroundColor = UIColor.init(red: 38/255, green: 153/255, blue: 251/255, alpha: 1);
        
        header.snp.makeConstraints { (make) in
            make.width.equalTo(view);
            make.height.equalTo(170);
            make.left.equalTo(0);
            make.top.equalTo(0);
        }
        
        let backBtn = UIButton();
        view.addSubview(backBtn);
        backBtn.titleLabel?.font = UIFont.init(name: "iconfont", size: 30)
        backBtn.setTitle("\u{e6e9}", for: .normal);
        backBtn.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10);
            make.left.equalTo(view).offset(25);
        }
        backBtn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        
        
        let accountContainer = UIView();
        accountContainer.layer.borderWidth = 2;
        accountContainer.layer.cornerRadius = 4;
        accountContainer.layer.borderColor = UIColor.init(red: 241/255, green: 249/255, blue: 255/255, alpha: 1).cgColor;

        view.addSubview(accountContainer);
        accountContainer.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(40);
            make.right.equalTo(view).offset(-40);
            make.centerY.equalTo(view).offset(-20);
            make.height.equalTo(50);
        }
        
        accountField.attributedPlaceholder = NSAttributedString.init(
            string: "邮箱",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 38/255, green: 153/255, blue: 251/255, alpha: 1)]
        )
        
        accountField.autocapitalizationType = .none;
        accountContainer.addSubview(accountField);
        accountField.snp.makeConstraints { (make) in
            make.centerY.equalTo(accountContainer);
            make.left.equalTo(accountContainer).offset(15);
            make.right.equalTo(accountContainer).offset(-15);
        }
        
        
        let passContainer = UIView();
        view.addSubview(passContainer)
        passContainer.backgroundColor = UIColor.white;
        passContainer.layer.borderWidth = 2;
        passContainer.layer.borderColor = UIColor.init(red: 241/255, green: 249/255, blue: 255/255, alpha: 1).cgColor;
        passContainer.layer.cornerRadius = 4;
        passContainer.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(40);
            make.right.equalTo(view).offset(-40);
            make.top.equalTo(accountContainer.snp.bottom).offset(10);
            make.height.equalTo(50);
        }
        
        passField.isSecureTextEntry = true;
        passField.attributedPlaceholder = NSAttributedString.init(
            string: "密码",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 38/255, green: 153/255, blue: 251/255, alpha: 1)]
        )
        passContainer.addSubview(passField);
        passField.snp.makeConstraints { (make) in
            make.centerY.equalTo(passContainer);
            make.left.equalTo(passContainer).offset(15);
            make.right.equalTo(passContainer).offset(-15);
        }
        
        let submit = UIButton()
        view.addSubview(submit);
        submit.setTitle("登录", for: .normal);
        submit.layer.cornerRadius = 4;
        submit.backgroundColor = UIColor.init(red: 38/255, green: 153/251, blue: 251/255, alpha: 1);
        submit.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(40);
            make.right.equalTo(view).offset(-40);
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40);
            make.height.equalTo(50);
        }
        submit.addTarget(self, action: #selector(onSubmit), for: .touchUpInside);
    }
    
    @objc
    func onBack() {
        self.dismiss(animated: true, completion: nil);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    @objc
    func onSubmit() {
        guard let account = accountField.text, account.count > 0,
            let passwd = passField.text, passwd.count > 0 else { return }
        DispatchQueue.global().async {
            Alamofire.request("https://cnodejs.org/signin")
                .validate()
                .responseString(completionHandler: { (response) in
                    guard case .success(_) = response.result else { return; }
                    guard let doc: Document = try? SwiftSoup.parse(response.result.value!),
                        let element: Element = try! doc.select("[name='_csrf']").first(),
                        let csrf = try? element.attr("value") else { return }
                    Alamofire.request(
                        "https://cnodejs.org/signin",
                        method: .post,
                        parameters: [ "name": account, "pass": passwd, "_csrf": csrf ],
                        headers: [
                            "Origin": "https://cnodejs.org",
                            "Referer": "https://cnodejs.org/signin"
                        ])
                        .validate()
                        .responseString(completionHandler: { (response) in
                            switch response.result {
                            case .success(_):
                                Alamofire.request("https://cnodejs.org/setting").responseString(completionHandler: { (response) in
                                    if let doc: Document = try? SwiftSoup.parse(response.result.value!),
                                        let element: Element = try! doc.select("#accessToken").first(),
                                        let accesstoken = try? element.text() {
                                        CNUserService.shared.login(accesstoken, with: {
                                            NotificationCenter.default.post(name: Notification.Name.init("UserLoginStatusChanged"), object: nil, userInfo: ["isLogin": true]);
                                            self.dismiss(animated: true, completion: nil)
                                        })
                                    }
                                })
                            case .failure(let error as AFError):
                                if let code = error.responseCode, code == 403 {
                                    SVProgressHUD.showError(withStatus: "账号密码错误");
                                }
                            case .failure(_):
                                SVProgressHUD.showError(withStatus: "登陆失败");
                            };
                        })
                })
        };
    }
}
