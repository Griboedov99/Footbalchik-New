//
//  HomeLayoutFactory.swift
//  Footbalchik
//
//  Created by Nick on 21.03.2026.
//


import UIKit

enum HomeLayoutFactory {
    static func create() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = HomeSection(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .favorites:
                return favoritesLayout()
            case .matches:
                return matchesLayout()
            }
        }
    }
    
    private static func favoritesLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .absolute(280),
                heightDimension: .absolute(120) // Меняем с 130 на 120
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .absolute(280),
                heightDimension: .absolute(120) // Меняем с 130 на 120
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 20,
            bottom: 20,
            trailing: 20
        )
        
        return section
    }
    
    private static func matchesLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(120)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(120)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 20,
            leading: 20,
            bottom: 20,
            trailing: 20
        )
        
        return section
    }
}
