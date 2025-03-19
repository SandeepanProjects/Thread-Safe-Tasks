//
//  Logger.swift
//  
//
//  Created by Apple on 19/03/25.
//

import Foundation

/// Enum which maps an appropiate symbol which added as prefix for each log message
/// - error: Log type error
/// - info: Log type info
/// - debug: Log type debug
/// - verbose: Log type verbose
/// - warning: Log type warning
/// - severe: Log type severe
enum LogEvent: String {
    case e = "Log.e[‼️]" // error
    case i = "Log.i[ℹ️]" // info
    case d = "Log.d[💬]" // debug
    case v = "Log.v[🔬]" // verbose
    case w = "Log.w[⚠️]" // warning
    case s = "Log.s[🔥]" // severe
}

/// Wrapping Swift.print() within DEBUG flag
///
/// - Parameter object: The object which is to be logged
///
func print(_ object: Any) {
    // Only allowing in DEBUG mode
    Swift.debugPrint(object)
}

class Log {
    
    // MARK: - Loging methods
    /// Logs error messages on console with prefix [‼️]
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func e( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        print("\(Date().asDateString(with: .logDateFormat)) \(LogEvent.e.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
    
    /// Logs info messages on console with prefix [ℹ️]
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func i ( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
            print("\(Date().asDateString(with: .logDateFormat)) \(LogEvent.i.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
    
    /// Logs debug messages on console with prefix [💬]
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func d( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
            print("\(Date().asDateString(with: .logDateFormat)) \(LogEvent.d.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
    
    /// Logs messages verbosely on console with prefix [🔬]
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func v( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
            print("\(Date().asDateString(with: .logDateFormat)) \(LogEvent.v.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
    
    /// Logs warnings verbosely on console with prefix [⚠️]
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func w( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
            print("\(Date().asDateString(with: .logDateFormat)) \(LogEvent.w.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
    
    /// Logs severe events on console with prefix [🔥]
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func s( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
            print("\(Date().asDateString(with: .logDateFormat)) \(LogEvent.s.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
    
    /// Extract the file name from the file path
    /// - Parameter filePath: Full file path in bundle
    /// - Returns: File Name with extension
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}


class NetworkLogger {
    
    static let shared = NetworkLogger()
    
    private init() {}
    
    func logRequest(_ request: URLRequest) {
        Logger.shared.log(.info, message: "Request: \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "")")
        
        if let headers = request.allHTTPHeaderFields {
            Logger.shared.log(.info, message: "Request Headers: \(headers)")
        }
        
        if let body = request.httpBody {
            let bodyString = String(data: body, encoding: .utf8) ?? "nil"
            Logger.shared.log(.info, message: "Request Body: \(bodyString)")
        }
    }
    
    func logResponse(_ response: HTTPURLResponse, data: Data?) {
        Logger.shared.log(.info, message: "Response: \(response.statusCode) \(response.url?.absoluteString ?? "")")
        
        if let headers = response.allHeaderFields as? [String: String] {
            Logger.shared.log(.info, message: "Response Headers: \(headers)")
        }
        
        if let data = data {
            let responseBody = String(data: data, encoding: .utf8) ?? "nil"
            Logger.shared.log(.info, message: "Response Body: \(responseBody)")
        }
    }
    
    func logError(_ error: Error) {
        Logger.shared.log(.error, message: "Error: \(error.localizedDescription)")
    }
}


class NetworkSession: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    static let shared = NetworkSession()
    
    private override init() {
        super.init()
    }
    
    func createSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return session
    }
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let response = dataTask.response as? HTTPURLResponse {
            NetworkLogger.shared.logResponse(response, data: data)
        }
    }
    
    // MARK: - URLSessionDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            NetworkLogger.shared.logError(error)
        }
    }
    
    // MARK: - URLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        NetworkLogger.shared.logRequest(request)
        completionHandler(request)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Handle any authentication challenges (e.g. for secure connections)
        completionHandler(.performDefaultHandling, nil)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        NetworkLogger.shared.logResponse(response as! HTTPURLResponse, data: nil)
        completionHandler(.allow)
    }
}

// Using the Logger in Network Requests
func fetchData(from url: URL) {
    let session = NetworkSession.shared.createSession()
    let request = URLRequest(url: url)
    
    // Log the request
    NetworkLogger.shared.logRequest(request)
    
    let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
            NetworkLogger.shared.logError(error)
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            NetworkLogger.shared.logResponse(httpResponse, data: data)
        }
        
        // Handle the received data
    }
    
    task.resume()
}
