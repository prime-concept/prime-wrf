import AutoInsetter
import Pageboy
import Tabman

final class TabDataSource: PageboyViewControllerDataSource, TMBarDataSource {
    private let items: [WRFBarItem]
    private let offset: CGFloat
    private let autoInsetter: AutoInsetter

    init(items: [WRFBarItem], offset: CGFloat) {
        self.items = items
        self.offset = offset
        self.autoInsetter = AutoInsetter()
    }

    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = self.items[index].title
        return TMBarItem(title: title)
    }

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return self.items.count
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        let viewController = self.items[index].viewController
        let insets = UIEdgeInsets(
            top: self.offset,
            left: 0,
            bottom: 0,
            right: 0
        )
        self.autoInsetter.enable(for: viewController)
        self.autoInsetter.inset(
            viewController, requiredInsetSpec: TabInsetSpec(
                additionalRequiredInsets: insets,
                allRequiredInsets: insets
            )
        )
        return viewController
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}
