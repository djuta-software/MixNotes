import SwiftUI

fileprivate let applicationFeatures = [
    ApplicationFeature(title: "Create a Project", description: "It's a lot of fun", systemImage: SFIcon.LOADING),
    ApplicationFeature(title: "Add some tracks", description: "It's a lot of fun", systemImage: SFIcon.DELETE),
    ApplicationFeature(title: "Make a note", description: "It's a lot of fun", systemImage: SFIcon.ERROR)
]

struct OnboardingView: View {
    let action: () -> Void
    var body: some View {
        Onboarding(
            title: "Mix Notes",
            applicationFeatures: applicationFeatures,
            actionTitle: "Let's Go!",
            action: action
        )
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(action: {})
    }
}
