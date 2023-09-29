//
//  Section.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation

struct Section: Codable, Hashable {
    
    let id: String
    let cover: String
    let name: String
    let description: String
}

struct SectionCollection: Codable, Hashable {
    let sections: [Section]
}

struct SectionResponse: Codable, Hashable {
    let data: SectionCollection
}
