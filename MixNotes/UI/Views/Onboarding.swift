//
//  OnboardingView.swift
//  MixNotes
//
//  Created by Deven Juta on 2020-06-25.
//  Copyright © 2020 Deven Juta. All rights reserved.
//

import SwiftUI

struct Onboarding: View {
    let title: String
    let applicationFeatures: [ApplicationFeature]
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack {
            Text(title).font(.largeTitle)
            List(applicationFeatures, id: \.title) { $0 }
            Button(action: action) {
                Text(actionTitle)
            }
        }
        
    }
}

struct ApplicationFeature: View {
    let title: String
    let description: String
    let systemImage: String
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(title).bold()
                Text(description)
            }
        }
    }
}

//struct Onboarding_Previews: PreviewProvider {
//    static var previews: some View {
//        Onboarding(
//            title: "Mix Notes",
//            applicationFeatures: applicationFeatures,
//            actionTitle: "Let's Go!",
//            action: {}
//        )
//    }
//}
