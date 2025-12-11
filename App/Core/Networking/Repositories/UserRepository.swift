//
//  UserRepository.swift
//  Smth
//
//  用户相关的数据仓库，负责获取用户资料、好友列表、粉丝列表等
//  Created by tony
//

import Foundation

protocol UserRepositoryProtocol {
    func fetchProfile() async throws -> Profile
    func fetchFriends(name: String) async throws -> FriendsData
    func fetchFans(name: String) async throws -> FansData
    func fetchNavigation() async throws -> [Navigation]
}

struct UserRepository: UserRepositoryProtocol {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchProfile() async throws -> Profile {
        let endpoint = APIEndpoint.profile.toEndpoint()
        let response: ProfileResponse = try await apiService.request(endpoint)
        return response.data
    }
    
    func fetchFriends(name: String) async throws -> FriendsData {
        let endpoint = APIEndpoint.friends(name: name).toEndpoint()
        let response: FriendsResponse = try await apiService.request(endpoint)
        
        guard response.code == 1 else {
            throw AppError.businessError(response.message)
        }
        
        return response.data
    }
    
    func fetchFans(name: String) async throws -> FansData {
        let endpoint = APIEndpoint.fans(name: name).toEndpoint()
        let response: FansResponse = try await apiService.request(endpoint)
        
        guard response.code == 1 else {
            throw AppError.businessError(response.message)
        }
        
        return response.data
    }
    
    func fetchNavigation() async throws -> [Navigation] {
        let endpoint = APIEndpoint.navigation.toEndpoint()
        let response: NavigationResponse = try await apiService.request(endpoint)
        
        guard response.code == 1 else {
            throw AppError.businessError(response.message)
        }
        
        guard response.data.code == 0 else {
            throw AppError.businessError(response.message)
        }
        
        return response.data.data
    }
}

struct StubUserRepository: UserRepositoryProtocol {
    var profile: () async throws -> Profile
    var friends: (_ name: String) async throws -> FriendsData
    var fans: (_ name: String) async throws -> FansData
    var navigation: () async throws -> [Navigation]

    init(
        profile: @escaping () async throws -> Profile = { Profile.defaultProfile },
        friends: @escaping (_ name: String) async throws -> FriendsData = { _ in
            FriendsData(
                pager: FriendPager(total: 1, size: 50, page: 0, items: 0),
                account: Account.defaultAccount,
                friends: []
            )
        },
        fans: @escaping (_ name: String) async throws -> FansData = { _ in
            FansData(
                pager: FriendPager(total: 1, size: 50, page: 0, items: 0),
                account: Account.defaultAccount,
                fans: []
            )
        },
        navigation: @escaping () async throws -> [Navigation] = {
            [
                Navigation(name: "热帖", id: "4ed7f0d8b621c8ccf9e11eca9991d6dc", type: "global", value: "global")
            ]
        }
    ) {
        self.profile = profile
        self.friends = friends
        self.fans = fans
        self.navigation = navigation
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
    
    func fetchNavigation() async throws -> [Navigation] {
        try await navigation()
    }
}
