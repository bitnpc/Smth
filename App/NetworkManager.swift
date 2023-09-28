import Foundation
import SwiftSoup
import Alamofire

actor NetworkManager: GlobalActor {
    
    static let shared = NetworkManager()
        
    func get(path: String, parameters: Parameters?) async throws -> Data {
        do {
            let valueData = try await AF.request(path).serializingData().value
            return valueData
        }catch {
            throw error
        }
    }
//
//    //https://m.newsmth.net/board/ITExpress?p=2
    func getTopFeeds() async throws -> [Topic]
    {
        let parameters = ["t": "1695861679884",
                          "page": "1",
                          "size": "20"]
        do {
            let value = try await AF.request(APIRouter.hot(parameters)).serializingDecodable(TopicResponse.self).value
            return value.data.topics
        }catch {
            debugPrint(error)
        }
        return []
    }
}
