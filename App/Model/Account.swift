//
//  Account.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation

struct Account: Codable, Hashable {
    var id: String
    var avatarUrl: String
    var nick: String
    var name: String
    
    var loginTime: TimeInterval
}
