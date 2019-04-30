//
//  Home.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/28.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import SnapKit

var tabs:[[String: String]] = [
    ["title":"全部", "type": "all"],
    ["title":"精华", "type": "good"],
    ["title":"分享", "type": "share"],
    ["title":"问答", "type": "ask"],
    ["title":"招聘", "type": "job"],
    ["title": "客服端测试", "type": "dev"]
];

class CNHomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var currentIndex: Int = -1;
    var pageViewController: UIPageViewController!;
    var controllerArr: [String: CNHomeContentViewControlelr] = [:];
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CNHomeCollectionCell", for: indexPath) as! CNHomeCollectionCell ;
        cell.title.text = tabs[indexPath.item]["title"];
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = tabs[indexPath.item]["type"];
        if let type = type {
            let viewController: CNHomeContentViewControlelr;
            if(self.controllerArr[type] != nil) {
                viewController = self.controllerArr[type]!;
            } else {
                viewController = CNHomeContentViewControlelr();
                viewController.type = type;
                self.controllerArr[type] = viewController;
            }
            
            if indexPath.item > currentIndex {
                pageViewController.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
            } else {
                pageViewController.setViewControllers([viewController], direction: .reverse, animated: true, completion: nil)
            }
            currentIndex = indexPath.item;
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true);
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin);
        let label:String = tabs[indexPath.item]["title"]!;
        let estimated = NSString.init(string: label).boundingRect(with: CGSize.init(width: collectionView.frame.width, height: collectionView.frame.height), options: option, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)], context: nil);
        return CGSize.init(width: estimated.width + 30, height: collectionView.frame.height);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout();
        layout.scrollDirection = .horizontal;
        let cellectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout);
        cellectionView.showsHorizontalScrollIndicator = false;
        cellectionView.dataSource = self;
        cellectionView.delegate = self;
        cellectionView.backgroundColor = UIColor.white;
        cellectionView.register(CNHomeCollectionCell.self, forCellWithReuseIdentifier: "CNHomeCollectionCell")
        self.view.addSubview(cellectionView);
        let lineView = UIView();
        lineView.backgroundColor = UIColor.gray;
        self.view.addSubview(lineView);
        lineView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view);
            make.height.equalTo(0.5);
            make.left.equalTo(self.view);
            make.top.equalTo(cellectionView.snp.bottom);
        }
        cellectionView.snp.makeConstraints { (make) in
            make.height.equalTo(50);
            make.width.equalTo(self.view);
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top);
            make.left.equalTo(self.view);
        }

        pageViewController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil);
        
        self.addChild(pageViewController);
        self.view.addSubview(pageViewController.view);

        pageViewController.view.snp.makeConstraints { (make) in
            make.width.equalTo(self.view);
            make.top.equalTo(lineView.snp.bottom);
            make.bottom.equalTo(self.view);
            make.left.equalTo(self.view);
        }
        cellectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        self.collectionView(cellectionView, didSelectItemAt: IndexPath(item: 0, section: 0));
    }
}