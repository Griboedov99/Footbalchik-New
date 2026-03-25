//
//  FavoriteTeam.swift
//  Footbalchik New
//
//  Created by Nick on 25.05.2026.
//


//
//  FavoriteTeam+CoreDataClass.swift
//  Footbalchik
//

import Foundation
import CoreData

@objc(FavoriteTeam)
public class FavoriteTeam: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var shortName: String?
    @NSManaged public var crestUrl: String?
    @NSManaged public var dateAdded: Date?
}