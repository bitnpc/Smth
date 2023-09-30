//
//  TopicDataSource.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation
import Alamofire

class TopicDataSource: BaseDataSource {
    
    @MainActor @Published var topics: [Topic] = []
    @MainActor @Published var myTopics: [Article] = []
    
    func fetchTopics () async {
        let ts = String(Int(NSDate().timeIntervalSince1970 * 1000))
        let parameters = ["t": ts,
                          "page": "1",
                          "size": "20"]
        do {
            let response = try await AF.request(APIRouter.hot(parameters)).serializingDecodable(TopicResponse.self).value
            Task { @MainActor in
                self.topics = response.data.topics
            }
        }catch {
            debugPrint(error)
        }
    }

    func fetchTopicInBoard(boardID: String) async {
        let ts = String(Int(NSDate().timeIntervalSince1970 * 1000))
        let parameters = ["t": ts,
                          "id": boardID,
                          "isOrderByFlushTime": "1",
                          "page": "1"]
        do {
            let response = try await AF.request(APIRouter.topicList(parameters)).serializingDecodable(TopicResponse.self).value
            Task { @MainActor in
                self.topics = response.data.topics
            }
        }catch {
            debugPrint(error)
        }
    }
    
    func fetchMyTopic() async {
        let ts = String(Int(NSDate().timeIntervalSince1970 * 1000))
        let parameters = ["t": ts,
                          "type": "0",
                          "page": "1",
                          "sort": "DESC"]
        do {
            let response = try await AF.request(APIRouter.myTopic(parameters)).serializingDecodable(ArticleResponse.self).value
            Task { @MainActor in
                self.myTopics = response.data.articles
            }
        }catch {
            debugPrint(error)
        }
    }
}
