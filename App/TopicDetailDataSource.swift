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
    
    func fetchArticles (topicID: String, page: Int, sortType: SortType) {
        
//        self.state = .loading
        
        let ts = String(Int(NSDate().timeIntervalSince1970 * 1000))
        let parameters = ["t": ts]
        let url = APIRouter.article(topicID: topicID,
                                    page: page,
                                    sortType: sortType,
                                    parameters: parameters)
        AF.request(url).responseString { response in
            switch response.result {
            case .success(let jsonString):
                if let responseData = jsonString.data(using: .utf8) {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: [])
                        if var jsonDict = jsonObject as? [String: Any],
                           var data = jsonDict["data"] as? [String: Any],
                           let articles = data["articles"] as? [Any],
                           var firstArticle = articles.first as? [String: Any]  {
                            let itemArray = firstArticle["attachments"] as? [Any?]
                            if (itemArray != nil) {
                                firstArticle["attachments"] = itemArray!.compactMap { $0 as? [String: Any] }
                                data["articles"] = [firstArticle]
                                jsonDict["data"] = data
                                let processedData = try JSONSerialization.data(withJSONObject: jsonDict)
                                let responseObject = try JSONDecoder().decode(TopicDetailResponse.self, from: processedData)
                                Task { @MainActor in
                                    self.articles = responseObject.data.articles
                                    self.board = responseObject.data.board
                                }
                            }else {
                                let responseObject = try JSONDecoder().decode(TopicDetailResponse.self, from: responseData)
                                Task { @MainActor in
                                    self.articles = responseObject.data.articles
                                    self.board = responseObject.data.board
                                }
                            }
                        }
                    }catch {
                        print("Error: \(error)")
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}

