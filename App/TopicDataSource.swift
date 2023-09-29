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
}
