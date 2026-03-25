//
//  FavoriteTeam+Extensions.swift
//  Footbalchik
//

import CoreData

extension FavoriteTeam {
    static func fetchRequest() -> NSFetchRequest<FavoriteTeam> {
        NSFetchRequest<FavoriteTeam>(entityName: "FavoriteTeam")
    }
    
    static func fetchById(_ id: Int, in context: NSManagedObjectContext) -> FavoriteTeam? {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    static func fetchAll(in context: NSManagedObjectContext) -> [FavoriteTeam] {
        let request = fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return (try? context.fetch(request)) ?? []
    }
    
    static func deleteAll(in context: NSManagedObjectContext) {
        let request = fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete all favorites: \(error)")
        }
    }
    
    static func createOrUpdate(
        from team: Team,
        in context: NSManagedObjectContext
    ) -> FavoriteTeam {
        if let existing = fetchById(team.id, in: context) {
            // Обновляем существующую запись
            existing.name = team.name
            existing.crestUrl = team.crest
            existing.shortName = team.shortName
            return existing
        } else {
            // Создаем новую
            let favorite = FavoriteTeam(context: context)
            favorite.id = Int64(team.id)
            favorite.name = team.name
            favorite.crestUrl = team.crest
            favorite.shortName = team.shortName
            favorite.dateAdded = Date()
            return favorite
        }
    }
    
    func toTeam() -> Team {
        Team(
            id: Int(self.id),
            name: self.name ?? "",
            shortName: self.shortName,
            tla: nil,
            crest: self.crestUrl,
            address: nil,
            website: nil,
            founded: nil,
            clubColors: nil,
            venue: nil
        )
    }
}