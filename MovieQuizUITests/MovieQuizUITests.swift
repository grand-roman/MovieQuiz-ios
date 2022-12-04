import XCTest

class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        
        // В каждом тесте указал такой параметр
        // Заметил, что когда плохой интернет, на кнопку нажать не могу
        // Пока не загрузиться картинка
        // Тест падает из за просто плохого интернета
        var is_tap = false
        
        while !is_tap {
            if app.buttons["Yes"].isEnabled {
                app.buttons["Yes"].tap()
                is_tap = true
            }
        }
        
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        
        sleep(2)
        
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        var is_tap = false
        
        while !is_tap {
            if app.buttons["No"].isEnabled {
                app.buttons["No"].tap()
                is_tap = true
            }
        }
        
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        
        sleep(2)
        
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testGameFinish() {
        let indexLabel = app.staticTexts["Index"]
        var count_tap = 0
        while indexLabel.label != "10/10" {
            if app.buttons["No"].isEnabled {
                app.buttons["No"].tap()
                count_tap += 1
            }
        }
        
        if count_tap != 10 {
            app.buttons["No"].tap()
        }
        
        sleep(2)
        
        let alert = app.alerts["Game results"]
        
        XCTAssertTrue(app.alerts["Game results"].exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
    }

    func testAlertDismiss() {
        let indexLabel = app.staticTexts["Index"]
        var count_tap = 0
        while indexLabel.label != "10/10" {
            if app.buttons["No"].isEnabled {
                app.buttons["No"].tap()
                count_tap += 1
            }
        }
        if count_tap != 10 {
            app.buttons["No"].tap()
        }
        sleep(2)
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        
        XCTAssertFalse(app.alerts["Game results"].exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }

}
