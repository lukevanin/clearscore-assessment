import Foundation


///
/// Web accessible repository of mock user credit scores and related information.
///
struct ScoreWebRepository: ScoreRepository {
    
    /// URL of the web service.
    let creditScoreURL: URL
    
    /// Generic transport used for accessing the web service..
    let transport: HTTPCodableTransport
    
    func fetchScore() async throws -> ScoreData {
        try await transport.get(request: HTTPGetRequest(url: creditScoreURL))
    }
}
