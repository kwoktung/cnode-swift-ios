//
//  CNTopicContentWebKitCell.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/4/29.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

typealias refreshCallback = (CGFloat) -> Void;

class CNTopicContentWebViewCell: UITableViewCell, WKNavigationDelegate {
    let webView = WKWebView();
    var loaded:Bool = false;
    var refresh: refreshCallback?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        print(self.frame.size.width)
        webView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.frame.size.height);
        self.contentView.addSubview(webView);
        webView.navigationDelegate = self;
        webView.scrollView.isScrollEnabled = false;
        webView.scrollView.bounces = false;
        webView.autoresizingMask = .flexibleHeight;
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(self.loaded) { return }
         self.loaded = true;
        webView.evaluateJavaScript("document.documentElement.offsetHeight") { (_ height, _ error) in
            if let height = height {
                self.refresh!(height as! CGFloat);
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
