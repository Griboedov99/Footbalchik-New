//
//  HomeViewModel.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import Foundation

final class HomeViewModel {
    private let matchService: MatchService
    private let leagueService: LeagueServicing
    private let favoriteStorage: FavoriteTeamStorage
    
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onLeaguesLoaded: (([League]) -> Void)?
    
    private(set) var favoriteMatches: [Match] = []
    private(set) var leagueMatches: [Match] = []
    private(set) var currentLeague: League?
    private(set) var availableLeagues: [League] = []
    private(set) var favoriteTeamIds: Set<Int> = []
    
    private var isLoading = false
    
    init(
        matchService: MatchService,
        leagueService: LeagueServicing,
        favoriteStorage: FavoriteTeamStorage
    ) {
        self.matchService = matchService
        self.leagueService = leagueService
        self.favoriteStorage = favoriteStorage
        loadInitialData()
    }
    
    private func loadInitialData() {
        // Загружаем избранные и лиги параллельно
        let group = DispatchGroup()
        
        group.enter()
        loadFavoriteTeamIds {
            group.leave()
        }
        
        group.enter()
        loadAvailableLeagues {
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            // После загрузки избранных и лиг, загружаем матчи для первой лиги
            if let firstLeague = self?.availableLeagues.first {
                self?.currentLeague = firstLeague
                self?.onLeaguesLoaded?(self?.availableLeagues ?? [])
                self?.loadData(for: firstLeague)
            }
        }
    }
    
    private func loadFavoriteTeamIds(completion: @escaping () -> Void) {
        favoriteStorage.getAllFavorites { [weak self] result in
            switch result {
            case .success(let teams):
                self?.favoriteTeamIds = Set(teams.map { $0.id ?? 0 })
            case .failure(let error):
                print("Failed to load favorites: \(error)")
            }
            completion()
        }
    }
    
    private func loadAvailableLeagues(completion: @escaping () -> Void) {
        leagueService.fetchAvailableLeagues { [weak self] result in
            switch result {
            case .success(let leagues):
                self?.availableLeagues = leagues
            case .failure(let error):
                print("Failed to load leagues: \(error)")
                // Используем рабочие лиги по умолчанию
                self?.availableLeagues = League.workingLeagues
            }
            completion()
        }
    }
    
    func loadData(for league: League, forceRefresh: Bool = false) {
        guard !isLoading else { return }

        currentLeague = league
        isLoading = true
        onLoadingChanged?(true)

        matchService.fetchMatches(league: league, forceRefresh: forceRefresh) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.onLoadingChanged?(false)

                switch result {
                case .success(let allMatches):
                    self?.filterMatches(allMatches)
                    self?.onDataUpdated?()
                case .failure(let error):
                    print("Failed to load matches for \(league.name): \(error)")
                    self?.favoriteMatches = []
                    self?.leagueMatches = []
                    self?.onDataUpdated?()
                    self?.onError?("Failed to load matches for \(league.name)")
                }
            }
        }
    }

    // Только переразбивка уже имеющихся матчей — без сети
    func refreshFavorites() {
        loadFavoriteTeamIds { [weak self] in
            guard let self else { return }
            let all = self.favoriteMatches + self.leagueMatches
            self.filterMatches(all)
            self.onDataUpdated?()
        }
    }
    
    private func filterMatches(_ allMatches: [Match]) {
        favoriteMatches = allMatches.filter { match in
            favoriteTeamIds.contains(match.homeTeam.id ?? 0) ||
            favoriteTeamIds.contains(match.awayTeam.id ?? 0)
        }
        
        leagueMatches = allMatches.filter { match in
            !favoriteTeamIds.contains(match.homeTeam.id ?? 0) &&
            !favoriteTeamIds.contains(match.awayTeam.id ?? 0)
        }
    }
}
