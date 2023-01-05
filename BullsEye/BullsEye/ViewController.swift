/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
///
///
///
/// Dameion Dismuke Jan 4, 2023
///
/// Task 2: Re-define what a "test" is
///
///  The point of unit testing is to sample and to trial smaller parts of a whole system in order to be sure that those parts work as intended.
///  Testing, as a whole, is trying to filter out as many bugs out of the finished product, so the consumer of the product can have a quality experience.
///  Testing smaller bits of a larger bit makes it a lot easier to pinpoint and to isolate an issue as well, so one wouldn't be looking for a needle in
///  a haystack, which would burn time, thus burning money for the company. And no company wants to waste money when it does not have to.
///  Advantages of unit testing, include finding bugs sooner to lessen compound errors; debugging is easier; quick changes can be made; successful
///  code snippets can be recycled for later use or even reused in other projects. The disadvantages of unit testing aren't that deep to be honest.
///  Disadvantages would include tests potentially not finding every single bug, unit tests will not find errors in integration, more lines of code to be
///  written to test one single line of code for the potential to cost more time, and there may be a steep learning curve for learning all the specific
///  automated software tools.
///
///
///
///

import UIKit

class ViewController: UIViewController {
  var defaults = UserDefaults.standard

  @IBOutlet weak var targetGuessLabel: UILabel!
  @IBOutlet weak var targetGuessField: UITextField!
  @IBOutlet weak var roundLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var slider: UISlider!
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  let game = BullsEyeGame()
  enum GameStyle: Int { case moveSlider, guessPosition }
  let gameStyleRange = 0..<2
  var gameStyle = GameStyle.guessPosition

  override func viewDidLoad() {
    super.viewDidLoad()

    let defaultGameStyle = defaults.integer(forKey: "gameStyle")
    print(defaultGameStyle)
    if gameStyleRange.contains(defaultGameStyle) {
      gameStyle = GameStyle(rawValue: defaultGameStyle) ?? .moveSlider
      segmentedControl.selectedSegmentIndex = defaultGameStyle
    } else {
      gameStyle = .moveSlider
      defaults.set(0, forKey: "gameStyle")
    }
    updateView()
  }

  @IBAction func chooseGameStyle(_ sender: UISegmentedControl) {
    if gameStyleRange.contains(sender.selectedSegmentIndex) {
      gameStyle = GameStyle(rawValue: sender.selectedSegmentIndex) ?? .moveSlider
      updateView()
    }
    defaults.set(sender.selectedSegmentIndex, forKey: "gameStyle")
  }

  func updateView() {
    switch gameStyle {
    case .moveSlider:
      targetGuessLabel.text = "Get as close as you can to: "
      targetGuessField.text = "\(game.targetValue)"
      targetGuessField.isEnabled = false
      slider.value = Float(game.startValue)
      slider.isEnabled = true
    case .guessPosition:
      targetGuessLabel.text = "Guess where the slider is: "
      targetGuessField.text = ""
      targetGuessField.placeholder = "1-100"
      targetGuessField.isEnabled = true
      slider.value = Float(game.targetValue)
      slider.isEnabled = false
    }
    roundLabel.text = "Round: \(game.round)"
    scoreLabel.text = "Score: \(game.scoreTotal)"
  }

  @IBAction func checkGuess(_ sender: Any) {
    var guess: Int?
    switch gameStyle {
    case .moveSlider:
      guess = Int(lroundf(slider.value))
    case .guessPosition:
      targetGuessField.resignFirstResponder()
      guess = Int(targetGuessField.text ?? "")
    }
    if let guess = guess {
      showScoreAlert(difference: game.check(guess: guess))
    } else {
      showNaNAlert()
    }
  }

  func showScoreAlert(difference: Int) {
    let title = "you scored \(game.scoreRound) points"
    let message = "target value \(game.targetValue)"
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default) { _ in
      self.game.startNewRound {
        alert.dismiss(animated: true, completion: nil)
        self.updateView()
      }
    }
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }

  func showNaNAlert() {
    let alert = UIAlertController(
      title: "Not A Number",
      message: "Please enter a positive number",
      preferredStyle: .alert
    )
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }

  @IBAction func startOver(_ sender: Any) {
    game.startNewGame()
    updateView()
  }
}
