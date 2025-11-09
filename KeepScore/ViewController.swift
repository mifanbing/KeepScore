//
//  ViewController.swift
//  KeepScore
//
//  Created by zeyi wang on 11/9/25.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    var players: [String] = ["Player 1", "Player 2"] // Default players
    var scores: [[Int]] = [] // scores[round][playerIndex]
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = false
        return tableView
    }()
    
    private let addPlayerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Player", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let addRoundButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Round", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        stackView.backgroundColor = .systemGray4
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Score Tracker"
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ScoreTableViewCell.self, forCellReuseIdentifier: "ScoreCell")
        
        // Setup buttons
        addPlayerButton.addTarget(self, action: #selector(addPlayerTapped), for: .touchUpInside)
        addRoundButton.addTarget(self, action: #selector(addRoundTapped), for: .touchUpInside)
        
        // Add subviews
        view.addSubview(headerStackView)
        view.addSubview(tableView)
        view.addSubview(addPlayerButton)
        view.addSubview(addRoundButton)
        
        updateHeaderView()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header stack view
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerStackView.heightAnchor.constraint(equalToConstant: 44),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addPlayerButton.topAnchor, constant: -16),
            
            // Add Player Button
            addPlayerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addPlayerButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8),
            addPlayerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addPlayerButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Add Round Button
            addRoundButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8),
            addRoundButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addRoundButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addRoundButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func updateHeaderView() {
        // Remove existing header labels
        headerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add "Round" label at the start
        let roundLabel = createHeaderLabel(text: "Round")
        roundLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        headerStackView.addArrangedSubview(roundLabel)
        
        // Add player name labels
        for player in players {
            let label = createHeaderLabel(text: player)
            headerStackView.addArrangedSubview(label)
        }
    }
    
    private func createHeaderLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        label.backgroundColor = .systemGray5
        label.textColor = .label
        return label
    }
    
    // MARK: - Actions
    @objc private func addPlayerTapped() {
        let alert = UIAlertController(title: "Add Player", message: "Enter player name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Player name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let playerName = textField.text,
                  !playerName.isEmpty else { return }
            
            self.players.append(playerName)
            
            // Add a score column (0) for existing rounds
            for i in 0..<self.scores.count {
                self.scores[i].append(0)
            }
            
            self.updateHeaderView()
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func addRoundTapped() {
        guard !players.isEmpty else {
            let alert = UIAlertController(title: "No Players", message: "Please add at least one player first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(title: "Add Round", message: "Enter scores for each player", preferredStyle: .alert)
        
        for (index, player) in players.enumerated() {
            alert.addTextField { textField in
                textField.placeholder = "\(player) score"
                textField.keyboardType = .numberPad
            }
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            var roundScores: [Int] = []
            for (index, textField) in (alert.textFields ?? []).enumerated() {
                let score = Int(textField.text ?? "0") ?? 0
                roundScores.append(score)
            }
            
            self.scores.append(roundScores)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath) as! ScoreTableViewCell
        let roundNumber = indexPath.row + 1
        let roundScores = scores[indexPath.row]
        cell.configure(roundNumber: roundNumber, scores: roundScores, playerCount: players.count)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - ScoreTableViewCell
class ScoreTableViewCell: UITableViewCell {
    private let roundLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        label.backgroundColor = .systemGray6
        return label
    }()
    
    private let scoresStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        stackView.backgroundColor = .systemGray4
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(roundLabel)
        contentView.addSubview(scoresStackView)
        
        NSLayoutConstraint.activate([
            roundLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            roundLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            roundLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            roundLabel.widthAnchor.constraint(equalToConstant: 80),
            
            scoresStackView.leadingAnchor.constraint(equalTo: roundLabel.trailingAnchor),
            scoresStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scoresStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scoresStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(roundNumber: Int, scores: [Int], playerCount: Int) {
        roundLabel.text = "\(roundNumber)"
        
        // Remove existing score labels
        scoresStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add score labels
        for (index, score) in scores.enumerated() {
            let scoreLabel = createScoreLabel(text: "\(score)")
            scoresStackView.addArrangedSubview(scoreLabel)
        }
        
        // Fill remaining columns if needed
        while scoresStackView.arrangedSubviews.count < playerCount {
            let scoreLabel = createScoreLabel(text: "-")
            scoresStackView.addArrangedSubview(scoreLabel)
        }
    }
    
    private func createScoreLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.backgroundColor = .systemBackground
        label.textColor = .label
        return label
    }
}

