//
//  Article.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation
import SwiftSoup

struct Article: Codable, Hashable {
    
    var id: String
    var subject: String
    var body: String
    
    var postTime: TimeInterval
    
    var account: Account
    
    var likes: [Like]?
    
    var content: String {
        do {
            let elements = try SwiftSoup.parse(body).select("p")
            var resut = ""
            for node in elements {
                resut += try node.text()
                resut += "\n"
            }
            return resut
        }catch {
            return ""
        }
    }
    
    var postTimeString: String {
        let date = Date(timeIntervalSince1970:postTime / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
    
}
