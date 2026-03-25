//
//  TeamCardCell.swift
//  Footbalchik New
//
//  Created by Nick on 18.05.2026.
//


import UIKit

final class TeamCardCell: UICollectionViewCell {
    static let reuseId = "TeamCardCell"
    
    private let glassCard = GlassCardView()
    private let logoImageView = UIImageView()
    private let nameLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    
    private var currentTeam: Team?
    var onFavoriteTapped: ((Team, Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        contentView.addSubview(glassCard)
        glassCard.pin(to: contentView)
        
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.backgroundColor = .clear
        glassCard.contentView.addSubview(logoImageView)
        
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.numberOfLines = 2
        glassCard.contentView.addSubview(nameLabel)
        
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.tintColor = .systemRed
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        glassCard.contentView.addSubview(favoriteButton)
        
        // Layout
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor, constant: 16),
            logoImageView.centerYAnchor.constraint(equalTo: glassCard.contentView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 50),
            logoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -12),
            nameLabel.centerYAnchor.constraint(equalTo: glassCard.contentView.centerYAnchor),
            
            favoriteButton.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: glassCard.contentView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        nameLabel.text = nil
        favoriteButton.isSelected = false
        currentTeam = nil
        onFavoriteTapped = nil
    }
    
    func configure(with team: Team, isFavorite: Bool) {
        currentTeam = team
        nameLabel.text = team.name
        favoriteButton.isSelected = isFavorite
        
        if let crestUrlString = team.crest, let url = URL(string: crestUrlString) {
            loadImage(from: url)
        } else {
            logoImageView.image = UIImage(systemName: "sportscourt")
            logoImageView.tintColor = .white
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.logoImageView.image = image
            }
        }.resume()
    }
    
    @objc private func favoriteTapped() {
        guard let team = currentTeam else { return }
        let newState = !favoriteButton.isSelected
        favoriteButton.isSelected = newState
        onFavoriteTapped?(team, newState)
    }
}
