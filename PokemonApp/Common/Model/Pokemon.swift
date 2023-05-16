//
//  Pokemon.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 7/05/23.
//

import Foundation
import PokemonAPI

struct Pokemon {
    let id:Int?
    let name:String?
    let image:String?
    let images:[String]?
    let types:[String]?
    let abilities: [String]?
    let moves: [String]?
    
    init(id: Int? = nil, name: String? = nil, image:String?, images: [String]? = [], types: [String]? = [], abilities: [String]? = [], moves: [String]? = []) {
        self.id = id
        self.name = name
        self.image = image
        self.images = images
        self.types = types
        self.abilities = abilities
        self.moves = moves
    }

}

struct PokemonSprite {
    let spriteType:SpriteType
    let imageURL: String
}

enum SpriteType {
    case frontDefault
    case frontFemale
    case frontShiny
    case backDefault
    case backFemale
    case backShiny
    case backShinyFemale
    case frontShinyFemale
}
