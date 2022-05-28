import UIKit

struct ReportModuleBuilder: ModuleBuilderProtocol {
    
    let modules: [ModuleBuilderProtocol]

    func build(environment: Environment) throws -> UIViewController {
        let viewControllers = try modules.map { module in
            try module.build(environment: environment)
        }
        return ReportViewController(viewControllers: viewControllers)
    }
}
