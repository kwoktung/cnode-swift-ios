//
//  BasicTitleCell.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/28.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit

class CNHomeCollectionCell: UICollectionViewCell {
    let title: UILabel = UILabel();
    let indicator: UIView = UIView();
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        title.textAlignment = .center;
        self.addSubview(title);
        self.addSubview(indicator);
        title.snp.makeConstraints { (make) in
            make.width.equalTo(self);
            make.height.equalTo(self);
        }
        indicator.snp.makeConstraints { (make) in
            make.width.equalTo(self);
            make.height.equalTo(2);
            make.left.equalTo(self);
            make.bottom.equalTo(self);
        }
    }
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.indicator.backgroundColor = self.isSelected ? UIColor.blue: UIColor.clear;
                self.layoutIfNeeded();
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
