//
//  ViewController.swift
//  KeepScore
//
//  Created by zeyi wang on 11/9/25.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    var players: [String] = ["ff", "qq", "mm", "bb"] // Default players
    var scores: [[Int]] = [] // scores[round][playerIndex]
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = true
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
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemRed
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
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        
        // Add subviews
        view.addSubview(headerStackView)
        view.addSubview(tableView)
        view.addSubview(addPlayerButton)
        view.addSubview(addRoundButton)
        view.addSubview(clearButton)
        
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
            addPlayerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addPlayerButton.heightAnchor.constraint(equalToConstant: 44),
            addPlayerButton.widthAnchor.constraint(equalTo: addRoundButton.widthAnchor),
            
            // Add Round Button
            addRoundButton.leadingAnchor.constraint(equalTo: addPlayerButton.trailingAnchor, constant: 8),
            addRoundButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addRoundButton.heightAnchor.constraint(equalToConstant: 44),
            addRoundButton.widthAnchor.constraint(equalTo: clearButton.widthAnchor),
            
            // Clear Button
            clearButton.leadingAnchor.constraint(equalTo: addRoundButton.trailingAnchor, constant: 8),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            clearButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            clearButton.heightAnchor.constraint(equalToConstant: 44)
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
        
        // First, ask who won the round
        let winnerAlert = UIAlertController(title: "Add Round", message: "Select the winner of this round", preferredStyle: .actionSheet)
        
        for (index, player) in players.enumerated() {
            let action = UIAlertAction(title: player, style: .default) { [weak self] _ in
                self?.promptForCardsLeft(winnerIndex: index)
            }
            winnerAlert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        winnerAlert.addAction(cancelAction)
        
        // For iPad support
        if let popover = winnerAlert.popoverPresentationController {
            popover.sourceView = addRoundButton
            popover.sourceRect = addRoundButton.bounds
        }
        
        present(winnerAlert, animated: true)
    }
    
    private func editRound(at roundIndex: Int) {
        guard roundIndex < scores.count else { return }
        
        let roundScores = scores[roundIndex]
        
        // Find the winner (player with highest/positive score)
        var winnerIndex = 0
        var maxScore = roundScores[0]
        for (index, score) in roundScores.enumerated() {
            if score > maxScore {
                maxScore = score
                winnerIndex = index
            }
        }
        
        // First, ask who won the round (with current winner pre-selected)
        let winnerAlert = UIAlertController(title: "Edit Round", message: "Select the winner of this round", preferredStyle: .actionSheet)
        
        for (index, player) in players.enumerated() {
            let action = UIAlertAction(title: player, style: .default) { [weak self] _ in
                self?.promptForCardsLeft(winnerIndex: index, roundIndex: roundIndex, existingScores: roundScores)
            }
            if index == winnerIndex {
                action.setValue(true, forKey: "checked")
            }
            winnerAlert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        winnerAlert.addAction(cancelAction)
        
        // For iPad support
        if let popover = winnerAlert.popoverPresentationController {
            if let cell = tableView.cellForRow(at: IndexPath(row: roundIndex, section: 0)) {
                popover.sourceView = cell
                popover.sourceRect = cell.bounds
            }
        }
        
        present(winnerAlert, animated: true)
    }
    
    private func promptForCardsLeft(winnerIndex: Int, roundIndex: Int? = nil, existingScores: [Int]? = nil) {
        let isEditing = roundIndex != nil
        let title = isEditing ? "Edit Cards Left" : "Cards Left"
        let message = "Enter the number of cards left for each player (winner gets sum of all losers' points)"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add text fields for each loser (all players except the winner)
        for (index, player) in players.enumerated() {
            if index != winnerIndex {
                alert.addTextField { textField in
                    textField.placeholder = "\(player) cards left"
                    textField.keyboardType = .numberPad
                    
                    // Pre-fill with existing value if editing
                    if let existingScores = existingScores {
                        let cardsLeft = abs(existingScores[index]) // Get absolute value of negative score
                        textField.text = "\(cardsLeft)"
                    }
                }
            }
        }
        
        let actionTitle = isEditing ? "Update" : "Add"
        let addAction = UIAlertAction(title: actionTitle, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            var roundScores: [Int] = Array(repeating: 0, count: self.players.count)
            var totalLoserPoints = 0
            
            // Process losers' cards left
            var textFieldIndex = 0
            for (index, _) in self.players.enumerated() {
                if index != winnerIndex {
                    if let textField = alert.textFields?[textFieldIndex],
                       let cardsLeftText = textField.text,
                       let cardsLeft = Int(cardsLeftText) {
                        // Losers get negative points equal to cards left
                        roundScores[index] = -cardsLeft
                        totalLoserPoints += cardsLeft
                    }
                    textFieldIndex += 1
                }
            }
            
            // Winner gets the sum of all losers' points (positive)
            roundScores[winnerIndex] = totalLoserPoints
            
            if let roundIndex = roundIndex {
                // Update existing round
                self.scores[roundIndex] = roundScores
            } else {
                // Add new round
                self.scores.append(roundScores)
            }
            
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func clearTapped() {
        let alert = UIAlertController(title: "Clear All Scores", message: "Are you sure you want to clear all rounds? This cannot be undone.", preferredStyle: .alert)
        
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.scores.removeAll()
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    private func calculateTotals() -> [Int] {
        guard !players.isEmpty else { return [] }
        
        var totals = Array(repeating: 0, count: players.count)
        
        for roundScores in scores {
            for (index, score) in roundScores.enumerated() {
                if index < totals.count {
                    totals[index] += score
                }
            }
        }
        
        return totals
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        editRound(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .systemBackground
        
        let totalsStackView = UIStackView()
        totalsStackView.translatesAutoresizingMaskIntoConstraints = false
        totalsStackView.axis = .horizontal
        totalsStackView.distribution = .fillEqually
        totalsStackView.spacing = 1
        totalsStackView.backgroundColor = .systemGray4
        
        // Add "Total" label
        let totalLabel = UILabel()
        totalLabel.text = "Total"
        totalLabel.textAlignment = .center
        totalLabel.font = .boldSystemFont(ofSize: 16)
        totalLabel.backgroundColor = .systemGray5
        totalLabel.textColor = .label
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        totalsStackView.addArrangedSubview(totalLabel)
        
        // Add total scores for each player
        let totals = calculateTotals()
        for (index, total) in totals.enumerated() {
            let scoreLabel = UILabel()
            scoreLabel.text = "\(total)"
            scoreLabel.textAlignment = .center
            scoreLabel.font = .boldSystemFont(ofSize: 16)
            scoreLabel.backgroundColor = .systemGray5
            scoreLabel.textColor = .label
            totalsStackView.addArrangedSubview(scoreLabel)
        }
        
        // Fill remaining columns if needed
        while totalsStackView.arrangedSubviews.count - 1 < players.count {
            let scoreLabel = UILabel()
            scoreLabel.text = "0"
            scoreLabel.textAlignment = .center
            scoreLabel.font = .boldSystemFont(ofSize: 16)
            scoreLabel.backgroundColor = .systemGray5
            scoreLabel.textColor = .label
            totalsStackView.addArrangedSubview(scoreLabel)
        }
        
        footerView.addSubview(totalsStackView)
        
        NSLayoutConstraint.activate([
            totalsStackView.topAnchor.constraint(equalTo: footerView.topAnchor),
            totalsStackView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
            totalsStackView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            totalsStackView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor),
            totalsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
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

