//
//  ContentView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/1.
//

import SwiftUI
import AVFoundation
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
    @State var looper: AVPlayerLooper?
    
    var body: some View {
        NavigationView {
        VStack {
                Image("Title")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                HStack{
                    Image("content_m")
                    Text("翻轉").font(.custom("SanafonMaru", size: 50))
                        .foregroundColor(titleColor) + Text("黑").font(.custom("SanafonMaru", size: 50))
                        .foregroundColor(.black) + Text("白棋").font(.custom("SanafonMaru", size: 50))
                        .foregroundColor(titleColor)
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
                    Button(action:{userLoginAction()}){
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
            .navigationBarItems(trailing:
                Button(action:{
                    if myPlayer.timeControlStatus == .playing {
                        myPlayer.pause()
                    }
                    else {
                        myPlayer.play()
                    }
                }){
                    HStack {
                        Text("Music")
                        Image(systemName: "play.circle.fill")
                    }.font(.title3)
                    .foregroundColor(midNightBlue)
            })
            .onTapGesture {
                self.endEditing()
            }
            .background(
                Image("bg")
                    .contrast(0.8)
            )
            .onAppear{
                self.playMusic()
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
    
    private func userLoginAction() {
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
                                    print("我有進來")
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
    }
    
    private func playMusic() {
        let fileUrl = Bundle.main.url(forResource: "bgm", withExtension: "mp3")!
        let item = AVPlayerItem(url: fileUrl)
        self.looper = AVPlayerLooper(player: myPlayer, templateItem: item)
        myPlayer.volume = 0.1
        myPlayer.play()
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


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
