//
//  League.swift
//  Footbalchik New
//
//  Created by Nick on 06.05.2026.
//


import Foundation

struct League: Codable, Equatable, Hashable {
    let id: Int
    let name: String
    let code: String
    let type: String
    let emblem: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, code, type, emblem
    }
    
    // Предопределенные лиги с правильными ID из API football-data.org
    static let championsLeague = League(
        id: 2001,
        name: "UEFA Champions League",
        code: "CL",
        type: "CUP",
        emblem: "https://crests.football-data.org/CL.png"
    )
    
    static let premierLeague = League(
        id: 2021,
        name: "Premier League",
        code: "PL",
        type: "LEAGUE",
        emblem: "https://crests.football-data.org/PL.png"
    )
    
    static let laLiga = League(
        id: 2014,
        name: "La Liga",
        code: "PD",
        type: "LEAGUE",
        emblem: "https://crests.football-data.org/PD.png"
    )
    
    static let serieA = League(
        id: 2019,
        name: "Serie A",
        code: "SA",
        type: "LEAGUE",
        emblem: "https://crests.football-data.org/SA.png"
    )
    
    static let bundesliga = League(
        id: 2002,
        name: "Bundesliga",
        code: "BL1",
        type: "LEAGUE",
        emblem: "https://crests.football-data.org/BL1.png"
    )
    
    static let ligue1 = League(
        id: 2015,
        name: "Ligue 1",
        code: "FL1",
        type: "LEAGUE",
        emblem: "https://crests.football-data.org/FL1.png"
    )
    
    static let eredivisie = League(
        id: 2003,
        name: "Eredivisie",
        code: "DED",
        type: "LEAGUE",
        emblem: "https://crests.football-data.org/DED.png"
    )
    
    static let primeiraLiga = League(
        id: 2017,
        name: "Primeira Liga",
        code: "PPL",
        type: "LEAGUE",
        emblem: "https://crests.football-data.org/PPL.png"
    )
    
    static let championship = League(
        id: 2016,
        name: "Championship",
        code: "ELC",
        type: "LEAGUE",
        emblem: "https://crests.football-data.org/ELC.png"
    )
    
    // Российская Премьер Лига с правильным ID = 2195
    static let russianPremierLeague = League(
        id: 2195,  // Исправленный ID
        name: "Russian Premier League",
        code: "RPL",
        type: "LEAGUE",
        emblem: "https://crests.football-data.org/RPL.png"
    )
    
    // Все доступные лиги
    static let allLeagues: [League] = [
        .championsLeague,
        .premierLeague,
        .laLiga,
        .serieA,
        .bundesliga,
        .ligue1,
        .eredivisie,
        .primeiraLiga,
        .championship,
        .russianPremierLeague
    ]
    
    // Проверенные рабочие лиги
    static let workingLeagues: [League] = [
        .championsLeague,
        .premierLeague,
        .laLiga,
        .serieA,
        .bundesliga,
        .ligue1,
        .russianPremierLeague  // Теперь РПЛ включена
    ]
    
    // Популярные лиги для отображения (можно настроить порядок)
    static let popularLeagues: [League] = [
        .premierLeague,
        .laLiga,
        .bundesliga,
        .serieA,
        .ligue1,
        .championsLeague,
        .russianPremierLeague,
        .eredivisie,
        .primeiraLiga
    ]
}
