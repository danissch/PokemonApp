//
//  ScrollGalleryView.swift
//  PokemonApp
//
//  Created by Daniel Duran Schutz on 11/05/23.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ScrollGalleryView: View {
    
    let images:[String]
    let action:((String?) -> ())?
    
    var body: some View {
        content.task {
            //
        }
    }
    
    var content: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(images.enumerated()), id:\.1) { index, image in
                    Button {
                        action?(image)
                        
                    } label: {
                        WebImage(url: URL(string: image ))
                            .onSuccess { image, data, cacheType in
                            }.placeholder {
                                Rectangle().foregroundColor(.clear)
                            }.indicator(.activity).transition(.fade(duration: 0.5))
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                minHeight: 0,
                                maxHeight: .infinity,
                                alignment: .center
                              )
                    }

                    
                }
            }
        }.frame(height: 100)
        
    }
    
}
