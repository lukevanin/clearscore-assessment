import Foundation
import OSLog


private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")


///
/// Information used to fetch data from an HTTP endpoint using the GET method.
///
struct HTTPGetRequest {
    
    /// Location of the remote resource
    var url: URL
    
    /// Policy used to determine whether previously cached data should be considered.
    var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringCacheData
    
    /// Time to wait for a response before reporting the request as a failure.
    var timeoutInterval: TimeInterval = 2.0
}


///
/// Interface for accessing resources from a REST endpoint, typically using HTTP/HTTPS.
///
protocol HTTPCodableTransport {
    
    ///
    /// Returns a Decodable object from an HTTP URL using the GET method.
    ///
    func get<Output>(request: HTTPGetRequest) async throws -> Output where Output: Decodable
}


///
/// HTTP Data Transport
///
/// Interface for communicating with a resource provider using HTTP.
///
/// Implemented by objects that can transport data using HTTP.
///
protocol HTTPDataTransport {
    
    ///
    /// Returns Data from an HTTP URL.
    ///
    func fetch(request: URLRequest) async throws -> Data
}


///
/// JSON HTTP Codable Transport
///
/// Transport for sending and receieving objects encoding as JSON to and from a provider using HTTP.
///
struct JSONHTTPCodableTransport: HTTPCodableTransport {
    
    /// Encoder used to convert objects into JSON.
    let encoder: JSONEncoder
    
    /// Decoder used to instantiate objects from a JSON representation.
    let decoder: JSONDecoder
    
    /// Service used to send and receive data from the network.
    let transport: HTTPDataTransport
    
    func get<Output>(request: HTTPGetRequest) async throws -> Output where Output: Decodable {
        var request = URLRequest(
            url: request.url,
            cachePolicy: request.cachePolicy,
            timeoutInterval: request.timeoutInterval
        )
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        logger.debug("Sending GET request: \(request)")
        let data = try await transport.fetch(request: request)
        let output = try decoder.decode(Output.self, from: data)
        logger.debug("Received GET response: \(String(describing: output))")
        return output
    }
}


///
/// Mock HTTP codable transport.
///
final class MockHTTPCodableTransport: HTTPCodableTransport {
    
    var mockGet: ((HTTPGetRequest) throws -> Any)!
    
    func get<Output>(request: HTTPGetRequest) async throws -> Output where Output : Decodable {
        try mockGet(request) as! Output
    }
}


///
/// Passthrough HTTP Data Transport.
///
/// Communicates with resources over the network using HTTP. Requests and responses are handled without modification.
///
struct PassthroughHTTPDataTransport: HTTPDataTransport {
    
    let session: URLSession
    
    func fetch(request: URLRequest) async throws -> Data {
        logger.debug("Sending request: \(String(describing: request))")
        let (data, _) = try await session.data(for: request, delegate: nil)
        logger.debug("Received response: \(String(data: data, encoding: .utf8) ?? String(describing: data))")
        return data
    }
}


///
///
///
final class MockHTTPDataTransport: HTTPDataTransport {
    
    var mockFetch: ((URLRequest) throws -> Data)!
    
    func fetch(request: URLRequest) async throws -> Data {
        try mockFetch(request)
    }
}
