import Foundation


protocol EndpointsProtocol {
    func creditScore() throws -> URL
}


struct ConfigurationEndpointProvider: EndpointsProtocol {
    
    let configuration: ApplicationConfiguration
    
    func creditScore() throws -> URL {
        try configuration.url(for: .creditScore)
    }
}


struct MockEndpointProvider: EndpointsProtocol {
    
    let baseURL: URL
    
    func creditScore() throws -> URL {
        baseURL.appendingPathComponent("credit-score")
    }
}
