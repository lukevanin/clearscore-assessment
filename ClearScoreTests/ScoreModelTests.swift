import XCTest
@testable import ClearScore

final class ScoreModelTests: XCTestCase {
    
    private var currency: Currency!
    private var scoreRepository: MockScoreRepository!
    private var scoreModel: ScoreModel!
    
    override func setUp() {
        currency = Currency.zar
        scoreRepository = MockScoreRepository()
        scoreModel = ScoreModel(currency: currency, scoreRepository: scoreRepository)
    }
    
    override func tearDown() {
        currency = nil
        scoreRepository = nil
        scoreModel = nil
    }

    func testScoreModel_shouldPublishScoreInfo_whenRepositoryReturnsValidScoreData() async {
        let input = ScoreData(
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
        let expectedOutput = ScoreModel.ScoreInfo(
            score: ScoreModel.ScoreInfo.Score(
                value: 500,
                range: 0...700,
                band: .good,
                totalFactorsCount: 9,
                positiveFactorsCount: 5,
                negativeFactorsCount: 4
            ),
            shortTermCredit: ScoreModel.ScoreInfo.Credit(
                debt: Money(currency: currency, amount: 1_000),
                limit: Money(currency: currency, amount: 2_000),
                change: Money(currency: currency, amount: 100),
                usage: Percentage(value: 50)
            ),
            longTermCredit: ScoreModel.ScoreInfo.Credit(
                debt: Money(currency: currency, amount: 10_000),
                limit: Money(currency: currency, amount: 40_000),
                change: Money(currency: currency, amount: -2000),
                usage: Percentage(value: 25)
            )
        )
        scoreRepository.mockFetchScore = {
            return input
        }
        scoreModel.update()
        var outputs = scoreModel.scorePublisher.values.makeAsyncIterator()
        let actualOutput = await outputs.next()
        XCTAssertEqual(actualOutput, expectedOutput)
    }

    func testScoreModel_shouldPublishScoreInfo_whenRepositoryReturnsError() async {
        scoreRepository.mockFetchScore = {
            throw URLError(.cancelled)
        }
        scoreModel.update()
        var outputs = scoreModel.errorPublisher.values.makeAsyncIterator()
        let actualOutput = await outputs.next()
        let errorOutput = actualOutput as? URLError
        XCTAssertEqual(errorOutput?.code, .cancelled)
    }
}
