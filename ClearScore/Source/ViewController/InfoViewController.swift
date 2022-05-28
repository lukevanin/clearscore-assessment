import UIKit
import OSLog
import Combine


private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "info-viewcontroller")


final class InfoViewController: UIViewController {

    struct ViewModel {
        
        struct Item {
            let caption: String
            let value: String
        }
        
        struct Guage {
            let ratio: CGFloat
            let value: String
            let caption: String
        }
        
        let title: String
        let creditUtilization: Guage
        let debt: Item
        let creditLimit: Item
        let debtChange: Item
    }
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .largeTitle)
        view.textColor = .white
        view.textAlignment = .center
        view.numberOfLines = 2
        return view
    }()
    
    private let guageTrackView: ArcView = {
        let view = ArcView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .white.withAlphaComponent(0.33)
        view.thickness = 8
        view.gap = .tau * 0.5
        view.value = 1
        return view
    }()

    private let guageIndicatorView: ArcView = {
        let view = ArcView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .systemCyan
        view.thickness = 8
        view.gap = .tau * 0.5
        view.layer.shadowColor = UIColor.systemCyan.cgColor
        view.layer.shadowOpacity = 0.70
        view.layer.shadowRadius = 3
        view.layer.shadowOffset = .zero
        return view
    }()
    
    private let guageValueLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .title1)
        view.textColor = .white
        view.textAlignment = .center
        return view
    }()
    
    private let guageCaptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .caption1)
        view.textColor = .white
        view.textAlignment = .center
        return view
    }()

    private let debtItemView: InfoItemView = {
        let view = InfoItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let debtChangeItemView: InfoItemView = {
        let view = InfoItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let creditLimitItemView: InfoItemView = {
        let view = InfoItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
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

        let blurEffect = UIBlurEffect(style: .systemThinMaterial)

        let blurView: UIVisualEffectView = {
            let view = UIVisualEffectView(effect: blurEffect)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 16
            view.layer.masksToBounds = true
            view.contentView.autoresizesSubviews = true
            return view
        }()

        let vibrancyView: UIVisualEffectView = {
            let effect = UIVibrancyEffect(blurEffect: blurEffect, style: .fill)
            let view = UIVisualEffectView(effect: effect)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.contentView.autoresizesSubviews = true
            return view
        }()
        
        let layoutView: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .vertical
            view.spacing = 32
            view.alignment = .fill
            view.addArrangedSubview(debtItemView)
            view.addArrangedSubview(creditLimitItemView)
            view.addArrangedSubview(debtChangeItemView)
            return view
        }()
        
        view.addSubview(blurView)
        blurView.contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(titleLabel)
        vibrancyView.contentView.addSubview(guageTrackView)
        vibrancyView.contentView.addSubview(guageValueLabel)
        vibrancyView.contentView.addSubview(guageCaptionLabel)
        vibrancyView.contentView.addSubview(layoutView)
        view.addSubview(guageIndicatorView)
        
        NSLayoutConstraint.activate([
            
            blurView.leftAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leftAnchor,
                constant: +32
            ),
            blurView.rightAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.rightAnchor,
                constant: -32
            ),
            blurView.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor
            ),
            
            titleLabel.leftAnchor.constraint(
                equalTo: blurView.leftAnchor,
                constant: 32
            ),
            titleLabel.rightAnchor.constraint(
                equalTo: blurView.rightAnchor,
                constant: -32
            ),
            titleLabel.topAnchor.constraint(
                equalTo: blurView.topAnchor,
                constant: 32
            ),

            guageTrackView.widthAnchor.constraint(
                equalToConstant: 200
            ),
            guageTrackView.heightAnchor.constraint(
                equalTo: guageTrackView.widthAnchor
            ),
            guageTrackView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 32
            ),
            guageTrackView.centerXAnchor.constraint(
                equalTo: blurView.centerXAnchor
            ),

            guageIndicatorView.leftAnchor.constraint(
                equalTo: guageTrackView.leftAnchor
            ),
            guageIndicatorView.rightAnchor.constraint(
                equalTo: guageTrackView.rightAnchor
            ),
            guageIndicatorView.topAnchor.constraint(
                equalTo: guageTrackView.topAnchor
            ),
            guageIndicatorView.bottomAnchor.constraint(
                equalTo: guageTrackView.bottomAnchor
            ),
            
            guageValueLabel.centerXAnchor.constraint(
                equalTo: guageTrackView.centerXAnchor
            ),
            guageValueLabel.lastBaselineAnchor.constraint(
                equalTo: guageTrackView.centerYAnchor
            ),
            
            guageCaptionLabel.centerXAnchor.constraint(
                equalTo: guageValueLabel.centerXAnchor
            ),
            guageCaptionLabel.topAnchor.constraint(
                equalTo: guageValueLabel.bottomAnchor,
                constant: 4
            ),

            layoutView.leftAnchor.constraint(
                equalTo: blurView.leftAnchor,
                constant: 32
            ),
            layoutView.rightAnchor.constraint(
                equalTo: blurView.rightAnchor,
                constant: -32
            ),
            layoutView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 196
            ),
            layoutView.bottomAnchor.constraint(
                equalTo: blurView.bottomAnchor,
                constant: -32
            )

        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.debug("view did appear")
        connectViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logger.debug("view will disappear")
        disconnectViewModel()
    }
    
    // MARK: View Model
    
    private func connectViewModel() {
        viewModelCancellable = viewModelPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] viewModel in
                self?.handleViewModel(viewModel)
            }
    }
    
    private func disconnectViewModel() {
        viewModelCancellable?.cancel()
        viewModelCancellable = nil
    }
    
    private func handleViewModel(_ viewModel: ViewModel?) {
        guard let viewModel = viewModel else {
            return
        }
        titleLabel.text = viewModel.title
        debtItemView.caption = viewModel.debt.caption
        debtItemView.content = viewModel.debt.value
        debtChangeItemView.caption = viewModel.debtChange.caption
        debtChangeItemView.content = viewModel.debtChange.value
        creditLimitItemView.caption = viewModel.creditLimit.caption
        creditLimitItemView.content = viewModel.creditLimit.value
        guageIndicatorView.value = viewModel.creditUtilization.ratio
        guageValueLabel.text = viewModel.creditUtilization.value
        guageCaptionLabel.text = viewModel.creditUtilization.caption
    }
}
