//
//  APIRouter.swift
//  Footbalchik
//
//  Created by Nick on 21.03.2026.
//


import Foundation

enum APIRouter {
    case matches(league: League)
    case matchDetails(id: Int)
    case teams(search: String)
    case competitionTeams(league: League)
    case standings(league: League)

    private var baseURL: String { "https://api.football-data.org/v4" }

    var url: URL? {
        switch self {
        case .matches(let league):
            return URL(string: "\(baseURL)/competitions/\(league.id)/matches")
        case .matchDetails(let id):
            return URL(string: "\(baseURL)/matches/\(id)")
        case .competitionTeams(let league):
            return URL(string: "\(baseURL)/competitions/\(league.id)/teams")
        case .standings(let league):
            return URL(string: "\(baseURL)/competitions/\(league.id)/standings")
        case .teams(let search):
            var components = URLComponents(string: "\(baseURL)/teams")
            components?.queryItems = [URLQueryItem(name: "search", value: search)]
            return components?.url
        }
    }

    var method: String { "GET" }

    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "X-Auth-Token": APIConfig.apiKey
        ]
    }
}
