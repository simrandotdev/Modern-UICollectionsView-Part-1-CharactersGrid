//
//  Character.swift
//  CharactersGrid
//
//  Created by Alfian Losari on 9/22/20.
//

import Foundation

struct Character: Codable, Hashable, Identifiable {
    var id: String {
        name
    }
    
    let name: String
    let imageName: String
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case imageName
        case category
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(category)
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.imageName == rhs.imageName &&
        lhs.category == rhs.category
    }
}
