import UIKit
import Combine

struct ReportModuleBuilder: ModuleBuilderProtocol {
    
    let modules: [ModuleBuilderProtocol]

    func build(environment: Environment) throws -> UIViewController {
        let viewControllers = try modules.map { module in
            try module.build(environment: environment)
        }
        return ReportViewController(
            viewControllers: viewControllers,
            refreshPublisher: Publishers
                .Merge(
                    environment.scoreModel.scorePublisher.map { _ in () },
                    environment.scoreModel.errorPublisher.map { _ in () }
                )
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .eraseToAnyPublisher(),
            refreshHandler: environment.scoreModel.update
        )
    }
}
