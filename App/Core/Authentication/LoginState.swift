//
//  LoginState.swift
//  Smth
//
//  Created by ChatGPT on 2025/11/12.
//

import Combine
import Foundation

final class LoginState: ObservableObject {
    static let shared = LoginState()

    @Published private(set) var isLoggedIn: Bool

    private let userDefaultsKey = "isLoggedIn"

    private init() {
        isLoggedIn = UserDefaults.standard.bool(forKey: userDefaultsKey)
    }

    func markLoggedIn() {
        updateState(isLoggedIn: true)
    }

    func markLoggedOut() {
        updateState(isLoggedIn: false)
    }

    private func updateState(isLoggedIn: Bool) {
        guard self.isLoggedIn != isLoggedIn else { return }

        if Thread.isMainThread {
            self.isLoggedIn = isLoggedIn
        } else {
            DispatchQueue.main.async {
                self.isLoggedIn = isLoggedIn
            }
        }

        UserDefaults.standard.set(isLoggedIn, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }
}


