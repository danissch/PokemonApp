//
//  PokemonListViewModel.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 7/05/23.
//

import Foundation
import PokemonAPI
import CoreData
import SwiftUI


class PokemonListViewModel: ObservableObject {
    
    //@Environment(\.managedObjectContext) private var viewContext
    private var viewContext: NSManagedObjectContext
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \PokemonItem.name, ascending: true)],
//        animation: .default)
    
    //var items: [PokemonItem] = []
    var localPagedObject: LocalPagedObject?
    
    @Published var onlineList:[Pokemon]? = []
    @Published var offlineList:[PokemonItem]? = []
    
    
    var pagedObject: PKMPagedObject<PKMPokemon>?
    
    //var error: Error?
    
    let apiService: APIServiceProtocol
    
    @Published var offlineMode = false
    
    @Published var selectedName:String?
    @Published var selectedImage:String?
    @Published var selectedImages:[String]?
    @Published var selectedTypes:[String]?
    @Published var selectedAbilities:[String]?
    @Published var selectedMoves:[String]?
    
    
    init(apiService: APIServiceProtocol = APIService(), viewContext: NSManagedObjectContext = PersistenceController.preview.container.viewContext) {
        self.apiService = apiService
        self.viewContext = viewContext
    }
    
}

extension PokemonListViewModel {
    
    func getPokemonName(pokemonName:String) -> String{
        if offlineMode {
            return offlineList?.first(where: {$0.name == pokemonName})?.name?.uppercased() ?? ""
        } else {
            return onlineList?.first(where: {$0.name == pokemonName})?.name?.uppercased() ?? ""
        }
        
    }
    
    func getPokemonID(pokemonName:String) -> Int? {
        if offlineMode {
            return Int(offlineList?.first(where: {$0.name == pokemonName})?.id ?? 0)
        } else{
            return Int(onlineList?.first(where: {$0.name == pokemonName})?.id ?? 0)
        }
    }

    func getPokemontImageURL(pokemonName:String) -> String? {
        if offlineMode{
            return offlineList?.first(where: {$0.name == pokemonName})?.image
        } else {
            return onlineList?.first(where: {$0.name == pokemonName})?.image
        }
    }
    
    func getPokemonImagesURLs(pokemonName:String) -> [String] {
        if offlineMode {
            let currentSprites = offlineList?.first(where: {$0.name == pokemonName})?.images
            return currentSprites ?? []
        } else {
            let currentSprites = onlineList?.first(where: {$0.name == pokemonName})?.images
            return currentSprites ?? []
        }
    }
    
    func getPokemonTypes(pokemonName:String) ->  [String]? {
        if offlineMode {
            return offlineList?.first(where: {$0.name == pokemonName})?.types
        } else {
            return onlineList?.first(where: {$0.name == pokemonName})?.types
        }
    }
    
    func getPokemonAbilities(pokemonName:String) ->  [String]? {
        if offlineMode {
            return offlineList?.first(where: {$0.name == pokemonName})?.abilities
        } else {
            return onlineList?.first(where: {$0.name == pokemonName})?.abilities
        }
    }
    
    func getPokemonMoves(pokemonName:String) ->  [String]? {
        if offlineMode {
            return offlineList?.first(where: {$0.name == pokemonName})?.moves
        } else {
            return onlineList?.first(where: {$0.name == pokemonName})?.moves
        }
    }
    
//    func getPokemonTypesStrings(pokemonName:String) -> [String] {
//        var typesStrings = ""
//        let types = getPokemonTypes(pokemonName: pokemonName)
//
//        for type in types ?? [] {
//            typesStrings += "\(type)"
//        }
//
//        return typesStrings
//    }
//
//    func getPokemonAbilitiesStrings(pokemonName:String) -> String {
//        var abilitiesStrings = ""
//        let abilities = getPokemonAbilities(pokemonName: pokemonName)
//
//        for ability in abilities ?? [] {
//            abilitiesStrings += "\(ability)"
//        }
//
//        return abilitiesStrings
//    }
//
//    func getPokemonMovesStrings(pokemonName:String) -> String {
//        var movesStrings = ""
//        let moves = getPokemonMoves(pokemonName: pokemonName)
//
//        for move in moves ?? [] {
//            movesStrings += "\(move)"
//        }
//
//        return movesStrings
//    }
    
}

extension PokemonListViewModel {
    
    func checkConnection() {
        offlineMode = Reachability.isConnectedToNetwork() ? false : true
    }
    
    func getPokemonListItems(paginationState: PaginationState<PKMPokemon>, completion: @escaping ([PokemonItem]?, [Pokemon]?, PKMPagedObject<PKMPokemon>?) -> () ){
        if !offlineMode {
            fetchFromAPI(paginationState: paginationState,completion: completion)
        } else {
            fetchFromLocalStorage(paginationState: paginationState, completion: completion)
        }
    }
    
