//
//  APIService.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 7/05/23.
//

import Foundation
import PokemonAPI

final class APIService: APIServiceProtocol {
    //var pokemonAPI: PokemonAPI.PokemonAPI?
    
    
    var pokemonAPI: PokemonAPI?
    var error: Error?
    var pagedObject: PKMPagedObject<PKMPokemon>?
    
    init(pokemonAPI:PokemonAPI = PokemonAPI()){
        self.pokemonAPI = pokemonAPI
    }
    
    func fetchData(paginationState:PaginationState<PKMPokemon>, completion: @escaping (PKMPagedObject<PKMPokemon>?) -> Void) {
        
        pokemonAPI?.pokemonService.fetchPokemonList(paginationState:paginationState, completion: { result in
            switch result {
            case .success(let success):
                completion(success)
                break
            
            case .failure(let failure):
                print("fetchData A failure", failure)
                self.error = failure
                completion(nil)
                break
            }
            
        })
    }
    
    func fetchData(pokemonID:Int? = nil, completion: @escaping (PKMPokemon?) -> Void) {
        
        guard let id = pokemonID else { return }
        pokemonAPI?.pokemonService.fetchPokemon(id, completion: { result in
            switch result {
            case .success(let success):
                completion(success)
                break
            case .failure(let failure):
                print("fetchData B failure:", failure)
                self.error = failure
                completion(nil)
                break
                
            }
        })
        
    }
}
