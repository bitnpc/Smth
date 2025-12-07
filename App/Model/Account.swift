//
//  Account.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation
import WebKit

struct Account: Codable, Hashable {
    let id: String
    let avatarUrl: String
    let nick: String
    let name: String
    let levelTitle: String
    let birthday: String?
    let gender: Int
    let loginTime: TimeInterval
    
    // 可选字段，用于兼容不同 API 返回的数据
    let avatar: String?
    let createTime: TimeInterval?
    let isBlack: Bool?
    let isFans: Bool?
    let k3sUrl: String?
    let level: Int?
    let score: Int?
    let suicide: Bool?
    let type: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, avatar, avatarUrl, nick, name, levelTitle, birthday, gender, loginTime
        case createTime, isBlack, isFans, k3sUrl, level, score, suicide, type
    }
    
    init(id: String, avatarUrl: String, nick: String, name: String, levelTitle: String, birthday: String? = nil, gender: Int, loginTime: TimeInterval, avatar: String? = nil, createTime: TimeInterval? = nil, isBlack: Bool? = nil, isFans: Bool? = nil, k3sUrl: String? = nil, level: Int? = nil, score: Int? = nil, suicide: Bool? = nil, type: Int? = nil) {
        self.id = id
        self.avatarUrl = avatarUrl
        self.nick = nick
        self.name = name
        self.levelTitle = levelTitle
        self.birthday = birthday
        self.gender = gender
        self.loginTime = loginTime
        self.avatar = avatar
        self.createTime = createTime
        self.isBlack = isBlack
        self.isFans = isFans
        self.k3sUrl = k3sUrl
        self.level = level
        self.score = score
        self.suicide = suicide
        self.type = type
    }
}

extension Account {
    var isLoggedIn: Bool {
        return LoginState.shared.isLoggedIn
    }
    
    static func logout() {
        LoginState.shared.markLoggedOut()
        HTTPCookieStorage.shared.removeCookies(since: NSDate.distantPast)
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                WKWebsiteDataStore.default().httpCookieStore.delete(cookie)
            }
        }
    }
}

extension Account {
    static let defaultAccount = Account(
        id: UUID().uuidString,
        avatarUrl: "",
        nick: "Nickname",
        name: "UserName",
        levelTitle: "梧桐",
        birthday: "2000-01-01",
        gender: 1,
        loginTime: 0
    )
}
