import UIKit

final class ViewCatalogController: UIViewController {
    private lazy var stack: ScrollableStack = {
        let stack = ScrollableStack(.vertical)
        stack.stackView.spacing = 20

        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        stack.addArrangedSubview(.vSpacer(10))
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColorThemed = Palette.shared.backgroundColor0

        placePaletteSwitcher()
        placeRestaurantHeaderView()

        stack.addArrangedSubview(.vSpacer(growable: 0))
    }

    private func placeRestaurantHeaderView() {
        stack.addArrangedSubview(makeStackEntry {
            let headerView = RestaurantHeaderView()
            headerView.title = "RestaurantHeaderView"
            headerView.distance = "100 м"
            headerView.address = "ул Ленина, дом 1"
            headerView.imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/DowneyMcdonalds.jpg/2560px-DowneyMcdonalds.jpg")
            headerView.price = "$100"

            headerView.rating = 3
            headerView.ratingText = "Текст рейтинга"

            headerView.isRatingHidden = false
            headerView.snp.makeConstraints { make in
                make.height.equalTo(132)
            }
            return headerView
        })
    }

    private func placePaletteSwitcher() {
        var paletteIndex = 1

        let label = UILabel()
        label.textColorThemed = Palette.shared.textPrimary
        label.text = "Switch palette"
        label.isUserInteractionEnabled = true
        label.onTap = {
            let filenameSuffix = paletteIndex == 0 ? "" : "\(paletteIndex)"
            let paletteName = "Palette" + filenameSuffix

            paletteIndex += 1

            if paletteIndex > 1 {
                paletteIndex = 0
            }
            
            Palette.shared.updateFrom(file: paletteName, ofType: ".json")
        }


        stack.addArrangedSubview(
            UIStackView.horizontal(.hSpacer(20), label)
        )
    }

    private func makeStackEntry<T: UIView>(
        title: String? = nil,
        inset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
        viewBuilder: () -> T
    ) -> UIView {
        let view = viewBuilder()

        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColorThemed = Palette.shared.textPrimary
        titleLabel.font = UIFont.wrfFont(ofSize: 22, weight: .bold)
        titleLabel.text = title ?? "\(type(of: view))"

        let container = UIView()
        container.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(inset.top)
            make.bottom.equalToSuperview().inset(inset.bottom)
            make.width.lessThanOrEqualToSuperview().inset(inset.left + inset.right)
            make.center.equalToSuperview()
        }

        let stack = UIStackView.vertical(
            UIStackView.horizontal(.hSpacer(10), titleLabel, .hSpacer(10)),
            .vSpacer(10),
            container
        )

        return stack
    }
}
