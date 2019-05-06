//
//  CNCollectionListCell.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/6.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit

class CNCollectionListCellPaddingLabel: UILabel {
    override func drawText(in rect: CGRect) {
        return super.drawText(in: rect.inset(by: .init(top: 0, left: 10, bottom: 0, right: 10)));
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize.init(width: size.width + 20, height: size.height)
    }
}

class CNCollectionListCell: UITableViewCell {
    let title = UILabel();
    let avator = UIImageView();
    let visitCount = UILabel();
    let lastAnswer = UILabel();
    let replyCount = CNCollectionListCellPaddingLabel();
    
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
        
        textView.addSubview(visitCount);
        visitCount.font = UIFont(name: "PingFang-SC-Regular", size: 12);
        visitCount.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1);
        visitCount.snp.makeConstraints { (make) in
            make.left.equalTo(textView);
            make.centerY.equalTo(textView);
        }
        
        textView.addSubview(lastAnswer);
        lastAnswer.font = UIFont(name: "PingFang-SC-Regular", size: 12);
        lastAnswer.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1);
        lastAnswer.snp.makeConstraints { (make) in
            make.left.equalTo(visitCount.snp.right).offset(10);
            make.centerY.equalTo(textView);
        }
        
        self.addSubview(replyCount);
        replyCount.textColor = UIColor.white;
        replyCount.layer.cornerRadius = 10;
        replyCount.font = UIFont.init(name: "PingFang-SC-Regular", size: 14);
        replyCount.layer.backgroundColor = UIColor(red: 170/255, green: 176/255, blue: 198/255, alpha: 1).cgColor;
        replyCount.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(self);
            make.height.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

