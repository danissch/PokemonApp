//
//  ListItem.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 11/05/23.
//

import Foundation
import SwiftUI

struct ListItem: View {

    @State var viewModel: PokemonListViewModel?
    @State var searchResults: [Pokemon]
    @State var list:[Pokemon]
    
    var body: some View {
        ForEach(searchResults.indices, id: \.self){ pok in
            
            let name = "\(list[pok].name)"
            
            Text("prueba: \(name)")
            
        }
    }

}
