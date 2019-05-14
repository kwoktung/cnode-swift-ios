//
//  CNPersonCenterModel.swift
//  cnode-swift-ios
//
//  Created by kwoktung on 14/5/2019.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import Foundation

struct CNPersonCenterTopicAuthor: Decodable {
    let loginname: String
    let avatarUrl: String
}

struct CNPersonCenterTopic: Decodable {
    var id:String
    var title: String
    var lastReplyAt: String
    var author: CNPersonCenterTopicAuthor
}

struct CNPersonCenterModel: Decodable {
    var loginname: String
    var avatarUrl: String
    var createAt: String
    var score: Int16
    var recentTopics: [CNPersonCenterTopic]
    var recentReplies: [CNPersonCenterTopic]
}

struct  CNPersonCenterResponse: Decodable {
    var success: Bool
    var data: CNPersonCenterModel
}
