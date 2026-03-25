//
//  LeagueSelectorDelegate.swift
//  Footbalchik New
//
//  Created by Nick on 27.05.2026.
//


//
//  LeagueSelectorView.swift
//  Footbalchik
//

import UIKit

protocol LeagueSelectorDelegate: AnyObject {
    func didSelectLeague(_ league: League)
}

final class LeagueSelectorView: UIView {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var leagueButtons: [UIButton] = []
    
    weak var delegate: LeagueSelectorDelegate?
    private var leagues: [League] = []
    private var selectedLeagueId: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        scrollView.showsHorizontalScrollIndicator = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.pin(to: self)
        stackView.pin(to: scrollView)
        stackView.pinHeight(to: self)
        stackView.pinLeft(to: scrollView, 16)
        stackView.pinRight(to: scrollView, 16)
    }
    
    func configure(with leagues: [League], selectedLeague: League?) {
        self.leagues = leagues
        self.selectedLeagueId = selectedLeague?.id
        
        // Очищаем существующие кнопки
        leagueButtons.forEach { $0.removeFromSuperview() }
        leagueButtons.removeAll()
        
        // Создаем кнопки для каждой лиги
        for league in leagues {
            let button = createLeagueButton(for: league)
            stackView.addArrangedSubview(button)
            leagueButtons.append(button)
        }
        
        // Добавляем отступ после последней кнопки
        let spacer = UIView()
        spacer.widthAnchor.constraint(equalToConstant: 0).isActive = true
        stackView.addArrangedSubview(spacer)
    }
    
    private func createLeagueButton(for league: League) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(league.name, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(leagueTapped(_:)), for: .touchUpInside)
        button.tag = league.id
        
        updateButtonAppearance(button, isSelected: league.id == selectedLeagueId)
        
        return button
    }
    
    private func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = UIColor.systemGreen
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        } else {
            button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            button.setTitleColor(.lightGray, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        }
    }
    
    @objc private func leagueTapped(_ sender: UIButton) {
        guard let league = leagues.first(where: { $0.id == sender.tag }) else { return }
        
        // Обновляем внешний вид кнопок
        for button in leagueButtons {
            let isSelected = button.tag == league.id
            updateButtonAppearance(button, isSelected: isSelected)
        }
        
        delegate?.didSelectLeague(league)
    }
}