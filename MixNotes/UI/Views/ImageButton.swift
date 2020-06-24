//
//  ImageButton.swift
//  MixNotes
//
//  Created by Deven Juta on 2020-06-23.
//  Copyright © 2020 Deven Juta. All rights reserved.
//

import SwiftUI

struct ImageButton: View {
    
    var systemName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
        }
    }
}

struct ImageButton_Previews: PreviewProvider {
    static var previews: some View {
        ImageButton(systemName: SFIcon.DELETE, action: {})
    }
}
