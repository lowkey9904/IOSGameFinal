//
//  ContentView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/1.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    init(){
        UITableView.appearance().backgroundColor = .clear
    }
    
    @State private var userEmail = ""
    @State private var userPW = ""
    @State private var alertMsg = ""
    @State private var showAlert = false
    @State private var showView = false
    @State private var returnBool = false
    var midNightBlue = Color(red: 58/255, green: 69/255, blue: 79/255)
    var body: some View {
        NavigationView {
        VStack {
                Image("Title")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                HStack{
                    Image("content_m")
                    Text("紙娃娃模擬")
                        .font(.custom("SanafonMaru", size: 50))
                        .foregroundColor(Color(red: 255/255, green: 255/255, blue: 255/255))
                    Image("content_f")
                        .offset(y: 5.2)
                }.offset(y: -20)
                Spacer()
                Group{
                    CustomTextField(
                        placeholder: Text("使用者Email(帳號)").foregroundColor(midNightBlue),
                        text: $userEmail, secure: false, isEmail: true
                    )
                    CustomTextField(
                        placeholder: Text("使用者密碼").foregroundColor(midNightBlue),
                        text: $userPW, secure: true, isEmail: false
                    )
                }.offset(y:-40)
                HStack{
                    Button(action:{
                        FireBase.shared.userSingIn(userEmail: userEmail, pw: userPW){
                            (result) in
                            switch result {
                            case .success( _):
                                if let user = Auth.auth().currentUser {
                                    print("\(user.uid) 登入成功")
                                    FireBase.shared.fetchUsers(){
                                        (result) in
                                        switch result {
                                        case .success(let udArray):
                                            print("使用者資料抓取成功")
                                            for u in udArray {
                                                if u.id == user.uid {
                                                    returnBool = true
                                                }
                                            }
                                            showView = true
                                            
                                        case .failure(_):
                                            print("使用者資料抓取失敗")
                                            returnBool = false
                                            //showView = true
                                        }
                                    }
                                } else {
                                    print("登入失敗")
                                }
                            case .failure(let errormsg):
                                switch errormsg {
                                case .pwInvalid:
                                    alertMsg = "密碼錯誤"
                                    showAlert = true
                                case .noAccount:
                                    alertMsg = "帳號不存在，請註冊或使用其他帳號"
                                    showAlert = true
                                case .others:
                                    alertMsg = "不明原因錯誤，請重新登入"
                                    showAlert = true
                                }
                            }
                        }
                    }){
                        ButtonView(buttonText: "登入")
                    }
                    .padding(5)
                    if returnBool {
                        EmptyView().fullScreenCover(isPresented: $showView)
                            { UserView()}
                    }
                    else {
                        EmptyView().fullScreenCover(isPresented: $showView)
                            { FirstLoginView(userEmail: userEmail, userPW: userPW) }
                    }
                    NavigationLink(
                        destination: RegisterView()){
                        ButtonView(buttonText: "註冊")
                    }
                    .padding(5)
                }.padding(.top, 5)
                Spacer()
            }.offset(y: -20)
            .onTapGesture {
                self.endEditing()
            }
            .background(
                Image("bg")
                    .contrast(0.8)
            )
            .onAppear{
                for code in NSLocale.isoCountryCodes as [String] {
                    let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
                    let name = NSLocale(localeIdentifier: "zh_TW").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
                    countries.append(name)
                }
            }
            .foregroundColor(.primary)
            .alert(isPresented: $showAlert) { () -> Alert in
                return Alert(title: Text("錯誤"), message: Text(alertMsg),  dismissButton: .default(Text("重新輸入")))
            }
        }
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { UIApplication.shared.endEditing() }
    var secure: Bool
    var isEmail: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if secure {
                SecureField("", text: $text, onCommit: commit)
                    .textFieldStyle(MyTextFieldStyle())
            } else {
                if isEmail {
                    TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                        .textFieldStyle(MyTextFieldStyle())
                        .keyboardType(.emailAddress)
                } else {
                    TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                        .textFieldStyle(MyTextFieldStyle())
                }
            }
            if text.isEmpty {
                placeholder
                    .offset(x: 40)
            }
        }
    }
}

struct MyTextFieldStyle: TextFieldStyle {
    var bgBlue = Color(red: 203/255, green: 217/255, blue: 228/255)
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .foregroundColor(.black)
        .padding(20)
        .background(bgBlue)
            .opacity(0.8)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color(red: 121/255, green: 124/255, blue: 177/255), lineWidth: 2)
        ).padding()
    }
}

struct ButtonView: View {
    var buttonText: String
    var body: some View {
        Text(buttonText)
            .font(.system(size: 25))
            .foregroundColor(.white)
            .frame(width: 160)
            .padding()
            .background(
            Image("buttonbg")
                .resizable()
                .scaledToFill()
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 130))
//            .cornerRadius(15)
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(Color.black, lineWidth: 2)
//            )
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
