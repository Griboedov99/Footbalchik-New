//
//  SearchTeamsViewModel.swift
//  Footbalchik New
//
//  Created by Nick on 18.05.2026.
//


import Foundation

final class SearchTeamsViewModel {
    private let teamService: TeamServicing
    private let favoriteStorage: FavoriteTeamStorage
    
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    
    private(set) var teams: [Team] = []
    private var favoriteStatuses: [Int: Bool] = [:]
    private var currentQuery: String = ""
    
    init(teamService: TeamServicing, favoriteStorage: FavoriteTeamStorage) {
        self.teamService = teamService
        self.favoriteStorage = favoriteStorage
        loadFavoriteStatuses()
    }
    
    private func loadFavoriteStatuses() {
        favoriteStorage.getAllFavorites { [weak self] result in
            switch result {
            case .success(let favorites):
                self?.favoriteStatuses = Dictionary(uniqueKeysWithValues: favorites.map { ($0.id ?? 0, true) })
                self?.onDataUpdated?()
            case .failure(let error):
                print("Failed to load favorites: \(error)")
            }
        }
    }
    
    func loadSuggestions() {
        onLoadingChanged?(true)
        teamService.suggestedTeams { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingChanged?(false)
                switch result {
                case .success(let teams):
                    self?.teams = teams
                    self?.onDataUpdated?()
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }

    func searchTeams(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            loadSuggestions()        // ← было: teams = []; onDataUpdated?()
            return
        }

        currentQuery = trimmed
        onLoadingChanged?(true)

        teamService.searchTeams(query: trimmed) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingChanged?(false)
                switch result {
                case .success(let teams):
                    self?.teams = teams
                    self?.onDataUpdated?()
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func isFavorite(teamId: Int) -> Bool {
        return favoriteStatuses[teamId] ?? false
    }
    
    func toggleFavorite(teamId: Int, team: Team) {
        let currentlyFavorite = isFavorite(teamId: teamId)
        
        if currentlyFavorite {
            favoriteStorage.removeFavorite(teamId: teamId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.favoriteStatuses[teamId] = false
                        self?.onDataUpdated?()
                    case .failure(let error):
                        self?.onError?(error.localizedDescription)
                    }
                }
            }
        } else {
            favoriteStorage.addFavorite(team: team) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.favoriteStatuses[teamId] = true
                        self?.onDataUpdated?()
                    case .failure(let error):
                        self?.onError?(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func refreshFavoriteStatuses() {
        loadFavoriteStatuses()
    }
}
