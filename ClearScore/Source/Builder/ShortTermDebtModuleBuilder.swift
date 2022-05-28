import UIKit

struct ShortTermCreditInfoModuleBuilder: ModuleBuilderProtocol {

    func build(environment: Environment) throws -> UIViewController {
        return InfoViewController(
            viewModelPublisher: environment.scoreModel.scorePublisher
                .map { model in
                    InfoViewController.ViewModel(
                        title: NSLocalizedString("short-term-credit-title", comment: "Short term credit"),
                        creditUtilization: InfoViewController.ViewModel.Guage(
                            ratio: Float(model.shortTermCredit.usage.unity()),
                            value: model.shortTermCredit.usage.formatted(),
                            caption: NSLocalizedString("short-term-credit-utilization", comment: "Short term credit utilization")
                        ),
                        debt: InfoViewController.ViewModel.Item(
                            caption: NSLocalizedString("short-term-debt", comment: "Short term debt"),
                            value: model.shortTermCredit.debt.formatted()
                        ),
                        creditLimit: InfoViewController.ViewModel.Item(
                            caption: NSLocalizedString("short-term-credit-limit", comment: "Short term credit limit"),
                            value: model.shortTermCredit.limit.formatted()
                        ),
                        debtChange: InfoViewController.ViewModel.Item(
                            caption: NSLocalizedString("short-term-debt-change", comment: "Short term credit limit"),
                            value:  model.shortTermCredit.change.formatted()
                        )
                    )
                }
                .eraseToAnyPublisher()
        )
    }
}
