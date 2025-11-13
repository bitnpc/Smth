//
//  Topic.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation

struct Topic: Codable, Hashable, Identifiable {
    
    let id: String
    let subject: String
    let availables: Int
    let likeAvailables: Int
    let flushTime: TimeInterval
    
    let board: Board?
    
    let article: Article?
}

struct TopicDetail: Codable, Hashable {
    let topic: Topic
    let articles: [Article]
    let board: Board
}

struct TopicCollection: Codable {
    let topics: [Topic]
}

struct TopicResponse: Codable {
    let data: TopicCollection
}

struct TopicDetailResponse: Codable {
    let data: TopicDetail
}

