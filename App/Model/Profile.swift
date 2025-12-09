//
//  Profile.swift
//  Smth
//
//  用户资料数据模型，定义用户个人信息结构
//  Created by tony
//

import Foundation

struct Profile: Codable, Hashable {
    let newsmthScore: SMScore
    let account: Account
    let title: String
}

struct SMScore: Codable, Hashable {
    let total: Int
}

struct ProfileResponse: Codable, Hashable {
    let data: Profile
}


extension Profile {
    static let defaultProfile = Profile(newsmthScore: SMScore(total: 0), account: Account.defaultAccount, title: "用户")
}
