//
//  CNRepliesCell.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/6.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit

class CNRepliesCell: UITableViewCell {
    let title = UILabel();
    let avator = UIImageView();
    let lastAnswer = UILabel();
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        title.numberOfLines = 3;
        self.addSubview(avator);
        avator.snp.makeConstraints { (make) in
            make.top.equalTo(10);
            make.left.equalTo(self).offset(15)
            make.width.height.equalTo(40);
        }
        self.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10);
            make.left.equalTo(avator.snp.right).offset(10);
            make.right.equalTo(self).offset(-50);
        }
        
        let textView = UIView();
        self.addSubview(textView);
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(title.snp.bottom)
            make.left.equalTo(avator.snp.right).offset(10);
            make.right.equalTo(self).offset(-50);
            make.height.equalTo(20);
            make.bottom.equalToSuperview().offset(-8);
        }
        
        textView.addSubview(lastAnswer);
        lastAnswer.font = UIFont(name: "PingFang-SC-Regular", size: 12);
        lastAnswer.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1);
        lastAnswer.snp.makeConstraints { (make) in
            make.left.equalTo(textView);
            make.centerY.equalTo(textView);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
