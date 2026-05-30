//
//  FavoritesViewModel.swift
//  Footbalchik New
//
//  Created by Nick on 30.05.2026.
//


//
//  FavoritesViewModel.swift
//  Footbalchik New
//

import Foundation

final class FavoritesViewModel {

    private let favoriteStorage: FavoriteTeamStorage

    // MARK: - Outputs
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?

    private(set) var favorites: [Team] = []
    var isEmpty: Bool { favorites.isEmpty }

    init(favoriteStorage: FavoriteTeamStorage) {
        self.favoriteStorage = favoriteStorage
    }

    func loadFavorites() {
        onLoadingChanged?(true)
        favoriteStorage.getAllFavorites { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingChanged?(false)
                switch result {
                case .success(let teams):
                    self?.favorites = teams
                    self?.onDataUpdated?()
                case .failure(let error):
                    print("Failed to load favorites: \(error)")
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }

    func team(at index: Int) -> Team {
        favorites[index]
    }

    func removeFavorite(at index: Int, completion: @escaping (Bool) -> Void) {
        let team = favorites[index]
        guard let teamId = team.id else { completion(false); return }

        favoriteStorage.removeFavorite(teamId: teamId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // удаляем из локального массива, чтобы контроллер мог точечно
                    // обновить коллекцию (deleteItems), а не перезагружать всё
                    self?.favorites.remove(at: index)
                    completion(true)
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                    completion(false)
                }
            }
        }
    }
}