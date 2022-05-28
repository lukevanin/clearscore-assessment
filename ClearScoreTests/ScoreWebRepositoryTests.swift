import XCTest
@testable import ClearScore

final class ScoreWebRepositoryTests: XCTestCase {
    
    private var url: URL!
    private var endpoints: MockEndpointProvider!
    private var transport: MockHTTPCodableTransport!
    private var scoreRepository: ScoreWebRepository!
    
    override func setUp() {
        url = URL(string: "http://example.org/")
        transport = MockHTTPCodableTransport()
        endpoints = MockEndpointProvider(baseURL: url)
        scoreRepository = ScoreWebRepository(
            endpoints: endpoints,
            transport: transport
        )
    }
    
    override func tearDown() {
        url = nil
        transport = nil
        endpoints = nil
        scoreRepository = nil
    }
    
    func testRepository_shouldReturnScoreData_whenTransportReturnsValidScoreData() async throws {
        let expectedOutput = ScoreData(
            creditReportInfo: ScoreData.CreditReportInfo(
                score: 500,
                minScoreValue: 0,
                maxScoreValue: 700,
                scoreBand: 3,
                numPositiveScoreFactors: 5,
                numNegativeScoreFactors: 4,
                currentShortTermDebt: 1_000,
                currentShortTermCreditLimit: 2_000,
                currentShortTermCreditUtilisation: 50,
                changeInShortTermDebt: 100,
                currentLongTermDebt: 10_000,
                currentLongTermCreditLimit: 40_000,
                currentLongTermCreditUtilisation: 25,
                changeInLongTermDebt: -2_000
            )
        )
        let expectedURL = try endpoints.creditScore()
        transport.mockGet = { request in
            XCTAssertEqual(request.url, expectedURL)
            return expectedOutput
        }
        let actualOutput = try await scoreRepository.fetchScore()
        XCTAssertEqual(actualOutput, expectedOutput)
    }
    
    func testRepository_shouldThrowError_whenTransportThrowsError() async throws {
        let expectedURL = try endpoints.creditScore()
        transport.mockGet = { request in
            XCTAssertEqual(request.url, expectedURL)
            throw URLError(.cancelled)
        }
        await XCTAssertThrowsError(try await scoreRepository.fetchScore())
    }
}
