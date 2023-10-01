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
    var topicId: String
    
    var quoteContent: String {
        var quote = ""
        do {
            let quoteString = body.components(separatedBy: "<div").last ?? ""
            let elements = try SwiftSoup.parse(quoteString).select("p")
            for node in elements {
                let line = try node.text()
                quote += line
                if line.count != 0 {
                    quote += "\n"
                }
            }
            quote.removeLast()
        }catch {
        }
        return quote
    }
    
    var content: String {
        var resut = ""
        do {
            let paragraph = body.components(separatedBy: "<div").first ?? ""
            let elements = try SwiftSoup.parse(paragraph).select("p")
            for node in elements {
                let line = try node.text()
                resut += line
                if line.count != 0 {
                    resut += "\n"
                }
            }
            resut.removeLast()
        }catch {
        
        }
        return resut
    }
    
    var postTimeString: String {
        let date = Date(timeIntervalSince1970:postTime / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
}

struct ArticleCollection: Codable {
    var articles: [Article]
}

struct ArticleResponse: Codable {
    var data: ArticleCollection
}
