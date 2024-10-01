import UIKit

extension PickerWithToolbarView {
    struct Appearance {
        var toolbarTintColor = Palette.shared.textPrimary
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class PickerWithToolbarView: UIView {
    let appearance: Appearance

    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.backgroundColorThemed = self.appearance.backgroundColor
        return datePicker
    }()

    lazy var genderPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColorThemed = self.appearance.backgroundColor
        return picker
    }()

    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneAction = ToolbarButtonItem(
            title: "Выбрать",
            style: .plain,
            actionHandler: self.onSelect
        )
        let spaceButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let cancelAction = ToolbarButtonItem(
            title: "Отмена",
            style: .plain,
            actionHandler: self.onCancel
        )
        [doneAction, cancelAction].forEach { $0.customView?.tintColorThemed = self.appearance.toolbarTintColor }
        toolbar.setItems([cancelAction, spaceButton, doneAction], animated: false)
        return toolbar
    }()

    var onSelect: (() -> Void)?
    var onCancel: (() -> Void)?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setGenderPicker(
        dataSource: UIPickerViewDataSource,
        delegate: UIPickerViewDelegate
    ) {
        self.genderPickerView.dataSource = dataSource
        self.genderPickerView.delegate = delegate
    }
}
