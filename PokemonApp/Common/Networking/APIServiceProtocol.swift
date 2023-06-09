//
//  APIServiceProtocol.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 7/05/23.
//

import Foundation
import PokemonAPI

protocol APIServiceProtocol {
    func fetchData(paginationState:PaginationState<PKMPokemon>, completion: @escaping (PKMPagedObject<PKMPokemon>?, Error?) -> Void)
    func fetchData(pokemonID:Int?, completion: @escaping (PKMPokemon?, Error?) -> Void)
}
