//
//  AppContainer.swift
//  Smth
//
//  依赖注入容器，管理应用中的所有依赖项和服务
//  Created by tony
//

import Observation
import SwiftUI

protocol DependencyContainer {
    func resolve<T>(_ type: T.Type) -> T
}

final class AppContainer: DependencyContainer {
    static let shared = AppContainer()

    private lazy var apiService: APIService = DefaultAPIService()
    private lazy var topicRepository: TopicRepositoryProtocol = TopicRepository(apiService: apiService)
    private lazy var sectionRepository: SectionRepositoryProtocol = SectionRepository(apiService: apiService)
    private lazy var userRepository: UserRepositoryProtocol = UserRepository(apiService: apiService)
    private lazy var messageRepository: MessageRepositoryProtocol = MessageRepository(apiService: apiService)
    private lazy var searchRepository: SearchRepositoryProtocol = SearchRepository(apiService: apiService)
    private lazy var draftRepository: DraftRepositoryProtocol = DraftRepository(apiService: apiService)

    private init() {}

    func resolve<T>(_ type: T.Type) -> T {
        if type == APIService.self {
            return apiService as! T
        } else if type == TopicRepositoryProtocol.self {
            return topicRepository as! T
        } else if type == SectionRepositoryProtocol.self {
            return sectionRepository as! T
        } else if type == UserRepositoryProtocol.self {
            return userRepository as! T
        } else if type == MessageRepositoryProtocol.self {
            return messageRepository as! T
        } else if type == SearchRepositoryProtocol.self {
            return searchRepository as! T
        } else if type == DraftRepositoryProtocol.self {
            return draftRepository as! T
        } else {
            fatalError("未注册的依赖：\(type)")
        }
    }
}

private struct DependencyKey: EnvironmentKey {
    static let defaultValue: DependencyContainer = AppContainer.shared
}

extension EnvironmentValues {
    var container: DependencyContainer {
        get { self[DependencyKey.self] }
        set { self[DependencyKey.self] = newValue }
    }
}

@propertyWrapper
struct Injected<T> {
    @Environment(\.container) private var container

    var wrappedValue: T {
        container.resolve(T.self)
    }
}

