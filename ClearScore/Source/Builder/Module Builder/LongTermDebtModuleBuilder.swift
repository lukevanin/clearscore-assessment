import UIKit

///
/// Creates an info card displaying long term credit information for the user.
///
struct LongTermCreditInfoModuleBuilder: ModuleBuilderProtocol {
    
    ///
    /// Transforms `ScoreInfo` from the score model into a  view model for displaying long term credit info in a `InfoViewController`.
    ///
    struct ModelTransformer: Transformer {
        func transform(input model: ScoreModel.ScoreInfo) -> InfoViewController.ViewModel {
            InfoViewController.ViewModel(
                title: NSLocalizedString("long-term-credit-title", comment: "Long term credit"),
                creditUtilization: InfoViewController.ViewModel.Guage(
                    ratio: CGFloat(model.longTermCredit.usage?.unity() ?? 0),
                    value: model.longTermCredit.usage?.formatted() ?? "--",
                    caption: NSLocalizedString("long-term-credit-utilization", comment: "Long term credit utilization")
                ),
                debt: InfoViewController.ViewModel.Item(
                    caption: NSLocalizedString("long-term-debt", comment: "Long term debt"),
                    value: model.longTermCredit.debt?.formatted(denomination: 100) ?? "--"
                ),
                creditLimit: InfoViewController.ViewModel.Item(
                    caption: NSLocalizedString("long-term-credit-limit", comment: "Long term credit limit"),
                    value: model.longTermCredit.limit?.formatted(denomination: 100) ?? "--"
                ),
                debtChange: InfoViewController.ViewModel.Item(
                    caption: NSLocalizedString("long-term-debt-change", comment: "Long term credit limit"),
                    value: model.longTermCredit.change?.formatted(denomination: 100) ?? "--"
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
