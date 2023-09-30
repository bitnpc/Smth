//
//  WebView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI
import WebKit

#if os(iOS)
typealias WebViewRepresentable = UIViewRepresentable
#elseif os(macOS)
typealias WebViewRepresentable = NSViewRepresentable
#endif

struct WebView: WebViewRepresentable {
    
    let url: URL
//    @Binding var isLoading: Bool
//    @Binding var error: Error?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
#if os(iOS)
    func makeUIView(context: Context) -> WKWebView  {
        makeView(context: context)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // This space is left intentionally blank.
    }
#endif
    
#if os(macOS)
    public func makeNSView(context: Context) -> WKWebView {
        makeView(context: context)
    }

    public func updateNSView(_ view: WKWebView, context: Context) {
        
    }
#endif
    
    private func makeView(context: Context) -> WKWebView {
        let wkwebView = WKWebView()
        wkwebView.navigationDelegate = context.coordinator
        wkwebView.load(URLRequest(url: url))
        return wkwebView
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            //parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            //parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.cookie") { (result, error) in
                if let cookieString = result as? String {
                    print("Cookies: \(cookieString)")
                    // 在这里处理获取到的 Cookie
                }
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                var isLoggedIn = false
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                    if cookie.name == "kbs-key" {
                        isLoggedIn = true;
                    }
                }
                UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("loading error: \(error)")
//            parent.isLoading = false
//            parent.error = error
        }
    }
}
