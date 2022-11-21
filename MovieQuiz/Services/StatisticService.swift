import Foundation


final class StatisticServiceImplementation: StatisticService {

    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var totalAccuracy: Double {
        get{
            let corrects = userDefaults.integer(forKey: Keys.correct.rawValue)
            let totals = userDefaults.integer(forKey: Keys.total.rawValue)
            return Double(corrects) / Double(totals)
        }
    }
    
    var gamesCount: Int {
        get{
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set{
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date().dateTimeString)
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let newGame: GameRecord = GameRecord(correct: count, total: amount, date: Date().dateTimeString)
        if bestGame.correct < newGame.correct {
            bestGame = newGame
        }
        
        var corrects = userDefaults.integer(forKey: Keys.correct.rawValue)
        corrects += count
        userDefaults.set(corrects, forKey: Keys.correct.rawValue)
        
        var totals = userDefaults.integer(forKey: Keys.total.rawValue)
        totals += amount
        userDefaults.set(totals, forKey: Keys.total.rawValue)
    }
    
}
