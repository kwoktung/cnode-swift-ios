import Foundation

struct CNHomeTopicAuthorModel: Codable {
    var loginname: String
    var avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case loginname
        case avatarUrl = "avatar_url"
    }
}

struct CNHomeTopicModel: Decodable {
    var id: String
    var title: String
    var content: String
    
    var lastReplyAt: String;
    var replyCount: Int32;
    var visitCount: Int32;
    var author: CNHomeTopicAuthorModel;
    
    enum CodingKeys: String, CodingKey {
        case title;
        case content;
        case id;
        
        case lastReplyAt = "last_reply_at"
        case replyCount = "reply_count";
        case visitCount = "visit_count"
        case author;
    }
}

struct CNHomeTopicResponse: Decodable {
    var success: Bool
    var topicArr: [CNHomeTopicModel]
    
    enum CodingKeys: String, CodingKey {
        case success
        case topicArr = "data"
    }
}
