import UIKit

struct ApplicationModuleBuilder: ModuleBuilderProtocol {
    
    let content: ModuleBuilderProtocol
    
    func build(environment: Environment) throws -> UIViewController {
        let contentViewController = try content.build(environment: environment)
        let toastViewController = try ToastModuleBuilder().build(environment: environment)
        toastViewController.willMove(toParent: contentViewController)
        contentViewController.addChild(toastViewController)
        contentViewController.view.addSubview(toastViewController.view)
        toastViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastViewController.view.leftAnchor.constraint(
                equalTo: contentViewController.view.leftAnchor
            ),
            toastViewController.view.rightAnchor.constraint(
                equalTo: contentViewController.view.rightAnchor
            ),
            toastViewController.view.topAnchor.constraint(
                equalTo: contentViewController.view.topAnchor
            ),
            toastViewController.view.bottomAnchor.constraint(
                equalTo: contentViewController.view.bottomAnchor
            )
        ])
        toastViewController.didMove(toParent: contentViewController)
        return contentViewController
    }
}
