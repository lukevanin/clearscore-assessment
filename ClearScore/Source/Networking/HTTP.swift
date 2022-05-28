import Foundation


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
        let data = try await transport.fetch(request: request)
        let output = try decoder.decode(Output.self, from: data)
        return output
    }
}


///
/// Passthrough HTTP Data Transport
///
/// Communicates with resources over the network using HTTP. Requests and responses are handled without modification.
///
struct PassthroughHTTPDataTransport: HTTPDataTransport {
    
    let session: URLSession
    
    func fetch(request: URLRequest) async throws -> Data {
        let (data, _) = try await session.data(for: request, delegate: nil)
        return data
    }
}
