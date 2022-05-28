import Foundation

struct MockScoreRepository: ScoreRepository {
    
    var mockFetchScore: (() async throws -> ScoreData)!
    
    func fetchScore() async throws -> ScoreData {
        try await Task.sleep(nanoseconds: UInt64(1 * 1e9))
        return try await mockFetchScore()
    }
}
