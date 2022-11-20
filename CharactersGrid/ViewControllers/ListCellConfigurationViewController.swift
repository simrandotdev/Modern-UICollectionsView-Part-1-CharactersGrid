//
//  ListCellConfigurationViewController.swift
//  CharactersGrid
//
//  Created by Simran Preet Narang on 2022-11-20.
//

import UIKit
import SwiftUI

class ListCellConfigurationViewController: UIViewController {

    var collectionView: UICollectionView!
    @objc let segmentedControl = UISegmentedControl(items: ["Inset", "Plain", "Grouped", "Sidebar"])
    
    var sectionedCharacters = Universe.ff7r.sectionedStubs {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // CELL REGISTRAtION
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Character>!
    private var listAppearance: UICollectionLayoutListConfiguration.Appearance = .insetGrouped
    
    // HEADER REGISTRATION
    private var headerRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!
    
    // LIST LAYOUT
    lazy var listLayout: UICollectionViewLayout = {
        // We are using the the first parameter `section` as our sections look all the same
        return UICollectionViewCompositionalLayout { _, layoutEnvironment in
            var listConfig = UICollectionLayoutListConfiguration(appearance: self.listAppearance)
            listConfig.headerMode = .supplementary
            return NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSegmentedController()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // For Resizing Cells in CollectionView
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        
        cellRegistration = UICollectionView.CellRegistration(handler: { cell, indexPath, model in
            var content = cell.defaultContentConfiguration()
            content.text = model.name
            content.secondaryText = model.category
            content.image = UIImage(named: model.imageName)
            content.imageProperties.maximumSize = .init(width: 60, height: 60)
            content.imageProperties.cornerRadius = 30
            cell.contentConfiguration = content
        })
        
        
        headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader, handler: { supplementaryView, elementKind, indexPath in
            
            let sectionedCharacters = self.sectionedCharacters[indexPath.section]
            
            var content = supplementaryView.defaultContentConfiguration()
            content.text = sectionedCharacters.category.description
            
            supplementaryView.contentConfiguration = content
        })
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    private func setupSegmentedController() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        navigationItem.titleView = segmentedControl
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.listAppearance = .insetGrouped
        case 1:
            self.listAppearance = .plain
        case 2:
            self.listAppearance = .grouped
        default:
            self.listAppearance = .sidebar
        }
        
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension ListCellConfigurationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionedCharacters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionedCharacters[section].characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let character = sectionedCharacters[indexPath.section].characters[indexPath.item]
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
        
        let section = sectionedCharacters[section]
        headerView.setup(text: "\(section.category) \(section.characters.count)".uppercased())
        
        return headerView.systemLayoutSizeFitting(.init(width: collectionView.bounds.width, height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
}


struct ListCellConfigurationViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: MultipleSectionsViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController
}


struct ListCellConfigurationViewController_Preview: PreviewProvider {
    static var previews: some View {
        ListCellConfigurationViewControllerRepresentable()
            .edgesIgnoringSafeArea(.top)
    }
}

