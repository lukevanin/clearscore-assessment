import UIKit
import Combine

struct LoadingModuleBuilder: ModuleBuilderProtocol {
    
    let module: ModuleBuilderProtocol
    
    func build(environment: Environment) throws -> UIViewController {
        defer {
            environment.scoreModel.update()
        }
        let scoreViewState = environment.scoreModel.scorePublisher.map { scoreInfo in
            LoadingViewController.ViewState.loaded
        }
        let errorViewState = environment.scoreModel.errorPublisher.map { error in
            LoadingViewController.ViewState.failed(error)
        }
        let viewState = Publishers.Merge(scoreViewState, errorViewState)
        return LoadingViewController(
            loadingPublisher: viewState
                .debounce(for: 2, scheduler: RunLoop.main)
                .eraseToAnyPublisher(),
            contentBuilder: {
                try module.build(environment: environment)
            }
        )
    }
}
