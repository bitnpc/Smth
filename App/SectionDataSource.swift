//
//  SectionDataSource.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import Foundation
import Alamofire

class SectionDataSource: BaseDataSource {
    
    @MainActor @Published var sections: [Section] = []
    
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
