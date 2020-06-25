//
//  CircularButton.swift
//  MixNotes
//
//  Created by Deven Juta on 2020-06-24.
//  Copyright © 2020 Deven Juta. All rights reserved.
//

import SwiftUI

struct CircularImageButton: View {
    let systemName: String
    let diameter: CGFloat
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        ImageButton(systemName: systemName, action: action)
            .frame(width: diameter, height: diameter)
            .background(backgroundColor)
            .clipShape(Circle())
    }
}

struct CircularButton_Previews: PreviewProvider {
    static var previews: some View {
        CircularImageButton(
            systemName: SFIcon.DOWNLOAD,
            diameter: 50,
            backgroundColor: Color.red,
            action: {}
        )
    }
}
