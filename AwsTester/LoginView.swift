import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var userData: UserData
    
    @State var username = ""
    @State var password = ""
    
    var body: some View {
        VStack
        {
            Spacer()
            
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            Button("Login", action: {
                userData.login(username: username, password: password)
            })
            
            Spacer()
            Button("Don't have an account yet? Sign up.", action: {
                userData.setAuthToSignUp()
            })
            
        }.padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
