import UIKit

extension UITextField {
    func setCursorLocation(_ location: Int) {
        if let cursorLocation = self.position(from: self.beginningOfDocument, offset: location) {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.selectedTextRange = strongSelf.textRange(from: cursorLocation, to: cursorLocation)
            }
        }
    }
}
