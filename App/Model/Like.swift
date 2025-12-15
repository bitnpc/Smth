//
//  Like.swift
//  Smth
//
//  点赞数据模型，定义点赞信息结构
//  Created by tony
//

import Foundation

struct Like: Codable, Hashable {

    let id: String
    let body: String
    let score: Int
    let account: Account
}
