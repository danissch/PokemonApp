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
    
    static func setImageURLString(view: PokemonCardView, url:String){
//        view.
    }
    
    static  func extractPokemonID(pokemon:PKMNamedAPIResource<PKMPokemon>) -> Int{
        let urlArray = pokemon.url?.components(separatedBy: "/")
        var id = 0
        if let count = urlArray?.count {
            id = Int(urlArray?[count - 2] ?? "0") ?? 0
        }
        
        return id
    }
    
    static func getPokemon(apiService:APIServiceProtocol = APIService(), id:Int, completion: @escaping (PKMPokemon?) -> () ) {
        apiService.fetchData(pokemonID: id) { result in
            completion(result)
        }
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
    
    
}
