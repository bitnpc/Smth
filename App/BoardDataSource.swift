//
//  BoardDataSource.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import Foundation
import Alamofire

class BoardDataSource: BaseDataSource {
    
    @MainActor @Published var boards: [Board] = []
    
    func fetchBoards (sectionID: String) async {
        let ts = String(Int(NSDate().timeIntervalSince1970 * 1000))
        let parameters = ["t": ts,
                          "id": sectionID]
        do {
            let response = try await AF.request(APIRouter.board(parameters)).serializingDecodable(BoardResponse.self).value
            Task { @MainActor in
                self.boards = response.data.boards
            }
        }catch {
            debugPrint(error)
        }
    }
}
