//
//  CoreDataFavoriteTeamStorage.swift
//  Footbalchik New
//
//  Created by Nick on 22.04.2026.
//


import CoreData

final class CoreDataFavoriteTeamStorage: FavoriteTeamStorage {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Асинхронные методы
    
    func addFavorite(team: Team, completion: @escaping (Result<Void, Error>) -> Void) {
        let context = coreDataStack.newBackgroundContext()
        context.perform {
            // Пытаемся найти существующую запись
            let request: NSFetchRequest<FavoriteTeam> = FavoriteTeam.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", team.id ?? 0)
            request.fetchLimit = 1
            
            let existing = try? context.fetch(request).first
            
            let favorite: FavoriteTeam
            if let existing = existing {
                // Обновляем существующую
                favorite = existing
                favorite.name = team.name
                favorite.crestUrl = team.crest
                favorite.shortName = team.shortName
            } else {
                // Создаем новую
                favorite = FavoriteTeam(context: context)
                favorite.id = Int64(team.id ?? 0)
                favorite.name = team.name
                favorite.crestUrl = team.crest
                favorite.shortName = team.shortName
                favorite.dateAdded = Date()
            }
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func removeFavorite(teamId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let context = coreDataStack.newBackgroundContext()
        context.perform {
            let request: NSFetchRequest<FavoriteTeam> = FavoriteTeam.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", teamId)
            request.fetchLimit = 1
            
            if let favorite = try? context.fetch(request).first {
                context.delete(favorite)
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            }
        }
    }
    
    func isFavorite(teamId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<FavoriteTeam> = FavoriteTeam.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", teamId)
        request.fetchLimit = 1
        
        let count = (try? context.count(for: request)) ?? 0
        DispatchQueue.main.async {
            completion(.success(count > 0))
        }
    }
    
    func getAllFavorites(completion: @escaping (Result<[Team], Error>) -> Void) {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<FavoriteTeam> = FavoriteTeam.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let favorites = try context.fetch(request)
            let teams = favorites.map { favorite in
                Team(
                    id: Int(favorite.id),
                    name: favorite.name ?? "",
                    shortName: favorite.shortName,
                    tla: nil,
                    crest: favorite.crestUrl,
                    venue: nil,
                    founded: nil,
                    clubColors: nil,
                    website: nil
                )
            }
            DispatchQueue.main.async {
                completion(.success(teams))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Синхронные методы (для простоты использования)
    
    func isFavoriteSync(teamId: Int) -> Bool {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<FavoriteTeam> = FavoriteTeam.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", teamId)
        request.fetchLimit = 1
        return (try? context.count(for: request)) ?? 0 > 0
    }
    
    func getAllFavoritesSync() -> [Team] {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<FavoriteTeam> = FavoriteTeam.fetchRequest()
        
        do {
            let favorites = try context.fetch(request)
            return favorites.map { favorite in
                Team(
                    id: Int(favorite.id),
                    name: favorite.name ?? "",
                    shortName: favorite.shortName,
                    tla: nil,
                    crest: favorite.crestUrl,
                    venue: nil,
                    founded: nil,
                    clubColors: nil,
                    website: nil
                )
            }
        } catch {
            print("Failed to fetch favorites: \(error)")
            return []
        }
    }
}
