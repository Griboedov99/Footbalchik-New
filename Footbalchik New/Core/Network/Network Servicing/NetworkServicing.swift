//
//  NetworkServicing.swift
//  Footbalchik
//
//  Created by Nick on 21.03.2026.
//


protocol NetworkServicing {
    func request<T: Decodable>(
        _ endpoint: APIRouter,
        completion: @escaping (Result<T, Error>) -> Void
    )
}
