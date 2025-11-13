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
            Board.init(id: "a317717325f16d68583d66294fe60044", title: "热帖", isFavorite: 0, groupId: "1", type: 0, name: "热门"),
            Board.init(id: "4ae455859a94230d1aaf93812db8e759", title: "十大", isFavorite: 0, groupId: "2", type: 0, name: "十大"),
            Board.init(id: "96e49d69096a5444d556bfd472d91c4f", title: "房产", isFavorite: 0, groupId: "3d1a6f8d2521f6066507f2bc3cca2bf5", type: 0, name: "房产"),
            Board.init(id: "3", title: "亲子", isFavorite: 0, groupId: "4", type: 0, name: "亲子"),
            Board.init(id: "4", title: "汽车", isFavorite: 0, groupId: "5", type: 0, name: "汽车"),
            Board.init(id: "5", title: "家庭", isFavorite: 0, groupId: "6", type: 0, name: "家庭"),
            Board.init(id: "6", title: "理财", isFavorite: 0, groupId: "7", type: 0, name: "理财"),
            Board.init(id: "7", title: "图览", isFavorite: 0, groupId: "8", type: 0, name: "图览")
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
