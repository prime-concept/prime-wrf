import SnapKit
import UIKit

extension MyCardInfoCardView {
    struct Appearance {
    }
}

final class MyCardInfoCardView: UIView {
    let appearance: Appearance

    private(set) lazy var myCardInfoTypeView = MyCardInfoTypeView()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyCardInfoCardView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.myCardInfoTypeView)
    }

    func makeConstraints() {
        self.myCardInfoTypeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
