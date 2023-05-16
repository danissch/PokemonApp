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

protocol PokemonListViewModelProtocol {
    func processStarted()
    func processFinish()
}

class PokemonListViewModel: ObservableObject {
    
    private var viewContext: NSManagedObjectContext
    
    var localPagedObject: LocalPagedObject?
    
    @Published var onlineList:[Pokemon]? = []
    @Published var offlineList:[PokemonItem]? = []
    
    
    var pagedObject: PKMPagedObject<PKMPokemon>?
    
    
    let apiService: APIServiceProtocol
    
    @Published var offlineMode = false
    
    @Published var selectedName:String?
    @Published var selectedImage:String?
    @Published var selectedImages:[String]?
    @Published var selectedTypes:[String]?
    @Published var selectedAbilities:[String]?
    @Published var selectedMoves:[String]?
    
    var delegate: PokemonListViewModelProtocol?
    
    init(apiService: APIServiceProtocol = APIService(), viewContext: NSManagedObjectContext = PersistenceController.preview.container.viewContext, delegate: PokemonListViewModelProtocol? ) {
        self.apiService = apiService
        self.viewContext = viewContext
        self.delegate = delegate
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
            onlineList?.removeAll()
            
            delegate?.processStarted()
            for pokemon in pokemonResults {
                let id = PokemonViewModelslHelper.extractPokemonID(pokemon: pokemon)
                
                apiService.fetchData(pokemonID: id) { item in
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
            
        }
            
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
        
        self.offlineList = self.offlineList?.sorted(by: {$0.id < $1.id})
        completion(self.offlineList, self.onlineList, self.pagedObject)
        if !offlineMode, onlineList?.count == pagedObject?.results?.count {
            self.delegate?.processFinish()
        }
    }

}


extension PokemonListViewModel {
    
    func checkRecordExists(id:Int16 , name:String) -> Bool {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PokemonItem")
            request.predicate = NSPredicate(format: "id == %d AND name == %@", id, name)
            
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
        delegate?.processStarted()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PokemonItem")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try viewContext.fetch(request)
            if let result = result as? [PokemonItem] {
                self.offlineList = result
                completion(result, nil, nil)
                delegate?.processFinish()
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func addItem(id:Int16, name:String, image:String, images:[String], types: [String], abilities: [String], moves: [String]) -> PokemonItem? {
        
        do {
            
            if !checkRecordExists(id: id, name: name ), id != 0 {
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
            return nil
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            
        }
        
        return nil
    }
    
}
