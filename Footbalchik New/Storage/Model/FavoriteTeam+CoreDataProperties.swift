//
//  func.swift
//  Footbalchik New
//
//  Created by Nick on 18.04.2026.
//


import Foundation
import CoreData

extension FavoriteTeam {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteTeam> {
        return NSFetchRequest<FavoriteTeam>(entityName: "FavoriteTeam")
    }
}
