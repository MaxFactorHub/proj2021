import SpriteKit

// MARK: - variables
var gameType: GameType = .offline

public class GameViewController: UIViewController, Transition {

    // MARK: - variables
    private var skView: SKView {
        (self.view as? SKView)!
    }

    override public var shouldAutorotate: Bool {
        return false
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override public var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - transition()
    public func transition() {
        let scene = skView.scene as? GameScene
        scene?.delegateVC = nil
        skView.presentScene(nil)
        self.navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - viewDidLoad()
    override public func viewDidLoad() {
        super.viewDidLoad()
        guard let scene = SKScene(fileNamed: "GameScene") else {
            return
        }
        scene.scaleMode = .aspectFill
        scene.size = view.bounds.size
        let gameScene = scene as? GameScene
        gameScene?.delegateVC = self
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
}
