//
//  AppContainer.swift
//  Smth
//
//  Created as part of the 2025 refactor.
//

import Observation
import SwiftUI

protocol DependencyContainer {
    func resolve<T>(_ type: T.Type) -> T
}

final class AppContainer: DependencyContainer {
    static let shared = AppContainer()

    private lazy var apiService: APIService = DefaultAPIService()
    private lazy var topicRepository: TopicRepositoryProtocol = TopicRepository()
    private lazy var sectionRepository: SectionRepositoryProtocol = SectionRepository()
    private lazy var userRepository: UserRepositoryProtocol = UserRepository()

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

