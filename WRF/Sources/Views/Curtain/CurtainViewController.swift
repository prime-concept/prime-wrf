import UIKit

class CurtainViewController: UIViewController {
	let curtainView: CurtainView
	var curtainViewTopConstraint: NSLayoutConstraint?

	private lazy var backgroundView = UIView { view in
		view.onTap = {
			self.curtainView.scrollTo(ratio: 0)
		}
	}

    init(
        with contentView: UIView,
        backgroundColor: ThemedColor = Palette.shared.black.withAlphaComponent(0.7),
        curtainViewBackgroundColor: ThemedColor = Palette.shared.backgroundColor0
    ) {
		self.curtainView = CurtainView(
            appearance: CurtainView.Appearance(
                curtainColor: curtainViewBackgroundColor
            ),
            content: contentView
        )
		self.curtainView.magneticRatios = [0]

		super.init(nibName: nil, bundle: nil)

		self.modalPresentationStyle = .overFullScreen
		self.backgroundView.backgroundColorThemed = backgroundColor
		self.backgroundView.alpha = 0
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.addSubview(self.backgroundView)
		self.view.sendSubviewToBack(self.backgroundView)
		self.backgroundView.make(.edges, .equalToSuperview)

		self.view.addSubview(self.curtainView)
		self.curtainViewTopConstraint = self.curtainView.make(.edges, .equalToSuperview)[0]
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		UIView.animate(withDuration: 0.3) {
			self.backgroundView.alpha = 1
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.curtainView.animateAlongsideMagneticScroll ??= { [weak self] from, to, _ in
			if to == 0 {
				self?.backgroundView.alpha = 0
			}
		}

		self.curtainView.didAnimateMagneticScroll ??= { [weak self] from, to in
			if to == 0 {
				self?.dismiss(animated: false)
			}
		}
	}

	override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
		guard self.presentedViewController == nil else {
			super.dismiss(animated: flag, completion: completion)
			return
		}

		if self.curtainView.currentRatio <= 0 {
			super.dismiss(animated: flag, completion: completion)
			return
		}

		self.curtainView.scrollTo(ratio: 0, animated: flag)
		delay(self.curtainView.animationDuration) {
			completion?()
		}
	}
}


infix operator ?> : ComparisonPrecedence
infix operator ?< : ComparisonPrecedence
infix operator ?+ : AdditionPrecedence
infix operator ??= : AssignmentPrecedence
infix operator |== : ComparisonPrecedence
postfix operator ^

//swiftlint:disable:next static_operator
public func ?> <T>(lhs: T?, rhs: T?) -> Bool where T: Comparable {
	guard let lhs = lhs, let rhs = rhs else {
		if lhs == nil {
			return false
		}
		return true
	}

	return lhs > rhs
}

//swiftlint:disable:next static_operator
public func ?< <T>(lhs: T?, rhs: T?) -> Bool where T: Comparable {
	guard let lhs = lhs, let rhs = rhs else {
		if rhs == nil {
			return false
		}
		return true
	}

	return lhs < rhs
}

//swiftlint:disable:next static_operator
public func ?+ <T>(lhs: T, rhs: T?) -> T where T: AdditiveArithmetic {
	guard let rhs = rhs else {
		return lhs
	}
	return lhs + rhs
}

//swiftlint:disable:next static_operator
public func ?+ <T, U>(lhs: T, rhs: T?) -> T where T: RangeReplaceableCollection, T.SubSequence == U {
	guard let rhs = rhs else {
		return lhs
	}
	return lhs + rhs
}

//swiftlint:disable:next static_operator
public func ??= <T>(lhs: inout T?, rhs: T?) {
	if lhs == nil, let rhs = rhs {
		lhs = rhs
	}
}

public func |== <T: Comparable>(lhs: T, rhs: [T]) -> Bool {
	rhs.first{ $0 == lhs } != nil
}
