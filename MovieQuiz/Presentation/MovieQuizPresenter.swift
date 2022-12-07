import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var correctAnswers: Int = 0
    
    private var currentQuestion: QuizQuestion?
    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController as? MovieQuizViewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func incCorrectAnswers() {
        correctAnswers += 1
    }
    
    func setCurrentQuestion(currentQuestion: QuizQuestion) {
        self.currentQuestion = currentQuestion
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func getResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY HH:mm"
        let alertText = """
            Ваш результат: \(correctAnswers) из 10
            Количество сыграных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
            """
        return alertText
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.showImageBorder(isCorrect: isCorrect)
        
        if isCorrect {
            incCorrectAnswers()
        }
        
        viewController?.showLoadingIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
            self.viewController?.hideLoadingIndicator()
        }
    }
    
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.showEndGameAlert()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
    }
    
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkErrorAlert(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadImage() {
        viewController?.showNetworkErrorAlert(message: "Не удаётся загрузить картинку")
    }
}
