import Foundation


class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading?
    private weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    /*
    private let questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 5?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
    ]
    */
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    func loadData() {
        moviesLoader?.loadMovies { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items// сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer()// сообщаем, что данные загрузились
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)// сообщаем об ошибке нашему
                }
            }
        }
    }
    
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            
                let rating = Float(movie.rating) ?? 0
                
                
                let (text, correctAnswer) = self.generateTextAnswer(rating: rating)
                
                let question = QuizQuestion(image: imageData,
                                             text: text,
                                             correctAnswer: correctAnswer)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.delegate?.didReceiveNextQuestion(question: question)
                }

            } catch {
                print("Failed to load image")
                //возвращаемся в главный поток, сетевые данные не удалось получить, работа с ними окончена
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.delegate?.didFailToLoadImage()
                }
            }
        }
    }
    
    private func generateTextAnswer(rating: Float) -> (text: String, correctAnswer: Bool) {
        let number = Int.random(in: 1..<10)
        let word = ["больше", "меньше"].randomElement()
        let text: String
        if let word {
            text = "Рейтинг этого фильма \(word) чем \(number)?"
        }
        else {
            text = "Рейтинг этого фильма меньше чем \(number)?"
        }
        var correctAnswer: Bool
        if word == "больше"{
            correctAnswer = rating > Float(number)
        }
        else {
            correctAnswer = rating < Float(number)
        }
        return (text, correctAnswer)

    }
}
