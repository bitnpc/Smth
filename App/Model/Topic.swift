//
//  Topic.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation

struct Topic: Codable, Hashable {
    
    var id: String
    var subject: String
    var availables: Int
    var likeAvailables: Int
    var flushTime: TimeInterval
    
//    var board: Board
    
    var article: Article?
    
}

struct TopicDetail: Codable, Hashable {
    var topic: Topic
    var articles: [Article]
    var board: Board
}

struct TopicCollection: Codable {
    var topics: [Topic]
}

struct TopicResponse: Codable {
    var data: TopicCollection
}

struct TopicDetailResponse: Codable {
    var data: TopicDetail
}

