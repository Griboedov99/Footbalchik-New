//
//  StandingsService.swift
//  Footbalchik New
//
//  Created by Nick on 20.05.2026.
//


import Foundation

protocol StandingsServicing {
    func fetchStandings(league: League,
                        forceRefresh: Bool,
                        completion: @escaping (Result<[TableRow], Error>) -> Void)
}

final class StandingsService: StandingsServicing {
    private let network: NetworkServicing
    private struct CacheEntry { let rows: [TableRow]; let timestamp: Date }
    private var cache: [Int: CacheEntry] = [:]
    private let ttl: TimeInterval = 300   // таблица меняется редко — 5 минут

    init(network: NetworkServicing) { self.network = network }

    func fetchStandings(league: League,
                        forceRefresh: Bool = false,
                        completion: @escaping (Result<[TableRow], Error>) -> Void) {
        if !forceRefresh,
           let entry = cache[league.id],
           Date().timeIntervalSince(entry.timestamp) < ttl {
            completion(.success(entry.rows)); return
        }

        network.request(APIRouter.standings(league: league)) { [weak self] (result: Result<StandingsResponse, Error>) in
            switch result {
            case .success(let response):
                // берём только общую таблицу; для кубков с группами тут будет несколько TOTAL по группам
                let rows = response.standings.first(where: { $0.type == "TOTAL" })?.table ?? []
                self?.cache[league.id] = CacheEntry(rows: rows, timestamp: Date())
                completion(.success(rows))
            case .failure(let error):
                if let entry = self?.cache[league.id] {
                    completion(.success(entry.rows))   // fallback на старые данные
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}
