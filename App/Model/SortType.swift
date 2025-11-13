//
//  SortType.swift
//  Smth
//
//  Defines sorting options for topic detail requests.
//

import Foundation

public enum SortType: Int, Codable {
    case onlyPublisher = 0
    case `default` = 1
    case latest = 2
}


