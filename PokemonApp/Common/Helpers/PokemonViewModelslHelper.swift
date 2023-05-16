//
//  PokemonViewModelslHelper.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 8/05/23.
//

import Foundation
import PokemonAPI
import SwiftUI

struct PokemonViewModelslHelper {
 
    static  func extractPokemonID(pokemon:PKMNamedAPIResource<PKMPokemon>) -> Int{
        let urlArray = pokemon.url?.components(separatedBy: "/")
        var id = 0
        if let count = urlArray?.count {
            id = Int(urlArray?[count - 2] ?? "0") ?? 0
        }
        
        return id
    }
    
    static func getPokemonSprites(item: PKMPokemon?) -> [PokemonSprite] {
        let images:[PokemonSprite] = [
            PokemonSprite(
                spriteType: SpriteType.frontDefault,
                imageURL: item?.sprites?.frontDefault ?? ""
            ),
            PokemonSprite(
                spriteType: SpriteType.frontFemale,
                imageURL: item?.sprites?.frontFemale ?? ""
            ),
            PokemonSprite(
                spriteType: SpriteType.frontShiny,
                imageURL: item?.sprites?.frontShiny ?? ""
            ),
            PokemonSprite(
                spriteType: SpriteType.backDefault,
                imageURL: item?.sprites?.backDefault ?? ""
            ),
            PokemonSprite(
                spriteType: SpriteType.backFemale,
                imageURL: item?.sprites?.backFemale ?? ""
            ),
            PokemonSprite(
                spriteType: SpriteType.backShiny,
                imageURL: item?.sprites?.backShiny ?? ""
            ),
            PokemonSprite(
                spriteType: SpriteType.backShinyFemale,
                imageURL: item?.sprites?.backShinyFemale ?? ""
            ),
            PokemonSprite(
                spriteType: SpriteType.frontShinyFemale,
                imageURL: item?.sprites?.frontShinyFemale ?? ""
            )
        ]
        
        return images
    }
    
    static func getPokemonSpritesStrings(item: PKMPokemon?) -> [String] {
        
        var images:[String] = []
        
        if let frontDefault = item?.sprites?.frontDefault, frontDefault != "" {
            images.append(frontDefault)
        }
        if let backDefault = item?.sprites?.backDefault, backDefault != "" {
            images.append(backDefault)
        }
        if let frontShiny = item?.sprites?.frontShiny, frontShiny != "" {
            images.append(frontShiny)
        }
        if let backShiny = item?.sprites?.backShiny, backShiny != "" {
            images.append(backShiny)
        }
        if let frontFemale = item?.sprites?.frontFemale, frontFemale != ""{
            images.append(frontFemale)
        }
        if let backFemale = item?.sprites?.backFemale, backFemale != "" {
            images.append(backFemale)
        }
        if let frontShinyFemale = item?.sprites?.frontShinyFemale, frontShinyFemale != "" {
            images.append(frontShinyFemale)
        }
        if let backShinyFemale = item?.sprites?.backShinyFemale, backShinyFemale != "" {
            images.append(backShinyFemale)
        }

        return images
    }
    
    
    static func getPokemonTypes(item: PKMPokemon?) -> [String]{
        var types:[String] = []
        
        for type in item?.types ?? [] {
            if let name = type.type?.name {
                types.append(name)
            }
        }
        
        return types
    }
    
    static func getPokemonAbilities(item: PKMPokemon?) -> [String] {
        var abilities:[String] = []
        for ability in item?.abilities ?? [] {
            if let name = ability.ability?.name {
                abilities.append(name)
            }
        }
        return abilities
    }
    
    static func getPokemonMoves(item: PKMPokemon?) -> [String] {
        var moves: [String] = []
        for move in item?.moves ?? []{
            if let name = move.move?.name {
                moves.append(name)
            }
        }
        return moves
    }
    
    
    static func convertArrayPokemonItemToPokemonArray(array:[PokemonItem]) -> [Pokemon]{
        var pokemonArray:[Pokemon] = []
    
        for data in array {
            let id = data.id
            let name = data.name
            let image = data.image
            let images = data.images
            let types = data.types
            let abilities = data.abilities
            let moves = data.moves
        }
    
        
        return []
    }
    
}
