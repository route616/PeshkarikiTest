//
//  FavoritesCell.swift
//  PeshkarikiTest
//
//  Created by Игорь on 05.05.2022.
//

import Foundation
import UIKit

final class FavoritesCell: UITableViewCell {

    // MARK: - Views

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        photoImageView.layer.cornerRadius = 5.0
        photoImageView.contentMode = .scaleAspectFill
        activityIndicator.startAnimating()
    }
}
