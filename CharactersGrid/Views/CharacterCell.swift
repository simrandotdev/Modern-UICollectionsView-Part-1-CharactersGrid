//
//  CharacterCell.swift
//  CharactersGrid
//
//  Created by Simran Preet Narang on 2022-11-15.
//

import UIKit
import SwiftUI

class CharacterCell: UICollectionViewCell {
    
    let imageView = RoundedImageView()
    let textLabel = UILabel()
    let vStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("XIB/Storyboard is not supported for \(#file)")
    }
    
    // For Resizing Cells in CollectionView
    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        let padding: CGFloat = 8
        let noOfItems = traitCollection.horizontalSizeClass == .compact ? 4 : 8
        let itemWidth = (UIScreen.main.bounds.width - (padding * 2)) / CGFloat(noOfItems)
        
        return super.systemLayoutSizeFitting(CGSize(width: itemWidth,
                                                    height: UIView.layoutFittingExpandedSize.height),
                                             withHorizontalFittingPriority: .required,
                                             verticalFittingPriority: .fittingSizeLevel)
    }
    
    private func setupLayout() {
        imageView.contentMode = .scaleAspectFit
        
        // TIP: Making a label dynamic text
        textLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        textLabel.adjustsFontForContentSizeCategory = true
        
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 8
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        // TIP: In a cell always add the subviews in the contentview. Not directly to the view.
        contentView.addSubview(vStack)
        
        vStack.addArrangedSubview(imageView)
        vStack.addArrangedSubview(textLabel)
        
        NSLayoutConstraint.activate([
            // Vertical Stack View constraints
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            // Image View constraints
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }
    
    func setup(character: Character) {
        textLabel.text = character.name
        imageView.image = UIImage(named: character.imageName)
    }
}


struct CharacterCellViewRepresentable: UIViewRepresentable {
    
    let character: Character
    
    func makeUIView(context: Context) -> CharacterCell {
        let cell = CharacterCell()
        cell.setup(character: character)
        return cell
    }
    
    func updateUIView(_ uiView: CharacterCell, context: Context) {
        
    }
    
    typealias UIViewType = CharacterCell
}

struct CharacterCell_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            ScrollView {
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())]) {
                    ForEach(Universe.ff7r.stubs) {
                        CharacterCellViewRepresentable(character: $0)
                            .frame(width: 120, height: 150)
                    }
                }
            }
        }
        
        
    }
}
