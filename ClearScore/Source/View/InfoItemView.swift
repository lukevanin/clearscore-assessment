import UIKit

///
/// Displays a caption / label in a horizontal format. Used by the `InfoViewController` component.
///
final class InfoItemView: UIView {
    
    var caption: String? {
        get {
            captionLabel.text
        }
        set {
            captionLabel.text = newValue
        }
    }
    
    var content: String? {
        get {
            contentLabel.text
        }
        set {
            contentLabel.text = newValue
        }
    }

    private let captionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .caption1)
        view.textColor = .label
        view.textAlignment = .left
        return view
    }()

    private let contentLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 15, weight: .bold)
        view.textColor = .label
        view.textAlignment = .right
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeLayout()
    }
    
    private func initializeLayout() {
        let layoutView: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            view.spacing = 16
            view.alignment = .center
            view.distribution = .equalSpacing
            view.addArrangedSubview(captionLabel)
            view.addArrangedSubview(contentLabel)
            return view
        }()
        addSubview(layoutView)
        NSLayoutConstraint.activate([
            layoutView.leftAnchor.constraint(
                equalTo: leftAnchor
            ),
            layoutView.rightAnchor.constraint(
                equalTo: rightAnchor
            ),
            layoutView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            layoutView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])
    }
}
