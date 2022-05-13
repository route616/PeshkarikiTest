//
//  AboutViewController.swift
//  PeshkarikiTest
//
//  Created by Игорь on 04.05.2022.
//

import Foundation
import UIKit

final class AboutViewController: UIViewController {

    // MARK: - Views

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet private weak var dismissBlurView: UIVisualEffectView!
    @IBOutlet private weak var addToFavoritesBlurView: UIVisualEffectView!
    @IBOutlet private weak var addToFavoritesButton: UIButton!

    @IBOutlet private weak var bottomBlurView: UIVisualEffectView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var creationDateLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var downloadsCountLabel: UILabel!

    // MARK: - Properties

    private var isControlsHidden = false {
        willSet {
            newValue ? hideControls() : showControls()
        }
    }

    var photo: Photo?

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
        guard let photo = photo else {
            return
        }

        NetworkService.fetchDownloadsCount(by: photo.id) { [weak self] result in
            switch result {
            case .success(let downloads):
                self?.downloadsCountLabel.text = "\(downloads) downloads"
            case .failure(let error):
                print(error.localizedDescription)
                self?.downloadsCountLabel.text = "0 downloads"
            }
        }

        NetworkService.downloadPhoto(photo.urls?.regular ?? "") { [weak self] result in
            switch result {
            case .success(let imageData):
                self?.imageView.image = UIImage(data: imageData) ?? UIImage(systemName: "photo")
            case .failure(_):
                self?.imageView.image = UIImage(systemName: "photo")
            }
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    // MARK: - Methods

    private func configureView() {
        [addToFavoritesBlurView, dismissBlurView, bottomBlurView].forEach {
            $0?.layer.cornerRadius = 10.0
        }

        guard let photo = photo else {
            return
        }

        if DatabaseService.sharedInstance.contains(id: photo.id) {
            var configuration = UIButton.Configuration.plain()
            configuration.baseForegroundColor = .label
            configuration.image = UIImage(systemName: "star.fill")
            addToFavoritesButton.configuration = configuration
        }

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "dd.MM.YYYY"

        nameLabel.text = photo.user?.name ?? "Anonymous"
        locationLabel.text = photo.location?.title
        creationDateLabel.text = "created at " + dateFormatter.string(from: photo.createdAt)

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

    }

    private func presentAlert(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }

    private func showControls() {
        bottomBlurView.isHidden = false
        dismissBlurView.isHidden = false
        addToFavoritesBlurView.isHidden = false

        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.bottomBlurView.alpha = 1.0
            self?.dismissBlurView.alpha = 1.0
            self?.addToFavoritesBlurView.alpha = 1.0
        }
    }

    private func hideControls() {
        UIView.animate(
            withDuration: 0.4,
            animations: { [weak self] in
                self?.dismissBlurView.alpha = 0.0
                self?.bottomBlurView.alpha = 0.0
                self?.addToFavoritesBlurView.alpha = 0.0
            },
            completion: { [weak self] finished in
                if finished {
                    self?.bottomBlurView.isHidden = true
                    self?.addToFavoritesBlurView.isHidden = true
                    self?.dismissBlurView.isHidden = true
                }
            }
        )
    }

    // MARK: - Actions

    @IBAction private func addToFavoritesButtonAction(_ sender: UIButton) {
        guard let photo = photo else { return }
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .label

        if DatabaseService.sharedInstance.contains(id: photo.id) {
            DatabaseService.sharedInstance.delete(photoBy: photo.id)
            configuration.image = UIImage(systemName: "star")
        } else {
            DatabaseService.sharedInstance.save(photo: photo)
            configuration.image = UIImage(systemName: "star.fill")
        }

        addToFavoritesButton.configuration = configuration
    }

    @IBAction private func dismissButtonAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func didTappedView(_ sender: UITapGestureRecognizer) {
        isControlsHidden.toggle()
    }
}

// MARK: - UIScrollViewDelegate

extension AboutViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
