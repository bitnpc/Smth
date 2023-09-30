//
//  Account.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation
import WebKit

struct Account: Codable, Hashable {
    var id: String
    var avatarUrl: String
    var nick: String
    var name: String
    var levelTitle: String
    var birthday: String?
    var gender: Int
    var loginTime: TimeInterval
}

extension Account {
    var isLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    static func logout() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        HTTPCookieStorage.shared.removeCookies(since: NSDate.distantPast)
        let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: "https://wap.newsmth.net")!)
        for cookie in cookies ?? [] {
            WKWebsiteDataStore.default().httpCookieStore.delete(cookie)
        }
        
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
