//
//  PokemonCardView.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 8/05/23.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct PokemonCardView: View {
    
    var name:String?
    var imageURLString:String?
    @State var imageURLStringForAction:String?
    var images:[String]?
    var types:[String]?
    var abilities:[String]?
    var moves:[String]?
    var isDetail:Bool?
    
    @State var loading:LoadingView? = LoadingView.shared
    
    @State private var showingSheet = false
    
    var body: some View {
        VStack {
            
            if isDetail ?? false {
                Text(name ?? "Unknown Pokemon").fontWeight(.heavy)
                
                Button {
                    showingSheet.toggle()
                } label: {
                    
                    WebImage(url: URL(string: imageURLStringForAction ?? "" ))
                        .onSuccess { image, data, cacheType in
                        }
                        .resizable()
                        .placeholder {
                            Rectangle().foregroundColor(.clear)
                        }.indicator(.activity).transition(.fade(duration: 0.5))
                        .imageScale(.medium)
                        .scaledToFit()
                        .frame(
                            minWidth: 100,
                            maxWidth: .greatestFiniteMagnitude,
                            minHeight: 100,
                            maxHeight: 200,
                            alignment: .center
                        )
                    
                }.sheet(isPresented: $showingSheet) {
                    
                    WebImage(url: URL(string: imageURLStringForAction ?? "" ))
                        .onSuccess { image, data, cacheType in
                        }
                        .resizable()
                        .placeholder {
                            Rectangle().foregroundColor(.clear)
                        }.indicator(.activity).transition(.fade(duration: 0.5))
                        .imageScale(.medium)
                        .scaledToFit()
                        .frame(
                            minWidth: 320,
                            maxWidth: .greatestFiniteMagnitude,
                            minHeight: 320,
                            maxHeight: .greatestFiniteMagnitude,
                            alignment: .center
                        )
                }
                
                ScrollGalleryView(images: images ?? [], action: { url in
                    if let url = url {
                        imageURLStringForAction = url
                    }
                }).background(.gray.opacity(0.05)).border(.gray.opacity(0.1)).cornerRadius(10)
                
                VStack {
                
                    Text("Types").bold().frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
                    if let types = types {
                        ForEach(types.indices) { index in
                            Text("\(types[index])").frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
                        }
                    }
                    
                    Text("Abilities").bold().frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
                    if let abilities = abilities {
                        ForEach(abilities.indices) { index in
                            Text("\(abilities[index])").frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
                        }
                    }
                    
                    Text("Moves").bold().frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
                    if let moves = moves {
                        ForEach(moves.indices) { index in
                            Text("\(moves[index])").frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
                        }
                    }
                    
                }.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                
            } else {
                loading
                WebImage(url: URL(string: imageURLString ?? "" ))
                    .onSuccess { image, data, cacheType in
                        loading = nil
                    }.placeholder {
                        Rectangle().foregroundColor(.clear)
                    }.indicator(.activity).transition(.fade(duration: 0.5)).aspectRatio(.pi, contentMode: .fill)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                  )
                
                Text(name ?? "Unknown Pokemon")
                
                if let types = types {
                    Text("Types:")
                    HStack {
                        ForEach(types, id: \.self){ type in
                            //let newIndex = types.count == 1 ? 0 : index
                            //if types.count == 1 {
                                
                            //} else if types.count == 0
                            Text("\(type)")
                        }
                    }
                }
                
            }
            
        }
        
    }

}
