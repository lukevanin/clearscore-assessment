import UIKit

///
/// Creates an info card displaying long term credit information for the user.
///
struct LongTermCreditInfoModuleBuilder: ModuleBuilderProtocol {

    func build(environment: Environment) throws -> UIViewController {
        return InfoViewController(
            viewModelPublisher: environment.scoreModel.scorePublisher
                .map { model in
                    // Convert the score info into the view model with long term credit score 
                    InfoViewController.ViewModel(
                        title: NSLocalizedString("long-term-credit-title", comment: "Long term credit"),
                        creditUtilization: InfoViewController.ViewModel.Guage(
                            ratio: CGFloat(model.longTermCredit.usage?.unity() ?? 0),
                            value: model.longTermCredit.usage?.formatted() ?? "--",
                            caption: NSLocalizedString("long-term-credit-utilization", comment: "Long term credit utilization")
                        ),
                        debt: InfoViewController.ViewModel.Item(
                            caption: NSLocalizedString("long-term-debt", comment: "Long term debt"),
                            value: model.longTermCredit.debt?.formatted() ?? "--"
                        ),
                        creditLimit: InfoViewController.ViewModel.Item(
                            caption: NSLocalizedString("long-term-credit-limit", comment: "Long term credit limit"),
                            value: model.longTermCredit.limit?.formatted() ?? "--"
                        ),
                        debtChange: InfoViewController.ViewModel.Item(
                            caption: NSLocalizedString("long-term-debt-change", comment: "Long term credit limit"),
                            value: model.longTermCredit.change?.formatted() ?? "--"
                        )
                    )
                }
                .eraseToAnyPublisher()
        )
    }
}
