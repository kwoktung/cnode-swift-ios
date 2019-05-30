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
            make.bottom.equalToSuperview();
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
