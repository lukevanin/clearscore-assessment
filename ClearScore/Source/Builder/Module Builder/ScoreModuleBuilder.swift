import UIKit

struct ScoreModuleBuilder: ModuleBuilderProtocol {
    
    func build(environment: Environment) throws -> UIViewController {
        return ScoreViewController(
            viewModelPublisher: environment.scoreModel.scorePublisher
                .map { scoreInfo in
                    let creditScoreRangeFormat = NSLocalizedString("credit-score-range", comment: "Out of %@")
                    let scoreLimit = scoreInfo.score.range.upperBound - scoreInfo.score.range.lowerBound
                    let relativeScore = scoreInfo.score.value - scoreInfo.score.range.lowerBound
                    let indicatorValue = CGFloat(relativeScore) / CGFloat(scoreLimit)
                    return ScoreViewController.ViewModel(
                        prompt: NSLocalizedString("credit-score-prompt", comment: "Your credit score is"),
                        label: scoreInfo.score.value.formatted(.number),
                        caption: String(format: creditScoreRangeFormat, scoreInfo.score.range.upperBound.formatted(.number)),
                        value: indicatorValue
                    )
                }
                .eraseToAnyPublisher()
        )
    }
}
