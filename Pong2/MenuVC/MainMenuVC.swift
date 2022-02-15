import UIKit
import SwiftGifOrigin
import AVFoundation

class MainMenuVC: UIViewController {

    // MARK: - @IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!

    // MARK: - Variable
    let sound = AVPlayer(url: Bundle.main.url(forResource: "Music/backgroundMainMenuSound", withExtension: "mp3")!)

    // MARK: - @IBActions
    @IBAction func playButtonAction(_ sender: Any) {
        sound.pause()
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        sound.play()
        backgroundImageView.loadGif(name: "menuBackground")
    }
}
