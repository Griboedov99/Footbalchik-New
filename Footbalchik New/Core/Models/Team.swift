//
//  Team.swift
//  Footbalchik
//
//  Created by Nick on 07.03.2026.
//


import UIKit
import Foundation

// MARK: - Team Model
struct Team: Codable, Identifiable, Equatable {
    let id: Int?
    let name: String?
    let shortName: String?
    let tla: String? // Трехбуквенный код (например, "ARS" для Arsenal)
    let crest: String? // URL логотипа
    let venue: String? // Домашний стадион
    let founded: Int? // Год основания
    let clubColors: String? // Цвета клуба
    let website: String? // Официальный сайт
    
    // Состав команды
    var squad: [Player]?
    
    // Тренерский штаб
    var coach: Coach?
    
    // Статистика (может обновляться отдельно)
    var statistics: TeamStatistics?
    
    // Для Equatable
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: Доп функционал
    // Отображаемое название (используем короче 15 символов или сокращенное,если оно есть)
    var displayName: String {
        // Приоритет: короткое полное имя -> короткое короткое имя -> TLA -> обрезанное имя
        let shortName = name ?? "Unknown"
        if shortName.count < 15 { return shortName }
        return tla ?? String(shortName.prefix(14)) + "..."
    }
    
    // Форматированный год основания
    var foundedDisplay: String {
        guard let founded = founded else { return "N/A" }
        return "Основан в \(founded) году"
    }
    
    // Цвета клуба в виде массива UIColor
    var clubColorsArray: [UIColor] {
        guard let clubColors = clubColors else { return [] }
        
        // Парсим строку типа "Red / White"
        let colorStrings = clubColors.components(separatedBy: " / ")
        return colorStrings.compactMap { colorName in
            switch colorName.lowercased() {
            case "red": return .systemRed
            case "white": return .white
            case "blue": return .systemBlue
            case "green": return .systemGreen
            case "yellow": return .systemYellow
            case "black": return .black
            case "purple": return .systemPurple
            case "orange": return .systemOrange
            case "pink": return .systemPink
            case "gray", "grey": return .systemGray
            default: return nil
            }
        }
    }
    
    // Основной цвет клуба (первый из списка)
    var primaryColor: UIColor? {
        return clubColorsArray.first
    }
    
    // Игроки по позициям
    var playersByPosition: [Player.PlayerPosition: [Player]] {
        var result: [Player.PlayerPosition: [Player]] = [:]
        
        guard let squad = squad else { return result }
        
        for player in squad {
            guard let position = player.position else { continue }
            result[position, default: []].append(player)
        }
        
        return result
    }
    
    // Основной состав (11 игроков - упрощенная логика)
    var startingEleven: [Player] {
        // В реальном приложении здесь может быть сложная логика
        // с учетом последних матчей, травм и т.д.
        return squad?.filter { $0.position != nil }.prefix(11).map { $0 } ?? []
    }
}
