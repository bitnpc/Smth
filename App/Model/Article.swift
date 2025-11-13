//
//  Article.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation
import SwiftSoup

struct Article: Codable, Hashable {
    
    let id: String
    let subject: String
    let body: String
    
    let postTime: TimeInterval
    
    let account: Account
    
//    let likes: [Like]?
    let topicId: String
    
    var attachments: [Attachment]?
    
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
            if quote.isEmpty == false {
                quote.removeLast()
            }
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
            if resut.isEmpty == false {
                resut.removeLast()
            }
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
    let articles: [Article]
}

struct ArticleResponse: Codable {
    let data: ArticleCollection
}

//extension Article {
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        var myid: String, mysubject: String, mybody: String, mypostTime: TimeInterval, myaccount: Account, mytopicId: String
//        do {
//            myid = try container.decode(String.self, forKey: .id)
//            mysubject = try container.decode(String.self, forKey: .subject)
//            mybody = try container.decode(String.self, forKey: .body)
//            mypostTime = try container.decode(TimeInterval.self, forKey: .postTime)
//            myaccount = try container.decode(Account.self, forKey: .account)
//            mytopicId = try container.decode(String.self, forKey: .topicId)
//            
//            var attachmentsArray = try container.nestedUnkeyedContainer(forKey: .attachments)
//            var validAttachments: [Attachment] = []
//            while !attachmentsArray.isAtEnd {
//                if let attachment = try? attachmentsArray.decode(Attachment.self) {
//                    // 检查 attachment 是否有效，可以根据您的条件进行检查
//                    if Article.isValid(attachment) {
//                        validAttachments.append(attachment)
//                    }
//                } else {
//                    // 解码无效 attachment
////                    _ = try? attachmentsArray.decode(AnyCodable.self)
//                }
//            }
//            self.attachments = validAttachments
//        }catch {
//            myid = ""
//            mysubject = ""
//            mybody = ""
//            mypostTime = TimeInterval()
//            myaccount = Account.defaultAccount
//            mytopicId = ""
//        }
//        self.id = myid
//        self.subject = mysubject
//        self.body = mybody
//        self.postTime = mypostTime
//        self.account = myaccount
//        self.topicId = mytopicId
//    }
//    
//    // 自定义方法来检查是否有效的 attachment
//    private static func isValid(_ attachment: Attachment) -> Bool {
//        // 根据您的条件来判断有效性
//        return !attachment.name.isEmpty
//    }
//}

