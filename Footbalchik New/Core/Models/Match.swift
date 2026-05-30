//
//  Match.swift
//  Footbalchik
//
//  Created by Nick on 07.03.2026.
//


import UIKit

import Foundation

struct Match: Codable, Identifiable {
    let id: Int
    let homeTeam: Team
    let awayTeam: Team
    let competition: Competition
    let utcDate: Date
    let status: MatchStatus
    let score: Score?
    let venue: String?
    let attendance: Int?
    let referees: [Referee]?
}

struct Score: Codable {
    let winner: String?
    let duration: String?
    let fullTime: ScoreTime?
    let halfTime: ScoreTime?

    var displayText: String? {
        guard
            let home = fullTime?.home,
            let away = fullTime?.away
        else {
            return nil
        }

        return "\(home) : \(away)"
    }
}

struct ScoreTime: Codable {
    let home: Int?
    let away: Int?
}

struct Competition: Codable {}

struct Referee: Codable, Identifiable {
    let id: Int
    let name: String
}

enum MatchStatus: String, Codable {
    case scheduled = "SCHEDULED"
    case timed = "TIMED"
    case live = "LIVE"
    case inPlay = "IN_PLAY"
    case paused = "PAUSED"
    case finished = "FINISHED"
    case postponed = "POSTPONED"
    case cancelled = "CANCELLED"

    var displayName: String {
        switch self {
        case .scheduled, .timed:
            return "Запланирован"
        case .live, .inPlay:
            return "LIVE"
        case .paused:
            return "Перерыв"
        case .finished:
            return "Завершен"
        case .postponed:
            return "Перенесен"
        case .cancelled:
            return "Отменен"
        }
    }

    var isLive: Bool {
        self == .live || self == .inPlay
    }
}

// MARK: калькулятор позиций
struct FormationCalculator {

    static func positions(for formation: String) -> [CGPoint] {

        let lines = formation
            .split(separator: "-")
            .compactMap { Int($0) }

        var result: [CGPoint] = []

        // GK
        result.append(CGPoint(x: 0.5, y: 0.95))

        let lineSpacing: CGFloat = 0.7 / CGFloat(lines.count)
        var currentY: CGFloat = 0.7

        for playersInLine in lines {

            let step = 1.0 / CGFloat(playersInLine + 1)

            for i in 0..<playersInLine {

                let x = step * CGFloat(i + 1)

                result.append(
                    CGPoint(x: x, y: currentY)
                )
            }

            currentY -= lineSpacing
        }

        return result
    }

    static func position(for place: Int, formation: String) -> CGPoint {

        let positions = positions(for: formation)

        guard place > 0 && place <= positions.count else {
            return CGPoint(x: 0.5, y: 0.5)
        }

        return positions[place - 1]
    }
}

// MARK: - Составы команд
struct Lineups: Codable {
    let home: TeamLineup
    let away: TeamLineup
}

struct TeamLineup: Codable {
    let teamId: String
    let formation: String?
    let startingXI: [PlayerOnField]
    let substitutes: [PlayerOnField]
    let coach: Coach?

    
    // Игроки по позициям для отображения на поле
    var playersByPosition: [PlayerPosition: [PlayerOnField]] {
        Dictionary(grouping: startingXI, by: { $0.position })
    }
    
    // Основной состав в порядке номеров
    var sortedStartingXI: [PlayerOnField] {
        startingXI.sorted { ($0.shirtNumber ?? 99) < ($1.shirtNumber ?? 99) }
    }
}

struct PlayerOnField: Codable, Identifiable {
    let id: String
    let teamId: String
    let name: String
    let firstName: String?
    let lastName: String?
    let shirtNumber: Int?
    let position: PlayerPosition
    let formationPlace: Int?
    let formation: String?
    let captain: Bool
    var rating: Double?
    var goals: Int?
    var assists: Int?
    var yellowCard: Bool
    var redCard: Bool

    var fieldPosition: CGPoint {
        guard let formation, let formationPlace else {
            return CGPoint(x: 0.5, y: 0.5)
        }

        return FormationCalculator.position(
            for: formationPlace,
            formation: formation
        )
    }
}

enum PlayerPosition: String, Codable {
    case goalkeeper = "Goalkeeper"
    case defender = "Defender"
    case midfielder = "Midfielder"
    case forward = "Forward"
    
    var icon: String {
        switch self {
        case .goalkeeper: return "🧤"
        case .defender: return "🛡️"
        case .midfielder: return "⚡"
        case .forward: return "⚽"
        }
    }
}

// MARK: - События матча
struct MatchEvent: Codable, Identifiable {
    let id: String
    let type: EventType
    let playerId: String
    let playerName: String
    let teamId: String
    let minute: Int
    let additionalMinute: Int?
    let assistPlayerId: String?
    let assistPlayerName: String?
    
    enum EventType: String, Codable {
        case goal = "GOAL"
        case yellowCard = "YELLOW_CARD"
        case redCard = "RED_CARD"
        case substitution = "SUBSTITUTION"
        case penalty = "PENALTY"
        case ownGoal = "OWN_GOAL"
        
        var icon: String {
            switch self {
            case .goal: return "⚽"
            case .yellowCard: return "🟨"
            case .redCard: return "🟥"
            case .substitution: return "🔄"
            case .penalty: return "🎯"
            case .ownGoal: return "🥅"
            }
        }
    }
}
