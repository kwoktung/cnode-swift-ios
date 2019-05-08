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
        self.navigationItem.title = "评论";
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        view.backgroundColor = UIColor.white;
        
        view.addSubview(textView);
        textView.layer.borderWidth = 0.5;
        textView.layer.borderColor = UIColor.gray.cgColor;
        textView.textContainerInset = UIEdgeInsets.init(top: 15, left: 10, bottom: 15, right: 10);
        textView.font = UIFont.systemFont(ofSize: 16);
        
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(15);
            make.right.equalTo(view.snp.right).offset(-15);
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15);
            make.height.equalTo(view).multipliedBy(0.3);
        }
        
        
        
        let submmit = UIButton();
        submmit.layer.cornerRadius = 5;
        submmit.layer.backgroundColor = UIColor.init(red: 0, green: 127/255, blue: 1, alpha: 1).cgColor;
        submmit.setTitle("提交", for: .normal);
        view.addSubview(submmit);
        submmit.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom);
            make.left.equalTo(view).offset(15);
            make.right.equalTo(view).offset(-15);
            make.height.equalTo(50);
        }
        submmit.addTarget(self, action: #selector(onSubmit), for: .touchUpInside);
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
                            NotificationCenter.default.post(name: Notification.Name.init("TopicNeedUpdateReplies"), object: nil)
                            self.navigationController?.popViewController(animated: true);
                        })
                }
            }
        }
    }
}
