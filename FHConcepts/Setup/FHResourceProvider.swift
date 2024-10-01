import PrimeGuideCore
import UIKit

final class FHResourceProvider { }

extension FHResourceProvider: ResourceProvider {
    
    func color(name: String) -> UIColor {
        UIColor(named: name, in: Bundle(for: Self.self), compatibleWith: nil)!
    }
    
    func image(name: String) -> UIImage {
        UIImage(named: name, in: Bundle(for: Self.self), compatibleWith: nil)!
    }
    
}

