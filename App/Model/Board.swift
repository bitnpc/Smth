//
//  Board.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation

struct Board: Codable, Hashable {
    var id: String
    var title: String = ""
    var isFavorite: Int
}

struct BoardCollection: Codable, Hashable {
    
    let boards: [Board]
    
}

struct BoardResponse: Codable, Hashable {
    
    let data: BoardCollection

}
