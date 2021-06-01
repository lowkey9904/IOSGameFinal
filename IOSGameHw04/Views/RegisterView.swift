//
//  RegisterView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/1.
//

import SwiftUI
import FirebaseAuth

struct Background<Content: View>: View {
    private var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        Color.white
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .overlay(content)
    }
}

struct RegisterView: View {
    
    //修改NavigationBarTitle字體顏色
    init() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    @State private var userEmail = ""
    @State private var userPW = ""
    @State private var userCPW = ""
    @State private var userGender = ""
    @State private var alertMsg = ""
    @State private var showAlert = false
    @State private var showFLView = false
    @State private var myAlert = Alert(title: Text(""))
    @State private var selectedIndex = 0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var gender = ["男", "女"]
    var midNightBlue = Color(red: 58/255, green: 69/255, blue: 79/255)
    var body: some View {
        Background{
        VStack{
            CustomTextField(
                placeholder: Text("使用者Email(帳號)").foregroundColor(midNightBlue),
                text: $userEmail, secure: false, isEmail: true
            )
            CustomTextField(
                placeholder: Text("使用者密碼").foregroundColor(midNightBlue),
                text: $userPW, secure: true, isEmail: false
            )
            HStack {
                CustomTextField(
                    placeholder: Text("確認密碼").foregroundColor(midNightBlue),
                    text: $userCPW, secure: true, isEmail: false
                )
                if userPW != userCPW {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                        .offset(x:-10)
                } else {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.largeTitle)
                        .offset(x:-10)
                }
            }
            HStack {
                Button(action:{
                    if userEmail != "" && userPW != ""{
                        if userPW != userCPW {
                            showAlertMsg(msg: "兩次密碼不一致")
                        } else {
                            FireBase.shared.createUser(userEmail: userEmail, pw: userPW) {
                                (result) in
                                switch result {
                                case .success( _):
                                    showAlertMsg(msg: "註冊成功")
                                case .failure(let errormsg):
                                    print("註冊失敗")
                                    switch errormsg {
                                    case .emailFormat:
                                        showAlertMsg(msg: "電子郵件格式不正確")
                                    case .emailUsed:
                                        showAlertMsg(msg: "電子郵件已被註冊")
                                    case .pwtooShort:
                                        showAlertMsg(msg: "密碼長度需至少大於6")
                                    case .others:
                                        showAlertMsg(msg: "不明原因錯誤，請重新註冊")
                                    }
                                    break
                                }
                            }
                        }
                    }
                    else {
                        showAlertMsg(msg: "帳號或密碼不得為空")
                    }
                }){
                    ButtonView(buttonText: "送出")
                }.alert(isPresented: $showAlert) { () -> Alert in
                    return myAlert
                }
            }.padding()
        }
        .background(
            Image("bg")
                .blur(radius: 10)
                .contrast(0.8)
        )
        .fullScreenCover(isPresented: $showFLView, content: {
            FirstLoginView(userEmail: userEmail, userPW: userPW)
        })
        .padding()
        .navigationTitle("註冊")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action:{self.presentationMode.wrappedValue.dismiss()}){
            HStack {
                Image(systemName: "chevron.left")
                Text("返回")
            }.foregroundColor(.black)
        })
        }.onTapGesture {
            self.endEditing()
        }
    }
    
    func go2FirstLoginView() -> Void {
        print(Auth.auth().currentUser!.uid)
        self.presentationMode.wrappedValue.dismiss()
        self.showFLView = true
    }
    
    func showAlertMsg(msg: String) -> Void {
        self.alertMsg = msg
        if alertMsg == "註冊成功" {
            self.myAlert = Alert(title: Text("成功"), message: Text(alertMsg), dismissButton: .cancel(Text("前往設置個人資料"), action:go2FirstLoginView))
            //
            self.showAlert = true
        }
        else {
            self.myAlert = Alert(title: Text("錯誤"), message: Text(alertMsg), dismissButton: .cancel(Text("重新輸入")))
            self.showAlert = true
        }
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
 
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

//fix the navigationLink back button gesture
//    extension UINavigationController: UIGestureRecognizerDelegate {
//
//        override open func viewDidLoad() {
//                super.viewDidLoad()
//            interactivePopGestureRecognizer?.delegate = self
//        }
//
//        public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//            return viewControllers.count > 1
//        }
//}
