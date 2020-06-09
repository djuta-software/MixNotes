import SwiftUI

struct GlobalMessageView: View {
    
    @ObservedObject var globalMessageService: GlobalMessageService
    
    var body: some View {
        guard let message = globalMessageService.currentMessage else {
            return AnyView(EmptyView())
        }
        let text = Text(message).background(backgroundColour)
        return AnyView(text)
    }
    
    private var backgroundColour: Color {
        switch globalMessageService.currentType {
        case .error:
            return Color.red
        case .success:
            return Color.green
        default:
            return Color.blue
        }
    }
}

struct GlobalMessageView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewUtils.createPreviewGlobalMessageView()
    }
}
