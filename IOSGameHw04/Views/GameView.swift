//
//  GameView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/28.
//

import SwiftUI
import Kingfisher

struct GameView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var myRoomData: MyRoom
    @StateObject var myGameData = MyGame()
    @State var userNum: Int
    @State var startPlayer: Int
    @State private var playerPieceNum = 0
    @State private var lastPiece = (-1, -1)
    @State private var showGameOverAlert = false
    @State private var showSkipAlert = false
    @State private var gameOverAlert = Alert(title: Text("null"))

    var body: some View {
        NavigationView {
        ZStack {
            VStack {
                HStack{
                    VStack {
                        if myGameData.myGameData.roomData.user0.userPhotoURL != ""{
                            KFImage(URL(string: myGameData.myGameData.roomData.user0.userPhotoURL)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 90)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        }
                        Text(myRoomData.roomData.user0.userName)
                            .font(.title3)
                            .foregroundColor(midNightBlue)
                            .padding(.top)
                            
                    }.padding(.vertical, 20)
                    .background(
                        Color.yellow
                            .frame(width: 120, height: 170)
                            .cornerRadius(20)
                            .scaledToFill()
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(midNightBlue, lineWidth: 5))
                            )
                    .padding()
                    Spacer()
                    VStack{
                        if myGameData.myGameData.nowPlayer == 0 {
                            Text("現在輪到")
                                .font(.system(size: 17))
                                .bold()
                                .padding(.bottom)
                            Image(systemName: "arrowshape.turn.up.left.fill")
                                .font(.system(size: 40))
                        } else {
                            Text("現在輪到")
                                .font(.system(size: 17))
                                .bold()
                                .padding(.bottom)
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .font(.system(size: 40))
                        }
                    }.foregroundColor(midNightBlue)
                    Spacer()
                    VStack {
                        if myGameData.myGameData.roomData.user1.userPhotoURL != "" {
                            KFImage(URL(string: myRoomData.roomData.user1.userPhotoURL)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 90)
                        }
                        Text(myRoomData.roomData.user1.userName)
                            .font(.title3)
                            .foregroundColor(midNightBlue)
                            .padding(.top)
                        
                    }.padding(.vertical, 20)
                    .background(
                        Color.yellow
                            .frame(width: 120, height: 170)
                            .cornerRadius(20)
                            .scaledToFill()
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(midNightBlue, lineWidth: 5))
                            )
                    .padding()
                }.padding()
            Spacer()
            Group {
            VStack {
                ForEach(0..<8){ index1 in
                    HStack {
                        ForEach(0..<8){ index2 in
                            //只有輪到自己的回合 且可以下的地方才會是button
                            if myGameData.myGameData.nowPlayer == userNum && myGameData.myGameData.checkerboard[String(index1)]![index2] == 0 {
                                    Button(action:{
                                        self.lastPiece = (index1, index2)
                                        myGameData.updateCB(index1: index1, index2: index2, playerPieceNum: playerPieceNum)
                                        //下完後對手沒有可下的地方(不需要turnPlayer，直接更新棋盤)
                                        if myGameData.checkCBAva() == false {
                                            myGameData.updateCB(index1: lastPiece.0, index2: lastPiece.1, playerPieceNum: 3 - playerPieceNum, isSkip: true)
                                            if userNum == 0 {
                                                myGameData.setisFinal(status: true, user: 1)
                                            } else {
                                                myGameData.setisFinal(status: true, user: 0)
                                            }
                                            //如果換自己下也沒有地方可下，則GameOver
                                            if myGameData.checkCBAva() == false {
                                                if userNum == 0 {
                                                    myGameData.setisFinal(status: true, user: 0)
                                                } else {
                                                    myGameData.setisFinal(status: true, user: 1)
                                                }
                                            }
                                        } else {
                                            myGameData.turnPlayer(nowPlayer: userNum)
                                        }
                                        print(index1, index2) }){
                                        if ((index1 + index2) % 2 == 0) {
                                            PiecePhoto(strokeCol: 0)
                                        } else {
                                            PiecePhoto(strokeCol: 1)
                                        }
                                    }.overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.red, lineWidth: 2))
                            } else {
                                if myGameData.myGameData.checkerboard[String(index1)]![index2] == 1 {
                                    Image("slime")
                                    .resizable()
                                    .frame(width: 43, height: 43)
                                } else if myGameData.myGameData.checkerboard[String(index1)]![index2] == 2 {
                                    Image("pika")
                                    .resizable()
                                    .frame(width: 43, height: 43)
                                } else {
                                    if ((index1 + index2) % 2 == 0) {
                                        PiecePhoto(strokeCol: 0)
                                    } else {
                                        PiecePhoto(strokeCol: 1)
                                    }
                                }
                            }
                        }
                    }.padding(.horizontal, 10)
                }
            }.onReceive(myGameData.changePlayer, perform: { _ in
                print("now userNum: " + String(myGameData.myGameData.nowPlayer))
            })
            .onReceive(myGameData.skipP0, perform: { _ in
                print("被跳過了 skipP0")
//                if userNum == 0 {
//                    myGameData.turnPlayer(nowPlayer: userNum)
//                    myGameData.updateCB(index1: lastPiece.0, index2: lastPiece.1, playerPieceNum: playerPieceNum, isSkip: true)
//                }
            })
            .onReceive(myGameData.skipP1, perform: { _ in
                print("被跳過了 skipP1")
//                if userNum == 1 {
//                    myGameData.turnPlayer(nowPlayer: userNum)
//                    myGameData.updateCB(index1: lastPiece.0, index2: lastPiece.1, playerPieceNum: playerPieceNum, isSkip: true)
//                }
            })
            .onReceive(myGameData.gameOver, perform: { _ in
                print(myGameData.myGameData.checkerboard)
                self.whoWIN()
                self.showGameOverAlert = true
            })
            .background(
                RadialGradient(gradient: Gradient(colors: [cbg0, cbg1]), center: .center, startRadius:
                50, endRadius: 200)
                    .frame(height: 420)
                    .cornerRadius(20))
            }
            Spacer()
            }.alert(isPresented: $showGameOverAlert) { () -> Alert in
                return gameOverAlert
            }
        }
        .background(Image("bg2").blur(radius: 10).contrast(0.8))
        .navigationBarItems(leading:
        Text("房號: " + myRoomData.roomData.id!).font(.title).bold().foregroundColor(.black))
        }.onAppear{
            if userNum == startPlayer {
                playerPieceNum = 1
            } else {
                playerPieceNum = 2
            }
            print("My Piece Num: " + String(playerPieceNum))
            myGameData.myGameData.roomData = myRoomData.roomData
            FireBase.shared.createGame(rd: myRoomData.roomData, startPlayer: startPlayer) { result in
                switch result {
                    case .success(let msg):
                        myGameData.addGameListener()
                        print("遊戲開始：" + msg)
                        //myRoomData.delRoom()
                    case .failure(_):
                        print("發生錯誤，遊戲開始失敗")
                }
            }
        }
    }
    
    func whoWIN() -> Void {
        var player1Count = 0
        var player2Count = 0
        let user0N = self.myRoomData.roomData.user0.userName
        let user1N = self.myRoomData.roomData.user1.userName
        for i in 0..<8 {
            for j in 0..<8 {
                if myGameData.myGameData.checkerboard[String(i)]![j] == 1 {
                    player1Count += 1
                } else if myGameData.myGameData.checkerboard[String(i)]![j] == 2 {
                    player2Count += 1
                }
            }
        }
        if player1Count > player2Count {
            if playerPieceNum == 1 {
                if userNum == 0 {
                    gameOverAlert = Alert(title: Text("獲勝！"), message: Text("你(" + user0N + ")的棋子數目: " + String(player1Count) + "\n對手(" + user1N + ")的棋子數目:" + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
                } else {
                    gameOverAlert = Alert(title: Text("獲勝！"), message: Text("你(" + user1N + ")的棋子數目: " + String(player1Count) + "\n對手(" + user0N + ")的棋子數目:" + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
                }
            } else {
                if userNum == 0 {
                    gameOverAlert = Alert(title: Text("輸了！"), message: Text("你(" + user0N + ")的棋子數目: " + String(player2Count) + "\n對手(" + user1N + ")的棋子數目:" + String(player1Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
                } else {
                    gameOverAlert = Alert(title: Text("輸了！"), message: Text("你(" + user0N + ")的棋子數目: " + String(player2Count) + "\n對手(" + user1N + ")的棋子數目:" + String(player1Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
                }
            }
        } else if player2Count > player1Count {
            if playerPieceNum == 1 {
                if userNum == 0 {
                    gameOverAlert = Alert(title: Text("輸了！"), message: Text("你(" + user0N + ")的棋子數目: " + String(player1Count) + "\n對手(" + user1N + ")的棋子數目:" + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
                } else {
                    gameOverAlert = Alert(title: Text("輸了！"), message: Text("你(" + user1N + ")的棋子數目: " + String(player1Count) + "\n對手(" + user0N + ")的棋子數目:" + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
                }
            } else {
                if userNum == 0 {
                    gameOverAlert = Alert(title: Text("獲勝！"), message: Text("你(" + user0N + ")的棋子數目: " + String(player2Count) + "\n對手(" + user1N + ")的棋子數目:" + String(player1Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
                } else {
                    gameOverAlert = Alert(title: Text("獲勝！"), message: Text("你(" + user1N + ")的棋子數目: " + String(player2Count) + "\n對手(" + user0N + ")的棋子數目:" + String(player1Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
                }
            }
        } else if player1Count == player2Count {
            if userNum == 0 {
                gameOverAlert = Alert(title: Text("平手！"), message: Text("你(" + user0N + ")的棋子數目: " + String(player1Count) + "\n對手(" + user1N + ")的棋子數目:" + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
            } else {
                gameOverAlert = Alert(title: Text("平手！"), message: Text("你(" + user1N + ")的棋子數目: " + String(player1Count) + "\n對手(" + user0N + ")的棋子數目:" + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
            }
        }
    }
    func turnBackToRoomView() -> Void {
        self.myGameData.removeGameListener()
        if self.userNum == 0 {
            self.myGameData.delGameRoom()
        }
        self.myRoomData.cancelReady(userNum: 0)
        self.myRoomData.cancelReady(userNum: 1)
        self.myRoomData.addRoomListener()
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(myRoomData: MyRoom(), userNum: 0, startPlayer: 0)
    }
}
