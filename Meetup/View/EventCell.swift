//
//  EventCell.swift
//  Meetup
//
//  Created by YIN CHAO LIAO on 1/22/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import UIKit

protocol EventCellDelegate: class {
    func eventCellDidTapFavIcon(_ eventCell: EventCell)
}

class EventCell: UITableViewCell {
    static let cellId = "eventCell"
    
    let eventImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.contentMode = UIImageView.ContentMode.scaleAspectFill
        return view
    }()
    
    let imageLoadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .lightGray
        view.startAnimating()
        return view
    }()
    
    let favIcon: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon-heart"))
        view.contentMode = UIView.ContentMode.scaleAspectFit
        view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let group: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    let venue: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    let dateTime: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    let rsvp: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()
    
    var isFavorited = false {
        didSet {
            accessoryView?.alpha = isFavorited ? 1 : 0.3
        }
    }
    weak var delegate: EventCellDelegate?
    
    var imageUrl: URL?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(eventImageView)
        contentView.addSubview(imageLoadingIndicator)
        contentView.addSubview(title)
        contentView.addSubview(group)
        contentView.addSubview(venue)
        contentView.addSubview(dateTime)
        contentView.addSubview(rsvp)
        
        setupLayout()
        
        accessoryView = favIcon
        selectionStyle = .none
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFavIcon))
        favIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        imageLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        group.translatesAutoresizingMaskIntoConstraints = false
        venue.translatesAutoresizingMaskIntoConstraints = false
        dateTime.translatesAutoresizingMaskIntoConstraints = false
        rsvp.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "eventImageView": eventImageView,
            "imageLoadingIndicator": imageLoadingIndicator,
            "title": title,
            "group": group,
            "venue": venue,
            "dateTime": dateTime,
            "rsvp": rsvp
        ]
        
        let metrics = [
            "imageDimension": 70,
            "imageTopSpacing": 18,
            "spacing": 16
        ]
        
        let constraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-spacing-[eventImageView(imageDimension)]-spacing-[group]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:[eventImageView(imageDimension)]-spacing-[title]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:[eventImageView(imageDimension)]-spacing-[venue]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:[eventImageView(imageDimension)]-spacing-[dateTime]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:[eventImageView(imageDimension)]-spacing-[rsvp]-spacing-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-imageTopSpacing-[eventImageView(imageDimension)]->=spacing@999-|", options: [], metrics: metrics, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-spacing-[group][title]-[venue]-[dateTime]-[rsvp]->=spacing@999-|", options: [], metrics: metrics, views: views),
            [imageLoadingIndicator.widthAnchor.constraint(equalTo: eventImageView.widthAnchor)],
            [imageLoadingIndicator.heightAnchor.constraint(equalTo: eventImageView.heightAnchor)],
            [imageLoadingIndicator.centerXAnchor.constraint(equalTo: eventImageView.centerXAnchor)],
            [imageLoadingIndicator.centerYAnchor.constraint(equalTo: eventImageView.centerYAnchor)]
        ].flatMap { $0 }
        NSLayoutConstraint.activate(constraints)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isFavorited {
            accessoryView?.alpha = 1
        } else {
            accessoryView?.alpha = 0.3
        }
    }
    
    @objc private func didTapFavIcon() {
        delegate?.eventCellDidTapFavIcon(self)
    }
    
    func configure(with viewModel: EventCellViewModel) {
        self.title.text = viewModel.name
        self.group.text = viewModel.group
        self.venue.text = viewModel.venue
        self.dateTime.text = viewModel.dateTime
        self.rsvp.text = viewModel.yesRsvp
        self.isFavorited = viewModel.isFavorited
        self.imageUrl = viewModel.imageUrl
        
        viewModel.loadImage { (image) in
            // Make sure the cell has not been reused for another view model (scrolled off screen)
            guard self.imageUrl == viewModel.imageUrl else { return }
            DispatchQueue.main.async {
                if image == nil {
                    self.eventImageView.image = UIImage(named: "icon-placeholder")
                } else {
                    self.eventImageView.image = image
                }
                self.imageLoadingIndicator.stopAnimating()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventImageView.image = nil
        imageLoadingIndicator.startAnimating()
    }
    
}
