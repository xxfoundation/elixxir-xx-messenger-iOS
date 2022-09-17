import UIKit
import Shared
import SnapKit

enum DrawerTableSection {
    case main
}

public final class DrawerTable: DrawerItem {
    private let view = UIView()
    private let tableView = UITableView()
    private var heightConstraint: Constraint?
    private let dataSource: UITableViewDiffableDataSource<DrawerTableSection, DrawerTableCellModel>

    public var spacingAfter: CGFloat? = 0

    public init(spacingAfter: CGFloat? = 10) {
        self.dataSource = .init(
            tableView: tableView,
            cellProvider: { tableView, indexPath, model in
                let cell: DrawerTableCell = tableView.dequeueReusableCell(forIndexPath: indexPath)

                cell.titleLabel.text = model.title
                cell.avatarView.setupProfile(
                    title: model.title,
                    image: model.image,
                    size: .medium
                )

                if model.isCreator {
                    cell.subtitleLabel.text = "Creator"
                    cell.subtitleLabel.isHidden = false
                    cell.subtitleLabel.textColor = Asset.accentSafe.color
                } else if !model.isConnection {
                    cell.subtitleLabel.text = "Not a connection"
                    cell.subtitleLabel.isHidden = false
                    cell.subtitleLabel.textColor = Asset.neutralSecondaryAlternative.color
                } else {
                    cell.subtitleLabel.isHidden = true
                }

                return cell
            })

        self.spacingAfter = spacingAfter
    }

    public func makeView() -> UIView {
        tableView.register(DrawerTableCell.self)
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white

        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            heightConstraint = $0.height.equalTo(1).priority(.low).constraint
        }

        return view
    }

    public func update(models: [DrawerTableCellModel]) {
        let cellHeight = 56
        self.heightConstraint?.update(offset: cellHeight * models.count)

        var snapshot = NSDiffableDataSourceSnapshot<DrawerTableSection, DrawerTableCellModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false) { [self] in
            tableView.isScrollEnabled = tableView.contentSize.height > tableView.frame.height
        }
    }
}

public struct DrawerTableCellModel: Hashable {
    let id: Data
    let title: String
    let image: Data?
    let isCreator: Bool
    let isConnection: Bool

    public init(
        id: Data,
        title: String,
        image: Data? = nil,
        isCreator: Bool = false,
        isConnection: Bool = true
    ) {
        self.id = id
        self.title = title
        self.image = image
        self.isCreator = isCreator
        self.isConnection = isConnection
    }
}

final class DrawerTableCell: UITableViewCell {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let avatarView = AvatarView()
    let stackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = Asset.neutralWhite.color

        titleLabel.font = Fonts.Mulish.semiBold.font(size: 16.0)
        subtitleLabel.font = Fonts.Mulish.regular.font(size: 14.0)
        titleLabel.textColor = Asset.neutralActive.color

        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        contentView.addSubview(avatarView)
        contentView.addSubview(stackView)

        avatarView.snp.makeConstraints {
            $0.width.equalTo(36)
            $0.height.equalTo(36)
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
        }

        stackView.snp.makeConstraints {
            $0.left.equalTo(avatarView.snp.right).offset(15)
            $0.top.equalTo(avatarView)
            $0.bottom.equalTo(avatarView)
            $0.right.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        subtitleLabel.text = nil
        avatarView.prepareForReuse()
    }
}
