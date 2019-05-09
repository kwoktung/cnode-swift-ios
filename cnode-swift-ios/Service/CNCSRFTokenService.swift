//
//  CNHTMLParser.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/7.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup

class CNCSRFTokenService {
    static let standard = CNCSRFTokenService();
    private init () { }
    
    func getCSRFToken(_ completionHandler: @escaping (_ token: String) -> Void) {
        DispatchQueue.global().async {
            Alamofire.request("https://cnodejs.org/signin").responseString { (response) in
                if let doc: Document = try? SwiftSoup.parse(response.result.value!),
                    let element: Element = try! doc.select("[name='_csrf']").first(),
                    let csrf = try? element.attr("value") {
                     completionHandler(csrf)
                }
            }
        }
    }
}
