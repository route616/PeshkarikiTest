//
//  GalleryViewController.swift
//  PeshkarikiTest
//
//  Created by Игорь on 28.04.2022.
//

import Foundation
import UIKit

final class GalleryViewController: UIViewController {

    // MARK: - Views

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!

    // MARK: - Properties

    private var photos = [Photo]() {
        didSet {
            collectionView.reloadData()
        }
    }

    private var photoIterator: PhotoAsyncIterator?

    private var selectedPhoto: Photo?
    private var isSearching = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Methods

    private func fetchData() {
        NetworkService.fetchPhotosData { [weak self] result in
            switch result {
            case .success(let photos):
                self?.photos = photos
            case .failure(_):
                self?.presentAlert("Not enough photos")
            }
        }
    }

    private func presentAlert(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "GalleryToAboutID",
            let aboutViewController = segue.destination as? AboutViewController
        else {
            return
        }

        aboutViewController.photo = selectedPhoto
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }

        let totalSpace = flowLayout.sectionInset.right +
                         flowLayout.sectionInset.left +
                         flowLayout.minimumInteritemSpacing
        let width = (collectionView.bounds.width - totalSpace) / 2.0
        return CGSize(width: width, height: width)
    }
}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPhoto = photos[indexPath.item]
        performSegue(withIdentifier: "GalleryToAboutID", sender: self)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isSearching else { return }
        let position = scrollView.contentOffset.y

        if position > (collectionView.contentSize.height - scrollView.frame.size.height - 200.0) {
            photoIterator?.next { [weak self] photos in
                if let photos = photos {
                    self?.photos.append(contentsOf: photos)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GalleryCell", for: indexPath
        ) as? GalleryCell else {
            return UICollectionViewCell()
        }

        let photo = photos[indexPath.item]

        cell.imageView.image = UIImage(blurHash: photo.blurHash, size: CGSize(width: 32.0, height: 32.0))
        NetworkService.downloadPhoto(photo.urls?.small ?? "") { result in
            switch result {
            case .success(let imageData):
                if let image = UIImage(data: imageData) {
                    cell.imageView.image = image
                } else {
                    cell.imageView.image = UIImage(systemName: "photo")
                }
            case .failure(_):
                cell.imageView.image = UIImage(systemName: "photo")
            }
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
        }

        return cell
    }
}

// MARK: - UISearchBarDelegate

extension GalleryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        photoIterator = nil
        if let text = searchBar.text, !text.isEmpty {
            isSearching = true
            photos.removeAll()
            NetworkService.generateIterator(query: text.trimmedTrailingWhitespace) { [weak self] result in
                switch result {
                case .success(let iterator):
                    self?.photoIterator = iterator
                    self?.photoIterator?.next { photos in
                        if let photos = photos {
                            self?.photos.append(contentsOf: photos)
                        }
                    }
                case .failure(_):
                    self?.presentAlert("Search is unavailable")
                }
            }
        } else {
            fetchData()
            isSearching = false
        }
    }
}
