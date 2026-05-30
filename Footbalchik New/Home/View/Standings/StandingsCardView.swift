//
//  StandingsCardView.swift
//  Footbalchik New
//
//  Created by Nick on 20.05.2026.
//


import UIKit

final class StandingsCardView: GlassCardView {

    // Колонки по ТЗ: И В Н П ЗМ ПМ О
    private let columns = ["И", "В", "Н", "П", "ЗМ", "ПМ", "О"]
    private let statColWidth: Double = 24
    private let formDotSize: Double = 16
    private let formSpacing: Double = 3
    private var formBlockWidth: Double { 5 * formDotSize + 4 * formSpacing }

    private let titleLabel = UILabel()
    private let mainStack = UIStackView()
    private let rowsStack = UIStackView()
    private let showAllButton = UIButton(type: .system)

    private var rows: [TableRow] = []
    private var isExpanded = false
    private let collapsedCount = 5

    var onLayoutChange: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(rows: [TableRow]) {
        self.rows = rows
        rebuild()
    }

    private func setup() {
        titleLabel.text = "Таблица"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white

        mainStack.axis = .vertical
        mainStack.spacing = 12

        rowsStack.axis = .vertical
        rowsStack.spacing = 0

        showAllButton.setTitleColor(.systemGreen, for: .normal)
        showAllButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        showAllButton.addTarget(self, action: #selector(toggle), for: .touchUpInside)

        contentView.addSubview(mainStack)
        mainStack.pinTop(to: contentView, 16)
        mainStack.pinLeft(to: contentView, 16)
        mainStack.pinRight(to: contentView, 16)
        mainStack.pinBottom(to: contentView, 12)

        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(makeHeaderRow())
        mainStack.addArrangedSubview(rowsStack)
        mainStack.addArrangedSubview(showAllButton)
    }

    @objc private func toggle() {
        isExpanded.toggle()
        rebuild()
        onLayoutChange?()
    }

    private func rebuild() {
        rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let visible = isExpanded ? rows : Array(rows.prefix(collapsedCount))
        for row in visible {
            rowsStack.addArrangedSubview(makeDataRow(row))
        }

        showAllButton.isHidden = rows.count <= collapsedCount
        showAllButton.setTitle(isExpanded ? "Свернуть" : "Показать всю таблицу", for: .normal)
    }

    // MARK: - Построение строк

    // Шапка: "Клуб" | И В Н П ЗМ ПМ О | "Последние 5"
    private func makeHeaderRow() -> UIView {
        let club = label("Клуб", font: .systemFont(ofSize: 13),
                         color: .white.withAlphaComponent(0.6), align: .left)

        let stats = columns.map {
            label($0, font: .systemFont(ofSize: 13),
                  color: .white.withAlphaComponent(0.6), align: .center, width: statColWidth)
        }

        let last = label("Последние 5", font: .systemFont(ofSize: 13),
                         color: .white.withAlphaComponent(0.6), align: .right)
        last.setWidth(mode: .equal, formBlockWidth)

        return assembleRow(left: club, stats: stats, right: last, height: 28)
    }

    private func makeDataRow(_ row: TableRow) -> UIView {
        // левый блок: место + герб + имя
        let pos = label("\(row.position)", font: .systemFont(ofSize: 14, weight: .semibold),
                        color: .white, align: .center, width: 22)

        let crest = UIImageView()
        crest.contentMode = .scaleAspectFit
        crest.setImage(from: row.team.crest)   // твой extension, как в MatchCardView
        crest.setWidth(mode: .equal, 20)
        crest.setHeight(mode: .equal, 20)

        let name = label(row.team.shortName ?? row.team.name,
                         font: .systemFont(ofSize: 14, weight: .medium),
                         color: .white, align: .left)
        name.lineBreakMode = .byTruncatingTail
        name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let left = UIStackView(arrangedSubviews: [pos, crest, name])
        left.axis = .horizontal
        left.alignment = .center
        left.spacing = 8

        // числа: И В Н П ЗМ ПМ О
        let values = ["\(row.playedGames)", "\(row.won)", "\(row.draw)", "\(row.lost)",
                      "\(row.goalsFor)", "\(row.goalsAgainst)", "\(row.points)"]
        let stats = values.enumerated().map { idx, v in
            label(v,
                  font: .systemFont(ofSize: 14, weight: idx == values.count - 1 ? .bold : .regular),
                  color: .white, align: .center, width: statColWidth)
        }

        // форма (5 кружков), прижата вправо
        let formStack = UIStackView(
            arrangedSubviews: row.recentForm.map { FormDotView(result: $0, size: formDotSize) }
        )
        formStack.axis = .horizontal
        formStack.spacing = CGFloat(formSpacing)
        formStack.alignment = .center

        let formContainer = UIView()
        formContainer.setWidth(mode: .equal, formBlockWidth)
        formContainer.addSubview(formStack)
        formStack.pinRight(to: formContainer)
        formStack.pinCenterY(to: formContainer)

        return assembleRow(left: left, stats: stats, right: formContainer, height: 44)
    }

    // Собирает строку: [левый блок (гибкий)] [числа (фикс)] [правый блок (фикс)]
    private func assembleRow(left: UIView, stats: [UIView], right: UIView, height: Double) -> UIView {
        let statsStack = UIStackView(arrangedSubviews: stats)
        statsStack.axis = .horizontal
        statsStack.alignment = .center

        let row = UIStackView(arrangedSubviews: [left, statsStack, right])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 6
        row.setHeight(mode: .equal, height)

        left.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return row
    }

    private func label(_ text: String,
                       font: UIFont,
                       color: UIColor,
                       align: NSTextAlignment,
                       width: Double? = nil) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = font
        l.textColor = color
        l.textAlignment = align
        if let width { l.setWidth(mode: .equal, width) }
        return l
    }
}
