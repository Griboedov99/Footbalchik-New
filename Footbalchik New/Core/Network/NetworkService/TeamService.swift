//
//  TeamService.swift
//  Footbalchik New
//
//  Created by Nick on 06.05.2026.
//


import Foundation
import UIKit

final class TeamService: TeamServicing {
    private let network: NetworkServicing
    private var cachedTeams: [Team] = []
    private var didLoad = false
    private var suggestions: [Team] = []

    init(network: NetworkServicing) { self.network = network }

    func searchTeams(query: String, completion: @escaping (Result<[Team], Error>) -> Void) {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { completion(.success([])); return }

        ensureLoaded { [weak self] in
            guard let self else { return }
            let results = self.cachedTeams.filter {
                $0.name?.lowercased().contains(q) ?? false ||
                ($0.shortName?.lowercased().contains(q) ?? false)
            }
            completion(.success(results))
        }
    }

    private func ensureLoaded(completion: @escaping () -> Void) {
        if didLoad { completion(); return }

        let group = DispatchGroup()
        var byId: [Int: Team] = [:]
        let lock = NSLock()
        var anySuccess = false

        for league in League.popularLeagues {
            group.enter()
            network.request(APIRouter.competitionTeams(league: league)) { (result: Result<TeamsResponse, Error>) in
                switch result {
                case .success(let resp):
                    lock.lock()
                    anySuccess = true
                    for t in resp.teams { if let id = t.id { byId[id] = t } }
                    lock.unlock()
                case .failure(let error):
                    print("❌ \(league.name):", error)   // покажет причину
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.cachedTeams = Array(byId.values)
            self?.didLoad = anySuccess        // не запираем пустой кеш при сбое
            completion()
        }
    }

    func suggestedTeams(completion: @escaping (Result<[Team], Error>) -> Void) {
        ensureLoaded { [weak self] in
            guard let self else { return }
            if self.suggestions.isEmpty {
                // случайная выборка один раз за сессию — чтобы список не «прыгал»
                self.suggestions = Array(self.cachedTeams.shuffled().prefix(20))
            }
            completion(.success(self.suggestions))
        }
    }
}
