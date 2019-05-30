//
//  CNTopicModel.swift
//  cnode-swift-ios
//
//  Created by kwoktung on 14/5/2019.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import Foundation

struct CNTopicAuthor:Decodable {
    let loginname: String
    let avatarUrl: String
}

struct CNTopicReply:Decodable {
    let id: String
    let author: CNTopicAuthor
    let content: String
    let createAt: String
}

struct CNTopicModel:Decodable {
    let id: String
    let content: String
    let title: String
    let lastReplyAt: String
    let createAt: String
    let replyCount: Int32
    let visitCount: Int32
    let author: CNTopicAuthor
    let replies: [CNTopicReply]
    let tab: String
    var isCollect: Bool
    
}

struct CNTopicModelResponse:Decodable {
    let success: Bool
    let data: CNTopicModel
}
