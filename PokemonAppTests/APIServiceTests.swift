//
//  APIServiceTests.swift
//  PokemonAppTests
//
//  Created by Daniel Duran Schutz on 15/05/23.
//

import Foundation
import XCTest
import PokemonAPI

@testable import PokemonApp

class APIServiceTests:XCTestCase {
    
    var sut: APIService?
    
    override func setUp() {
        super.setUp()
        sut = APIService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_fetchData_defaultRows(){
        let expect = XCTestExpectation(description: "callback")
        let paginationState:PaginationState<PKMPokemon> = StubGenerator().stubPaginatedStateObject()

        sut?.fetchData(paginationState: paginationState, completion: { pagedObject, error  in
            expect.fulfill()
            if let results = pagedObject?.results {
                XCTAssertEqual(results.count, 10)
                for pokemon in results {
                    XCTAssertNotNil(pokemon)
                }
            }
        })
    }
    
    func test_fetchData_onePokemon(){
        let expect = XCTestExpectation(description: "callback")
        sut?.fetchData(pokemonID: 1, completion: { pokemon, error  in
            expect.fulfill()
            XCTAssertNotNil(pokemon?.name)
            XCTAssertEqual(pokemon?.id, 1)
        })
    }
    
    func test_fetchData_pokemonService_SuccessResponse(){
        let expect = XCTestExpectation(description: "callback")
        let paginationState:PaginationState<PKMPokemon> = StubGenerator().stubPaginatedStateObject()
        sut?.fetchData(paginationState: paginationState, completion: { pagedObject, error  in
            self.sut?.pokemonAPI?.pokemonService.fetchPokemonList(paginationState:paginationState, completion: { result in
                switch result {
                case .success(let success):
                    expect.fulfill()
                    XCTAssertGreaterThanOrEqual(success.results?.count ?? 0, 1)
                    break

                case .failure(let failure):
                    print("appflow:: failure: ")
                    XCTAssertNil(failure)
                    break
                }

            })
        })
    }
    
    func test_fetchPokemonListDataCountIsAccording(){
        let paginationState:PaginationState<PKMPokemon> = StubGenerator().stubPaginatedStateObject()
        sut?.fetchData(paginationState: paginationState, completion: { pagedObject, error  in
            let url = URL(string:self.sut?.pagedObject?.current ?? "")
            if let limit = url?.valueOf("limit") as? String {
                XCTAssertEqual(Int(limit), self.sut?.pagedObject?.results?.count)
            }
        })
    }
    
//    func test_failureCase(){
//        let expect = XCTestExpectation(description: "callback")
//        let paginationState:PaginationState<PKMPokemon> = StubGenerator().stubPaginatedStateObject()
//
//        sut?.fetchData(paginationState: paginationState, completion: { pagedObject, error  in
//            self.sut?.pokemonAPI?.pokemonService.fetchPokemonList(paginationState:paginationState, completion: { result in
//                let result = StubGenerator().stubResultFailurePagedObjectPokemons()
//                switch result {
//                case .success(_):
//                    break
//                case .failure(let failure):
//                    expect.fulfill()
//                    XCTAssertEqual(failure.localizedDescription, HTTPError.httpError.errorDescription)
//                    //print("appflow:: This is the error: \(failure.localizedDescription)")
//                    //XCTAssertNotNil(failure)
//                    break
//                }
//            })
//        })
//    }
    
}

extension URL {
    func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}
