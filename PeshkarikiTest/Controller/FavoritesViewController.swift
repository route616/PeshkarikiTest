//
//  FavoritesViewController.swift
//  PeshkarikiTest
//
//  Created by Игорь on 05.05.2022.
//

import Foundation
import UIKit
import RealmSwift

final class FavoritesViewController: UIViewController {

    // MARK: - Views

    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties

    private var photos = [Photo]() {
        didSet {
            tableView.reloadData()
        }
    }

    private var selectedPhoto: Photo?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        photos = DatabaseService.sharedInstance.fetch()
    }

    // MARK: - Methods

    private func presentAlert(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "FavoritesToAboutID",
            let aboutViewController = segue.destination as? AboutViewController
        else {
            return
        }

        aboutViewController.photo = selectedPhoto
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedPhoto = photos[indexPath.row]
        performSegue(withIdentifier: "FavoritesToAboutID", sender: self)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            DatabaseService.sharedInstance.delete(photoBy: photos[indexPath.row].id)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            photos.remove(at: indexPath.row)
            tableView.endUpdates()
        }
    }
}

// MARK: - UITableViewDataSource

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoritesCellID",
            for: indexPath
        ) as? FavoritesCell else {
            return UITableViewCell()
        }

        let photo = photos[indexPath.row]
        let location = photo.location?.title

        cell.nameLabel.text = photo.user?.name ?? "Anonymous"
        cell.locationLabel.text = location
        cell.photoImageView.image = UIImage(blurHash: photo.blurHash, size: CGSize(width: 32.0, height: 32.0))

        NetworkService.downloadPhoto(photo.urls?.thumb ?? "") { result in
            switch result {
            case .success(let imageData):
                if let image = UIImage(data: imageData) {
                    cell.photoImageView.image = image
                } else {
                    cell.photoImageView.image = UIImage(systemName: "photo")
                }
            case (.failure(_)):
                cell.photoImageView.image = UIImage(systemName: "photo")
            }
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
        }

        return cell
    }
}
