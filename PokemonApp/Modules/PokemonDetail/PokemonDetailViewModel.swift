//
//  PokemonDetailViewModel.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 10/05/23.
//

import Foundation
import PokemonAPI

class PokemonDetailViewModel: ObservableObject {
    @Published var name:String?
    var pkmpokemon:PKMPokemon?
    @Published var pokemon:PKMNamedAPIResource<PKMPokemon>?
    
    let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
}

extension PokemonDetailViewModel {
    
    private func getPokemon(id:Int, completion: @escaping (PKMPokemon?) -> ()) async {
        PokemonViewModelslHelper.getPokemon(apiService: self.apiService, id: id) {  result in
            completion(result)
        }
    }
    
    func getPok(){
        
    }
    
    
}
