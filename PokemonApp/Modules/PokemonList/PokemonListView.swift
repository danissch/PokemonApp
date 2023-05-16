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
import CoreData

struct PokemonListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var viewModel: PokemonListViewModel?
    @State var error: Error?
    @State var pageIndex = 0
    @State var pagedObject: PKMPagedObject<PKMPokemon>?
    @State var offlineList: [PokemonItem]?
    @State private var showingSheet = false
    @State var loading:LoadingView? = LoadingView.shared
    var detailView: PokemonDetailView?
    @State private var searchText = ""
    @State var rowsPerPage:Int = 10

    var onlineSearchResults: [PKMNamedAPIResource<PKMPokemon>]? {
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
    
    var offlineSearchResults: [PokemonItem]? {
        if searchText.isEmpty {
            if let results = offlineList {
                return results
            }
            return []
        } else {
            if let results = offlineList {
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
                            viewModel = PokemonListViewModel(viewContext:viewContext, delegate: self)
                            await fetchPokemon()
                            
                        }.navigationBarHidden(false)
                        .navigationTitle("Pokemons")
                        .navigationBarTitleDisplayMode(.inline)
                }
                
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always) ,prompt: "Look on this page")
            .disableAutocorrection(true)

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
            } else {
                
                if viewModel?.offlineMode ?? false {
                    
                    if let offlineSearchResults = offlineSearchResults?.sorted(by: { $0.id < $1.id }) {
                        
                        List {
                            ForEach(offlineSearchResults.indices, id: \.self){ pok in
                                let pokemon = offlineSearchResults[pok]
                                
                                let pokemonCardView = PokemonCardView(
                                    name: getPokemonName(pokemonName: pokemon.name ?? ""),
                                    imageURLString: getPokemonImage(pokemonName: pokemon.name ?? ""),
                                    images: getPokemonImages(pokemonName: pokemon.name ?? ""),
                                    types: getPokemonTypes(pokemonName: pokemon.name ?? ""),
                                    abilities: getPokemonAbilities(pokemonName: pokemon.name ?? ""),
                                    moves: getPokemonMoves(pokemonName: pokemon.name ?? ""),
                                    isDetail: false
                                ).padding(12)
                                
                                Button {
                                    self.setViewModelSelectedData(
                                        selectedName: getPokemonName(pokemonName: pokemon.name ?? ""),
                                        selectedImage: getPokemonImage(pokemonName: pokemon.name ?? ""),
                                        selectedImages: getPokemonImages(pokemonName: pokemon.name ?? ""),
                                        selectedTypes: getPokemonTypes(pokemonName: pokemon.name ?? ""),
                                        selectedAbilities: getPokemonAbilities(pokemonName: pokemon.name ?? ""),
                                        selectedMoves: getPokemonMoves(pokemonName: pokemon.name ?? "")
                                    )
                                    showingSheet.toggle()
                                    
                                } label: {
                                    
                                    pokemonCardView
                                
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
                            
                        }.refreshable(action: {
                            guard let pagedObject = pagedObject else { return }
                            Task {
                                await fetchPokemon(paginationState: .continuing(pagedObject, .page(pageIndex)))
                            }
                        })
                        .listStyle(.automatic).textSelection(.disabled)
                    }
                    
                } else {
                    
                    menu
                    
                    if let searchResults = onlineSearchResults {
                        List {
                            ForEach(searchResults.indices, id: \.self){ pok in
                                let pokemon = searchResults[pok]
                                
                                let pokemonCardView = PokemonCardView(
                                    name: getPokemonName(pokemonName: pokemon.name ?? ""),
                                    imageURLString: getPokemonImage(pokemonName: pokemon.name ?? ""),
                                    images: getPokemonImages(pokemonName: pokemon.name ?? ""),
                                    types: getPokemonTypes(pokemonName: pokemon.name ?? ""),
                                    abilities: getPokemonAbilities(pokemonName: pokemon.name ?? ""),
                                    moves: getPokemonMoves(pokemonName: pokemon.name ?? ""),
                                    isDetail: false
                                ).padding(12)
                                
                                Button {
                                    self.setViewModelSelectedData(
                                        selectedName: getPokemonName(pokemonName: pokemon.name ?? ""),
                                        selectedImage: getPokemonImage(pokemonName: pokemon.name ?? ""),
                                        selectedImages: getPokemonImages(pokemonName: pokemon.name ?? ""),
                                        selectedTypes: getPokemonTypes(pokemonName: pokemon.name ?? ""),
                                        selectedAbilities: getPokemonAbilities(pokemonName: pokemon.name ?? ""),
                                        selectedMoves: getPokemonMoves(pokemonName: pokemon.name ?? "")
                                    )
                                    showingSheet.toggle()
                                    
                                } label: {
                                    
                                    pokemonCardView
                                    
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
                        .refreshable(action: {
                            if !showingSheet {
                                guard let pagedObject = pagedObject else { return }
                                Task {
                                    await fetchPokemon(paginationState: .continuing(pagedObject, .page(pageIndex)))
                                }
                            }
                        })
                        .listStyle(.automatic).textSelection(.disabled)
                    }
                }
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
                .frame(width: 100, height: 50)
                .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
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
            let limit1 = 30
            let limit2 = 50
            let limit3 = 100
            let limit4 = 200
            let limit5 = 400
            let limit6 = 800
            let limit7 = 2000
            let label = "Limit "
            Text("\(label)\(limit0)").tag(limit0)
            Text("\(label)\(limit1)").tag(limit1)
            Text("\(label)\(limit2)").tag(limit2)
            Text("\(label)\(limit3)").tag(limit3)
            Text("\(label)\(limit4)").tag(limit4)
            Text("\(label)\(limit5)").tag(limit5)
            Text("\(label)\(limit6)").tag(limit6)
            Text("\(label)\(limit7)").tag(limit7)
        }
        
        #if os(macOS)
        .pickerStyle(.menu)
        #endif
        
        .onChange(of: rowsPerPage) { index in
            rowsPerPage = index
            pageIndex = 0
            Task {
                await fetchPokemon()
            }
        }
    }
    
}

extension PokemonListView {
    func fetchPokemon(paginationState: PaginationState<PKMPokemon>? = nil) async {
        viewModel?.checkConnection()
        var pageLimit:PaginationState<PKMPokemon> = .initial(pageLimit: rowsPerPage )
        
        if let paginationState = paginationState {
            pageLimit = paginationState
        }
        
        await viewModel?.getPokemonListItems(paginationState: pageLimit) { (responseOffline, responseOnline, remotePagedObject) in
            if viewModel?.offlineMode ?? false{
                offlineList = responseOffline
            } else {
                pagedObject = remotePagedObject
            }
        }
    }
}

extension PokemonListView {
    func setViewModelSelectedData(selectedName:String, selectedImage:String, selectedImages:[String], selectedTypes:[String], selectedAbilities:[String], selectedMoves: [String]){
        viewModel?.selectedName = selectedName
        viewModel?.selectedImage = selectedImage
        viewModel?.selectedImages = selectedImages
        viewModel?.selectedTypes = selectedTypes
        viewModel?.selectedAbilities = selectedAbilities
        viewModel?.selectedMoves = selectedMoves
    }
    
}

extension PokemonListView: PokemonListViewModelProtocol {
    func processStarted(){
        loading = LoadingView()
    }
    
    func processFinish(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            loading = nil
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
}

extension PokemonListView {
    private func getPokemonName(pokemonName:String) -> String{
        return viewModel?.getPokemonName(pokemonName: pokemonName).uppercased() ?? ""
    }
    
    private func getPokemonImage(pokemonName:String) -> String{
        return viewModel?.getPokemontImageURL(pokemonName: pokemonName) ?? ""
    }
    
    private func getPokemonImages(pokemonName:String) -> [String]{
        return viewModel?.getPokemonImagesURLs(pokemonName: pokemonName) ?? []
    }
    
    private func getPokemonTypes(pokemonName:String) -> [String]{
        return viewModel?.getPokemonTypes(pokemonName: pokemonName) ?? []
    }
    
    private func getPokemonAbilities(pokemonName:String) -> [String]{
        return viewModel?.getPokemonAbilities(pokemonName: pokemonName) ?? []
    }
    
    private func getPokemonMoves(pokemonName:String) -> [String]{
        return viewModel?.getPokemonMoves(pokemonName: pokemonName) ?? []
    }
    
}




struct PokemonListView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

