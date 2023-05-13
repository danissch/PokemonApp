//
//  PokemonListView.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 7/05/23.
//

import Foundation
import SwiftUI
import PokemonAPI
import SDWebImageSwiftUI

struct PokemonListView: View {
    
    @State var viewModel: PokemonListViewModel?
    @State var error: Error?
    @State var pageIndex = 0
    @State var pagedObject: PKMPagedObject<PKMPokemon>?
    @State var list: [Pokemon]?
    @State private var showingSheet = false
    @State var loading:LoadingView? = LoadingView.shared
    var detailView: PokemonDetailView?
    @State private var searchText = ""
    @State var rowsPerPage:Int = 10

    var searchResults: [PKMNamedAPIResource<PKMPokemon>]? {
        if searchText.isEmpty {
            if let results = pagedObject?.results as? [PKMNamedAPIResource] {
                return results
            }
            return []
        } else {
            if let results = pagedObject?.results as? [PKMNamedAPIResource] {
                return results.filter({
                    if let name = $0.name?.lowercased(), let found = name.contains(searchText.lowercased()) as Bool? {
                        return found
                    }
                    return false
                })
            }
            
            return []
        }
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    mainContent
                        .task {
                            viewModel = PokemonListViewModel()
                            await fetchPokemon()
                        }.navigationBarHidden(false)
                        .navigationTitle("Pokemons")
                        .navigationBarTitleDisplayMode(.inline)
                }
                
            }.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always) ,prompt: "Look for a Pokemon")

            loading?.frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .center
            )
        }
        
    }

    var mainContent: some View {
        VStack {
            if let error = error {
                Text("An error occurred: \(error.localizedDescription)")
            } else if let pagedObject = pagedObject,
                        let pokemonResults = pagedObject.results as? [PKMNamedAPIResource],
                        let searchResults = searchResults {
                menu
                List {
                    ForEach(searchResults.indices, id: \.self){ pok in
                        
                        let pokemon = searchResults[pok]
                        let pokemonName = getPokemonName(pokemonName: pokemon.name ?? "", list: list)
                        let image = getPokemonImage(pokemonName: pokemon.name ?? "")
                        let images = getPokemonImages(pokemonName: pokemon.name ?? "")
                        let types = getPokemonTypes(pokemonName: pokemon.name ?? "")
                        let abilities = getPokemonAbilities(pokemonName: pokemon.name ?? "")
                        let moves = getPokemonMoves(pokemonName: pokemon.name ?? "")
                        
                        Button {
                            viewModel?.selectedName = pokemonName
                            viewModel?.selectedImage = image
                            viewModel?.selectedImages = images
                            viewModel?.selectedTypes = types
                            viewModel?.selectedAbilities = abilities
                            viewModel?.selectedMoves = moves
                            showingSheet.toggle()
                        } label: {
                                PokemonCardView(
                                    name: pokemonName,
                                    imageURLString: image,
                                    images: images,
                                    types: types,
                                    abilities: abilities,
                                    moves: moves,
                                    isDetail: false
                                ).padding(12)
                            
                        }.sheet(isPresented: $showingSheet) {
                            
                            PokemonDetailView(
                                name: viewModel?.selectedName,
                                defaultImage: viewModel?.selectedImage,
                                images: viewModel?.selectedImages,
                                types: viewModel?.selectedTypes,
                                abilities: viewModel?.selectedAbilities,
                                moves: viewModel?.selectedMoves
                            )
                        }
                        
                    }
                    
                }
                .listStyle(.automatic).textSelection(.disabled)
            }
        }
    }
    
    var menu: some View {
        HStack {
            
            Button("First") {
                getFirstPage()
            }.frame(width: 35)
            .padding(.init(top: 0, leading: 15, bottom: 0, trailing: 0))
            .disabled(pagedObject?.hasPrevious == false)
                     
            Spacer()
            
            Button(action: {
                getPreviousPage()
                
            }) {
                Image.left
            }
            .frame(width: 10)
            .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .disabled(pagedObject?.hasPrevious == false)
            
            //Spacer()
            
            pagePicker
                .frame(width: 95)
                .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .disabled(pagedObject?.pages ?? 0 <= 1)
            
            //Spacer()
            
            rowsPerPagePicker
                .frame(width: 40, height: 50)
                .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                //.disabled(searchResults?.count ?? 0 <= rowsPerPage-1)
            
            Spacer()
            
            Button(action: {
                getAnotherPage()
                
            }) {
                Image.right
            }
            .frame(width: 10)
            .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .disabled(pagedObject?.hasNext == false)
            
            Spacer()
            
            Button("Last") {
                getLastPage()
            }
            .frame(width: 35)
            .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 15))
            .disabled(pagedObject?.hasNext == false)
            
        }
    }
    
    var pagePicker: some View {
        Picker("", selection: $pageIndex) {
            if let pagedObject = pagedObject {
                ForEach(0..<pagedObject.pages, id: \.self) { page in
                    let current = Int(pagedObject.current) ?? 0
                    Text("Page \(page + 1)")
                        .tag(page)
                }
            }
        }
        
        #if os(macOS)
        .pickerStyle(.menu)
        #endif
        
        .onChange(of: pageIndex) { index in
            guard let pagedObject = pagedObject else { return }
            Task {
                await fetchPokemon(paginationState: .continuing(pagedObject, .page(index)))
            }
        }
    }
    
    var rowsPerPagePicker: some View {
        Picker("", selection: $rowsPerPage) {
            let limit0 = 10
            let limit1 = 20
            let limit2 = 50
            let limit3 = 100
            let limit4 = 200
            let limit5 = 500
            let limit6 = 1000
            let label = "Limit "
            Text("\(label)\(limit0)").tag(limit0)
            Text("\(label)\(limit1)").tag(limit1)
            Text("\(label)\(limit2)").tag(limit2)
            Text("\(label)\(limit3)").tag(limit3)
            Text("\(label)\(limit4)").tag(limit4)
            Text("\(label)\(limit5)").tag(limit5)
            Text("\(label)\(limit6)").tag(limit6)
        }
        
        #if os(macOS)
        .pickerStyle(.menu)
        #endif
        
        .onChange(of: rowsPerPage) { index in
            rowsPerPage = index
            Task {
                await fetchPokemon()
                pageIndex = 0
            }
        }
    }
    
    
    
    func fetchPokemon(paginationState: PaginationState<PKMPokemon>? = nil) async {
        loading = LoadingView()
        var pageLimit:PaginationState<PKMPokemon> = .initial(pageLimit: rowsPerPage )
        
        if let paginationState = paginationState {
            pageLimit = paginationState
        }
        
        viewModel?.getPokemonListItems(paginationState: pageLimit) { (response, remotePagedObject) in
            pagedObject = remotePagedObject
            list = response
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                loading = nil
            }
            
        }
    }
    
}

