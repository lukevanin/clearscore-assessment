import Foundation


///
/// Web accessible repository of mock user credit scores and related information.
///
struct ScoreWebRepository: ScoreRepository {
    
    /// URL of the web service.
    let endpoints: EndpointsProtocol
    
    /// Generic transport used for accessing the web service..
    let transport: HTTPCodableTransport
    
    func fetchScore() async throws -> ScoreData {
        let url = try endpoints.creditScore()
        return try await transport.get(request: HTTPGetRequest(url: url))
    }
}
