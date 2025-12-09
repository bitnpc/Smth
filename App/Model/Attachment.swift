//
//  Attachment.swift
//  Smth
//
//  附件数据模型，定义文章附件信息结构
//  Created by tony
//

import Foundation

struct Attachment: Codable, Hashable {
    let id: String
    let cdnUrl: String
    let ks3Url: String?
    let name: String
    let type: String
}

