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
    @StateObject var myUserData = MyUserData()
    @State private var showContentView = false
    @State private var showCgUserNameView = false
    @State private var showAlert = false
    @State private var userBGNum = 0
    @State private var userUID = "*********************"
    @State private var buttonText = "顯示"
    @State private var roomSheet = false
    @State private var roomNum = "0"
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ScrollView {
                    HStack {
                        Spacer()
                        if myUserData.currentUser?.photoURL != nil {
                            KFImage(myUserData.currentUser?.photoURL)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .padding(70)
                        }
                        Spacer()
                        VStack{
                            Spacer()
                            Button(action:{
                                self.userBGNum = Int.random(in: 0...3)
                            }){
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundColor(.red)
                            }
                        }.padding(.bottom, 30)
                    }.background(
                        Image("userbg" + String(userBGNum))
                            .resizable()
                            .frame(width: 380, height: 220)
                            .cornerRadius(20)
                            .scaledToFill()
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(midNightBlue, lineWidth: 5))
                            )
                    .padding()

                    //基本資料
                    VStack {
                        HStack {
                            Image(systemName: "person.crop.circle")
                            if myUserData.currentUser?.displayName != nil {
                                Text("暱稱: " + (myUserData.currentUserData.userName))
                            } else {
                                Text("暱稱錯誤")
                            }
                            Spacer()
                           
                        }.padding(.top,10)
                        .padding(.horizontal)
                        .padding(.vertical,2)
                        UserDataView(dataIconStr: "envelope", dataInfo: "Email", data: (myUserData.currentUser?.email)!)
                        UserDataView(dataIconStr: "g.circle", dataInfo: "性別", data: myUserData.currentUserData.userGender)
                        UserDataView(dataIconStr: "calendar", dataInfo: "生日", data: myUserData.currentUserData.userBD)
                        UserDataView(dataIconStr: "globe", dataInfo: "國家", data:  myUserData.currentUserData.userCountry)
                        UserDataView(dataIconStr: "clock", dataInfo: "首次登入", data: myUserData.currentUserData.userFirstLogin)
                        HStack{
                            Image(systemName: "face.smiling")
                            Text("UID: " + userUID)
                            Spacer()
                            Button(action:{
                                if userUID == "*********************" {
                                    userUID =  myUserData.currentUser!.uid
                                    buttonText = "隱藏"
                                } else {
                                    userUID = "*********************"
                                    buttonText = "顯示"
                                }
                            }){
                                Text(buttonText)
                            }
                        }.padding(.horizontal)
                        .padding(.vertical,2)
                        .padding(.bottom, 10)
                    }.background(Color.yellow)
                    .padding(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(midNightBlue, lineWidth: 10))
                    .cornerRadius(20)
                    
                    
                }.font(.title3)
                .foregroundColor(midNightBlue)
                .padding()
                HStack {
                    Spacer()
                    NavigationLink(destination: WaitingGameView( currentUserData: myUserData.currentUserData, mRN: "-1")) {
                        Button2View(buttonText: "創建遊戲房間")
                    }
                   Spacer()
                    NavigationLink(destination: IntoRoomView(currentUserData: myUserData.currentUserData)){
                        Button2View(buttonText: "進入遊戲房間")
                    }
                    Spacer()
                }

                }.background(Image("bg2").contrast(0.8))
                .onAppear{
                    FireBase.shared.fetchUsers(){ result in
                        switch (result) {
                        case .success(let usersArray):
                            for u in usersArray {
                                if u.id == myUserData.currentUser?.uid {
                                    myUserData.currentUserData = u
                                    break
                                }
                            }
                        case .failure(_):
                            print("抓取失敗，找不到使用者資料")
                        }
                    }
                }.navigationTitle("個人資料")
                .navigationBarItems(leading:
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
                }, trailing: Button(action:{
                    FireBase.shared.userSingOut()
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    HStack{
                        Image(systemName: "figure.walk")
                        Text("登出")
                    }.font(.title3)
                    .foregroundColor(.red)
                })
            }
        }
    
    private func changeUserName(userName: String) {
        if userName != "" {
            FireBase.shared.setUserDisplayName(userDisplayName: userName)
            FireBase.shared.setDBUserName(userID: myUserData.currentUser!.uid, userName: userName) { result in
                switch result {
                case .success(let msg):
                    print(msg)
                    FireBase.shared.fetchUsers(){ result in
                        switch (result) {
                        case .success(let usersArray):
                            for u in usersArray {
                                if u.id == myUserData.currentUser?.uid {
                                    myUserData.currentUserData = u
                                    break
                                }
                            }
                        case .failure(_):
                            print("抓取失敗，找不到使用者資料")
                        }
                    }
                case .failure(_):
                    print("修改暱稱失敗")
                }
            }
        }
    }
}


struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}


