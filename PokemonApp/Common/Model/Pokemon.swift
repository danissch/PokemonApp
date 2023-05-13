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
    let images:[PokemonSprite]?
    let types:[PKMPokemonType]?
    let abilities: [PKMPokemonAbility]?
    let moves: [PKMPokemonMove]?
    
    init(id: Int? = nil, name: String? = nil, images: [PokemonSprite]? = [], types: [PKMPokemonType]? = [], abilities: [PKMPokemonAbility]? = [], moves: [PKMPokemonMove]? = []) {
        self.id = id
        self.name = name
        self.images = images
        self.types = types
        self.abilities = abilities
        self.moves = moves
    }

//    override init() {
//        super.init()
//    }
    
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
