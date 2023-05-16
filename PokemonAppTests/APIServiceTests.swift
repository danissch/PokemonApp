//
//  APIServiceTests.swift
//  PokemonAppTests
//
//  Created by Daniel Duran Schutz on 15/05/23.
//

import Foundation
import XCTest

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
    
    
    
    
}
