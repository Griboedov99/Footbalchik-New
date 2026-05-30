//
//  MatchViewController.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//

import UIKit

final class MatchViewController: BaseViewController {

    // MARK: - Properties

    private let viewModel: MatchViewModel

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private let headerCard = MatchHeaderCardView()
    private let pitchView = FootballPitchView()
    private let infoCard = MatchInfoCardView()
    private let loadingLabel = UILabel()

    // MARK: - Init

    init(viewModel: MatchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupLayout()
        configureInitialState()
        bind()
        viewModel.loadDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Убеждаемся, что navigation bar виден
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Отступ снизу, чтобы таб-бар не перекрывал нижнюю карточку
        let bottom = tabBarController?.tabBar.frame.height ?? 0
        if scrollView.contentInset.bottom != bottom {
            scrollView.contentInset.bottom = bottom
            scrollView.verticalScrollIndicatorInsets.bottom = bottom
        }
    }

    // MARK: - Setup

    private func setupAppearance() {
        view.backgroundColor = .black
        title = viewModel.screenTitle
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        scrollView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        scrollView.pinLeft(to: view)
        scrollView.pinRight(to: view)
        scrollView.pinBottom(to: view)

        contentView.pinTop(to: scrollView)
        contentView.pinLeft(to: scrollView)
        contentView.pinRight(to: scrollView)
        contentView.pinBottom(to: scrollView)
        contentView.pinWidth(to: view)

        stackView.axis = .vertical
        stackView.spacing = 20

        stackView.pinTop(to: contentView, 20)
        stackView.pinLeft(to: contentView, 16)
        stackView.pinRight(to: contentView, 16)
        stackView.pinBottom(to: contentView, 24)

        stackView.addArrangedSubview(headerCard)
        stackView.addArrangedSubview(pitchView)
        stackView.addArrangedSubview(loadingLabel)
        stackView.addArrangedSubview(infoCard)

        pitchView.setHeight(mode: .equal, 760)

        loadingLabel.textColor = .white.withAlphaComponent(0.82)
        loadingLabel.font = .systemFont(ofSize: 15, weight: .medium)
        loadingLabel.textAlignment = .center
        loadingLabel.numberOfLines = 0
    }

    // MARK: - Initial State

    private func configureInitialState() {
        configureHeader()
        configureEmptyPitch()
        loadingLabel.text = "Загрузка составов..."
        configureInitialInfo()
    }

    private func configureHeader() {
        headerCard.configure(
            homeTeamName: viewModel.homeTeamName,
            awayTeamName: viewModel.awayTeamName,
            homeLogoURL: viewModel.homeLogoURL,
            awayLogoURL: viewModel.awayLogoURL,
            dateText: viewModel.dateText,
            centerText: viewModel.centerText,
            statusText: ""
        )
    }

    private func configureEmptyPitch() {
        pitchView.homePlayers = []
        pitchView.awayPlayers = []
    }

    private func configureInitialInfo() {
        infoCard.configure(
            title: "Информация о матче",
            text: viewModel.initialInfoText
        )
    }

    // MARK: - Binding

    private func bind() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            if isLoading {
                self?.loadingLabel.text = "Загрузка составов..."
                self?.loadingLabel.isHidden = false
            }
        }

        viewModel.onLineupsLoaded = { [weak self] data in
            guard let self else { return }
            self.pitchView.homePlayers = data.homePlayers
            self.pitchView.awayPlayers = data.awayPlayers
            self.loadingLabel.text = data.lineupMessage
            self.loadingLabel.isHidden = (data.lineupMessage == nil)
            self.infoCard.configure(title: "Информация о матче", text: data.infoText)
        }

        viewModel.onError = { [weak self] title, text in
            guard let self else { return }
            self.configureEmptyPitch()
            self.loadingLabel.text = "Не удалось загрузить составы"
            self.loadingLabel.isHidden = false
            self.infoCard.configure(title: title, text: text)
        }
    }
}
