//
//  Like.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation

struct Like: Codable, Hashable {
    
    var id: String
    var body: String
    var score: Int
    var account: Account
}
