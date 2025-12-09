//
//  Article.swift
//  Smth
//
//  文章数据模型，定义文章内容、附件及相关响应结构
//  Created by tony
//

import Foundation
import SwiftSoup

struct Article: Codable, Hashable {
    
    let id: String
    let subject: String
    let body: String
    
    let postTime: TimeInterval
    
    let account: Account?
    let accountId: String?
    
//    let likes: [Like]?
    let topicId: String
    
    var attachments: [Attachment]?
    let board: Board? // 可选，在某些场景下可能没有
    
    enum CodingKeys: String, CodingKey {
        case id, subject, body, postTime, account, accountId, topicId, attachments, board
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        subject = try container.decode(String.self, forKey: .subject)
        body = try container.decode(String.self, forKey: .body)
        postTime = try container.decode(TimeInterval.self, forKey: .postTime)
        topicId = try container.decode(String.self, forKey: .topicId)
        account = try? container.decodeIfPresent(Account.self, forKey: .account)
        accountId = try? container.decodeIfPresent(String.self, forKey: .accountId)
        attachments = try? container.decodeIfPresent([Attachment].self, forKey: .attachments)
        board = try? container.decodeIfPresent(Board.self, forKey: .board)
    }
    
    init(id: String, subject: String, body: String, postTime: TimeInterval, account: Account?, accountId: String?, topicId: String, attachments: [Attachment]? = nil, board: Board? = nil) {
        self.id = id
        self.subject = subject
        self.body = body
        self.postTime = postTime
        self.account = account
        self.accountId = accountId
        self.topicId = topicId
        self.attachments = attachments
        self.board = board
    }
    
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
    
    // 从纯文本 body 中提取内容（去掉邮件头）
    var plainTextContent: String {
        let lines = body.components(separatedBy: "\n")
        var contentLines: [String] = []
        var foundEmptyLine = false
        
        for line in lines {
            if foundEmptyLine {
                // 跳过引用内容（以 : 开头的行通常是引用）
                if !line.trimmingCharacters(in: .whitespaces).hasPrefix(":") {
                    // 跳过来源信息（包含 ※ 来源）
                    if !line.contains("※ 来源") && !line.contains("发自") {
                        contentLines.append(line)
                    }
                }
            } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                foundEmptyLine = true
            }
        }
        
        let content = contentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        // 如果提取的内容为空，返回 body（可能是 HTML 格式）
        return content.isEmpty ? body : content
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

