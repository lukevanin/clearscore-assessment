import Foundation

///
/// Craates dependencies configured with static data for testing.
///
struct TestEnvironmentBuilder {
    
    func build() -> Environment {
        Environment(
            scoreModel: ScoreModel(
                currency: .zar,
                scoreRepository: {
                    // Inject a mock repository with static data.
                    let repository = MockScoreRepository()
                    repository.mockFetchScore = {
                        return ScoreData(
                            creditReportInfo: ScoreData.CreditReportInfo(
                                score: 514,
                                minScoreValue: 0,
                                maxScoreValue: 700,
                                scoreBand: 4,
                                numPositiveScoreFactors: 9,
                                numNegativeScoreFactors: 0,
                                currentShortTermDebt: 32500,
                                currentShortTermCreditLimit: 38000,
                                currentShortTermCreditUtilisation: 85,
                                changeInShortTermDebt: +1544,
                                currentLongTermDebt: 470000,
                                currentLongTermCreditLimit: 500000,
                                currentLongTermCreditUtilisation: 94,
                                changeInLongTermDebt: -2016
                            )
                        )
                    }
                    return repository
                }()
            )
        )
    }
}
