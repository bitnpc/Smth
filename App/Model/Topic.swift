//
//  Topic.swift
//  Smth
//
//  话题数据模型，定义话题、话题详情及相关响应结构
//  Created by tony
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

// FavTopic related models
struct TopicWrapper: Codable, Hashable {
    let id: String
    let subject: String
    let availables: Int
    let likeAvailables: Int
    let flushTime: TimeInterval
    let lastPostTime: TimeInterval
    let lastArticleOrder: Int
    let lastArticleId: String
    let firstArticleId: String
    let boardId: String
    let board: Board?
    let article: Article?
    let fav: Bool
    let status: Int
}

struct FavTopic: Codable, Hashable, Identifiable {
    let id: String
    let createTime: TimeInterval
    let topicWrapper: TopicWrapper
    let readOrder: Int
    let hasNewReply: Bool
    
    // 转换为 Topic
    var topic: Topic {
        Topic(
            id: topicWrapper.id,
            subject: topicWrapper.subject,
            availables: topicWrapper.availables,
            likeAvailables: topicWrapper.likeAvailables,
            flushTime: topicWrapper.flushTime,
            board: topicWrapper.board,
            article: topicWrapper.article
        )
    }
}

struct FavTopicData: Codable {
    let favTopic: [FavTopic]
    let pager: Pager?
}

struct Pager: Codable {
    let currentPage: Int
    let pageSize: Int
    let start: Int
    let totalItems: Int
    let totalPages: Int
}

struct FavTopicResponse: Codable {
    let code: Int
    let data: FavTopicData
    let message: String
    let kbsCode: Int
}

