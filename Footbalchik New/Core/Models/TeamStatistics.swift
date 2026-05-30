//
//  TeamStatistics.swift
//  Footbalchik
//
//  Created by Nick on 07.03.2026.
//


import UIKit

struct TeamStatistics: Codable {
    let wins: Int?
    let draws: Int?
    let losses: Int?
    let goalsScored: Int?
    let goalsConceded: Int?
    let cleanSheets: Int?
    
    var matchesPlayed: Int {
        (wins ?? 0) + (draws ?? 0) + (losses ?? 0)
    }
    
    var goalDifference: Int {
        (goalsScored ?? 0) - (goalsConceded ?? 0)
    }
    
    var form: [MatchResult]? // Последние 5 матчей
    
    enum MatchResult: String, Codable {
        case win = "W"
        case draw = "D"
        case loss = "L"
        
        var displayString: String {
            switch self {
            case .win: return "Победа"
            case .draw: return "Ничья"
            case .loss: return "Поражение"
            }
        }
        
        var color: UIColor {
            switch self {
            case .win: return .systemGreen
            case .draw: return .systemOrange
            case .loss: return .systemRed
            }
        }
    }
}
