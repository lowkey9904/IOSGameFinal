//
//  RoomRowView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/6/10.
//

import SwiftUI

struct RoomRowView: View {
    @State var room: RoomData
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(room.id!)
                        .bold()
                        .font(.title)
                    if room.roomPassWord != "" {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundColor(midNightBlue)
                    }
                }
                HStack {
                    Text(NSLocalizedString("房主: ", comment: "") + room.user0.userName)
                }.font(.system(size: 15))
            }
            Spacer()
            if room.user1.userName == "" {
                Image(systemName: "person")
                    .font(.title3)
                Text("1/2")
                    .font(.title3)
            } else {
                Image(systemName: "person.fill")
                    .font(.title3)
                Text("2/2")
                    .font(.title3)
            }
            if room.roomGameStatus {
                HStack {
                    Text("遊戲中..")
                        .bold()
                    Image(systemName: "gamecontroller.fill")
                }.font(.title3)
                .frame(width: 120)
            } else {
                HStack {
                Text("進入房間")
                    .bold()
                Image(systemName: "chevron.right.circle.fill")
                }.font(.title3)
                .frame(width: 120)
            }
        }.padding()
        .foregroundColor(midNightBlue)
        .background(Color.yellow)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(midNightBlue, lineWidth: 10))
        .cornerRadius(20)
    }
}

struct RoomRowView_Previews: PreviewProvider {
    static var previews: some View {
        RoomRowView(room: RoomData(id: "1234", user0: UserData(id: "", userID: "", userName: "你好", userPhotoURL: "", userGender: "", userBD: "", userFirstLogin: "", userCountry: ""), user0ready: false, user1: UserData(id: "", userID: "", userName: "22", userPhotoURL: "", userGender: "", userBD: "", userFirstLogin: "", userCountry: ""), user1ready: false, roundTime: -1, roomPassWord: "", startPlayer: 0, roomGameStatus: false))
            .previewLayout(.sizeThatFits)
    }
}
