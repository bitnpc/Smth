//
//  Friend.swift
//  Smth
//
//  好友数据模型，定义好友信息和相关响应结构
//  Created by tony
//

import Foundation

struct Friend: Codable, Hashable, Identifiable {
    let id: String
    let accountId: String
    let friendId: String
    let friend: Account
    let account: Account
}

struct FriendsData: Codable {
    let pager: FriendPager
    let account: Account
    let friends: [Friend]
}

struct FriendPager: Codable {
    let total: Int
    let size: Int
    let page: Int
    let items: Int
}

struct FriendsResponse: Codable {
    let code: Int
    let data: FriendsData
    let message: String
    let kbsCode: Int
}

// 粉丝相关数据结构（复用 Friend 结构）
struct FansData: Codable {
    let pager: FriendPager
    let account: Account
    let fans: [Friend]
}

struct FansResponse: Codable {
    let code: Int
    let data: FansData
    let message: String
    let kbsCode: Int
}

