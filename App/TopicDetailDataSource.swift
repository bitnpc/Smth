//
//  TopicDetailDataSource.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation
import Alamofire

public enum SortType: Int {
    case OnlyPublisher = 0
    case Defatul = 1
    case Latest = 2
}

class TopicDetailDataSource: BaseDataSource {
    
    @MainActor @Published var articles: [Article] = []
    @MainActor @Published var board: Board? = nil
    
    func fetchArticles (topicID: String, page: Int, sortType: SortType) async {
        
//        self.state = .loading
        
        let ts = String(Int(NSDate().timeIntervalSince1970 * 1000))
        let parameters = ["t": ts]
        do {
            let url = APIRouter.article(topicID: topicID,
                                        page: page,
                                        sortType: sortType,
                                        parameters: parameters)
            let response = try await AF.request(url).serializingDecodable(TopicDetailResponse.self).value
            Task { @MainActor in
                self.articles = response.data.articles
                self.board = response.data.board
            }
        }catch {
            debugPrint(error)
        }
    }
}

