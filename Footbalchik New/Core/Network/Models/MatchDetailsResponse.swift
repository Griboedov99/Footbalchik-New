//
//  MatchDetailsResponse.swift
//  Footbalchik New
//
//  Created by Nick on 25.03.2026.
//


import Foundation

struct MatchDetailsResponse: Decodable {
    let id: Int
    let homeTeam: MatchDetailsTeam
    let awayTeam: MatchDetailsTeam
}

struct MatchDetailsTeam: Decodable {
    let id: Int
    let name: String
    let shortName: String?
    let tla: String?
    let crest: String?
    let lineup: [MatchDetailsPlayer]?
    let bench: [MatchDetailsPlayer]?
    let formation: String?
}

struct MatchDetailsPlayer: Decodable {
    let id: Int
    let name: String
    let position: String?
    let shirtNumber: Int?
}
