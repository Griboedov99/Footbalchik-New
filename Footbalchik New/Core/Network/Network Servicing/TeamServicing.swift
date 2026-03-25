//
//  TeamServicing.swift
//  Footbalchik New
//
//  Created by Nick on 06.05.2026.
//


protocol TeamServicing {
    func searchTeams(query: String, completion: @escaping (Result<[Team], Error>) -> Void)
    func suggestedTeams(completion: @escaping (Result<[Team], Error>) -> Void)
}
