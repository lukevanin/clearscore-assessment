import UIKit
import Combine

protocol LoadingCoordinatorProtocol {
    func showContent()
    func showError(error: Error)
}

final class LoadingViewController: UIViewController {
    
    typealias ContentBuilder = () throws -> UIViewController
    
    enum ViewState {
        case loaded
        case failed(Error)
    }
    
    override var prefersStatusBarHidden: Bool {
        if contentViewController == nil {
            return true
        }
        else {
            return false
        }
    }
    
    private let backgroundView: VideoView = {
        let view = VideoView()
        view.videoGravity = .resizeAspectFill
        view.rate = 1.0
        view.url = Bundle.main.url(forResource: "background-0", withExtension: "mp4")
        return view
    }()

    private var contentViewController: UIViewController?
    private var loadingCancellable: AnyCancellable?
    
    private let loadingPublisher: AnyPublisher<ViewState, Never>
    private let contentBuilder: ContentBuilder
    
    init(loadingPublisher: AnyPublisher<ViewState, Never>, contentBuilder: @escaping ContentBuilder) {
        self.loadingPublisher = loadingPublisher
        self.contentBuilder = contentBuilder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.autoresizesSubviews = true
        view.addSubview(backgroundView)
        backgroundView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        connectLoadingPublisher()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disconnectLoadingPublisher()
    }
    
    private func connectLoadingPublisher() {
        loadingCancellable = loadingPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] viewState in
                guard let self = self else {
                    return
                }
                self.handleViewState(viewState)
            }
    }
    
    private func disconnectLoadingPublisher() {
        loadingCancellable?.cancel()
        loadingCancellable = nil
    }
    
    private func handleViewState(_ viewState: ViewState) {
        disconnectLoadingPublisher()
        switch viewState {
        
        case .loaded:
            showContent()
            
        case .failed(let error):
            showError(error: error)
        }
    }
    
    private func showContent() {
        let viewController: UIViewController
        do {
            viewController = try contentBuilder()
        }
        catch {
            showError(error: error)
            return
        }
        viewController.willMove(toParent: self)
        addChild(viewController)
        UIView.transition(
            from: backgroundView,
            to: viewController.view,
            duration: 1.0,
            options: [.transitionFlipFromLeft],
            completion: { _ in
                viewController.didMove(toParent: self)
                self.contentViewController = viewController
                self.setNeedsStatusBarAppearanceUpdate()
            }
        )
    }
    
    private func showError(error: Error) {
        // TODO: Show error notification
    }
}
