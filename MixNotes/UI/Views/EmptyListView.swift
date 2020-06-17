//
//  EmptyView.swift
//  MixNotes
//
//  Created by Deven Juta on 2020-06-10.
//  Copyright © 2020 Deven Juta. All rights reserved.
//

import SwiftUI

struct EmptyListView: View {
    let title: String
    let systemImageName: String
    let description: String
    
    var body: some View {
        VStack {
            Text(title).font(.title)
            Image(systemName: systemImageName)
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            Text(description)
        }
        .padding()
        .multilineTextAlignment(.center)
        
    }
}

struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView(
            title: "Message",
            systemImageName: SFIcon.ERROR,
            description: "Oh no! Something wrong happened and we're sorry."
        )
    }
}
