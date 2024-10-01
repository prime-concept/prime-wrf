import SnapKit
import Tabman
import UIKit

extension CertificatesTabbedView {
    struct Appearance {
        let tabBarWeight: CGFloat = 1
        let tabBarTintColor = Palette.shared.strokeStrong
        let tabBarHeight: CGFloat = 44
        let tabBarColor = Palette.shared.backgroundColor0

		let separatorHeight: CGFloat = 1
		let separatorColor = Palette.shared.strokeSecondary
    }
}

final class CertificatesTabbedView: UIView {
	let appearance: Appearance = ApplicationAppearance.appearance()

    private(set) lazy var tabContainerView: UIView = {
        let view = UIView()
        view.backgroundColorThemed = self.appearance.tabBarColor
        return view
    }()

    init() {
		super.init(frame: .zero)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API

    func makeTabBar() -> TMBar.WRFBar {
        let bar = TMBar.WRFBar()
        bar.layout.contentMode = .fit
        bar.layout.transitionStyle = .none
        bar.backgroundView.style = .clear
        bar.indicator.weight = .custom(value: self.appearance.tabBarWeight)
        bar.indicator.tintColorThemed = self.appearance.tabBarTintColor
        return bar
    }

	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		self.tabContainerView.frame.contains(point)
	}
}

extension CertificatesTabbedView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.tabContainerView)
    }

    func makeConstraints() {
        self.tabContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.tabContainerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top
                    .equalTo(self.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.tabBarHeight)
        }

		let separatorView = UIView {
			$0.backgroundColorThemed = self.appearance.separatorColor
			$0.make(.height, .equal, self.appearance.separatorHeight)
		}

		self.tabContainerView.addSubview(separatorView)
		self.tabContainerView.sendSubviewToBack(separatorView)
		separatorView.make(.hEdges, .equalToSuperview)
		separatorView.make(.bottom, .equal, to: self.tabContainerView)
    }
}
