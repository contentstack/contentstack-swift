//
//  CSURLSessionDelegate.swift
//  ContentstackSwift
//
//  Created by Reeshika Hosmani on 19/05/25.
//

import Foundation

/// Protocol for SSL pinning customization in Contentstack SDK
@objc public protocol CSURLSessionDelegate: NSObjectProtocol, URLSessionDelegate {
    
    /// Tells the delegate that the session received an authentication challenge.
    /// - Parameters:
    ///   - session: The session that received the authentication challenge.
    ///   - challenge: An object that contains the request for authentication.
    ///   - completionHandler: A handler that your delegate method must call.
    @objc func urlSession(_ session: URLSession,
                          didReceive challenge: URLAuthenticationChallenge,
                          completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    
    /// Tells the delegate that the session task received an authentication challenge.
    /// - Parameters:
    ///   - session: The session containing the task that received the authentication challenge.
    ///   - task: The task that received the authentication challenge.
    ///   - challenge: An object that contains the request for authentication.
    ///   - completionHandler: A handler that your delegate method must call.
    @objc optional func urlSession(_ session: URLSession,
                                   task: URLSessionTask,
                                   didReceive challenge: URLAuthenticationChallenge,
                                   completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}
