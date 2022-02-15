import CoreData

class CoreDataStack {

    static let shared = CoreDataStack()

    private init() { }

    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                debugPrint(error)
                return
            }
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        })
        return container
    }()

    func saveCoreData() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            debugPrint(error)
        }
    }

    func viewContext() -> NSFetchedResultsController<GamingSessions> {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<GamingSessions>(entityName: "GamingSessions")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "winner", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error")
        }
        return fetchedResultsController
    }
}
