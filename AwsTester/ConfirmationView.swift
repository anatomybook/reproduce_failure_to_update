import SwiftUI

struct ConfirmationView: View {
    
    @EnvironmentObject var userData: UserData
    
    @State var confirmation_code = ""
    let username : String
    
    var body: some View {
        VStack
        {
            Text("Username: \(username)")
            TextField("Confirmation Code", text: $confirmation_code)
            Button("Confirm", action: {
                userData.confirmSignUp(username: username, code: confirmation_code)
            })
        }.padding()
    }
}

struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationView(username: "Just Me")
    }
}
