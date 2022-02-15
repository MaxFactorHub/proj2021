import UIKit
import SwiftGifOrigin
import AVFoundation

public class MenuVC: UIViewController {

    // MARK: - variables
    private let sound = AVPlayer(url: Bundle.main.url(forResource: "Music/backgroundMenuSound", withExtension: "mp3")!)

    // MARK: - @IBOutlets
    @IBOutlet weak private var online: UIButton!
    @IBOutlet weak private var status: UILabel!
    @IBOutlet weak private var backgroundImageView: UIImageView!

    // MARK: - @IBActions
    @IBAction private func online(_ sender: UIButton) {
        moveToGameVC(game: .online)
    }

    @IBAction private func player2(_ sender: UIButton) {
        moveToGameVC(game: .player2)
    }

    @IBAction private func offline(_ sender: UIButton) {
        moveToGameVC(game: .offline)
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - moveToGameVC()
    private func moveToGameVC(game: GameType) {
        sound.pause()
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as? GameViewController
        gameType = game
        self.navigationController?.pushViewController(gameVC ?? GameViewController(), animated: true)
    }

    // MARK: - viewDidLoad()
    override public func viewDidLoad() {
        sound.play()
        if  Internet.connection() == false {
            online.isEnabled = false
            status.textColor = UIColor.red
            status.text = "No internet connection"
        } else {
            online.isEnabled = true
            status.textColor = UIColor.green
            status.text = "Internet is connected"
        }
        backgroundImageView.loadGif(name: "menuBackground")
    }
}
