import UIKit
import Combine

///
/// Creates the loading screen view.
///
struct LoadingModuleBuilder: ModuleBuilderProtocol {
    
    let module: ModuleBuilderProtocol
    
    func build(environment: Environment) throws -> UIViewController {
        defer {
            // Start loading the latest score data when returning the module.
            environment.scoreModel.update()
        }
        // Publish the `loaded` state when the `scoreInfo` is emitted.
        let scoreViewState = environment.scoreModel.scorePublisher.map { scoreInfo in
            LoadingViewController.ViewState.loaded
        }
        // Publish the `error` state when an `error` is emitted.
        let errorViewState = environment.scoreModel.errorPublisher.map { error in
            LoadingViewController.ViewState.failed(error)
        }
        // Merge the score and error publishers into a single publisher that publishes the loaded state.
        let viewState = Publishers.Merge(scoreViewState, errorViewState)
        return LoadingViewController(
            loadingPublisher: viewState
                // Debounce forces the loading screen to wait a minimum amount of time before completing, even if the
                // result is received before that time. This prevents the loading screen from flickering if loading
                // happens too quickly.
                .debounce(for: 2, scheduler: RunLoop.main)
                .eraseToAnyPublisher(),
            errorHandler: { error in
                let message = UserMessage(
                    message: error.localizedDescription,
                    action: UserMessage.Action(
                        title: "Retry",
                        block: environment.scoreModel.update
                    )
                )
                environment.userMessageSubject.send(message)
                environment.scoreModel.update()
            },
            contentBuilder: {
                try module.build(environment: environment)
            }
        )
    }
}
