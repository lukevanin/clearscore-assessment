import UIKit
import Combine

///
/// Displays a popup message or "toast" when a `UserMessage` is received from the provided publisher. The toast disappears again after a time.
///
///
final class ToastViewController: AbstractViewModelViewController<UserMessage> {

    ///
    /// Abstract state which all view states must inherit from.
    ///
    private class ToastViewState {
        unowned var context: ToastViewController!
        func enter() { }
        func showNextToast() { }
    }

    ///
    /// View state when the toast popup is not visible.
    ///
    private final class HiddenToastViewState: ToastViewState {
        ///
        /// Displays the next user message in the queue.
        ///
        override func showNextToast() {
            guard context.queue.count > 0 else {
                return
            }
            let toast = context.queue.removeFirst()
            context.setViewState(ShowingToastViewState(toast: toast))
        }
    }

    ///
    /// View state while the popup toast is being animated off-screen.
    ///
    private final class HidingToastViewState: ToastViewState {
        override func enter() {
            context.cardVisibleConstraint.isActive = false
            context.cardHiddenConstraint.isActive = true
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseIn],
                animations: {
                    self.context.view.layoutIfNeeded()
                    self.context.cardView.alpha = 0
                },
                completion: { [weak self] _ in
                    self?.context.setViewState(HiddenToastViewState())
                }
            )
        }
    }

    ///
    /// View state while the popup toast is being animated on-screen.
    ///
    private final class ShowingToastViewState: ToastViewState {
        private let toast: UserMessage
        
        init(toast: UserMessage) {
            self.toast = toast
        }
        
        override func enter() {
            context.messageLabel.text = toast.message
            context.cardHiddenConstraint.isActive = false
            context.cardVisibleConstraint.isActive = true
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseOut],
                animations: {
                    self.context.view.layoutIfNeeded()
                    self.context.cardView.alpha = 1
                },
                completion: { [weak self] _ in
                    self?.context.setViewState(VisibleToastViewState())
                }
            )
        }
    }

    ///
    /// View state when the popup toast is visible and not animating.
    ///
    private final class VisibleToastViewState: ToastViewState {
        
        override func enter() {
            // TODO: Make timeout configurable
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2.0) { [weak self] in
                guard let self = self else {
                    return
                }
                self.showNextToast()
            }
        }
        
        override func showNextToast() {
            context.setViewState(HidingToastViewState())
        }
    }

    private let messageLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .label
        view.numberOfLines = 0
        return view
    }()
    
    private let cardView: CardView = {
        let view = CardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private let passthroughView: PassthroughView = {
        let view = PassthroughView()
        return view
    }()
    
    private var cardVisibleConstraint: NSLayoutConstraint!
    private var cardHiddenConstraint: NSLayoutConstraint!
    private var currentViewState: ToastViewState?
    private var queue = [UserMessage]()
    
    override func loadView() {
        view = passthroughView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardView.contentView.addSubview(messageLabel)
        view.addSubview(cardView)
        
        cardVisibleConstraint = (cardView.bottomAnchor == view.safeAreaLayoutGuide.bottomAnchor) - 32
        cardHiddenConstraint = (cardView.topAnchor == view.bottomAnchor)

        constraints {
            (cardView.leftAnchor == view.safeAreaLayoutGuide.leftAnchor) + 32
            (cardView.rightAnchor == view.safeAreaLayoutGuide.rightAnchor) - 32
            cardHiddenConstraint!
            
            (messageLabel.leftAnchor == cardView.leftAnchor) + 32
            (messageLabel.rightAnchor == cardView.rightAnchor) - 32
            (messageLabel.topAnchor == cardView.topAnchor) + 32
            (messageLabel.bottomAnchor == cardView.bottomAnchor) - 32
        }
        
        setViewState(HiddenToastViewState())
    }
    
    private func setViewState(_ viewState: ToastViewState) {
        currentViewState = viewState
        currentViewState?.context = self
        currentViewState?.enter()
    }
    
    override func updateViewModel(_ viewModel: UserMessage) {
        queue.append(viewModel)
        currentViewState?.showNextToast()
    }
}
