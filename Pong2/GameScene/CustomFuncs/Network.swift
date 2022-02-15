import Starscream
import CoreMotion.CMMotionManager
import SpriteKit
import PlainPing

extension GameScene {

    // MARK: - receive
    func receive(data: Data, type: DecodeType) {
        let jsonDecoder = JSONDecoder()
        switch type {
        case .identifiers:
            do {
                let identifiers = try jsonDecoder.decode(Identifiers.self, from: data)
                identifier = identifiers.id
                self.type = .connection
            } catch {
                print("Unexpected error: \(error).")
            }
        case .connection:
            do {
                let connection = try jsonDecoder.decode(Connection.self, from: data)
                isConnected = connection.isConnected
                detected()
                сountdownf()
                self.type = .enemy
            } catch {
                print("Unexpected error: \(error).")
                do {
                    let disconnect = try jsonDecoder.decode(Disconnect.self, from: data)
                    delegateVC?.transition()
                } catch {
                    print("Unexpected error: \(error).")
                }
            }
        default:
            do {
                let enemy = try jsonDecoder.decode(Enemy.self, from: data)
                let leftBorder = -UIScreen.main.bounds.width / 2 + player.size.width / 2
                let rightBorder = UIScreen.main.bounds.width / 2 - player.size.width / 2
                self.enemy.position.x = enemy.position.x
                self.enemy.position.y = -enemy.position.y
                let playerDur: TimeInterval = 1

                if !(enemy.position.x <= leftBorder) && !(enemy.position.x >= rightBorder) {
                    if xAccelerate > 0 {
                        self.enemy.run(SKAction.moveTo(x: rightBorder, duration: playerDur))
                    } else if xAccelerate < 0 {
                        self.enemy.run(SKAction.moveTo(x: leftBorder, duration: playerDur))
                    }
                } else {
                    if enemy.position.x <= leftBorder {
                        if xAccelerate > 0 {
                            self.enemy.run(SKAction.moveTo(x: rightBorder, duration: playerDur))
                        }
                    } else {
                        if xAccelerate < 0 {
                            self.enemy.run(SKAction.moveTo(x: leftBorder, duration: playerDur))
                        }
                    }
                }
            } catch {
                print("Unexpected error: \(error).")
                do {
                    let disconnect = try jsonDecoder.decode(Disconnect.self, from: data)
                } catch {
                    print("Unexpected error: \(error).")
                }
            }
        }
    }

    // MARK: - send
    func send(data: User) {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(data)
            socket.write(data: jsonData)
        } catch {
            print("Unexpected error: \(error).")
        }
    }

    func refreshPing() {
        if gameType == .online {
            refreshPingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer
                in
                timer.tolerance = 0.5
                PlainPing.ping("www.google.com", withTimeout: 3,
                               completionBlock: { (timeElapsed: Double?, error: Error?) in
                                if let latency = timeElapsed {
                                    print("latency (ms): \(latency)")
                                    if self.pingArray.count == 20 {
                                        if self.pingArrayIndex == 19 {
                                            self.pingArray[self.pingArrayIndex] = latency
                                            self.pingArrayIndex = 0
                                        } else {
                                            self.pingArray[self.pingArrayIndex] = latency
                                            self.pingArrayIndex += 1
                                        }
                                    } else {
                                        self.pingArray.append(latency)
                                    }
                                }
                                if let error = error {
                                    print("error: \(error.localizedDescription)")
                                }
                })
            }
        }
    }

    // MARK: - loadServerSettings
    func loadServerSettings() {
        if gameType == .online {
            let url = URL(string: "http://localhost:8080/ws")!
            let request = URLRequest(url: url)
            socket = WebSocket(request: request)
            socket.delegate = self
            socket.connect()
        }
    }
}
