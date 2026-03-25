//
//  LeagueServicing.swift
//  Footbalchik New
//
//  Created by Nick on 15.04.2026.
//


import Foundation

protocol LeagueServicing {
    func fetchAvailableLeagues(completion: @escaping (Result<[League], Error>) -> Void)
}

final class LeagueService: LeagueServicing {
    private let network: NetworkServicing
    private var cachedLeagues: [League]?
    
    init(network: NetworkServicing) {
        self.network = network
    }
    
    func fetchAvailableLeagues(completion: @escaping (Result<[League], Error>) -> Void) {
        // Возвращаем кэш если есть
        if let cachedLeagues = cachedLeagues {
            completion(.success(cachedLeagues))
            return
        }
        
        // Используем только рабочие лиги, которые точно есть в API
        let workingLeagues = League.workingLeagues
        cachedLeagues = workingLeagues
        completion(.success(workingLeagues))
    }
}
