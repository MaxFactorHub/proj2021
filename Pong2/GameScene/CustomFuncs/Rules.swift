import SpriteKit
import PlainPing

extension GameScene {

    // MARK: - getPositionType
    func getPositionType(position: CGFloat) -> PositionType {
        var value = PositionType.zero
        if position > 0 {
            value = .positive
        } else if position < 0 {
            value = .negative
        } else if position == 0 {
            value = .zero
        }
        return value
    }

    // MARK: - managment
    func managment(location: CGPoint) {
        switch gameType {
        case .player2:
            let leftBorder = -((view?.frame.width)! / 2) + player.size.width / 2
            let rightBorder = ((view?.frame.width)! / 2) - player.size.width / 2
            let playerDur = 0.5
            let enemyDur = 0.5
            if location.x < rightBorder && location.x > leftBorder {
                if location.y > 0 {
                    enemy.run(SKAction.moveTo(x: location.x, duration: enemyDur))
                }
                if location.y < 0 {
                    player.run(SKAction.moveTo(x: location.x, duration: playerDur))
                }
            } else {
                if location.x > rightBorder {
                    if location.y > 0 {
                        enemy.run(SKAction.moveTo(x: rightBorder, duration: enemyDur))
                    }
                    if location.y < 0 {
                        player.run(SKAction.moveTo(x: rightBorder, duration: playerDur))
                    }
                } else {
                    if location.y > 0 {
                        enemy.run(SKAction.moveTo(x: leftBorder, duration: enemyDur))
                    }
                    if location.y < 0 {
                        player.run(SKAction.moveTo(x: leftBorder, duration: playerDur))
                    }
                }
            }
        case .offline:
            enemy.run(SKAction.moveTo(x: ball.position.x, duration: 0.1))
            fallthrough
        default:
            if gameType == .online, isConnected == true {
                let randomPosition: Array<CGFloat> = [-1, 0, 1]
                xAccelerate = randomPosition.randomElement()!
                let old = getPositionType(position: lastXAccelerate)
                let new = getPositionType(position: xAccelerate)
                borderRules()
                if new != old {
                    var average = Double()
                    var sum: Double = 0
                    for item in pingArray {
                        sum += item
                    }
                    average = sum / Double(pingArray.count)
                    lastXAccelerate = xAccelerate
                    send(data: User(id: identifier, position: player.position, ping: average))
                }
            } else {
                borderRules()
            }
        }
    }

    func borderRules() {

        let leftBorder = -UIScreen.main.bounds.width / 2 + player.size.width / 2
        let rightBorder = UIScreen.main.bounds.width / 2 - player.size.width / 2
        let playerDur: TimeInterval = 1

        if !(player.position.x <= leftBorder) && !(player.position.x >= rightBorder) {
            if xAccelerate > 0 {
                player.run(SKAction.moveTo(x: rightBorder, duration: playerDur))
            } else if xAccelerate < 0 {
                player.run(SKAction.moveTo(x: leftBorder, duration: playerDur))
            }
        } else {
            if player.position.x <= leftBorder {
                if xAccelerate > 0 {
                    player.run(SKAction.moveTo(x: rightBorder, duration: playerDur))
                }
            } else {
                if xAccelerate < 0 {
                    player.run(SKAction.moveTo(x: leftBorder, duration: playerDur))
                }
            }
        }
    }

    // MARK: - stopObj
    func stopObj() {
        player.position.x = 0
        enemy.position.x = 0
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
    }

