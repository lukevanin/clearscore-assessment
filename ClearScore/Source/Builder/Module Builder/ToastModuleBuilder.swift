import UIKit

struct ToastModuleBuilder: ModuleBuilderProtocol {
    func build(environment: Environment) throws -> UIViewController {
        let viewController = ToastViewController()
        viewController.viewModelPublisher = environment.userMessageSubject.eraseToAnyPublisher()
        return viewController
    }
}
