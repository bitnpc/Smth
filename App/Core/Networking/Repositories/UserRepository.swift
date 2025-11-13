//
//  UserRepository.swift
//  Smth
//
//  Provides user related network operations.
//

import Foundation
import Alamofire

protocol UserRepositoryProtocol {
    func fetchProfile() async throws -> Profile
}

struct UserRepository: UserRepositoryProtocol {
    func fetchProfile() async throws -> Profile {
        do {
            let response = try await AF.request(APIRouter.profile([:]))
                .serializingDecodable(ProfileResponse.self)
                .value
            return response.data
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }
}

struct StubUserRepository: UserRepositoryProtocol {
    var profile: () async throws -> Profile

    init(profile: @escaping () async throws -> Profile = { Profile.defaultProfile }) {
        self.profile = profile
    }

    func fetchProfile() async throws -> Profile {
        try await profile()
    }
}


