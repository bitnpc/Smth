//
//  LoginView.swift
//  Smth
//
//  登录页面视图，提供用户登录功能
//  Created by tony
//

import SwiftUI
import WebKit

struct LoginView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @Binding var showLoginView: Bool
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let loginURL = URL(string: "https://wap.newsmth.net/login")!
    
    var body: some View {
        NavigationStack {
            ZStack {
                LoginWebView(
                    url: loginURL,
                    isLoading: $isLoading,
                    errorMessage: $errorMessage,
                    onComplete: {
                        showLoginView = false
                    }
                )
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("正在加载...")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        AppTheme.surfaceBackground(for: colorScheme)
                            .opacity(0.9)
                    )
                }
                
                if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.orange)
                        Text("加载失败")
                            .font(.system(.headline, design: .rounded))
                        Text(errorMessage)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("重试") {
                            self.errorMessage = nil
                            self.isLoading = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        AppTheme.surfaceBackground(for: colorScheme)
                            .opacity(0.95)
                    )
                }
            }
            .navigationTitle("登录")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showLoginView = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showLoginView = false
                    } label: {
                        Text("关闭")
                    }
                }
                #endif
            }
            .tint(AppTheme.accentColor(for: colorScheme))
        }
        #if os(macOS)
        .frame(minWidth: 600, minHeight: 500)
        #endif
    }
}

// MARK: - SwiftUI WebView 实现
#if os(iOS)
private struct LoginWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    let onComplete: () -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: LoginWebView
        
        init(_ parent: LoginWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.errorMessage = nil
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.errorMessage = error.localizedDescription
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.errorMessage = error.localizedDescription
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            checkLoginStatus(webView: webView)
            return .allow
        }
        
        private func checkLoginStatus(webView: WKWebView) {
            Task {
                let cookies = await WKWebsiteDataStore.default().httpCookieStore.allCookies()
                var isLoggedIn = false
                
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                    if cookie.name == "kbs-key" {
                        isLoggedIn = true
                    }
                }

                await MainActor.run {
                    if LoginState.shared.isLoggedIn {
                        return
                    }
                    if isLoggedIn {
                        LoginState.shared.markLoggedIn()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.parent.onComplete()
                            print("LoginWebView: logged in. hide")
                        }
                    } else {
                        LoginState.shared.markLoggedOut()
                        print("LoginWebView: logged out.")
                    }
                }
            }
        }
    }
}
#elseif os(macOS)
private struct LoginWebView: NSViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    let onComplete: () -> Void
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.minimumFontSize = 10
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if nsView.url != url {
            nsView.load(URLRequest(url: url))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: LoginWebView
        
        init(_ parent: LoginWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.errorMessage = nil
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
            checkLoginStatus(webView: webView)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.errorMessage = error.localizedDescription
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.errorMessage = error.localizedDescription
            }
        }
        
        private func checkLoginStatus(webView: WKWebView) {
            Task {
                do {
                    let cookies = try await WKWebsiteDataStore.default().httpCookieStore.allCookies()
                    var isLoggedIn = false
                    
                    for cookie in cookies {
                        HTTPCookieStorage.shared.setCookie(cookie)
                        if cookie.name == "kbs-key" {
                            isLoggedIn = true
                        }
                    }
                    
                    await MainActor.run {
                        if isLoggedIn {
                            LoginState.shared.markLoggedIn()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.parent.onComplete()
                            }
                        } else {
                            LoginState.shared.markLoggedOut()
                        }
                    }
                } catch {
                    print("Error checking login status: \(error.localizedDescription)")
                }
            }
        }
    }
}
#endif
