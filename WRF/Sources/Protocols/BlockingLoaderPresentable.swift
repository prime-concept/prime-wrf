import MBProgressHUD

protocol BlockingLoaderPresentable: AnyObject {
    func showLoading()
    func hideLoading()
}

extension BlockingLoaderPresentable where Self: UIViewController {
    func showLoading() {
        let hud = MBProgressHUD()
        hud.mode = .customView
        hud.customView = WineLoaderView()
        hud.bezelView.color = .clear
        hud.bezelView.style = .solidColor
        self.view.addSubview(hud)
        hud.show(animated: true)
    }

    func hideLoading() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}
