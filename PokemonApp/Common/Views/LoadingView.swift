//
//  LoadingView.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 9/05/23.
//

import Foundation
import SwiftUI

struct LoadingView:View {
    
    static let shared = LoadingView()
    static var backgroundColor = Color.black
    var body: some View {
        VStack {
            ActivityIndicator().frame(width: 100, height: 100)
                .foregroundColor(.white).opacity(0.9)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(LoadingView.backgroundColor).opacity(0.6)
    }
    
}
