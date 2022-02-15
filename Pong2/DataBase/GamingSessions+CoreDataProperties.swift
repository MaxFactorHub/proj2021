import Foundation
import CoreData

extension GamingSessions {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GamingSessions> {
        return NSFetchRequest<GamingSessions>(entityName: "GamingSessions")
    }
    @NSManaged public var ricochets: Int16
    @NSManaged public var winner: Bool
    @NSManaged public var topScore: Int16
    @NSManaged public var btmScore: Int16
    @NSManaged public var gameType: Int16

}
