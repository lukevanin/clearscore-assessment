import UIKit
import Combine


final class ToastViewController: AbstractViewModelViewController<UserMessage> {

    private class ToastViewState {
        unowned var context: ToastViewController!
        func enter() { }
        func showNextToast() { }
    }

    private final class HiddenToastViewState: ToastViewState {
        override func showNextToast() {
            guard context.queue.count > 0 else {
                return
            }
            let toast = context.queue.removeFirst()
            context.setViewState(ShowingToastViewState(toast: toast))
        }
    }

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
        
        cardVisibleConstraint = cardView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -32
        )
        cardHiddenConstraint = cardView.topAnchor.constraint(
            equalTo: view.bottomAnchor
        )

        NSLayoutConstraint.activate([
            cardView.leftAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leftAnchor,
                constant: 32
            ),
            cardView.rightAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.rightAnchor,
                constant: -32
            ),
            cardHiddenConstraint,
            
            messageLabel.leftAnchor.constraint(
                equalTo: cardView.leftAnchor,
                constant: 32
            ),
            messageLabel.rightAnchor.constraint(
                equalTo: cardView.rightAnchor,
                constant: -32
            ),
            messageLabel.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 32
            ),
            messageLabel.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -32
            ),
        ])
        
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
