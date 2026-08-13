//
//  ContentstackLogger.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 07/04/20.
//

import Foundation

/// Implement this protocol in order to provide your own custom logger for the SDK to log messages to.
/// Your `CustomLogger` instance will only be passed message it should log according the set log level.
public protocol CustomLogger {
    /// Logs a message if the message being logged has a log level less than
    /// the level configured on the Logger instance.
    /// Logging with LogType `none` does nothing.
    func log(message: String)
}

public enum ContentstackLogger {

    #if os(iOS) || os(tvOS) || os(watchOS) || os(macOS)
    /// The type of logger used to log messages; defaults to `NSLog` on
    /// iOS, tvOS, watchOS, macOS. Defaults to `print` on other platforms.
    public static var logType: LogType = .nsLog
    #else
    /// The type of logger used to log messages; defaults to `NSLog` on
    /// iOS, tvOS, watchOS, macOS. Defaults to `print` on other platforms.
    public static var logType: LogType = .print
    #endif

    /// The highest order of message types that should be logged. Defaults to `LogLevel.error`.
    public static var logLevel: LogLevel = .error
    /// An enum describing the types of messages to be logged.
    public enum LogLevel: Int {
        /// Log nothing to the console.
        case none = 0
        /// Only log errors to the console.
        case error
        /// Log messages when requests are sent, and when responses are received, as well as other useful information.
        case info
    }

    /// The type of logger to use.
    public enum LogType {
        /// Log using simple Swift print statements
        case print
        /// Log using NSLog.
        case nsLog
        /// Log using a custom logger.
        case custom(CustomLogger)
    }

    internal static func log(_ level: LogLevel, message: String) {
        guard level.rawValue <= self.logLevel.rawValue && level != .none else { return }

        var formattedMessage = "[Contentstack] "
        switch level {
        case .error:
            formattedMessage += "Error: "
        default: break
        }
        formattedMessage += message

        switch self.logType {
        case .print:
            Swift.print(formattedMessage)
        case .nsLog:
            // `formattedMessage` must be passed as an argument, never as the format string.
            // Logged messages carry percent-encoded URLs and server-supplied error text, so a
            // message used as a format string is parsed for conversion specifiers (`%22s` from
            // `{"sku":..}`, for example) and reads arguments that were never supplied.
            NSLog("%@", formattedMessage)
        case .custom(let customLogger):
            customLogger.log(message: formattedMessage)
        }
    }
}
