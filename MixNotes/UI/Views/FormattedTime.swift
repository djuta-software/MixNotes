//
//  FormattedTime.swift
//  MixNotes
//
//  Created by Deven Juta on 2020-06-25.
//  Copyright © 2020 Deven Juta. All rights reserved.
//

import SwiftUI

struct FormattedTime: View {
    let time: Double
    var body: some View {
        return Text(DateTimeUtils.formatTime(time))
    }
}

struct FormattedTime_Previews: PreviewProvider {
    static var previews: some View {
        FormattedTime(time: 0.0)
    }
}