    // MARK: - topReminder
    func topReminder() {
        let topReminder = SKLabelNode(text: "touch on screen")
        topReminder.color = .white
        topReminder.fontColor = .white
        topReminder.position = CGPoint(x: 0, y: -125)
        topReminder.zPosition = 5
        topReminder.alpha = 0
        topReminder.fontSize = 15
        topReminder.horizontalAlignmentMode = .center
        topReminder.verticalAlignmentMode = .center
        self.addChild(topReminder)

        topTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer
            in
            timer.tolerance = 0.2
            if topReminder.alpha == 0 {
                topReminder.run(SKAction.fadeIn(withDuration: 0.6))
            } else {
                topReminder.run(SKAction.fadeOut(withDuration: 0.6))
            }
        }
    }

    // MARK: - btmReminder
    func btmReminder() {
        let btmReminder = SKLabelNode(text: "touch on screen")
        btmReminder.color = .white
        btmReminder.fontColor = .white
        btmReminder.position = CGPoint(x: 0, y: 125)
        btmReminder.zPosition = 5
        btmReminder.alpha = 0
        btmReminder.fontSize = 15
        btmReminder.horizontalAlignmentMode = .center
        btmReminder.verticalAlignmentMode = .center
        self.addChild(btmReminder)
        btmReminder.zRotation = 3.14159 // radians
        btmReminder.run(SKAction.fadeAlpha(by: 1, duration: 1))

        btmTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer
            in
            timer.tolerance = 0.2
            if btmReminder.alpha == 0 {
                btmReminder.run(SKAction.fadeIn(withDuration: 0.6))
            } else {
                btmReminder.run(SKAction.fadeOut(withDuration: 0.6))
            }
        }
    }

    func convertGameType(type: GameType) -> Int16 {
        switch type {
        case .player2:
            return 1
        case .offline:
            return 2
        default:
            return 3
        }
    }

    // MARK: - victory
    func victory(winner: SKSpriteNode) {
        audio.run(SKAction.stop())
        self.run(SKAction.playSoundFileNamed("Music/endRound.mp3", waitForCompletion: false))
        stopObj()
        let background = SKSpriteNode(color: .black, size: CGSize(width: self.frame.width, height: self.frame.height))
        background.alpha = 0
        background.zPosition = 3
        self.addChild(background)
        background.run(SKAction.fadeAlpha(by: 0.5, duration: 2))

        let topLabel = SKLabelNode(text: "Defeat")
        topLabel.color = .white
        topLabel.fontColor = .white
        topLabel.position = CGPoint(x: 0, y: 0)
        topLabel.zPosition = 5
        topLabel.alpha = 0
        topLabel.fontSize = 40
        topLabel.horizontalAlignmentMode = .center
        topLabel.verticalAlignmentMode = .center
        self.addChild(topLabel)
        topLabel.run(SKAction.fadeAlpha(by: 1, duration: 1))

        topReminder()

        if gameType == .player2 {
            let btmlabel = SKLabelNode(text: "Victory")
            btmlabel.color = .white
            btmlabel.fontColor = .white
            btmlabel.position = CGPoint(x: 0, y: -100)
            btmlabel.zPosition = 5
            btmlabel.alpha = 0
            btmlabel.fontSize = 40
            btmlabel.horizontalAlignmentMode = .center
            btmlabel.verticalAlignmentMode = .center
            self.addChild(btmlabel)
            btmlabel.run(SKAction.fadeAlpha(by: 1, duration: 1))
            topLabel.zRotation = 3.14159
            topLabel.position.y = 100

            btmReminder()

            if winner == enemy {
                btmlabel.text = "Defeat"
                topLabel.text = "Victory"
            }
        }

        if gameType == .offline {
            if winner == enemy {
                topLabel.text = "Defeat"
                background.color = .black
            }
        }
        //
        let gameSession = GamingSessions(context: self.coreData.persistentContainer.viewContext)
        gameSession.btmScore = Int16(btmScore)
        gameSession.topScore = Int16(topScore)
        gameSession.ricochets = Int16(ricochets)
        gameSession.winner = winner == player ? true : false
        gameSession.gameType = convertGameType(type: gameType)
        self.coreData.saveCoreData()
        afterEnd.isPositional = false
        addChild(afterEnd)
    }

    // MARK: - refresh
    func refresh(winner: SKSpriteNode) {
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

        if winner == player {
            if btmScore == matchLimit {
                victory(winner: winner)
                gameOver = true
                return
            }
            btmScore += 1
            shakeAndFlashAnimation(view: view!)
            let vector = CGVector(dx: 5 * coefficientBallSpeed().0, dy: 5 * coefficientBallSpeed().1)
            ball.physicsBody?.applyImpulse(vector)
            let arctangent = atan2(-vector.dy, -vector.dx)
            ricochetEmitter.emissionAngle = arctangent
            ricochetEmitter.resetSimulation()
        } else if winner == enemy {
            if topScore == matchLimit {
                victory(winner: winner)
                gameOver = true
                return
            }
            topScore += 1
            shakeAndFlashAnimation(view: view!)
            let vector = CGVector(dx: -5 * coefficientBallSpeed().0, dy: -5 * coefficientBallSpeed().1)
            ball.physicsBody?.applyImpulse(vector)
            let arctangent = atan2(-vector.dy, -vector.dx)
            ricochetEmitter.emissionAngle = arctangent
            ricochetEmitter.resetSimulation()
        }
        self.run(SKAction.playSoundFileNamed("Music/outBall.mp3", waitForCompletion: false))
        topLabel.text = "\(topScore)"
        btmLabel.text = "\(btmScore)"
    }

    // MARK: - searchEnemyProgress
    func searchEnemyProgress() {
        if gameType == .online {
            background = SKSpriteNode(color: .black, size: CGSize(width: self.frame.width, height: self.frame.height))
            background.alpha = 1
            background.zPosition = 1

            search = SKLabelNode(text: "Enemy search")
            search.color = .white
            search.position = CGPoint(x: 0, y: 0)
            search.zPosition = 3
            search.horizontalAlignmentMode = .center
            search.verticalAlignmentMode = .center

            progress = SKLabelNode(text: ".")
            progress.color = .white
            progress.position = CGPoint(x: 0, y: -30)
            progress.zPosition = 3
            progress.horizontalAlignmentMode = .center
            progress.verticalAlignmentMode = .center

            backButton = SKSpriteNode(texture: SKTexture(imageNamed: "X"))
            backButton.zPosition = 3
            backButton.position = CGPoint(x: 0, y: -200)
            backButton.setScale(0.05)

            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                timer.tolerance = 1
                switch self.progress.text {
                case ".":
                    self.progress.text = ".."
                case "..":
                    self.progress.text = "..."
                case "...":
                    self.progress.text = ""
                case "":
                    self.progress.text = "."
                default:
                    self.progress.text = ""
                }
            }
            self.addChild(search)
            self.addChild(progress)
            self.addChild(background)
            self.addChild(backButton)
        }
    }

    // MARK: - detected
    func detected() {
        timer.invalidate()
        progress.removeFromParent()
        let attenuation = SKAction.fadeOut(withDuration: 5)
        background.run(attenuation)
        search.run(attenuation)
    }

    // MARK: - сountdown
    func сountdownf() {
        score = 5
        if gameType == .player2 {
            inverted.text = "Start \(score)"
            inverted.horizontalAlignmentMode = .center
            inverted.verticalAlignmentMode = .center
            inverted.fontSize = 40
            inverted.color = .white
            inverted.position = CGPoint(x: 0, y: 150)
            inverted.zPosition = 3
            inverted.zRotation = 3.14159
            inverted.run(SKAction.fadeOut(withDuration: 10))
            self.addChild(inverted)
        }

        сountdown.text = "Start \(score)"
        сountdown.horizontalAlignmentMode = .center
        сountdown.verticalAlignmentMode = .center
        сountdown.fontSize = 50
        сountdown.color = .white
        сountdown.position = CGPoint(x: 0, y: 0)
        сountdown.zPosition = 3
        сountdown.run(SKAction.fadeOut(withDuration: 10))

        if gameType == .player2 {
            сountdown.fontSize = 40
            сountdown.position = CGPoint(x: 0, y: -150)
        }

        self.addChild(сountdown)
        self.сountdownT = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.score -= 1
            if self.score == 0 {
                if gameType == .online {
                    self.search.removeFromParent()
                    self.background.removeFromParent()
                }
                timer.invalidate()
                self.сountdown.removeFromParent()
                self.inverted.removeFromParent()
                self.start()
            }
        }
    }

    @objc func doubleTapped() {
        delegateVC?.transition()
    }

    // MARK: - pause
    func pause() {
        if self.scene?.isPaused == false {
            pauseLbl = SKLabelNode(text: "Pause")
            pauseLbl.position = CGPoint(x: 0, y: 0)
            pauseLbl.fontSize = 50
            pauseLbl.verticalAlignmentMode = .center
            pauseLbl.horizontalAlignmentMode = .center
            self.addChild(pauseLbl)

            menuLbl = SKLabelNode(text: "double tap to menu")
            menuLbl.position = CGPoint(x: 0, y: -100)
            menuLbl.fontSize = 20
            menuLbl.fontColor = .red
            menuLbl.verticalAlignmentMode = .center
            menuLbl.horizontalAlignmentMode = .center
            self.addChild(menuLbl)
            let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
            tap.numberOfTapsRequired = 2
            self.view!.addGestureRecognizer(tap)

            сountdownT.invalidate()
            _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                self.scene?.isPaused = true
            }
        } else {
            _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                self.scene?.isPaused = false
                self.view!.gestureRecognizers?.remove(at: 0)
                self.pauseLbl.removeFromParent()
                self.menuLbl.removeFromParent()
                self.сountdownT = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    self.score -= 1
                    if self.score == 0 {
                        if gameType == .online {
                            self.search.removeFromParent()
                            self.background.removeFromParent()
                        }
                        timer.invalidate()
                        self.сountdown.removeFromParent()
                        self.inverted.removeFromParent()
                        self.start()
                    }
                }
            }
        }
    }

    // MARK: - start
    func start() {
        let vector = CGVector(dx: 5 * coefficientBallSpeed().0, dy: 5 * coefficientBallSpeed().1)
        let arctangent = atan2(-vector.dy, -vector.dx)
        ricochetEmitter.emissionAngle = arctangent
        ball.physicsBody?.applyImpulse(vector)
        ricochetEmitter.resetSimulation()
    }
}
