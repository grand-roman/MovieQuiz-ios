@testable import MovieQuiz


final class MovieQuizViewControllerProtocolMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {}
    
    func showImageBorder(isCorrect: Bool) {}
    
    func showLoadingIndicator() {}
    
    func hideLoadingIndicator() {}
    
    func showNetworkErrorAlert(message: String) {}
    
}