    private func fetchFromAPI(paginationState: PaginationState<PKMPokemon>, completion: @escaping ([PokemonItem]?, [Pokemon]?, PKMPagedObject<PKMPokemon>?) -> ()){
        self.apiService.fetchData(paginationState: paginationState) { result in
            if let response = result {
                self.pagedObject = response
                self.extract_pokemonList(completion: completion)
            }
        }
    }
    
    
    private func extract_pokemonList(completion: @escaping ([PokemonItem]?, [Pokemon]?, PKMPagedObject<PKMPokemon>?) -> ()){
        if let pagedObject = pagedObject,
                let pokemonResults = pagedObject.results as? [PKMNamedAPIResource] {
            offlineList?.removeAll()
            for pokemon in pokemonResults {
                let id = PokemonViewModelslHelper.extractPokemonID(pokemon: pokemon)
                PokemonViewModelslHelper.getPokemon(apiService: self.apiService, id: id) { item in
                    self.fillData(item: item, completion: completion)
                }
                
            }
        }
    }
    
    private func fillData(item: PKMPokemon?, completion: @escaping ([PokemonItem]?, [Pokemon]?, PKMPagedObject<PKMPokemon>?) -> ()){
        
        let image = item?.sprites?.frontDefault ?? "no default image..."
        let images = PokemonViewModelslHelper.getPokemonSpritesStrings(item: item)
        let types = PokemonViewModelslHelper.getPokemonTypes(item: item)
        let abilities = PokemonViewModelslHelper.getPokemonAbilities(item: item)
        let moves = PokemonViewModelslHelper.getPokemonMoves(item: item)
        
        if let itemForList = self.addItem(
            id: Int16(item?.id ?? 0),
            name: item?.name ?? "No name...",
            image: image,
            images: images,
            types: types,
            abilities: abilities,
            moves: moves
        ) {
            self.offlineList?.append(itemForList)
            
        } else {
            
            self.onlineList?.append(
                Pokemon(
                    id:item?.id,
                    name: item?.name,
                    image: image,
                    images: images,
                    types: types,
                    abilities: abilities,
                    moves: moves
                )
            )
        }

        print("appflow:: extract_pokemonList:B:items.count: \(self.offlineList?.count)")
        
        self.offlineList = self.offlineList?.sorted(by: {$0.id < $1.id})
        completion(self.offlineList, self.onlineList, self.pagedObject)
    }

}


extension PokemonListViewModel {
    
    func checkRecordExists(id:Int16 , name:String) -> Bool {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PokemonItem")
            request.predicate = NSPredicate(format: "id == %d AND name == %@", id, name)
            let record = try viewContext.fetch(request)
            let numberOfRecords = try viewContext.count(for: request)
            
            if numberOfRecords == 0 {
                return false
            } else {
                return true
            }
            
        } catch {
            print("Error checking context \(error)")
            return false
        }
        
    }
    
    func fetchFromLocalStorage(paginationState: PaginationState<PKMPokemon>, completion: @escaping ([PokemonItem]?, [Pokemon]?, PKMPagedObject<PKMPokemon>?) -> ()){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PokemonItem")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try viewContext.fetch(request)
            if let result = result as? [PokemonItem] {
                //self.items = result
                for data in result {
                    let id = data.id
                    let name = data.name
                    let image = data.image
                    let images = data.images
                    let types = data.types
                    let abilities = data.abilities
                    let moves = data.moves
                    print("appflow::: getItems: for: id: \(id)")
                    print("appflow::: getItems: for: name: \(name)")
                    print("appflow::: getItems: for: image: \(image)")
                    print("appflow::: getItems: for: images: \(images)")
                    print("appflow::: getItems: for: types: \(types)")
                    print("appflow::: getItems: for: abilities: \(abilities)")
                    print("appflow::: getItems: for: moves: \(moves)")
                }
                self.offlineList = result
                completion(result, nil, nil)
            }
            
            
        } catch {
            print("Failed")
        }
    }
    
    func addItem(id:Int16, name:String, image:String, images:[String], types: [String], abilities: [String], moves: [String]) -> PokemonItem? {
        
        do {
            
            if !checkRecordExists(id: id, name: name ) {
                let newItem = PokemonItem(context: viewContext)
                newItem.id = Int16(id)
                newItem.name = name
                newItem.image = image
                newItem.images = images
                newItem.types = types
                newItem.abilities = abilities
                newItem.moves = moves
                
                try viewContext.save()
                print("appflow:: addItem:A:")
                return newItem
            }
            
        } catch {
            print("appflow:: addItem:B:")
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            return nil
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            
        }
        
        return nil
    }
    
}
