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

extension Board {
    static func defaultBoard() -> [Board] {
        return [
            Board.init(id: "1", title: "热帖", isFavorite: 0, groupId: "1", type: 0, name: "热门"),
            Board.init(id: "0", title: "十大", isFavorite: 0, groupId: "2", type: 0, name: "十大"),
            Board.init(id: "c2ea7c56020eb65b0f4dfc2a867d97e7", title: "房产", isFavorite: 0, groupId: "3d1a6f8d2521f6066507f2bc3cca2bf5", type: 0, name: "房产"),
            Board.init(id: "db0bbb22ae11a11c352110e2cf31ce41", title: "亲子", isFavorite: 0, groupId: "4", type: 0, name: "亲子"),
            Board.init(id: "e8d1470f8c33b86d8dae444090e81be4", title: "汽车", isFavorite: 0, groupId: "5", type: 0, name: "汽车"),
            Board.init(id: "eb8324a810531dc904815d120988e6de", title: "家庭", isFavorite: 0, groupId: "6", type: 0, name: "家庭"),
            Board.init(id: "3bcda03dcf4ca0e36c3cc96eaa4cf6f8", title: "理财", isFavorite: 0, groupId: "7", type: 0, name: "理财"),
        ]
    }
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
