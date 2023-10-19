//
//  Attachment.swift
//  Smth
//
//  Created by Tony Clark on 2023/10/15.
//

import Foundation

struct Attachment: Codable, Hashable {
    let id: String
    let cdnUrl: String
    let ks3Url: String
    let name: String
    let type: String
}

