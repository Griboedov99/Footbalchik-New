//
//  StandingsResponse.swift
//  Footbalchik New
//
//  Created by Nick on 30.05.2026.
//


//  Standings.swift
import Foundation

struct StandingsResponse: Decodable {
    let standings: [Standing]
}

struct Standing: Decodable {
    let stage: String
    let type: String          // "TOTAL", "HOME", "AWAY"
    let group: String?
    let table: [TableRow]
}

struct TableRow: Decodable {
    let position: Int
    let team: StandingTeam
    let playedGames: Int
    let form: String?         // напр. "W,W,L,D,W"
    let won: Int
    let draw: Int
    let lost: Int
    let points: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let goalDifference: Int
}

struct StandingTeam: Decodable {
    let id: Int
    let name: String
    let shortName: String?
    let tla: String?
    let crest: String?
}

// Результат одного из последних матчей
enum FormResult {
    case win, draw, loss

    init?(_ ch: Character) {
        switch ch {
        case "W": self = .win
        case "D": self = .draw
        case "L": self = .loss
        default:  return nil
        }
    }
}

extension TableRow {
    // Последние 5 матчей, слева направо от старого к новому
    var recentForm: [FormResult] {
        let parsed = (form ?? "")
            .split(separator: ",")
            .compactMap { $0.trimmingCharacters(in: .whitespaces).first }
            .compactMap(FormResult.init)
        return Array(parsed.suffix(5))
        // Если на экране форма окажется в обратном порядке — добавь .reversed()
    }
}