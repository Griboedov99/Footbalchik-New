//
//  Player.swift
//  Footbalchik
//
//  Created by Nick on 07.03.2026.
//


struct Player: Codable, Identifiable {
    let id: Int
    let name: String
    let firstName: String?
    let lastName: String?
    let dateOfBirth: String?
    let nationality: String?
    let position: PlayerPosition?
    let shirtNumber: Int?
    let marketValue: Double? // Стоимость в евро
    let contractUntil: String?
    
    enum PlayerPosition: String, Codable {
        case goalkeeper = "Goalkeeper"
        case defender   = "Defender"
        case midfielder = "Midfielder"
        case forward    = "Forward"
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = PlayerPosition(rawValue: raw) ?? .unknown   // не падаем на чужих значениях
        }

        var displayName: String {
            switch self {
            case .goalkeeper: return "Вратарь"
            case .defender:   return "Защитник"
            case .midfielder: return "Полузащитник"
            case .forward:    return "Нападающий"
            case .unknown:    return "—"
            }
        }

        var shortName: String {
            switch self {
            case .goalkeeper: return "GK"
            case .defender:   return "DF"
            case .midfielder: return "MF"
            case .forward:    return "FW"
            case .unknown:    return "?"
            }
        }
    }
}
