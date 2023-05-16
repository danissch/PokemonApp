//
//  StubGenerator.swift
//  PokemonAppTests
//
//  Created by Daniel Duran Schutz on 16/05/23.
//

import Foundation
import PokemonAPI


class StubGenerator {
    func stubPaginatedStateObject() -> PaginationState<PKMPokemon>{
        return .initial(pageLimit: 10)
    }
    
    func stubResultSuccessPagedObjectPokemons<T>(completion: @escaping (Result<PKMPagedObject<T>, Error>) -> Void) where T : Codable {
        completion(
            Result.success(stubPagedObject())
        )
    }
    
    func stubResultFailurePagedObjectPokemons<T>(completion: @escaping (Result<PKMPagedObject<T>, Error>) -> Void) where T : Codable {
        let error = stubNetworkError()
        completion(.failure(error))
    }
    
    func stubResultFailurePagedObjectPokemons() -> Result<PKMPagedObject<PKMPokemon>, Error> {
        let error = stubNetworkError()
        return .failure(error)
    }
    
    
    func stubNetworkError() -> Error{
        var error = HTTPError.httpError
        return error
    }
    
    func stubPagedObject<T>() -> PKMPagedObject<T>{
        var pagedObject:PKMPagedObject<T>?
        
        let testBundle = Bundle(for: type(of: self))
        if let path = testBundle.url(forResource: "MockPagedObject", withExtension: "json") {
            do {
                let data = try Data(contentsOf: path)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(PKMPagedObject<T>.self, from: data)
                pagedObject = jsonData
            } catch {
                print("appflow:: error:\(error)")
            }
        }
        
        return pagedObject!
    }
}

extension NSError {
    
}
