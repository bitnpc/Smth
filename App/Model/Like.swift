//
//  Like.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation

struct Like: Codable, Hashable {
    
    let id: String
    let body: String
    let score: Int
    let account: Account
}
