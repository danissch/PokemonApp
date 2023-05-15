//
//  PokemonDetailView.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 9/05/23.
//

import Foundation
import SwiftUI
import PokemonAPI

struct PokemonDetailView: View {
    
    @State var name:String?
    @State var defaultImage:String?
    @State var images:[String]?
    @State var types:[String]?
    @State var abilities:[String]?
    @State var moves:[String]?
    
    @State var viewModel: PokemonDetailViewModel?

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
            mainContent.task {
                viewModel = PokemonDetailViewModel()
            }
            .navigationBarTitle("\(self.getName() )")
            .navigationBarBackButtonHidden(false)
    }
    
    var mainContent: some View {
        List{
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "chevron.backward")
                    Text("Back")
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
            
            VStack {
                PokemonCardView(
                    name: self.getName(),
                    imageURLString: getDefaultImage(),
                    imageURLStringForAction: getDefaultImage(),
                    images: getImages(),
                    types: self.getTypes(),
                    abilities: self.getAbilities(),
                    moves: self.getMoves(),
                    isDetail: true
                )
            }
        }
    }
    
}

extension PokemonDetailView {
    func getName() -> String {
        return name ?? "No name"
    }
    
    func getDefaultImage() -> String{
        return defaultImage ?? "No default image"
    }
    
    func getImages() -> [String] {
        return images ?? []
    }
    
    func getTypes() -> [String] {
        return types ?? ["No types"]
    }
    
    func getAbilities() -> [String] {
        return abilities ?? ["No abilities"]
    }
    
    func getMoves() -> [String] {
        return moves ?? ["No moves"]
    }
    
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetailView()
            //.environmentObject(PokemonListViewModel())
    }
}

