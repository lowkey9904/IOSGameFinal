//
//  WaitingGameView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/24.
//

import SwiftUI
import Kingfisher
import URLImage
import Firebase

struct WaitingGameView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var currentUserData: UserData
    @State var roomPW: String
    @State private var titleText = ""
    @State private var showText = false
    @State private var userNum = 0
    @State private var notReadyAlert = false
    @State private var showHostLeft = false
    @State var gotoGameView = false
    @State private var otherUserData = UserData(id: "", userID: "", userName: "", userPhotoURL: "", userGender: "", userBD: "", userFirstLogin: "", userCountry: "")
    @StateObject var myRoomData = MyRoom()
    var mRN: String
    var body: some View {
        Background {
            VStack {
                VStack(alignment: .leading) {
                    if myRoomData.roomData.roomPassWord != "" {
                        HStack {
                            Image(systemName: "lock")
                            Text(NSLocalizedString("密碼: ", comment: "") + myRoomData.roomData.roomPassWord)
                            Spacer()
                        }
                    }
                }.font(.title2)
                .padding()
                HStack {
                    VStack {
                        Text(myRoomData.roomData.user0.userName)
                            .font(.system(size: 25))
                            .bold()
                            .shadow(radius: 10)
                            .padding(.bottom, 40)
                        if myRoomData.roomData.user0.userPhotoURL != "" {
                            ImageView(withURL: myRoomData.roomData.user0.userPhotoURL)
                                //.resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 200)
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                .shadow(radius: 20.0)
                        }
                    
                    }.frame(width: 100, height: 300)
                    .padding()
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .padding(.bottom, 30)
                    Spacer()
                    VStack {
                        Text(myRoomData.roomData.user1.userName)
                            .font(.system(size: 25))
                            .bold()
                            .shadow(radius: 10)
                            .padding(.bottom, 40)
                        if myRoomData.roomData.user1.userPhotoURL != "" {
                            ImageView(withURL: myRoomData.roomData.user1.userPhotoURL)
                                //.resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 200)
                                .shadow(radius: 20.0)
                        }
                    }.frame(width: 100, height: 300)
                    .padding()
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .padding(.bottom, 30)
                }.padding(30)
                HStack {
                    VStack{
                        HStack {
                            Image(systemName: "crown")
                            Text("主持人")
                                .bold()
                        }.font(.system(size: 22))
                    }.foregroundColor(.black)
                    .frame(width: 130, height: 40)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    VStack {
                        if myRoomData.roomData.user1.userName != "" {
                            if myRoomData.roomData.user1ready {
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                    Text("準備")
                                        .bold()
                                }.font(.system(size: 22))
                            } else {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("尚未準備")
                                        .bold()
                                }.font(.system(size: 22))
                            }
                        }
                    }.foregroundColor(.black)
                    .frame(width: 130, height: 40)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.yellow)
                    .cornerRadius(10)
                }
            }.foregroundColor(.black)
            .fullScreenCover(isPresented: $gotoGameView)
                { GameView(gotoGameView: $gotoGameView, myRoomData: myRoomData, userNum: userNum, startPlayer: myRoomData.roomData.startPlayer) }
            .onAppear{
                if mRN != "-1" {
                    userNum = 1
                }
                self.myCreatRoom(roomNum: mRN)
            }
            .onReceive(self.myRoomData.secondPlayerInto , perform: { _ in
                print("Second Player Into Room.")
                print()
            })
            .onReceive(self.myRoomData.roomReady, perform: { _ in
                print("Get Ready, Goto Game View.")
                //turn Room status to gaming
                self.myRoomData.setRoomGameStatus(status: true)
                self.myRoomData.removeRoomListener()
                self.gotoGameView = true
            })
            .onReceive(self.myRoomData.changeHost, perform: { _ in
                if userNum == 1{
                    self.showHostLeft = true
                    self.userNum = 0
                }
            })
            .background(Image("bg2").blur(radius: 10).contrast(0.69))
            .navigationTitle(NSLocalizedString("等待房間: ", comment: "") + titleText)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action:{
                    if userNum == 0 && self.myRoomData.roomData.user1.userName != "" {
                        self.myRoomData.leaveRoom(userNum: 0)
                    } else if userNum == 0 && self.myRoomData.roomData.user1.userName == "" {
                        self.myRoomData.removeRoomListener()
                        self.myRoomData.delRoom()
                    } else {
                        self.myRoomData.leaveRoom(userNum: 1)
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }){
                HStack {
                    Image(systemName: "figure.walk")
                    Text("離開")
                }.font(.title3)
                .foregroundColor(midNightBlue)
            }, trailing:
                Button(action:{
                if self.userNum == 0{
                    if myRoomData.roomData.user1ready {
                        myRoomData.selectStartPlayer()
                        myRoomData.getReady(userNum: 0)
                    } else{
                        self.notReadyAlert = true
                    }
                } else {
                if self.myRoomData.roomData.user1ready{
                    self.myRoomData.cancelReady(userNum: self.userNum)
                } else {
                    self.myRoomData.getReady(userNum: self.userNum)
                }}}){
                HStack {
                    if self.userNum == 0 {
                        Image(systemName: "gamecontroller")
                            .foregroundColor(.red)
                        Text("開始")
                            .foregroundColor(.red)
                    }else{
                        if userNum == 1 && self.myRoomData.roomData.user1ready == false {
                            Image(systemName: "gamecontroller")
                            Text("準備")
                        } else if userNum == 1 && self.myRoomData.roomData.user1ready {
                            Image(systemName: "gamecontroller")
                            Text("取消準備")
                        }
                    }
                }.font(.title3)
                .foregroundColor(midNightBlue)
            
            }.alert(isPresented: $notReadyAlert) { () -> Alert in
                return Alert(title: Text("尚未準備完成"), message: Text("有玩家還沒準備完成喔！"),  dismissButton: .default(Text("好")))
            })
        }.alert(isPresented: $showHostLeft) { () -> Alert in
            return Alert(title: Text("主持"), message: Text("由於主持人已離開，自動成為主持人"),  dismissButton: .default(Text("好")))
        }
    }
    
    func myCreatRoom(roomNum: String) {
        FireBase.shared.createRoom(ud: [currentUserData, otherUserData], rP: roomPW, rid_str: roomNum) { result in
            switch result {
            case .success(let rNum):
                titleText = rNum
                print("創建房間成功，房號為: " + rNum)
                FireBase.shared.fetchRooms() { result in
                    switch result {
                    case .success(let rArray):
                        for r in rArray {
                            if r.id == rNum || r.id == mRN{
                                myRoomData.roomData = r
                                myRoomData.addRoomListener()
                                break
                            }
                        }
                    
                    case .failure(_):
                        print("fail")
                    }
                }
            case .failure(_):
                print("創建房間失敗")
            }
        }
    }
}

struct WaitingGameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        WaitingGameView(currentUserData: UserData(id: "123", userID: "1234", userName: "勇者002", userPhotoURL: "https://firebasestorage.googleapis.com/v0/b/finaliosgame.appspot.com/o/20BFA0F3-EECF-411A-8328-1092A9EB5CC2.png?alt=media&token=68cc8c23-c0a5-4613-8a38-7952c060b45e", userGender: "女", userBD: "2021 May 25", userFirstLogin: "2021 May 25 13:44", userCountry: "台灣"), roomPW: "556879", mRN: "1320")
        }
    }
}
