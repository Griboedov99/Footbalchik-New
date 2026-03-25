//
//  AppDIContainer.swift
//  Footbalchik
//
//  Created by Nick on 22.03.2026.
//


final class AppDIContainer {
    let network: NetworkService
    let matchService: MatchService
    let teamService: TeamService
    let leagueService: LeagueServicing
    let favoriteStorage: FavoriteTeamStorage
    
    init() {
        self.network = NetworkService(apiKey: "cf6c0f5142f746f3bb192baf9c582753")
        self.matchService = MatchService(network: network)
        self.teamService = TeamService(network: network)
        self.leagueService = LeagueService(network: network)
        self.favoriteStorage = CoreDataFavoriteTeamStorage()
    }
}
