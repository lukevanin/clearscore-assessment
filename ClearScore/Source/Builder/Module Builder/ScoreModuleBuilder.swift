import UIKit

struct ScoreModuleBuilder: ModuleBuilderProtocol {
    
    ///
    /// Transforms `ScoreInfo` into a  view model used by the `ScoreViewController`.
    ///
    struct ModelTransformer: Transformer {
        func transform(input: ScoreModel.ScoreInfo) -> ScoreViewController.ViewModel {
            let creditScoreRangeFormat = NSLocalizedString("credit-score-range", comment: "Out of %@")
            let scoreLimit = input.score.range.upperBound - input.score.range.lowerBound
            let relativeScore = input.score.value - input.score.range.lowerBound
            let indicatorValue = CGFloat(relativeScore) / CGFloat(scoreLimit)
            return ScoreViewController.ViewModel(
                prompt: NSLocalizedString("credit-score-prompt", comment: "Your credit score is"),
                label: input.score.value.formatted(.number),
                caption: String(format: creditScoreRangeFormat, input.score.range.upperBound.formatted(.number)),
                value: indicatorValue
            )
        }
    }
    
    func build(environment: Environment) throws -> UIViewController {
        return ScoreViewController(
            viewModelPublisher: environment.scoreModel.scorePublisher
                .map(ModelTransformer().transform)
                .eraseToAnyPublisher()
        )
    }
}
