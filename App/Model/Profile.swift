//
//  Profile.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
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
