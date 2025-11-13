//
//  SMSection.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
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
