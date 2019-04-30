//
//  CNTopicContentCell.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/29.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit

class CNTopicContentCell: UITableViewCell {
    let headingTitile = UILabel();
    let authorName = UILabel();
    let createdAt = UILabel();
    let avator = UIImageView();

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        
        headingTitile.font = UIFont.init(name: "PingFang-SC-Medium", size: 24);
        headingTitile.textColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1);
        headingTitile.numberOfLines = 3;
        self.addSubview(headingTitile);
        headingTitile.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20);
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
        }
        let userView = UIView();
        self.addSubview(userView);
        userView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(headingTitile.snp.bottom);
            make.height.equalTo(40);
            make.bottom.equalToSuperview()
        }
        userView.addSubview(avator);
        avator.snp.makeConstraints { (make) in
            make.width.height.equalTo(40);
            make.top.equalTo(userView);
            make.left.equalTo(userView);
        }
        
        authorName.font = UIFont.init(name: "PingFang-SC-Medium", size: 15);
        authorName.textColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1);
        userView.addSubview(authorName);
        authorName.snp.makeConstraints { (make) in
            make.left.equalTo(avator.snp.right).offset(10);
            make.centerY.equalTo(userView);
        }
        createdAt.font = UIFont.init(name: "PingFang-SC-Medium", size: 14);
        createdAt.textColor = UIColor.init(red: 50/255, green: 50/255, blue: 50/255, alpha: 1);
        userView.addSubview(createdAt);
        createdAt.snp.makeConstraints { (make) in
            make.right.equalTo(userView);
            make.centerY.equalTo(userView);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
