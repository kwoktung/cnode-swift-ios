//
//  CNTopicTableView.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/29.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit

class CNTopicReplyCell: UITableViewCell {
    let authorName = UILabel();
    let replyContent = UILabel();
    let replyAt = UILabel();
    let avator = UIImageView();
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.addSubview(avator);
        avator.snp.makeConstraints { (make) in
            make.width.height.equalTo(40);
            make.left.equalTo(self).offset(15);
            make.top.equalTo(self).offset(10);
        }
        self.addSubview(authorName);
        authorName.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10);
            make.left.equalTo(avator.snp.right).offset(10);
        }
        let line = UIView();
        line.backgroundColor = UIColor.gray;
        self.addSubview(line);
        line.snp.makeConstraints { (make) in
            make.width.equalTo(self).offset(15);
            make.left.equalTo(self).offset(10);
            make.bottom.equalToSuperview();
        }
        self.addSubview(replyContent);
        replyContent.numberOfLines = 0;
//        replyContent.lineBreakMode = .byWordWrapping;
        replyContent.snp.makeConstraints { (make) in
            make.top.equalTo(authorName.snp.bottom);
            make.left.equalTo(avator.snp.right).offset(10);
            make.right.equalTo(self).offset(-15);
            make.bottom.equalTo(line.snp.top);
        }
        self.addSubview(replyAt);
        replyAt.font = UIFont.init(name: "PingFang-SC-Regular", size: 12);
        replyAt.textColor = UIColor.gray;
        replyAt.snp.makeConstraints { (make) in
            make.left.equalTo(authorName.snp.right).offset(10);
            make.centerY.equalTo(authorName);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
