//
//  Dashboard.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/28.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit

class CNDashboardViewConntroller: UITabBarController {
    var isLogin: Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.setNavigationBarHidden(true, animated: false);
        self.refreshView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.setNavigationBarHidden(false, animated: false);
    }
    
    override func viewDidLoad() {
        self.refreshView()
    }
    
    func refreshView() {
        if (isLogin == nil || isLogin != CNUserService.shared.isLogin) {
            isLogin = CNUserService.shared.isLogin;
            self.view.backgroundColor = UIColor.white;
            super.viewDidLoad();
            let home = self.viewControllers?[0] ?? CNHomeViewController() ;
            home.tabBarItem.title = "首页";
            home.tabBarItem.image = UIImage.init(named: "dashboard_home_icon");
            home.tabBarItem.selectedImage = UIImage.init(named: "dashboard_home_selected_icon");
            
            let personCenter = CNUserService.shared.isLogin ? CNPersonCenterViewController() :  CNLoginViewController() ;
            personCenter.tabBarItem.title = "个人中心";
            personCenter.tabBarItem.image = UIImage.init(named: "dashboard_me_icon");
            personCenter.tabBarItem.selectedImage = UIImage.init(named: "dashboard_me_selected_icon");
            
            self.setViewControllers([home, personCenter], animated: false)
        }
    }
}
