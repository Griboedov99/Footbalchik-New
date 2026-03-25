//
//  FavoriteTeamStorage.swift
//  Footbalchik New
//
//  Created by Nick on 18.05.2026.
//


import Foundation

protocol FavoriteTeamStorage {
    func addFavorite(team: Team, completion: @escaping (Result<Void, Error>) -> Void)
    func removeFavorite(teamId: Int, completion: @escaping (Result<Void, Error>) -> Void)
    func isFavorite(teamId: Int, completion: @escaping (Result<Bool, Error>) -> Void)
    func getAllFavorites(completion: @escaping (Result<[Team], Error>) -> Void)
    
    // Синхронные версии для простых случаев (опционально)
    func isFavoriteSync(teamId: Int) -> Bool
    func getAllFavoritesSync() -> [Team]
}
