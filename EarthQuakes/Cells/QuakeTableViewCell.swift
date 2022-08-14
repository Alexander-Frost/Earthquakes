import UIKit

final class QuakeTableViewCell: UITableViewCell {
    static let reuseId = "QuakeTableViewCell"
    static let cellHeight: CGFloat = 80

    // MARK: - Outlets
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            subtitleLabelTwo
        ])
        stackView.spacing = 6
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let subtitleLabelTwo: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        subtitleLabelTwo.text = nil
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 2)
        ])
    }
    
    // MARK: - Load Data
    
    public func loadData(title: String?, subtitle: String?, subtitleTwo: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabelTwo.text = subtitleTwo
    }
    
}
