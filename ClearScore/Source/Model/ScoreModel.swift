import Foundation
import OSLog
import Combine


private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "score-model")

///
/// Models of the credit score rating for a user.
///
final class ScoreModel {
    
    ///
    /// Information about the credit rating for a user.
    ///
    struct ScoreInfo: Equatable {
        
        struct Score: Equatable {
            
            enum Band: Int, Equatable {
                case veryPoor = 0
                case poor
                case fair
                case good
                case excellent
            }

            let value: Int
            let range: ClosedRange<Int>
            let band: Band?
            let totalFactorsCount: Int
            let positiveFactorsCount: Int
            let negativeFactorsCount: Int
        }
        
        struct Credit: Equatable {
            let debt: Money
            let limit: Money
            let change: Money
            let usage: Percentage
        }
        
        let score: Score
        let shortTermCredit: Credit
        let longTermCredit: Credit
    }
    
    lazy var errorPublisher: AnyPublisher<Error, Never> = errorSubject.eraseToAnyPublisher()
    lazy var scorePublisher: AnyPublisher<ScoreInfo, Never> = scoreSubject.compactMap { $0 }.eraseToAnyPublisher()

    private var errorSubject = PassthroughSubject<Error, Never>()
    private var scoreSubject = CurrentValueSubject<ScoreInfo?, Never>(nil)

    private let currency: Currency
    private let scoreRepository: ScoreRepository
    
    init(currency: Currency, scoreRepository: ScoreRepository) {
        self.currency = currency
        self.scoreRepository = scoreRepository
    }
    
    ///
    /// Updates the score info from the repository. Publishes the new score info or an error.
    ///
    func update() {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            logger.debug("update > started")
            do {
                let scoreData = try await self.scoreRepository.fetchScore()
                let scoreInfo = try self.scoreInfo(from: scoreData)
                logger.debug("update > completed: \(String(describing: scoreInfo))")
                self.scoreSubject.send(scoreInfo)
            }
            catch {
                logger.debug("update > failed: \(error.localizedDescription)")
                self.errorSubject.send(error)
            }
        }
    }
    
    ///
    /// Converts score data into score information.
    ///
    private func scoreInfo(from data: ScoreData) throws -> ScoreInfo {
        ScoreInfo(
            score: ScoreInfo.Score(
                value: data.creditReportInfo.score,
                range: (data.creditReportInfo.minScoreValue...data.creditReportInfo.maxScoreValue),
                band: ScoreInfo.Score.Band(rawValue: data.creditReportInfo.scoreBand),
                totalFactorsCount: data.creditReportInfo.numNegativeScoreFactors + data.creditReportInfo.numPositiveScoreFactors,
                positiveFactorsCount: data.creditReportInfo.numPositiveScoreFactors,
                negativeFactorsCount: data.creditReportInfo.numNegativeScoreFactors
            ),
            shortTermCredit: ScoreInfo.Credit(
                debt: Money(currency: currency, amount: data.creditReportInfo.currentShortTermDebt),
                limit: Money(currency: currency, amount: data.creditReportInfo.currentShortTermCreditLimit),
                change: Money(currency: currency, amount: data.creditReportInfo.changeInShortTermDebt),
                usage: Percentage(value: data.creditReportInfo.currentShortTermCreditUtilisation)
            ),
            longTermCredit: ScoreInfo.Credit(
                debt: Money(currency: currency, amount: data.creditReportInfo.currentLongTermDebt),
                limit: Money(currency: currency, amount: data.creditReportInfo.currentLongTermCreditLimit),
                change: Money(currency: currency, amount: data.creditReportInfo.changeInLongTermDebt),
                usage: Percentage(value: data.creditReportInfo.currentLongTermCreditUtilisation)
            )
        )
    }
}

