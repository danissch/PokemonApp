//
//  PokemonListViewModel.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 7/05/23.
//

import Foundation
import PokemonAPI

class PokemonListViewModel: ObservableObject {
    
    @Published var pokemonListItems:[Pokemon]? = []
    @Published var filteredPokemonListItems:[Pokemon]?
    
    var pagedObject: PKMPagedObject<PKMPokemon>?
    //var error: Error?
    
    let apiService: APIServiceProtocol
    //@Published var selectedPokemon:Pokemon?
    
    @Published var selectedName:String?
    @Published var selectedImage:String?
    @Published var selectedImages:[String]?
    @Published var selectedTypes:String?
    @Published var selectedAbilities:String?
    @Published var selectedMoves:String?
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
}

extension PokemonListViewModel {
    
    func getPokemonName(pokemonName:String, list: [Pokemon]?) -> String{
        return pokemonListItems?.first(where: {$0.name == pokemonName})?.name?.uppercased() ?? ""
    }
    
    func getPokemonItem(pokemonName:String) -> Pokemon {
        return pokemonListItems?.first(where: {$0.name == pokemonName}).self ?? Pokemon(id: 0, name: "", images: [], types: [], abilities: [], moves: [])
    }
    
    func getPokemonID(pokemonName:String) -> Int? {
        return pokemonListItems?.first(where: {$0.name == pokemonName})?.id
    }

    func getPokemontImageURL(pokemonName:String) -> String? {
        let currentSprites = pokemonListItems?.first(where: {$0.name == pokemonName})?.images
        var image: String = ""
        for sprite in currentSprites ?? [] {
            if sprite.spriteType == .frontDefault, sprite.imageURL != "" {
                image = sprite.imageURL
            }
//            else if sprite.spriteType == .frontShiny, sprite.imageURL != "" {
//                image = sprite.imageURL
//            } else if sprite.spriteType == .frontFemale, sprite.imageURL != "" {
//                image = sprite.imageURL
//            } else if sprite.spriteType == .frontShinyFemale, sprite.imageURL != "" {
//                image = sprite.imageURL
//            }
            
        }
        return image
    }
    
    func getPokemonImagesURLs(pokemonName:String) -> [String] {
        let currentSprites = pokemonListItems?.first(where: {$0.name == pokemonName})?.images
        var images: [String] = []
        for sprite in currentSprites ?? [] {
            if sprite.imageURL != "" {
                images.append(sprite.imageURL)
            }
        }
        return images
    }
    
    
    func getPokemonTypes(pokemonName:String) ->  [PKMPokemonType]? {
        return pokemonListItems?.first(where: {$0.name == pokemonName})?.types
    }
    
    func getPokemonAbilities(pokemonName:String) ->  [PKMPokemonAbility]? {
        return pokemonListItems?.first(where: {$0.name == pokemonName})?.abilities
    }
    
    func getPokemonMoves(pokemonName:String) ->  [PKMPokemonMove]? {
        return pokemonListItems?.first(where: {$0.name == pokemonName})?.moves
    }
    
    func getPokemonTypesStrings(pokemonName:String) -> String {
        var typesStrings = ""
        let types = getPokemonTypes(pokemonName: pokemonName)
        
        for type in types ?? [] {
            typesStrings += "\(type.type?.name ?? "") "
        }
        
        return typesStrings
    }
    
    func getPokemonAbilitiesStrings(pokemonName:String) -> String {
        var abilitiesStrings = ""
        let abilities = getPokemonAbilities(pokemonName: pokemonName)
        
        for ability in abilities ?? [] {
            abilitiesStrings += "\(ability.ability?.name ?? "") "
        }
        
        return abilitiesStrings
    }
    
    func getPokemonMovesStrings(pokemonName:String) -> String {
        var movesStrings = ""
        let moves = getPokemonMoves(pokemonName: pokemonName)
        
        for move in moves ?? [] {
            movesStrings += "\(move.move?.name ?? "") "
        }
        
        return movesStrings
    }
    
}

extension PokemonListViewModel {
    
    func getPokemonListItems(paginationState: PaginationState<PKMPokemon>, completion: @escaping ([Pokemon]?, PKMPagedObject<PKMPokemon>?) -> () ){
        self.apiService.fetchData(paginationState: paginationState) { result in
            if let response = result {
                self.pagedObject = response
                self.extract_pokemonList(completion: completion)
            }
        }
    }
    
}

extension PokemonListViewModel {
    private func extract_pokemonList(completion: @escaping ([Pokemon]?, PKMPagedObject<PKMPokemon>?) -> ()){
        if let pagedObject = pagedObject,
                let pokemonResults = pagedObject.results as? [PKMNamedAPIResource] {
            pokemonListItems?.removeAll()
            for pokemon in pokemonResults {
                let id = PokemonViewModelslHelper.extractPokemonID(pokemon: pokemon)
                
                
                PokemonViewModelslHelper.getPokemon(apiService: self.apiService, id: id) { item in
                    let itemForList = Pokemon(
                        id: item?.id,
                        name: item?.name ?? "",
                        images: PokemonViewModelslHelper.getPokemonSprites(item: item),
                        types: item?.types,
                        abilities: item?.abilities,
                        moves: item?.moves
                    )
                    
                    self.pokemonListItems?.append(itemForList)
                    completion(self.pokemonListItems, self.pagedObject)
                }
                
            }
        }
    }
    
}



