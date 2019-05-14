//
//  CNCollectionListModel.swift
//  cnode-swift-ios
//
//  Created by kwoktung on 14/5/2019.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import Foundation

struct CNCollectionListAuthor: Decodable {
    let loginname: String
    let avatarUrl: String
}

struct CNCollectionListModel: Decodable {
    let id: String
    let content: String
    let title: String
    let createAt:String
    let lastReplyAt: String
    let replyCount: Int64
    let visitCount: Int64
    let author: CNCollectionListAuthor
}

struct CNCollectionListResponse: Decodable {
    let success: Bool
    let data: [CNCollectionListModel]
}
