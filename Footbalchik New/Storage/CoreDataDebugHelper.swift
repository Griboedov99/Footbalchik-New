//
//  CoreDataDebugHelper.swift
//  Footbalchik New
//
//  Created by Nick on 03.05.2026.
//


import CoreData

struct CoreDataDebugHelper {
    static func printAllFavorites() {
        let context = CoreDataStack.shared.viewContext
        let request: NSFetchRequest<FavoriteTeam> = FavoriteTeam.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            print("Все избранные команды в Core Data:")
            for team in results {
                print("   - \(team.name ?? "Unknown") (ID: \(team.id))")
            }
        } catch {
            print("Ошибка при загрузке избранных: \(error)")
        }
    }
    
    static func clearAllFavorites() {
        let context = CoreDataStack.shared.viewContext
        let request: NSFetchRequest<FavoriteTeam> = FavoriteTeam.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("Все избранные команды удалены")
        } catch {
            print("Ошибка при удалении: \(error)")
        }
    }
}
