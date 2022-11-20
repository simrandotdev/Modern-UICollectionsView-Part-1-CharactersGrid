//
//  MultipleSectionsViewController.swift
//  CharactersGrid
//
//  Created by Simran Preet Narang on 2022-11-18.
//

import UIKit
import SwiftUI

class MultipleSectionsViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    @objc let segmentedControl = UISegmentedControl(items: Universe.allCases.map({ $0.title }))
    
    var sectionStubs = Universe.ff7r.sectionedStubs {
        didSet {
            updateCollectionView(oldSectionItems: oldValue, newSectionItems: sectionStubs)
        }
    }
    
    private var cellRegistration: UICollectionView.CellRegistration<CharacterCell, Character>!
    private var headerRegistration: UICollectionView.SupplementaryRegistration<HeaderView>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupLayout()
        setupSegmentedController()
        setupNavigationItem()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // For Resizing Cells in CollectionView
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupCollectionView() {
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
//        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: "Cell")
        cellRegistration = UICollectionView.CellRegistration(handler: { cell, _, itemIdentifier in
            cell.setup(character: itemIdentifier)
        })
//        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader, handler: { headerView, _, indexPath in
            let section = self.sectionStubs[indexPath.section]
            headerView.setup(text: "\(section.category) \(section.characters.count)".uppercased())
        })
        
        view.addSubview(collectionView)
    }
    
    
    private func setupLayout() {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        flowLayout.sectionInset = .init(top: 0, left: 8, bottom: 0, right: 8)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        // For Resizing Cells in CollectionView
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "shuffle"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(shuffleTapped))
    }
    
    
    private func setupSegmentedController() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        navigationItem.titleView = segmentedControl
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        sectionStubs = sender.selectedUniverse.sectionedStubs
    }
    
    @objc func shuffleTapped() {
        sectionStubs = sectionStubs
            .shuffled()
            .map({
                return SectionCharacters(category: $0.category,
                                         characters: $0.characters.shuffled())
            })
    }
}

extension MultipleSectionsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionStubs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionStubs[section].characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let character = sectionStubs[indexPath.section].characters[indexPath.item]
        let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: character)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        return headerView
    }
    
    // For calculating the height of HeaderView dynamically on large text size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = HeaderView()
        
        let section = sectionStubs[section]
        headerView.setup(text: "\(section.category) \(section.characters.count)".uppercased())
        
        return headerView.systemLayoutSizeFitting(.init(width: collectionView.bounds.width, height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
    private func updateCollectionView(oldSectionItems: [SectionCharacters], newSectionItems: [SectionCharacters]) {
        var sectionsToInsert = IndexSet()
        var sectionsToRemove = IndexSet()
        var indexPathsToRemove = [IndexPath]()
        var indexPathsToInsert = [IndexPath]()
        
        let sectionDiff = newSectionItems.difference(from: oldSectionItems)
        sectionDiff.forEach { (change) in
            switch change {
            case let .remove(offset, _, _):
                sectionsToRemove.insert(offset)
            case let .insert(offset, _, _):
                sectionsToInsert.insert(offset)
            }
        }
        
        (0..<newSectionItems.count).forEach { (index) in
            let newSection = newSectionItems[index]
            if let oldSectionIndex = oldSectionItems.firstIndex(where: { $0 == newSection }) {
                let oldSection = oldSectionItems[oldSectionIndex]
                let diff = newSection.characters.difference(from: oldSection.characters)
                diff.forEach { (change) in
                    switch change {
                    case let .remove(offset, _, _):
                        indexPathsToRemove.append(IndexPath(item: offset, section: oldSectionIndex))
                    case let .insert(offset, _, _):
                        indexPathsToInsert.append(IndexPath(item: offset, section: index))
                    }
                }
            }
        }
        
        collectionView.performBatchUpdates {
            self.collectionView.deleteSections(sectionsToRemove)
            self.collectionView.deleteItems(at: indexPathsToRemove)
            self.collectionView.insertSections(sectionsToInsert)
            self.collectionView.insertItems(at: indexPathsToInsert)
        } completion: { (_) in
            let headerIndexPaths = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)
            headerIndexPaths.forEach { (indexPath) in
                let headerView = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as! HeaderView
                let section = self.sectionStubs[indexPath.section]
                headerView.setup(text: "\(section.category) (\(section.characters.count))".uppercased())
            }
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
}


struct MultipleSectionsVCRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: MultipleSectionsViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController
}


struct MultipleSectionsViewController_Preview: PreviewProvider {
    static var previews: some View {
        MultipleSectionsVCRepresentable()
            .edgesIgnoringSafeArea(.top)
    }
}
