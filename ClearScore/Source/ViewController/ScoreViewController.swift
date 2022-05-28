import UIKit
import OSLog
import Combine


private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "score-viewcontroller")


final class ScoreViewController: UIViewController {
        
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
        view.text = NSLocalizedString("credit-score-prompt", comment: "Your credit score is")
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

    private let scoreModel: ScoreModel
    private var scoreCancellable: AnyCancellable?
    
    init(scoreModel: ScoreModel) {
        self.scoreModel = scoreModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let blurEffect = UIBlurEffect(style: .systemThinMaterial)

        let containerView: UIVisualEffectView = {
            let view = UIVisualEffectView(effect: blurEffect)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 16
            view.layer.masksToBounds = true
            return view
        }()

        let contentView: UIVisualEffectView = {
            let effect = UIVibrancyEffect(blurEffect: blurEffect, style: .fill)
            let view = UIVisualEffectView(effect: effect)
            // view.translatesAutoresizingMaskIntoConstraints = false
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return view
        }()
        
        containerView.contentView.autoresizesSubviews = true
        contentView.frame = containerView.bounds
        
        view.addSubview(containerView)
        containerView.contentView.addSubview(contentView)
        contentView.contentView.addSubview(scoreTrackView)
        contentView.contentView.addSubview(scoreLabel)
        contentView.contentView.addSubview(scorePromptLabel)
        contentView.contentView.addSubview(scoreCaptionLabel)
        view.addSubview(scoreIndicatorView)

        NSLayoutConstraint.activate([
            
            containerView.leftAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leftAnchor,
                constant: +32
            ),
            containerView.rightAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.rightAnchor,
                constant: -32
            ),
            containerView.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor
            ),
            containerView.heightAnchor.constraint(
                equalTo: containerView.widthAnchor,
                multiplier: 1.3
            ),

            scoreTrackView.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor
            ),
            scoreTrackView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            scoreTrackView.widthAnchor.constraint(
                equalToConstant: 250
            ),
            scoreTrackView.heightAnchor.constraint(
                equalTo: scoreIndicatorView.widthAnchor
            ),

            scoreIndicatorView.centerXAnchor.constraint(
                equalTo: scoreTrackView.centerXAnchor
            ),
            scoreIndicatorView.centerYAnchor.constraint(
                equalTo: scoreTrackView.centerYAnchor
            ),
            scoreIndicatorView.widthAnchor.constraint(
                equalTo: scoreTrackView.widthAnchor
            ),
            scoreIndicatorView.heightAnchor.constraint(
                equalTo: scoreTrackView.heightAnchor
            ),

            scoreLabel.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor
            ),
            scoreLabel.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            
            scorePromptLabel.centerXAnchor.constraint(
                equalTo: scoreLabel.centerXAnchor
            ),
            scorePromptLabel.bottomAnchor.constraint(
                equalTo: scoreLabel.topAnchor,
                constant: -4
            ),
            
            scoreCaptionLabel.centerXAnchor.constraint(
                equalTo: scoreLabel.centerXAnchor
            ),
            scoreCaptionLabel.topAnchor.constraint(
                equalTo: scoreLabel.bottomAnchor,
                constant: 4
            ),

        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.debug("view did appear")
        connectScoreModel()
        updateScore()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logger.debug("view will disappear")
        disconnectScoreModel()
    }
    
    // MARK: Score Model
    
    private func updateScore() {
        logger.debug("update score")
        scoreModel.update()
    }
    
    private func connectScoreModel() {
        scoreCancellable = scoreModel.scorePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] scoreInfo in
                self?.handleScore(scoreInfo)
            }
    }
    
    private func disconnectScoreModel() {
        scoreCancellable?.cancel()
        scoreCancellable = nil
    }
    
    private func handleScore(_ scoreInfo: ScoreModel.ScoreInfo) {
        logger.debug("score: \(String(describing: scoreInfo))")
        scoreLabel.text = scoreInfo.score.value.formatted(.number)
        let creditScoreRangeFormat = NSLocalizedString("credit-score-range", comment: "Out of %@")
        scoreCaptionLabel.text = String(format: creditScoreRangeFormat, scoreInfo.score.range.upperBound.formatted(.number))
        view.layoutIfNeeded()
        
        let scoreLimit = scoreInfo.score.range.upperBound - scoreInfo.score.range.lowerBound
        let relativeScore = scoreInfo.score.value - scoreInfo.score.range.lowerBound
        let indicatorValue = CGFloat(relativeScore) / CGFloat(scoreLimit)
        
        UIView.animate(withDuration: 2.0) {
            self.scoreIndicatorView.value = indicatorValue
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
