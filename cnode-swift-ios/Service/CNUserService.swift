//
//  CNUserService.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/5.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import Foundation
import Alamofire

struct CNUserServiceModel: Decodable {
    let success: Bool
    let loginname: String
    let id: String
    let avatarUrl: String
}

typealias completeHandler = () -> Void

class CNUserService {
    static let shared = CNUserService();
    var accesstoken: String? {
        get {
            return UserDefaults.standard.object(forKey: "accesstoken") as! String?;
        }
    }

    var loginname: String? {
        get {
            return UserDefaults.standard.object(forKey: "loginname") as! String?;
        }
    }
    
    var `id`: String? {
        get {
            return UserDefaults.standard.object(forKey: "id") as! String?;
        }
    }
    
    var avatar_url: String? {
        get {
            return UserDefaults.standard.object(forKey: "avatar_url") as! String?
        }
    }

    var isLogin: Bool {
        get {
            return UserDefaults.standard.object(forKey: "accesstoken") != nil;
        }
    }
    
    private init () { }
    
    public func login(_ accesstoken:String, with handler: completeHandler?) {
        Alamofire.request(
            "https://cnodejs.org/api/v1/accesstoken",
            method: .post,
            parameters: ["accesstoken": accesstoken])
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    let decoder = JSONDecoder();
                    decoder.keyDecodingStrategy = .convertFromSnakeCase;
                    guard let res = try? decoder.decode(CNUserServiceModel.self, from: response.data!) else { return }
                    UserDefaults.standard.set(res.loginname, forKey: "loginname");
                    UserDefaults.standard.set(res.id, forKey: "id");
                    UserDefaults.standard.set(res.avatarUrl, forKey: "avatar_url");
                    UserDefaults.standard.set(accesstoken, forKey: "accesstoken");
                    handler?();
                case .failure(_):
                    ()
                }
            });
    }

    public func logout() {
        UserDefaults.standard.removeObject(forKey: "loginname");
        UserDefaults.standard.removeObject(forKey: "id");
        UserDefaults.standard.removeObject(forKey: "avatar_url");
        UserDefaults.standard.removeObject(forKey: "accesstoken");
    }
}
