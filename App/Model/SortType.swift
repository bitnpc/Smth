//
//  SortType.swift
//  Smth
//
//  排序类型枚举，定义话题详情的排序选项
//  Created by tony
//

import Foundation

public enum SortType: Int, Codable {
    case onlyPublisher = 0
    case `default` = 1
    case latest = 2
}


