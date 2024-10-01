import UIKit

protocol ProfileFaqViewControllerProtocol: AnyObject { }

final class ProfileFaqViewController: UIViewController {
    let presenter: ProfileFaqPresenterProtocol
    private lazy var profileFaqView = ProfileFaqView()

    private let faqItems = [
        // swiftlint:disable line_length
        ProfileFaqViewModel(
            title: "Как перейти на новый уровень кешбэка?",
            text:
                """
                5% – стартовая карта при вступлении в Клуб;
                10% – при достижении порога трат 100 000 руб/год;
                12% – при достижении порога трат 500 000 руб/год;
                15% – при достижении порога трат 1 000 000 руб/год.
                 
                Переход на все уровни накоплений осуществляется автоматически при суммарном совершении покупок на необходимую сумму.
                """
        ),
        ProfileFaqViewModel(
            title: "Что можно оплатить баллами?",
            text:
                """
                Счет в ресторане до 70%
                """
        ),
        ProfileFaqViewModel(
            title: "Чем приложение лучше?",
            text:
                """
                Все события холдинга Maison Dellos находятся в одном месте. О которых вы узнаете первыми!
                Можно отследить историю транзакций.
                Специальные акции только для пользователей приложения.
                """
        ),
        ProfileFaqViewModel(
            title: "Как посмотреть историю транзакций?",
            text:
                """
                1. Войти в свой профиль
                2. Открыть раздел «моя карта»
                3. Перейти в раздел «история»
                """
        ),
        ProfileFaqViewModel(
            title: "Какие есть ограничение при трате бонусов?",
            text:
                """
                • Банкеты свыше 25 человек в ресторанах могут быть оплачены накопленными баллами в размере не более 50%
                • В «Посольстве красоты» можно расплатиться баллами, накопленными в ресторанах Maison Dellos. Баллы за пользование услугами «Посольства Красоты» не накапливаются.
                • В «Посольстве красоты» программа лояльности действует только на услуги и не распространяется на товары.
                """
        )
        // swiftlint:enable line_length
    ]

    init(presenter: ProfileFaqPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(profileFaqView)
        view.backgroundColorThemed = profileFaqView.appearance.backgroundColor
        profileFaqView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        self.navigationItem.title = "FAQ"
        self.navigationItem.setBackButtonText()

        self.profileFaqView.updateTableView(delegate: self, dataSource: self)
    }
}

extension ProfileFaqViewController: ProfileFaqViewControllerProtocol { }

extension ProfileFaqViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.profileFaqView.appearance.itemHeight
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.faqItems[indexPath.row]
        let viewController = ProfileFaqDetailAssembly(model: model).makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ProfileFaqViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.faqItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileFaqTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let item = self.faqItems[indexPath.row]
        cell.title = item.title
        return cell
    }
}
