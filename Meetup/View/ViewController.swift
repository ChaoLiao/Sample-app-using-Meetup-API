//
//  ViewController.swift
//  Meetup
//
//  Created by YIN CHAO LIAO on 1/20/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.color = .lightGray
        return view
    }()
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar(frame: .zero)
        bar.placeholder = "Search events nearby"
        bar.searchBarStyle = .minimal
        bar.showsCancelButton = true
        return bar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(EventCell.self, forCellReuseIdentifier: EventCell.cellId)
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private var searchTimer: Timer?
    private let meetupAPI = MeetupAPI()
    private var events = [EventCellViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        setupLayout()
        
        searchBar.delegate = self
        tableView.dataSource = self
    }

    private func setupLayout() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "searchBar": searchBar,
            "tableView": tableView
        ]
        let metrics = [
            "topMargin": UIApplication.shared.statusBarFrame.height
        ]
        
        let constraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[searchBar]|", options: [], metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-topMargin-[searchBar][tableView]|", options: [], metrics: metrics, views: views),
            [loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)],
            [loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
        ].flatMap { $0 }
        
        NSLayoutConstraint.activate(constraints)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        guard !searchText.isEmpty else { return }
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] (timer) in
            guard let `self` = self else { return }
            
            self.loadingIndicator.startAnimating()
            
            let favoritedEventIds = FavoritedEventStore.shared.favoritedEventIds()
            
            self.meetupAPI.events(with: searchText, favoritedEventIds: favoritedEventIds) { (result) in
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                }
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let events):
                    self.events = events.map { EventCellViewModel(eventModel: $0) }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(10, events.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.cellId, for: indexPath) as! EventCell
        let event = events[indexPath.row]
        cell.configure(with: event)
        cell.delegate = self
        return cell
    }
}

extension ViewController: EventCellDelegate {
    func eventCellDidTapFavIcon(_ eventCell: EventCell) {
        guard let indexPath = tableView.indexPath(for: eventCell) else { return }
        let event = events[indexPath.row]
        if event.isFavorited {
            FavoritedEventStore.shared.unfavoriteEvent(for: event.id)
            eventCell.isFavorited = false
            event.isFavorited = false
        } else {
            FavoritedEventStore.shared.favoriteEvent(for: event.id)
            eventCell.isFavorited = true
            event.isFavorited = true
        }
    }
}

