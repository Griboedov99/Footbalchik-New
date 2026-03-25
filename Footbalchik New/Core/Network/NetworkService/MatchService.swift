//
//  MatchService.swift
//  Footbalchik
//
//  Created by Nick on 21.03.2026.
//


import Foundation

final class MatchService {
    private let network: NetworkServicing

    // Кеш: матчи по id лиги + момент загрузки
    private struct CacheEntry {
        let matches: [Match]
        let timestamp: Date
    }
    private var cache: [Int: CacheEntry] = [:]
    private let ttl: TimeInterval = 120   // считаем данные свежими 2 минуты

    init(network: NetworkServicing) {
        self.network = network
    }

    func fetchMatches(
        league: League,
        forceRefresh: Bool = false,
        completion: @escaping (Result<[Match], Error>) -> Void
    ) {
        // Отдаём из кеша, если запись свежая и это не принудительное обновление
        if !forceRefresh,
           let entry = cache[league.id],
           Date().timeIntervalSince(entry.timestamp) < ttl {
            completion(.success(entry.matches))
            return
        }

        network.request(APIRouter.matches(league: league)) { [weak self] (result: Result<MatchesResponse, Error>) in
            switch result {
            case .success(let response):
                self?.cache[league.id] = CacheEntry(matches: response.matches, timestamp: Date())
                completion(.success(response.matches))
            case .failure(let error):
                // При ошибке отдаём прошлый кеш, если он есть — лучше старые данные, чем пустой экран
                if let entry = self?.cache[league.id] {
                    completion(.success(entry.matches))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchMatchDetails(
        matchId: Int,
        completion: @escaping (Result<MatchDetailsResponse, Error>) -> Void
    ) {
        network.request(APIRouter.matchDetails(id: matchId)) { (result: Result<MatchDetailsResponse, Error>) in
            switch result {
            case .success(let details):
                completion(.success(details))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
