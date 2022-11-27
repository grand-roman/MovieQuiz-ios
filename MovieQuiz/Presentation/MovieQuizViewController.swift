import UIKit



final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?

    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            // показываем индикатор
            self.showLoadingIndicator()
            // начинаем загрузку данных заново
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.show(model: model)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func show(quiz result: QuizResultsViewModel) {
        var finalMessage = result.text //итоговый текст алерта
        
        //добавлением статистику
        if let statisticService = statisticService {
            let count = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            
            let record = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date))"
            
            let accuracy = "Средняя точность \(String(format: "%.2f", statisticService.totalAccuracy * 100))%"
            
            finalMessage += "\n" + count + "\n" + record + "\n" + accuracy
        }
        
        //создаём модель с данными прошедшой игры
        let model = AlertModel(title: result.title, message: finalMessage, buttonText: result.buttonText){[weak self] in
            guard let self = self else {return}

            self.currentQuestionIndex = 0
            self.correctAnswers = 0

            // заново показываем первый вопрос
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.show(model: model)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
              correctAnswers += 1
          }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        
        imageView.layer.cornerRadius = 20

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }

    }
    
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questionsAmount - 1 {
          // - 1 потому что индекс начинается с 0, а длинна массива — с 1
          let text = "Ваш результат: \(correctAnswers) из \(questionsAmount)"
          let viewModel = QuizResultsViewModel(title: "Этот раунд окончен",
                                               text: text,
                                               buttonText: "Сыграть еще раз")
          statisticService?.store(correct: correctAnswers, total: questionsAmount) //сохраняем статистику
          show(quiz: viewModel)
      } else {
          currentQuestionIndex += 1 // увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий урок
          questionFactory?.requestNextQuestion()
      }
    }
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")// высчитываем номер вопроса
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imageView.layer.cornerRadius = 20
        // делегируем создание вопросов классу QuestionFactory
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        statisticService = StatisticServiceImplementation()
        // делегируем показ алерта классу AlertPresenter
        alertPresenter = AlertPresenter(delegate: self)
       
        questionFactory?.loadData()
        showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.activityIndicator.isHidden = true // скрываем индикатор загрузки
            self.show(quiz: viewModel) // показываем вопрос
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didFailToLoadImage() {
        showNetworkError(message: "Не удаётся загрузить картинку")
      }

}
