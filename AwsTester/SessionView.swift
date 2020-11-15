import SwiftUI
import Amplify

struct SessionView: View {
    
    @EnvironmentObject var userData: UserData
    
    let user: AuthUser
    
    var body: some View {
        VStack
        {
            Spacer()
            Text("You (\(user.username), id=\(user.userId)) signed in using Amplify!!").font(.largeTitle).multilineTextAlignment(.center)
            Spacer()
            Button("Sign out!", action: {
                userData.signOut()
            })
        }
    }
}

struct SessionView_Previews: PreviewProvider {
    private struct DummyUser : AuthUser
    {
        let userId: String = "dummy id"
        let username: String = "dummy"
    }
    
    static var previews: some View {
        SessionView(user: DummyUser())
    }
}
