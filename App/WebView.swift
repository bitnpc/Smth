//
//  WebView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    let url: URL
//    @Binding var isLoading: Bool
//    @Binding var error: Error?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        let wkwebView = WKWebView()
        wkwebView.navigationDelegate = context.coordinator
        wkwebView.load(URLRequest(url: url))
        return wkwebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // This space is left intentionally blank.
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
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
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
