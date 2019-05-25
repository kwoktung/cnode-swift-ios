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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        view.backgroundColor = UIColor.white;

        view.addSubview(titleField);
        titleField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 50))
        titleField.leftViewMode = .always
        titleField.textAlignment = .left;
        titleField.layer.borderColor = UIColor.init(red: 188/255, green: 224/255, blue: 253/255, alpha: 1).cgColor;
        titleField.layer.borderWidth = 1;
        titleField.textColor = UIColor.init(red: 188/255, green: 224/255, blue: 253/255, alpha: 1);
        titleField.attributedPlaceholder = NSAttributedString.init(
            string: "标题(10个字以上)",
            attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
            ])
        titleField.font = UIFont.systemFont(ofSize: 14);
        titleField.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60);
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
            make.left.equalTo(view).offset(15);
            make.right.equalTo(view).offset(-15);
            make.height.equalTo(50);
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        submit.addTarget(self, action: #selector(onSubmit), for: .touchUpInside);
        
        contentView.textContainerInset = UIEdgeInsets.init(top: 15, left: 10, bottom: 15, right: 10);
        contentView.layer.borderWidth = 0.5;
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
    func onTap() {
        print("onTap");
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
