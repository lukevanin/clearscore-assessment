import UIKit
import Combine

final class ReportViewController: UIViewController {
    
    enum AccessibilityIdentifiers: String {
        case scrollIndicatorUp = "report-scroll-indicator-up"
        case scrollIndicatorDown = "report-scroll-indicator-down"
        case scrollView = "report-scrollview"
    }
    
    typealias RefreshHandler = () -> Void
    
    private let backgroundView: VideoView = {
        let view = VideoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.videoGravity = .resizeAspectFill
        view.rate = 1.0
        view.url = Bundle.main.url(forResource: "background-1", withExtension: "mov")
        return view
    }()
    
    private let backgroundBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let upIconImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "chevron.up"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = AccessibilityIdentifiers.scrollIndicatorUp.rawValue
        return view
    }()
    
    private let downIconImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "chevron.down"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = AccessibilityIdentifiers.scrollIndicatorDown.rawValue
        return view
    }()
    
    private let refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.tintColor = .white
        return view
    }()

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isPagingEnabled = true
        view.clipsToBounds = false
        view.accessibilityIdentifier = AccessibilityIdentifiers.scrollView.rawValue
        return view
    }()
    
    private let layoutView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()
    
    private var refreshCancellable: AnyCancellable?
    
    private let viewControllers: [UIViewController]
    private let refreshPublisher: AnyPublisher<Void, Never>
    private let refreshHandler: RefreshHandler
    
    init(
        viewControllers: [UIViewController],
        refreshPublisher: AnyPublisher<Void, Never>,
        refreshHandler: @escaping RefreshHandler
    ) {
        self.viewControllers = viewControllers
        self.refreshPublisher = refreshPublisher
        self.refreshHandler = refreshHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        view.tintColor = .white
        view.autoresizesSubviews = true
        view.addSubview(backgroundView)
        view.addSubview(backgroundBlurView)
        view.addSubview(upIconImageView)
        view.addSubview(downIconImageView)
        backgroundBlurView.contentView.addSubview(scrollView)
        scrollView.addSubview(layoutView)
        scrollView.delegate = self
        scrollView.refreshControl = refreshControl
        
        constraints {
            backgroundView.leftAnchor == view.leftAnchor
            backgroundView.rightAnchor == view.rightAnchor
            backgroundView.topAnchor == view.topAnchor
            backgroundView.bottomAnchor == view.bottomAnchor

            backgroundBlurView.leftAnchor == backgroundView.leftAnchor
            backgroundBlurView.rightAnchor == backgroundView.rightAnchor
            backgroundBlurView.topAnchor == backgroundView.topAnchor
            backgroundBlurView.bottomAnchor == backgroundView.bottomAnchor

            scrollView.leftAnchor == view.leftAnchor
            scrollView.rightAnchor == view.rightAnchor
            scrollView.topAnchor == view.safeAreaLayoutGuide.topAnchor
            scrollView.bottomAnchor == view.safeAreaLayoutGuide.bottomAnchor

            layoutView.widthAnchor == view.widthAnchor
            layoutView.leftAnchor == scrollView.leftAnchor
            layoutView.rightAnchor == scrollView.rightAnchor
            layoutView.topAnchor == scrollView.topAnchor
            layoutView.bottomAnchor == scrollView.bottomAnchor

            upIconImageView.widthAnchor == 40
            upIconImageView.centerXAnchor == view.safeAreaLayoutGuide.centerXAnchor
            (upIconImageView.topAnchor == view.safeAreaLayoutGuide.topAnchor) + 16

            downIconImageView.widthAnchor == 40
            downIconImageView.centerXAnchor == view.safeAreaLayoutGuide.centerXAnchor
            (downIconImageView.bottomAnchor == view.safeAreaLayoutGuide.bottomAnchor) - 16
        }
        
        viewControllers.forEach { viewController in
            viewController.willMove(toParent: self)
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            layoutView.addArrangedSubview(viewController.view)
            NSLayoutConstraint.activate([
                viewController.view.heightAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.heightAnchor
                ),
            ])
            addChild(viewController)
            viewController.didMove(toParent: self)
        }
        
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setArrowsVisible(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cancelRefresh()
        connectRefreshPublisher()
        setArrowsVisible(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelRefresh()
        disconnectRefreshPublisher()
    }
    
    @objc func onRefresh(sender: UIRefreshControl) {
        refreshHandler()
    }
    
    private func cancelRefresh() {
        refreshControl.endRefreshing()
    }
    
    private func connectRefreshPublisher() {
        refreshCancellable = refreshPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.cancelRefresh()
            }
    }
    
    private func disconnectRefreshPublisher() {
        refreshCancellable?.cancel()
        refreshCancellable = nil
    }

    private func setArrowsVisible(_ visible: Bool, animated: Bool) {
        let upArrowVisible: Bool
        let downArrowVisible: Bool
        if visible {
            let minimumOffset = CGFloat(0)
            let maximumOffset = scrollView.contentSize.height - scrollView.bounds.height
            let currentOffset = scrollView.contentOffset.y
            upArrowVisible = currentOffset > minimumOffset
            downArrowVisible = currentOffset < maximumOffset
        }
        else {
            upArrowVisible = false
            downArrowVisible = false
        }
        let upArrowAlpha: CGFloat = upArrowVisible ? 1 : 0
        let downArrowAlpha: CGFloat = downArrowVisible ? 1 : 0
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.upIconImageView.alpha = upArrowAlpha
                self.downIconImageView.alpha = downArrowAlpha
            }
        }
        else {
            upIconImageView.alpha = upArrowAlpha
            downIconImageView.alpha = downArrowAlpha
        }
    }
}

extension ReportViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setArrowsVisible(false, animated: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setArrowsVisible(true, animated: true)
    }
}
