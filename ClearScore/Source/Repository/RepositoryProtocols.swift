import Foundation

///
/// Score Data
///
/// Credit score and related information or a user.
///
/// See: https://5lfoiyb0b3.execute-api.us-west-2.amazonaws.com/prod/mockcredit/values
///
/// ```
/// {
///     "accountIDVStatus": "PASS",
///     "creditReportInfo": {
///         "score": 514,
///         "scoreBand": 4,
///         "clientRef": "CS-SED-655426-708782",
///         "status": "MATCH",
///         "maxScoreValue": 700,
///         "minScoreValue": 0,
///         "monthsSinceLastDefaulted": -1,
///         "hasEverDefaulted": false,
///         "monthsSinceLastDelinquent": 1,
///         "hasEverBeenDelinquent": true,
///         "percentageCreditUsed": 44,
///         "percentageCreditUsedDirectionFlag": 1,
///         "changedScore": 0,
///         "currentShortTermDebt": 13758,
///         "currentShortTermNonPromotionalDebt": 13758,
///         "currentShortTermCreditLimit": 30600,
///         "currentShortTermCreditUtilisation": 44,
///         "changeInShortTermDebt": 549,
///         "currentLongTermDebt": 24682,
///         "currentLongTermNonPromotionalDebt": 24682,
///         "currentLongTermCreditLimit": null,
///         "currentLongTermCreditUtilisation": null,
///         "changeInLongTermDebt": -327,
///         "numPositiveScoreFactors": 9,
///         "numNegativeScoreFactors": 0,
///         "equifaxScoreBand": 4,
///         "equifaxScoreBandDescription": "Excellent",
///         "daysUntilNextReport": 9
///     },
///     "dashboardStatus": "PASS",
///     "personaType": "INEXPERIENCED",
///     "coachingSummary": {
///         "activeTodo": false,
///         "activeChat": true,
///         "numberOfTodoItems": 0,
///         "numberOfCompletedTodoItems": 0,
///         "selected": true
///     },
///     "augmentedCreditScore": null
/// }
/// ```
///
struct ScoreData: Decodable {
    
    struct CreditReportInfo: Decodable {
        
        let score: Int
        let minScoreValue: Int
        let maxScoreValue: Int
        let scoreBand: Int
        let numPositiveScoreFactors: Int
        let numNegativeScoreFactors: Int
        
        let currentShortTermDebt: Int
        let currentShortTermCreditLimit: Int
        let currentShortTermCreditUtilisation: Int
        let changeInShortTermDebt: Int
        
        let currentLongTermDebt: Int
        let currentLongTermCreditLimit: Int
        let currentLongTermCreditUtilisation: Int
        let changeInLongTermDebt: Int
    }
    
    let accountIDVStatus: String
    let dashboardStatus: String
    let creditReportInfo: CreditReportInfo
}

///
/// Score Repository
///
/// Repository of user credit score and related informaition.
///
protocol ScoreRepository {
    
    ///
    /// Returns credit score information for the current user.
    ///
    /// - Returns: The score data for the current user.
    ///
    func fetchScore() async throws -> ScoreData
}
