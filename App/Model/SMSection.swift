//
//  SMSection.swift
//  Smth
//
//  版块分组数据模型，定义版块分组信息结构
//  Created by tony
//

import Foundation

struct SMSection: Codable, Hashable {

    let id: String
    let cover: String
    let name: String
    let description: String
}

struct SectionCollection: Codable, Hashable {
    let sections: [SMSection]
}

struct SectionResponse: Codable, Hashable {
    let data: SectionCollection
}
