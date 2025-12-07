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
    func fetchFriends(name: String) async throws -> FriendsData
    func fetchFans(name: String) async throws -> FansData
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
    
    func fetchFriends(name: String) async throws -> FriendsData {
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let parameters = ["t": timestamp]
        do {
            let response = try await AF.request(APIRouter.friends(name: name, parameters: parameters))
                .serializingDecodable(FriendsResponse.self)
                .value
            
            guard response.code == 1 else {
                throw AppError.businessError(response.message)
            }
            
            return response.data
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }
    
    func fetchFans(name: String) async throws -> FansData {
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let parameters = ["t": timestamp]
        do {
            let response = try await AF.request(APIRouter.fans(name: name, parameters: parameters))
                .serializingDecodable(FansResponse.self)
                .value
            
            guard response.code == 1 else {
                throw AppError.businessError(response.message)
            }
            
            return response.data
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }
}

struct StubUserRepository: UserRepositoryProtocol {
    var profile: () async throws -> Profile
    var friends: (_ name: String) async throws -> FriendsData
    var fans: (_ name: String) async throws -> FansData

    init(
        profile: @escaping () async throws -> Profile = { Profile.defaultProfile },
        friends: @escaping (_ name: String) async throws -> FriendsData = { _ in FriendsData(pager: FriendPager(total: 1, size: 50, page: 0, items: 0), account: Account.defaultAccount, friends: []) },
        fans: @escaping (_ name: String) async throws -> FansData = { _ in FansData(pager: FriendPager(total: 1, size: 50, page: 0, items: 0), account: Account.defaultAccount, fans: []) }
    ) {
        self.profile = profile
        self.friends = friends
        self.fans = fans
    }

    func fetchProfile() async throws -> Profile {
        try await profile()
    }
    
    func fetchFriends(name: String) async throws -> FriendsData {
        try await friends(name)
    }
    
    func fetchFans(name: String) async throws -> FansData {
        try await fans(name)
    }
}