extension PokemonListView {
    
    private func getFirstPage(){
        guard let pagedObject = pagedObject else { return }
        Task {
            await fetchPokemon(paginationState: .continuing(pagedObject, .first))
        }
        pageIndex = 0
    }
    
    private func getLastPage(){
        guard let pagedObject = pagedObject else { return }
        Task {
            await fetchPokemon(paginationState: .continuing(pagedObject, .last))
        }
        pageIndex = pagedObject.pages-1
    }
    
    private func getAnotherPage(){
        guard let pagedObject = pagedObject else { return }
        Task {
            await fetchPokemon(paginationState: .continuing(pagedObject, .next));
        }
        pageIndex = pagedObject.currentPage+1
    }
    
    private func getPreviousPage(){
        guard let pagedObject = pagedObject else { return }
        Task {
            await fetchPokemon(paginationState: .continuing(pagedObject, .previous))
        }
        pageIndex = pagedObject.currentPage-1
        
    }
    
    
    private func getPokemonName(pokemonName:String, list: [Pokemon]?) -> String{
        return viewModel?.getPokemonName(pokemonName: pokemonName, list: list).uppercased() ?? ""
    }
    
    private func getPokemonImage(pokemonName:String) -> String{
        return viewModel?.getPokemontImageURL(pokemonName: pokemonName) ?? ""
    }
    
    private func getPokemonImages(pokemonName:String) -> [String]{
        return viewModel?.getPokemonImagesURLs(pokemonName: pokemonName) ?? []
    }
    
    private func getPokemonTypes(pokemonName:String) -> String{
        return viewModel?.getPokemonTypesStrings(pokemonName: pokemonName) ?? ""
    }
    
    private func getPokemonAbilities(pokemonName:String) -> String{
        return viewModel?.getPokemonAbilitiesStrings(pokemonName: pokemonName) ?? ""
    }
    
    private func getPokemonMoves(pokemonName:String) -> String{
        return viewModel?.getPokemonMovesStrings(pokemonName: pokemonName) ?? ""
    }
    
}

struct PokemonListView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListView()
            .environmentObject(PokemonListViewModel())
    }
}

