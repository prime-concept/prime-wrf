import UIKit
import SnapKit

private enum ViewTapHandler {
    static let cancelableRecognizerDelegate = CancellableGestureRecognizerDelegate()
}

extension UIView {
    func removeTapHandler() {
        self.gestureRecognizers?
            .filter { $0 is CustomTapGestureRecognizer }
            .forEach(self.removeGestureRecognizer)
    }

    func addTapHandler(feedback: TapHandlerFeedback = .opacity, _ handler: @escaping () -> Void) {
        if self is UIButton {
            assertionFailure("Use setEventHandler() instead")
            return
        }

        self.removeTapHandler()
        self.isUserInteractionEnabled = true

        let initialAlphaColor = Box(self.layer.opacity)

        let recognizer = self.addGestureRecognizer { [weak self] (recognizer: CustomTapGestureRecognizer) in
            guard let strongSelf = self else {
                return
            }

            let oldSize = max(strongSelf.frame.width, strongSelf.frame.height)
            let newSize = oldSize - 8
            let finalScale = newSize / oldSize

            if recognizer.state == .began {
                initialAlphaColor.value = strongSelf.layer.opacity

                switch feedback {
                case .scale:
                    UIView.animate(
                        withDuration: 0.1,
                        animations: {
                            strongSelf.transform = CGAffineTransform.identity.scaledBy(x: finalScale, y: finalScale)
                        }
                    )
                case .opacity:
                    UIView.animate(
                        withDuration: 0.1,
                        animations: {
                            strongSelf.layer.opacity = 0.5
                        }
                    )
                }
            }

            if Set([
                UIGestureRecognizer.State.failed,
                UIGestureRecognizer.State.cancelled,
                UIGestureRecognizer.State.ended
            ]).contains(recognizer.state) {
                let ended = recognizer.state == .ended

                switch feedback {
                case .scale:
                    UIView.animate(
                        withDuration: 0.1,
                        animations: {
                            strongSelf.transform = CGAffineTransform.identity
                        },
                        completion: { _ in
                            if ended { handler() }
                        }
                    )
                case .opacity:
                    UIView.animate(
                        withDuration: 0.1,
                        animations: {
                            strongSelf.layer.opacity = initialAlphaColor.value
                        },
                        completion: { _ in
                            if ended { handler() }
                        }
                    )
                }
            }
        }

        recognizer.delegate = ViewTapHandler.cancelableRecognizerDelegate
    }

    enum TapHandlerFeedback {
        case scale
        case opacity
    }
}

private final class CustomTapGestureRecognizer: UIGestureRecognizer {
    private var firstTouchLocation: CGPoint?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        guard touches.count == 1 else {
            self.state = .failed
            return
        }

        if self.firstTouchLocation == nil {
            self.firstTouchLocation = touches.first?.location(in: self.view?.window)
            self.state = .began
        }

        var optionalSuperview = self.view?.superview
        while let superview = optionalSuperview {
            if let scrollView = superview as? UIScrollView, scrollView.isDragging {
                self.state = .failed
                return
            }

            optionalSuperview = superview.superview
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        if let touch = touches.first, let firstTouchLocation = self.firstTouchLocation {
            let diffX = abs(firstTouchLocation.x - touch.location(in: self.view?.window).x)
            let diffY = abs(firstTouchLocation.y - touch.location(in: self.view?.window).y)

            if diffX > 10.0 || diffY > 10.0 {
                self.state = .cancelled
                return
            }
        }

        self.state = .changed
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        self.state = .ended
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        self.state = .cancelled
    }

    override func reset() {
        self.firstTouchLocation = nil
    }
}

// MARK: - CancelableGestureRecognizerDelegate

private final class CancellableGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer is UIPanGestureRecognizer
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view is UIControl == false
    }
}

// MARK: - View for extended tap area

private final class ExtendedTouchEventAreaView: UIView {
    private let tapInsets: UIEdgeInsets

    init(frame: CGRect = .zero, tapInsets: UIEdgeInsets) {
        self.tapInsets = tapInsets
        super.init(frame: frame)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newBounds = self.bounds.inset(by: self.tapInsets.negated())
        return newBounds.contains(point)
    }
}

// MARK: - UIView + wrap in extended touch event area

extension UIView {
    func withExtendedTouchArea(insets: UIEdgeInsets) -> UIView {
        let view = ExtendedTouchEventAreaView(tapInsets: insets)
        view.addSubview(self)

        self.snp.removeConstraints()
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return view
    }
}

// MARK: - Helper to make reference symantic for value

private final class Box<T> {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}

extension UIView {
	private static var tapHandlerKey = 0
	private static var recognizerKey = 1
	private static var wasUserInteractionEnabled = 2

	var onTap: (() -> Void)? {
		get {
			ObjcAssociatedProperty.get(from: self, for: &Self.tapHandlerKey)
		}
		set {
			if self.onTap == nil {
				self.wasUserInteractionEnabled = self.isUserInteractionEnabled
			}
			ObjcAssociatedProperty.set(newValue, to: self, for: &Self.tapHandlerKey)
			guard newValue != nil else {
				self.tapGestureRecognizer = nil
				self.wasUserInteractionEnabled = self.wasUserInteractionEnabled
				return
			}
			self.isUserInteractionEnabled = true
			let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
			self.addGestureRecognizer(recognizer)
			self.tapGestureRecognizer = recognizer
		}
	}

	private var tapGestureRecognizer: UITapGestureRecognizer? {
		get {
			ObjcAssociatedProperty.get(from: self, for: &Self.recognizerKey)
		}
		set {
			self.tapGestureRecognizer?.remove()
			ObjcAssociatedProperty.set(newValue, to: self, for: &Self.recognizerKey)
		}
	}

	private var wasUserInteractionEnabled: Bool {
		get {
			ObjcAssociatedProperty.get(from: self, for: &Self.wasUserInteractionEnabled) ?? self.isUserInteractionEnabled
		}
		set {
			ObjcAssociatedProperty.set(newValue, to: self, for: &Self.wasUserInteractionEnabled)
		}
	}

	@objc
	private func handleTap(_ recognizer: UITapGestureRecognizer) {
		onTap?()
	}
}
