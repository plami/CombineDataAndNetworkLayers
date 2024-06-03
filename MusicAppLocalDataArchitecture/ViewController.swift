//
//  ViewController.swift
//  MusicAppLocalDataArchitecture
//
//  Created by Plamena Nikolova on 15.05.24.
//

import UIKit
import Combine

struct Section: Identifiable {
    
    enum Identifier: String, CaseIterable {
        case main = "Main"
    }
    
    var id: Identifier
    var artists: [ArtistWrapper]
}


class ViewController: UIViewController {
    
    @IBOutlet weak var getLastArtists: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section.ID, ArtistWrapper>!
    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section.ID, ArtistWrapper>! = nil
    private var cancelables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureHierarchy()
        configureCollectionView()
        
        Application.shared.getArtists()
        setInitialData()
        
    }
    
    private func configureUI() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(udpateArtists))
        getLastArtists.customView?.addGestureRecognizer(tap)
    }
    
    @IBAction func udpateArtists(_ sender: UIBarButtonItem) {
        Task {
            Application.shared.updateArtists()
            Application.shared.artistsPublisher
                .receive(on: DispatchQueue.main)
                .sink {[weak self] _ in self?.reloadDataSource()}
                .store(in: &cancelables)
            setInitialData()
        }
    }
    
    private func reloadDataSource() {
        currentSnapshot.reloadItems(currentSnapshot.itemIdentifiers)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    //get initial data with unique ID by Identifiable protocol
    private func setInitialData() {
        currentSnapshot = NSDiffableDataSourceSnapshot<Section.ID, ArtistWrapper>()
        currentSnapshot.appendSections(Section.ID.allCases)
        currentSnapshot.appendItems(Application.shared.artists, toSection: Section.ID.main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    private func configureHierarchy() {
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = artistCollectionViewCompositionalLayout(contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
    }
    
    // Cell registrations
    private func configureCollectionView() {
        let registeredCell = registrateCell(for: UINib(nibName: "ArtistCollectionViewCell", bundle: nil))
//        registeredCell.delegate = self
        dataSource = UICollectionViewDiffableDataSource<Section.ID, ArtistWrapper>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: ArtistWrapper) -> UICollectionViewCell? in
            let cell: ArtistCollectionViewCell?
            
            cell = collectionView.dequeueConfiguredReusableCell(using: registeredCell, for: indexPath, item: identifier)
            return cell
        }
    }
    
    func registrateCell(for nib: UINib) -> UICollectionView.CellRegistration<ArtistCollectionViewCell, ArtistWrapper> {
        
        UICollectionView.CellRegistration<ArtistCollectionViewCell, ArtistWrapper>(cellNib: nib) { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self,
                  let artist = try? Application.shared.getArtistByURL(url: itemIdentifier.wrappedPhotoUrl)
            else { return }
            
            cell.configure(with: artist)
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard dataSource.itemIdentifier(for: indexPath) != nil else { return false }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    
    func artistCollectionViewCompositionalLayout(contentInsets: NSDirectionalEdgeInsets) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.backgroundColor = .clear
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.contentInsets = contentInsets
            
            return section
        }
    }
}

