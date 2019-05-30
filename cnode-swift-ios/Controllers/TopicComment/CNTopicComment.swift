//
//  CNTopicComment.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/8.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup

class CNTopicCommentViewController: UIViewController {
    var topicId: String!;
    let textView = UITextView();
    
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
        
        let title = UILabel();
        view.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.centerX.equalTo(view);
            make.top.equalTo(backBtn.snp.bottom).offset(4);
        }
        title.textColor = .init(red: 38/255, green: 153/255, blue: 251/255, alpha: 1);
        title.text = "评论";
        title.font = .systemFont(ofSize: 14);
        
        view.addSubview(textView);
        textView.layer.borderWidth = 1;
        textView.layer.borderColor = UIColor.init(red: 188/255, green: 224/255, blue: 253/255, alpha: 1).cgColor;
        textView.textContainerInset = UIEdgeInsets.init(top: 15, left: 10, bottom: 15, right: 10);
        textView.font = UIFont.systemFont(ofSize: 16);
        
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(25);
            make.right.equalTo(view.snp.right).offset(-25);
            make.top.equalTo(backBtn.snp.bottom).offset(56);
            make.height.equalTo(view).multipliedBy(0.3);
        }
        
        let submmit = UIButton();
        submmit.layer.cornerRadius = 5;
        submmit.layer.backgroundColor = UIColor.init(red: 0, green: 127/255, blue: 1, alpha: 1).cgColor;
        submmit.setTitle("提交", for: .normal);
        view.addSubview(submmit);
        submmit.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-25);
            make.left.equalTo(view).offset(25);
            make.right.equalTo(view).offset(-25);
            make.height.equalTo(50);
        }
        submmit.addTarget(self, action: #selector(onSubmit), for: .touchUpInside);
    }
    
    
    @objc
    func onBack() {
        self.navigationController?.popViewController(animated: true);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false);
    }
    
    @objc
    func onSubmit() {
        if let text = textView.text {
            Alamofire.request("https://cnodejs.org/signin").responseString { (response) in
                if let doc: Document = try? SwiftSoup.parse(response.result.value!),
                    let element: Element = try! doc.select("[name='_csrf']").first(),
                    let csrf = try? element.attr("value") {
                    Alamofire.request(
                        "https://cnodejs.org/\(self.topicId!)/reply",
                        method: .post,
                        parameters: [
                            "r_content": text,
                            "_csrf": csrf
                        ]
                        ).validate()
                        .responseData(completionHandler: { (response) in
                            guard case .success(_) = response.result else { return; }
                            NotificationCenter.default.post(name: Notification.Name.init("TopicNeedUpdateReplies"), object: nil)
                            self.navigationController?.popViewController(animated: true);
                        })
                }
            }
        }
    }
}
