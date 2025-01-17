import UIKit

struct AlertPresenter: AlertPresenterProtocol{

    private weak var delegate: UIViewController?

    init(delegate: UIViewController?){
        self.delegate = delegate
    }

    func show(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "Game results"

        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }

        alert.addAction(action)

        delegate?.present(alert, animated: true, completion: nil)
    }
}
