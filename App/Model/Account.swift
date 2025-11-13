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
    static let defaultAccount = Account(id: UUID().uuidString, avatarUrl: "", nick: "Nickname", name: "UserName", levelTitle: "梧桐", birthday: "2000-01-01", gender: 1, loginTime: 0)
}
