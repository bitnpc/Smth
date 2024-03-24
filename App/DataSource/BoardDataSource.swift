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
    var allboards: [Board] = []
    
    func fetchBoards (sectionID: String) async {
        let ts = String(Int(NSDate().timeIntervalSince1970 * 1000))
        let parameters = ["t": ts,
                          "id": sectionID]
        do {
            let response = try await AF.request(APIRouter.board(parameters)).serializingDecodable(BoardResponse.self).value
            Task { @MainActor in
                let groupIDs = response.data.boards.map { board in
                    return board.id
                }
                self.boards = response.data.boards.filter({ board in
                    return (board.type == 0 && groupIDs.contains(board.groupId) == false) || (board.type == 1 && board.groupId.isEmpty)
                })
                self.allboards = response.data.boards
            }
        }catch {
            debugPrint(error)
        }
    }
}
