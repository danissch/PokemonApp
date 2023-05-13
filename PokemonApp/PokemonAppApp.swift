//
//  PokemonAppApp.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 7/05/23.
//

import SwiftUI
import PokemonAPI

@main
struct PokemonAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            let pokemonAPI = PokemonAPI()
            //ContentView()
                //.environment(\.managedObjectContext, persistenceController.container.viewContext)
            PokemonListView().environmentObject(pokemonAPI)
        }
    }
}
