//
//  JerseyView.swift
//  Footbalchik New
//
//  Created by Nick on 28.04.2026.
//


import UIKit

final class JerseyView: UIView {
    
    private let containerView = UIView()
    private let numberLabel = UILabel()
    private let nameLabel = UILabel()
    private let jerseyImageView = UIImageView()
    
    enum JerseyStyle {
        case home
        case away
        case goalkeeper
        
        var backgroundColor: UIColor {
            switch self {
            case .home:
                return UIColor.systemRed
            case .away:
                return UIColor.systemBlue
            case .goalkeeper:
                return UIColor.systemGreen
            }
        }
        
        var numberColor: UIColor {
            return .white
        }
        
        var pattern: String? {
            switch self {
            case .home:
                return "⚽"
            case .away:
                return "★"
            case .goalkeeper:
                return "🧤"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // Контейнер с фоном футболки
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        
        // Добавляем паттерн на футболку
        let patternLabel = UILabel()
        patternLabel.font = .systemFont(ofSize: 40)
        patternLabel.textAlignment = .center
        patternLabel.alpha = 0.15
        containerView.addSubview(patternLabel)
        
        addSubview(containerView)
        
        // Номер игрока
        numberLabel.font = .systemFont(ofSize: 28, weight: .bold)
        numberLabel.textAlignment = .center
        numberLabel.textColor = .white
        numberLabel.shadowColor = UIColor.black.withAlphaComponent(0.3)
        numberLabel.shadowOffset = CGSize(width: 1, height: 1)
        containerView.addSubview(numberLabel)
        
        // Имя игрока (опционально)
        nameLabel.font = .systemFont(ofSize: 11, weight: .medium)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1
        containerView.addSubview(nameLabel)
        
        // Эмблема клуба (маленькая иконка)
        jerseyImageView.contentMode = .scaleAspectFit
        jerseyImageView.tintColor = .white.withAlphaComponent(0.3)
        containerView.addSubview(jerseyImageView)
        
        setupConstraints()
        
        // Добавляем тень
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 4
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        jerseyImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            numberLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -5),
            
            nameLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 2),
            nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -4),
            
            jerseyImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            jerseyImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            jerseyImageView.widthAnchor.constraint(equalToConstant: 20),
            jerseyImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(number: Int, name: String?, style: JerseyStyle = .home, clubEmblem: UIImage? = nil) {
        numberLabel.text = "\(number)"
        nameLabel.text = name
        containerView.backgroundColor = style.backgroundColor
        
        // Добавляем градиент для эффекта ткани
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            style.backgroundColor.withAlphaComponent(0.8).cgColor,
            style.backgroundColor.withAlphaComponent(1.0).cgColor
        ]
        gradientLayer.frame = containerView.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // Удаляем старые градиенты
        containerView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        
        if let emblem = clubEmblem {
            jerseyImageView.image = emblem
        } else {
            jerseyImageView.image = UIImage(systemName: "sportscourt.fill")
        }
        
        // Анимация появления
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.transform = .identity
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = containerView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.frame = containerView.bounds
        }
    }
}
