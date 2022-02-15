import CoreData
import UIKit

class TableViewGameSession: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBAction func back(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return coreData.viewContext().sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreData.viewContext().fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let gameSession = coreData.viewContext().object(at: indexPath)
        var type = String()
        switch gameSession.gameType {
        case 1:
            type = "2Player"
        case 2:
            type = "Offline"
        default:
            type = "Onlline"
        }
        if gameSession.winner == true {
            cell.textLabel?.text = "Winner: You, Loser: Player2, GameType: \(type)"
            cell.textLabel?.font = UIFont(name: "ArialMT", size: 14)
            cell.textLabel?.numberOfLines = 2
            cell.detailTextLabel?.text = "Winner: \(gameSession.btmScore), Loser: \(gameSession.topScore), Ricochets: \(gameSession.ricochets)"
        } else {
            cell.textLabel?.text = "Winner: Player2, Loser: You, GameType: \(type)"
            cell.textLabel?.font = UIFont(name: "ArialMT", size: 14)
            cell.textLabel?.numberOfLines = 2
            cell.detailTextLabel?.text = "Winner: \(gameSession.topScore), Loser: \(gameSession.btmScore), Ricochets: \(gameSession.ricochets)"
        }
        return cell
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table.reloadData()
    }

    var coreData = CoreDataStack.shared

    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
