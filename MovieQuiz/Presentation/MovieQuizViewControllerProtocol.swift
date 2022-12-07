import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showImageBorder(isCorrect: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkErrorAlert(message: String)
}
