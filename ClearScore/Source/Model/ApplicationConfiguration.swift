import Foundation

///
/// Defines the custom configuration parameters for the application, such as web service URLs, custom images, etc.
///
struct ApplicationConfiguration {
    
    enum ConfigurationError: Error, LocalizedError {
        
        /// An endpoint with the specified name is not present in the current configuration.
        case unknownEndpoint(_ name: Endpoint)
        
        /// Returns a human readable description of the error.
        var errorDescription: String? {
            switch self {
            case .unknownEndpoint(let endpoint):
                return "Missing endpoint in configuration: \(endpoint.rawValue)"
            }
        }
    }

    ///
    /// Names of endpoints provided by the configuration.
    ///
    enum Endpoint: String {
        /// Provides credit score
        case creditScore
    }
    
    /// URL where the endpoint service is located.
    let baseURL: URL
    
    /// Maps paths to specific endpoints.
    let endpoints: [Endpoint: String]
    
    init(baseURL: URL, endpoints: [Endpoint: String]) {
        self.baseURL = baseURL
        self.endpoints = endpoints
    }
    
    ///
    /// Returns the complete URL of the endpoint with the given name.
    ///
    /// The endpoint path is appended to the base URL to produce the URL.
    ///
    /// - Parameter name: Name of the endpoint in the endpoints dictionary.
    /// - Returns: URL of the endpoint with the given name.
    ///
    func url(for endpoint: Endpoint) throws -> URL {
        guard let path = endpoints[endpoint] else {
            throw ConfigurationError.unknownEndpoint(endpoint)
        }
        return baseURL.appendingPathComponent(path)
    }
}

extension ApplicationConfiguration: Decodable {
    
    
    ///
    /// Keys used to decode the application configuration from a file
    ///
    enum CodingKeys: String, CodingKey {
        case baseURL
        case endpoints
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            baseURL: try {
                let rawURL = try container.decode(String.self, forKey: .baseURL)
                guard let url = URL(string: rawURL) else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .baseURL,
                        in: container,
                        debugDescription: "Cannot decode url \(rawURL)"
                    )
                }
                return url
            }(),
            endpoints: try {
                var endpoints = [Endpoint: String]()
                let rawEndpoints = try container.decode([String: String].self, forKey: .endpoints)
                for (key, value) in rawEndpoints {
                    guard let endpoint = Endpoint(rawValue: key) else {
                        throw DecodingError.dataCorruptedError(
                            forKey: .endpoints,
                            in: container,
                            debugDescription: "Cannot decode endpoint \(key)"
                        )
                    }
                    endpoints[endpoint] = value
                }
                return endpoints
            }()
        )
    }

    
    ///
    /// Convenience initializer. Loads the configuration from a property list (.plist) file. The structure of the file should correspond with the structure of the
    /// ApplicationConfiguration object.
    ///
    init(withPropertyList fileURL: URL) throws {
        let data = try Data(contentsOf: fileURL)
        let decoder = PropertyListDecoder()
        self = try decoder.decode(ApplicationConfiguration.self, from: data)
    }
}
