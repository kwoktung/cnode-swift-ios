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
    var titleField = UITextField()
    var contentView = UITextView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationItem.title = "新建主题";
    }
    override func viewDidLoad() {
        super.viewDidLoad();
        view.backgroundColor = UIColor.white;
        
        let titleContainer = UIView();
        view.addSubview(titleContainer);
        titleContainer.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(15);
            make.right.equalTo(view).offset(-15);
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top);
            make.height.equalTo(60);
        }
        
        let titleLine = UIView();
        titleLine.backgroundColor = UIColor.gray;
        titleContainer.addSubview(titleLine);
        titleLine.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(15);
            make.right.equalTo(view).offset(-15);
            make.bottom.equalTo(titleContainer);
            make.height.equalTo(0.5);
        }
        
        let titleLabel = UILabel();
        titleContainer.addSubview(titleLabel);
        titleLabel.text = "标题"
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleContainer);
            make.centerY.equalTo(titleContainer);
        }
        
        titleField.textAlignment = .left;
        titleField.placeholder = "标题10字数以上";
        titleContainer.addSubview(titleField);
        titleField.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(10);
            make.centerY.equalTo(titleContainer);
        }
        
        let submit = UIButton();
        submit.layer.cornerRadius = 5;
        submit.setTitle("提交", for: .normal);
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
        contentView.layer.borderColor = UIColor.gray.cgColor;
        contentView.font = UIFont.systemFont(ofSize: 16);
        view.addSubview(contentView);
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(titleContainer.snp.bottom).offset(20);
            make.left.equalTo(view).offset(15);
            make.right.equalTo(view).offset(-15);
            make.height.equalTo(200);
        }
        
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
                        ).validate()
                        .responseData(queue: DispatchQueue.main, completionHandler: { (data:DataResponse) in
                            SVProgressHUD.showSuccess(withStatus: "创建成功")
                            if let topicId = data.response?.url?.lastPathComponent
                            {
                                let controller = CNTopicViewController();
                                controller.topicId = topicId;
                                self.navigationController?.pushViewController(controller, animated: true);
                            } else {
                                self.navigationController?.popViewController(animated: true);
                            }
                        })
                }
            }
        }
    }
}
