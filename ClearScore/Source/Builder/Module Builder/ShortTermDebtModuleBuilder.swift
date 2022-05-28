import UIKit

struct ShortTermCreditInfoModuleBuilder: ModuleBuilderProtocol {
    
    ///
    /// Transforms `ScoreInfo` from the score model into a  view model for displaying short term credit info in a `InfoViewController`.
    ///
    struct ModelTransformer: Transformer {
        func transform(input model: ScoreModel.ScoreInfo) -> InfoViewController.ViewModel {
            InfoViewController.ViewModel(
                title: NSLocalizedString("short-term-credit-title", comment: "Short term credit"),
                creditUtilization: InfoViewController.ViewModel.Guage(
                    ratio: CGFloat(model.shortTermCredit.usage?.unity() ?? 0),
                    value: model.shortTermCredit.usage?.formatted() ?? "--",
                    caption: NSLocalizedString("short-term-credit-utilization", comment: "Short term credit utilization")
                ),
                debt: InfoViewController.ViewModel.Item(
                    caption: NSLocalizedString("short-term-debt", comment: "Short term debt"),
                    value: model.shortTermCredit.debt?.formatted(denomination: 100) ?? "--"
                ),
                creditLimit: InfoViewController.ViewModel.Item(
                    caption: NSLocalizedString("short-term-credit-limit", comment: "Short term credit limit"),
                    value: model.shortTermCredit.limit?.formatted(denomination: 100) ?? "--"
                ),
                debtChange: InfoViewController.ViewModel.Item(
                    caption: NSLocalizedString("short-term-debt-change", comment: "Short term credit limit"),
                    value:  model.shortTermCredit.change?.formatted(denomination: 100) ?? "--"
                )
            )
        }
    }

    func build(environment: Environment) throws -> UIViewController {
        InfoViewController(
            viewModelPublisher: environment.scoreModel.scorePublisher
                .map(ModelTransformer().transform)
                .eraseToAnyPublisher()
        )
    }
}
