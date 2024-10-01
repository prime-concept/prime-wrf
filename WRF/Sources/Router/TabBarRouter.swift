import UIKit

/// Router for switching tab bar active tab
open class TabBarRouter: SourcelessRouter, Router {
    public private(set) var tabIndex: Int

    public init(tabIndex: Int) {
        self.tabIndex = tabIndex
    }

    open func route() {
        self.currentTabBarController?.selectedIndex = self.tabIndex
    }
}
