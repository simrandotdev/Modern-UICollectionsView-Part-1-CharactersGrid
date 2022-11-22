//
//  DiffableDataSourceViewController.swift
//  CharactersGrid
//
//  Created by Simran Preet Narang on 2022-11-21.
//

import UIKit
import SwiftUI

typealias SectionCharactersTuple = (section: Section, characters: [Character])

class DiffableDataSourceViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var segmentedControl = UISegmentedControl(
        items: Universe.allCases.map { $0.title }
    )
    // Data for collection View with Sections and Characters for each section
    var backingStore: [SectionCharactersTuple]
    
    // Diffable DataSource
    private var dataSource: UICollectionViewDiffableDataSource<Section, Character>!
    
    // Properties to hold what we show in the cell and header
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Character>!
    private var headerRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!
    
    // Layout to decide what kind of layout we need for collection view.
    private lazy var listLayout: UICollectionViewLayout = {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.headerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: listConfig)
    }()
    
    init(sectionedCharacters: [SectionCharactersTuple] = Universe.ff7r.sectionedStubsTuple) {
        self.backingStore = sectionedCharacters
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSegmentedControl()
        setupBaritems()
        setupDataSource()
        setupSnapshot(store: backingStore)
    }
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    private func setupBaritems() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "shuffle"), style: .plain, target: self, action: #selector(shuffleTapped)),
            UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise.circle"), style: .plain, target: self, action: #selector(resetTapped))
        ]
    }
    
    private func setupCollectionView() {
        collectionView = .init(frame: view.bounds, collectionViewLayout: listLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        cellRegistration = UICollectionView.CellRegistration(
            handler: { (cell: UICollectionViewListCell, _, character: Character) in
                var content = cell.defaultContentConfiguration()
                content.text = character.name
                content.secondaryText = character.category
                content.image = UIImage(named: character.imageName)
                content.imageProperties.maximumSize = .init(width: 60, height: 60)
                content.imageProperties.cornerRadius = 30
                cell.contentConfiguration = content
            })
        
        headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader, handler: { [weak self] (header: UICollectionViewListCell, _, indexPath) in
            guard let self = self else { return }
            self.configureHeaderView(header, at: indexPath)
        })
    }
    
    private func setupDataSource() {
        // Cell
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier -> UICollectionViewCell? in
            guard let self = self else { return nil }
            let cell = collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
        
        // Header
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView in
            guard let self = self else { return UICollectionReusableView() }
            
            let headerView = self.collectionView.dequeueConfiguredReusableSupplementary(using: self.headerRegistration, for: indexPath)
            return headerView
        }
    }
    
    private func configureHeaderView(_ headerView: UICollectionViewListCell, at indexPath: IndexPath) {
        
        guard let character = dataSource.itemIdentifier(for: indexPath),
              let section = dataSource.snapshot().sectionIdentifier(containingItem: character) else { return }
        
        let count = dataSource.snapshot().itemIdentifiers(inSection: section).count
        
        var content = headerView.defaultContentConfiguration()
        content.text = section.headerTitleText(count: count)
        headerView.contentConfiguration = content
    }
    
    private func setupSnapshot(store: [SectionCharactersTuple]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Character>()
        store.forEach { sectionCharacters in
            let (section, characters) = sectionCharacters
            snapshot.appendSections([section])
            snapshot.appendItems(characters, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
 
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        backingStore = sender.selectedUniverse.sectionedStubsTuple
        setupSnapshot(store: backingStore)
    }
    
    @objc private func shuffleTapped(_ sender: Any) {
        backingStore = backingStore
            .shuffled()
            .map {
                ($0.section, $0.characters.shuffled())
            }
        setupSnapshot(store: backingStore)
    }
    
    @objc private func resetTapped(_ sender: Any) {
        backingStore = segmentedControl.selectedUniverse.sectionedStubsTuple
        setupSnapshot(store: backingStore)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Please initialize programaticaly instead of using Storyboard/XiB")
    }
}


struct DiffableDataSourceViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: MultipleSectionsViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController
}


struct DiffableDataSourceViewController_Preview: PreviewProvider {
    static var previews: some View {
        DiffableDataSourceViewControllerRepresentable()
            .edgesIgnoringSafeArea(.top)
    }
}

