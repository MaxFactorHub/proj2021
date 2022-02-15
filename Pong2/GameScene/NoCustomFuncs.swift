import SpriteKit
import Starscream
import CoreMotion

extension GameScene {

    // MARK: - update
    override public func update(_ currentTime: TimeInterval) {
        if ball.position.y <= player.position.y - 30 * coefficient().1 {
            refresh(winner: enemy)
        } else if ball.position.y >= enemy.position.y + 30 * coefficient().1 {
            refresh(winner: player)
        }
    }

    // MARK: - didSimulatePhysics
    override public func didSimulatePhysics() {
        if gameType != .online {
            managment(location: CGPoint(x: 0, y: 0))
        }
    }

    // MARK: - touchesBegan
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver == false {
            for touch in touches {
                managment(location: touch.location(in: self))
            }
        } else if gameOver == true {
            topTimer.invalidate()
            if gameType == .player2 {
                btmTimer.invalidate()
            }
            delegateVC?.transition()
        }
        for touch in touches {
            if backButton.contains(touch.location(in: self)) {
                if gameType != .online {
                    pause()
                } else {
                    simulation.invalidate()
                    refreshPingTimer.invalidate()
                    delegateVC?.transition()
                }
            } else if player2Button.contains(touch.location(in: self)) {
                if gameType == .player2 {
                    pause()
                }
            }
        }
    }

    // MARK: - touchesMoved
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            managment(location: touch.location(in: self))
        }
    }

    // MARK: - didBegin
    public func didBegin(_ contact: SKPhysicsContact) {
        let arctangent = atan2(-ball.physicsBody!.velocity.dy, -ball.physicsBody!.velocity.dx)
        ricochetEmitter.emissionAngle = arctangent
        ricochetEmitter.resetSimulation()

        if contact.bodyA.categoryBitMask == player.physicsBody?.categoryBitMask ||
            contact.bodyB.categoryBitMask == player.physicsBody?.categoryBitMask {
            ricochets += 1
            self.run(SKAction.playSoundFileNamed("Music/picSound.mp3", waitForCompletion: false))
        }
        if contact.bodyA.categoryBitMask == enemy.physicsBody?.categoryBitMask ||
            contact.bodyB.categoryBitMask == enemy.physicsBody?.categoryBitMask {
            ricochets += 1
            self.run(SKAction.playSoundFileNamed("Music/picSound.mp3", waitForCompletion: false))
        }
    }

    // MARK: - didReceive
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
            receive(data: data, type: type)
        case .ping:
            break
        case .pong:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            break
        case .error(let error):
            print(error ?? "error")
        case .viabilityChanged(_):
            break
        }
    }
}
