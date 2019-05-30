//
//  CNNewTopic.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/7.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup
import SVProgressHUD

class CNNewTopicViewController: UIViewController {
    
    let titleField = UITextField()
    let contentView = UITextView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.setNavigationBarHidden(true, animated: true);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.setNavigationBarHidden(false, animated: true);
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        view.backgroundColor = UIColor.white;
        
        let backBtn = UIButton();
        view.addSubview(backBtn);
        backBtn.titleLabel?.font = UIFont.init(name: "iconfont", size: 30)
        backBtn.setTitle("\u{e739}", for: .normal);
        backBtn.setTitleColor(UIColor.init(red: 38/255, green: 153/255, blue: 251/255, alpha: 1), for: .normal);
        backBtn.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20);
            make.left.equalTo(view).offset(15);
        }
        backBtn.addTarget(self, action: #selector(onBack), for: .touchUpInside);
        
        
        view.addSubview(titleField);
        titleField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 50))
        titleField.leftViewMode = .always
        titleField.textAlignment = .left;
        titleField.layer.borderColor = UIColor.init(red: 188/255, green: 224/255, blue: 253/255, alpha: 1).cgColor;
        titleField.layer.borderWidth = 1;
        titleField.textColor = UIColor.init(red: 188/255, green: 224/255, blue: 253/255, alpha: 1);
        titleField.attributedPlaceholder = NSAttributedString.init(
            string: "标题(10个字以上)",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 38/255, green: 153/255, blue: 251/255, alpha: 1)]
        )
        titleField.font = UIFont.systemFont(ofSize: 14);
        titleField.snp.makeConstraints { (make) in
            make.top.equalTo(backBtn.snp.bottom).offset(24);
            make.left.equalTo(view).offset(25);
            make.right.equalTo(view).offset(-25);
            make.height.equalTo(50);
        }
        
        let submit = UIButton();
        submit.layer.cornerRadius = 5;
        submit.setTitle("创建主题", for: .normal);
        submit.backgroundColor = UIColor.init(red: 0, green: 127/255, blue: 255/255, alpha: 1)
        view.addSubview(submit);
        submit.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(25);
            make.right.equalTo(view).offset(-25);
            make.height.equalTo(50);
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        submit.addTarget(self, action: #selector(onSubmit), for: .touchUpInside);
        
        contentView.textContainerInset = UIEdgeInsets.init(top: 15, left: 10, bottom: 15, right: 10);
        contentView.layer.borderWidth = 1;
        contentView.layer.borderColor = UIColor.init(red: 188/255, green: 224/255, blue: 253/255, alpha: 1).cgColor;
        contentView.font = UIFont.systemFont(ofSize: 16);
        view.addSubview(contentView);
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(titleField.snp.bottom).offset(30);
            make.left.equalTo(view).offset(25);
            make.right.equalTo(view).offset(-25);
            make.height.equalTo(200);
        }
        
    }
    
    @objc
    func onBack() {
        self.navigationController?.popViewController(animated: true);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    @objc
    func onSubmit() {
        guard let title = titleField.text, title.count > 10 else {
            SVProgressHUD.showInfo(withStatus: "标题长度必须大于10");
            return
        }
        guard let content = contentView.text else {
            SVProgressHUD.showInfo(withStatus: "内容不能为空");
            return
        }
        DispatchQueue.global().async {
            Alamofire.request("https://cnodejs.org/signin").responseString { (response) in
                if let doc: Document = try? SwiftSoup.parse(response.result.value!),
                    let element: Element = try! doc.select("[name='_csrf']").first(),
                    let csrf = try? element.attr("value") {
                    Alamofire.request(
                        "https://cnodejs.org/topic/create",
                        method: .post,
                        parameters: [
                            "tab": "dev",
                            "title": title,
                            "t_content": content,
                            "_csrf": csrf
                        ]
                        )
                        .validate()
                        .responseData(queue: DispatchQueue.main, completionHandler: { [unowned self] (data:DataResponse) in
                            guard case .success(_) = data.result else { return; }
                            SVProgressHUD.showSuccess(withStatus: "创建成功")
                            if let topicId = data.response?.url?.lastPathComponent
                            {
                                let controller = CNTopicViewController();
                                controller.topicId = topicId;
                                if var viewControllers = self.navigationController?.viewControllers {
                                    viewControllers.removeLast()
                                    viewControllers.append(controller)
                                    self.navigationController?.setViewControllers(viewControllers, animated: true);
                                } else {
                                    self.navigationController?.pushViewController(controller, animated: true);
                                }
                            } else {
                                self.navigationController?.popViewController(animated: true);
                            }
                        })
                }
            }
        }
    }
}
