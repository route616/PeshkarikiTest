//
//  GalleryCell.swift
//  PeshkarikiTest
//
//  Created by Игорь on 04.05.2022.
//

import Foundation
import UIKit

final class GalleryCell: UICollectionViewCell {

    // MARK: - Subviews

    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        roundedView.layer.cornerRadius = 5.0
        imageView.contentMode = .scaleAspectFill
        activityIndicator.startAnimating()
    }
}
