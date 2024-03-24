//
//  Board.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation

struct Board: Codable, Hashable {
    let id: String
    let title: String
    let isFavorite: Int
    let groupId: String
    let type: Int
    let name: String
}

struct BoardCollection: Codable, Hashable {
    let boards: [Board]
}

struct BoardResponse: Codable, Hashable {
    let data: BoardCollection
}

struct FavBoardItem: Codable, Hashable {
    let addTime: Int
    let bid: Board
    let type: String
}

struct FavBoard: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let bnum: Int
    let father: Int
    var items: [FavBoardItem] = []
}

struct FavBoardCollection: Codable, Hashable {
    let favBoards: [FavBoard]
}

struct FavBoardResponse: Codable, Hashable {
    let data: FavBoardCollection
}
