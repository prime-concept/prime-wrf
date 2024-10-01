import UIKit

final class ActionButton: UIButton {
    init(title: String, image: UIImage? = nil, backgroundColor: UIColor, borderColor: UIColor? = nil) {
        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
        
        layer.masksToBounds = true
        layer.cornerRadius = 8
        if let borderColor = borderColor {
            layer.borderWidth = 1
            layer.borderColor = borderColor.cgColor
        }
        if let image = image {
            setImage(image, for: .normal)
            
            let insetLeft = imageEdgeInsets.left
            imageEdgeInsets = .init(top: 0, left: insetLeft, bottom: 0, right: 0)
        }
        
        setTitle(title, for: .normal)
        tintColor = .white
        snp.makeConstraints { make in
            make.height.equalTo(40).priorityHigh()
        }
        
        set(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(title: String) {
        let font = UIFont.wrfFont(ofSize: 14)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: font]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributedTitle, for: .normal)
        
        let highlightedColor = imageView?.image != nil ? UIColor.lightGray : UIColor.white.withAlphaComponent(0.4)
        let highlightedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: highlightedColor, .font: font]
        let highlightedTitle = NSAttributedString(string: title, attributes: highlightedAttributes)
        setAttributedTitle(highlightedTitle, for: .highlighted)
    }
}
