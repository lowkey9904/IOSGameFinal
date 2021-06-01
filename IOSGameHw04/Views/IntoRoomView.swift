//
//  IntoRoomView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/24.
//

import SwiftUI
import SwiftUIPullToRefresh

struct IntoRoomView: View {
    @State var currentUserData: UserData
    @State private var roomNum = ""
    @State private var intoWaitingView: Int? = 0
    @State private var roomAlert = false
    @State private var alertMsg = ""
    @State private var searchText = ""
    @StateObject var roomList = MyRoomList()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var test = ""
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                SearchBar(text: $searchText)
                    .frame(width: 408)

                List(roomList.roomList.filter({ searchText.isEmpty ? true : $0.id!.contains(searchText) })) { item in
                    Button(action:{
                        findRoom(rn: item.id!)
                    }){
                        HStack{
                            Text("房號:" + item.id! + " ")
                            Text("主持人:" + item.user0.userName)
                            Spacer()
                            if item.user1.userName == "" {
                                Image(systemName: "person")
                                Text("1/2")
                            } else {
                                Image(systemName: "person.fill")
                                Text("2/2")
                            }
                            Text("進入 >")
                        }.foregroundColor(Color.primary)
                    }
                }.listStyle(InsetGroupedListStyle())
                
                
                NavigationLink(
                    destination: WaitingGameView(currentUserData: currentUserData, mRN: roomNum), tag: 1, selection: $intoWaitingView){
                    EmptyView()
                }
                Spacer()

             }
            .onAppear{
                roomList.updateRoomList()
            }
            .alert(isPresented: $roomAlert, content: {
                Alert(title: Text("錯誤"), message: Text(alertMsg), dismissButton: .cancel())
            })
            .foregroundColor(.black)
            .background(Image("bg2").blur(radius: 10).contrast(0.69))
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("搜尋遊戲房間")
            .navigationBarItems(leading: Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                HStack {
                    Image(systemName: "chevron.left")
                    Text("返回")
                }.foregroundColor(.black)
            })
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    func findRoom(rn: String) {
        roomNum = rn
        var findRoom = false
        var fullRoom = false
        FireBase.shared.fetchRooms { result in
            switch result {
            case .success(let rArray):
                for r in rArray {
                    if r.id! == rn {
                        findRoom = true
                        if r.user1.userName != "" && r.user0.userName != "" {
                            fullRoom = true
                        }
                        break
                    }
                }
                if findRoom == false {
                    alertMsg = "找不到該房間，請重新確認房號"
                    roomAlert = true
                } else {
                    if fullRoom {
                        alertMsg = "房間已滿人，請稍後再試"
                        roomAlert = true
                    } else {
                        intoWaitingView = 1
                    }
                }
            case .failure(_):
                print("進入失敗請重新嘗試")
            }
        }
    }
}

struct IntoRoomView_Previews: PreviewProvider {
    static var previews: some View {
        IntoRoomView(currentUserData: UserData(id: "", userName: "", userPhotoURL: "", userGender: "", userBD: "", userFirstLogin: "", userCountry: ""))
    }
}
