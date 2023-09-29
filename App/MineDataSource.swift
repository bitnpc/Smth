//
//  MineDataSource.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import Foundation
import Alamofire

class MineDataSource: BaseDataSource {
    
    @MainActor @Published var profile: Profile = Profile.defaultProfile

    func fetchProfile () async {
        let parameters: [String: String] = [:]
        do {
            let response = try await AF.request(APIRouter.profile(parameters)).serializingDecodable(ProfileResponse.self).value
            Task { @MainActor in
                self.profile = response.data
            }
        }catch {
            debugPrint(error)
        }
    }
    
}
