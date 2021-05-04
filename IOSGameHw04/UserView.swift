//
//  UserView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/1.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

struct UserView: View {
    
    init(){
        UITableView.appearance().backgroundColor = .clear
    }
    
    @State private var currentUser = Auth.auth().currentUser
    @State private var userPhotoURL = URL(string: "")
    @State private var showContentView = false
    @State private var currentUserData = UserData(id: "", userGender: "", userBD: "", userFirstLogin: "", userCountry: "")
    var body: some View {
        NavigationView{
            VStack{
                Form {
                    HStack{
                        Text("個人資料")
                            .font(.system(size: 27))
                            .bold()
                        Image("lucid")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                    }
                    .frame(height: 100)
                    HStack {
                        Spacer()
                        KFImage(userPhotoURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 150)
                        Spacer()
                    }
                    //基本資料
                    Group{
                        HStack {
                            Image(systemName: "person.crop.circle")
                            if currentUser?.displayName != nil {
                                Text("暱稱: " + (currentUser?.displayName)!)
                            } else {
                                Text("暱稱錯誤")
                            }
                        }
                        HStack{
                            Image(systemName: "g.circle")
                            Text("性別: " + currentUserData.userGender)
                        }
                        HStack{
                            Image(systemName: "calendar")
                            Text("生日: " + currentUserData.userBD)
                        }
                        HStack{
                            Image(systemName: "globe")
                            Text("國家: " + currentUserData.userCountry)
                        }
                        HStack{
                            Image(systemName: "clock")
                            Text("首次登入: " + currentUserData.userFirstLogin)
                        }
                        HStack{
                            Image(systemName: "face.smiling")
                            Text("UID: " + currentUser!.uid)
                        }
                    }
                }
            }.onAppear{
                userPhotoURL = (currentUser?.photoURL)
                FireBase.shared.fetchUsers(){ result in
                    switch (result) {
                    case .success(let usersArray):
                        for u in usersArray {
                            if u.id == currentUser?.uid {
                                currentUserData = u
                                break
                            }
                        }
                    case .failure(_):
                        print("抓取失敗，找不到使用者資料")
                    }
                }
            }
            .background(Image("bg2").contrast(0.8))
            .navigationBarItems(trailing: Button(action:{
                FireBase.shared.userSingOut()
                showContentView = true
            }){
                HStack{
                    Image(systemName: "figure.walk")
                    Text("登出")
                }.font(.title3)
                .foregroundColor(.red)
            }.fullScreenCover(isPresented: $showContentView, content: {
                ContentView()
            }))
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
