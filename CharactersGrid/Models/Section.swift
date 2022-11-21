//
//  Section.swift
//  CharactersGrid
//
//  Created by Simran Preet Narang on 2022-11-21.
//

import Foundation

struct Section: Hashable {
    let category: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
    }
    
    func headerTitleText(count: Int = 0) -> String {
        guard count > 0 else {
            return category.uppercased()
        }
        return "\(category) (\(count))".uppercased()
    }
    
}
