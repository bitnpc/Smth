//
//  Navigation.swift
//  Smth
//
//  Created by tony on 2025/12/11.
//

import Foundation

struct Navigation: Codable, Hashable {
    let name: String
    let id: String
    let type: String
    let value: String
}

struct NavigationData: Codable {
    let code: Int
    let data: [Navigation]
}

struct NavigationResponse: Codable {
    let code: Int
    let data: NavigationData
    let kbsCode: Int
    let message: String
}

extension Navigation {
    static func topNavigation() -> Navigation {
        return Navigation(name: "十大", id: "0", type: "top", value: "top")
    }
}
