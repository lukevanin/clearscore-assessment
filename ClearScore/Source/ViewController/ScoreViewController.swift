import UIKit
import OSLog
import Combine


private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "score-viewcontroller")


final class ScoreViewController: UIViewController {
    
    struct ViewModel {
        let prompt: String
        let label: String
        let caption: String
        let value: CGFloat
    }
        
    private let scoreTrackView: ArcView = {
        let view = ArcView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .white.withAlphaComponent(0.33)
        view.thickness = 8
        view.gap = .tau * 0.1
        view.value = 1
        return view
    }()
    
    private let scoreIndicatorView: ArcView = {
        let view = ArcView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .systemCyan
        view.thickness = 8
        view.gap = .tau * 0.1
        view.layer.shadowColor = UIColor.systemCyan.cgColor
        view.layer.shadowOpacity = 0.70
        view.layer.shadowRadius = 3
        view.layer.shadowOffset = .zero
        return view
    }()

    private let scoreLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 80, weight: .thin)
        view.textColor = .white
        view.alpha = 0
        return view
    }()
    
    private let scorePromptLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .secondaryLabel
        view.alpha = 0
        return view
    }()
    
    private let scoreCaptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .secondaryLabel
        view.alpha = 0
        return view
    }()

    private let viewModelPublisher: AnyPublisher<ViewModel, Never>
    private var viewModelCancellable: AnyCancellable?
    
    init(viewModelPublisher: AnyPublisher<ViewModel, Never>) {
        self.viewModelPublisher = viewModelPublisher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cardView: CardView = {
            let view = CardView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.contentView.addSubview(scoreTrackView)
            view.contentView.addSubview(scoreLabel)
            view.contentView.addSubview(scorePromptLabel)
            view.contentView.addSubview(scoreCaptionLabel)
            return view
        }()
        
        view.addSubview(cardView)
        view.addSubview(scoreIndicatorView)

        constraints {
            (cardView.leftAnchor == view.safeAreaLayoutGuide.leftAnchor) + 32
            (cardView.rightAnchor == view.safeAreaLayoutGuide.rightAnchor) - 32
            (cardView.centerYAnchor == view.safeAreaLayoutGuide.centerYAnchor)
            (cardView.heightAnchor == cardView.widthAnchor)  * 1.3

            scoreTrackView.centerXAnchor == cardView.centerXAnchor
            scoreTrackView.centerYAnchor == cardView.centerYAnchor
            scoreTrackView.widthAnchor == 250
            scoreTrackView.heightAnchor == scoreIndicatorView.widthAnchor

            scoreIndicatorView.centerXAnchor == scoreTrackView.centerXAnchor
            scoreIndicatorView.centerYAnchor == scoreTrackView.centerYAnchor
            scoreIndicatorView.widthAnchor == scoreTrackView.widthAnchor
            scoreIndicatorView.heightAnchor == scoreTrackView.heightAnchor

            scoreLabel.centerXAnchor == cardView.centerXAnchor
            scoreLabel.centerYAnchor == cardView.centerYAnchor
            
            scorePromptLabel.centerXAnchor == scoreLabel.centerXAnchor
            (scorePromptLabel.bottomAnchor == scoreLabel.topAnchor) - 4
            
            scoreCaptionLabel.centerXAnchor == scoreLabel.centerXAnchor
            (scoreCaptionLabel.topAnchor == scoreLabel.bottomAnchor) + 4
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.debug("view did appear")
        connectScoreModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logger.debug("view will disappear")
        disconnectScoreModel()
    }
    
    // MARK: Score Model
    
    private func connectScoreModel() {
        viewModelCancellable = viewModelPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] viewModel in
                self?.handleViewModel(viewModel)
            }
    }
    
    private func disconnectScoreModel() {
        viewModelCancellable?.cancel()
        viewModelCancellable = nil
    }
    
    private func handleViewModel(_ viewModel: ViewModel) {
        logger.debug("score: \(String(describing: viewModel))")
        scorePromptLabel.text = viewModel.prompt
        scoreLabel.text = viewModel.label
        scoreCaptionLabel.text = viewModel.caption
        view.layoutIfNeeded()

        UIView.animate(withDuration: 2.0) {
            self.scoreIndicatorView.value = CGFloat(viewModel.value)
        }
        
        UIView.animate(
            withDuration: 1.0,
            delay: 0.5,
            options: [],
            animations: {
                self.scoreLabel.alpha = 1
                self.scoreCaptionLabel.alpha = 1
                self.scorePromptLabel.alpha = 1
            },
            completion: nil
        )
    }
}
