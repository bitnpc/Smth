//
//  SectionDataSource.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import Foundation
import Alamofire

class SectionDataSource: BaseDataSource {
    
    @MainActor @Published var favSections: [FavBoard] = []
    @MainActor @Published var sections: [SMSection] = []
    
    func fetchFavSections () async {
        let parameters: [String: String] = [:]
        do {
            let response = try await AF.request(APIRouter.favBoard(parameters)).serializingDecodable(FavBoardResponse.self).value
            Task { @MainActor in
                self.favSections = response.data.favBoards
            }
        }catch {
            debugPrint(error)
        }
    }
    
    func fetchSections () async {
        let parameters: [String: String] = [:]
        do {
            let response = try await AF.request(APIRouter.section(parameters)).serializingDecodable(SectionResponse.self).value
            Task { @MainActor in
                self.sections = response.data.sections
            }
        }catch {
            debugPrint(error)
        }
    }
}
