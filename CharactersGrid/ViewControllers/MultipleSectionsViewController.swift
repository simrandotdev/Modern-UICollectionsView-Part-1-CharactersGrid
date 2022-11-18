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
            collectionView.reloadData()
        }
    }
    
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
        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CharacterCell
        let character = sectionStubs[indexPath.section].characters[indexPath.item]
        cell.setup(character: character)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        let section = sectionStubs[indexPath.section]
        headerView.setup(text: "\(section.category) \(section.characters.count)".uppercased())
        
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
