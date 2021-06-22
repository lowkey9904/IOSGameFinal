//
//  GameView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/28.
//
import SwiftUI
import Kingfisher
import URLImage
import GoogleMobileAds

struct GameView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var gotoGameView : Bool
    @State var myRoomData: MyRoom
    @StateObject var myGameData = MyGame()
    @State private var firstButton = true
    @State var userNum: Int
    @State var startPlayer: Int
    @State private var playerPieceNum = 0
    @State private var lastPiece = (-1, -1)
    @State private var showGameOverAlert = false
    @State private var showSkipAlert = false
    @State private var showGiveUpAlert = false
    @State private var skippedMsg = NSLocalizedString("遊戲進行中...", comment: "")
    @State private var pieceDegrees = 0.0
    @State private var myContrast = 1.0
    @State private var dollBGColor = [Color.clear, Color.clear]
    @State private var dollOLColor = [Color.clear, Color.clear]
    @State private var gameOverAlert = Alert(title: Text("null"))
    let myRewardAD = RewardedAdController()
    
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
                        dollBGColor[0]
                            .frame(width: 120, height: 170)
                            .cornerRadius(20)
                            .scaledToFill()
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(dollOLColor[0], lineWidth: 5))
                            )
                    .padding()
                    Spacer()
                    VStack {
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
                        dollBGColor[1]
                            .frame(width: 120, height: 170)
                            .cornerRadius(20)
                            .scaledToFill()
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(dollOLColor[1], lineWidth: 5))
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
                                    Button(action: {
                                        self.firstButton = true
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
                                        .stroke(Color.red, lineWidth: 1))
                                    
                                    
                            } else {
                                if myGameData.myGameData.checkerboard[String(index1)]![index2] > 0 {
                                    //只有被翻的棋子需要動畫
                                    Image(myGameData.myGameData.checkerboard[String(index1)]![index2] == 1 ? "slime_" : "pikachu_")
                                        .resizable()
                                        .frame(width: 43, height: 43)
                                        .rotation3DEffect(.degrees(myGameData.myGameData.rotateDegree[String(index1)]![index2]), axis: (x: 0, y: 1, z: 0))
                                        .animation(.easeOut)
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
            }
            .onReceive(myGameData.skipP0, perform: { _ in
                print("被跳過了 skipP0")
                if userNum == 0 {
                    skippedMsg = NSLocalizedString("沒有地方可以下，被跳過了!", comment: "")
                } else {
                    skippedMsg = NSLocalizedString("對手沒有地方可以下，又輪到你了!", comment: "")
                }
            })
            .onReceive(myGameData.skipP1, perform: { _ in
                print("被跳過了 skipP1")
                if userNum == 1 {
                    skippedMsg = NSLocalizedString("沒有地方可以下，被跳過了!", comment: "")
                } else {
                    skippedMsg = NSLocalizedString("對手沒有地方可以下，又輪到你了!", comment: "")
                }

            })
            .onReceive(myGameData.gameNormal, perform: { _ in
                skippedMsg = NSLocalizedString("遊戲進行中...", comment: "")
            })
            .onReceive(myGameData.giveupP0, perform: { _ in
                print("user0投降")
                self.whoWIN(isGiveUp: true, giveupUser: 0)
                self.showGameOverAlert = true
            })
            .onReceive(myGameData.giveupP1, perform: { _ in
                print("user1投降")
                self.whoWIN(isGiveUp: true, giveupUser: 1)
                self.showGameOverAlert = true
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
            HStack {
                Text(self.skippedMsg)
                    .bold()
                Spacer()
            }.foregroundColor(midNightBlue)
            .padding()
            .background(
                Color.yellow
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(midNightBlue, lineWidth: 5))
                    )
            .padding()
            }.alert(isPresented: $showGameOverAlert) { () -> Alert in
                return gameOverAlert
            }
        }
        .background(Image("bg2").blur(radius: 10).contrast(0.8))
        .navigationBarItems(leading:
            Text(NSLocalizedString("房號: ", comment: "") + myRoomData.roomData.id!).font(.title).bold().foregroundColor(.black), trailing:
                Button(action:{self.showGiveUpAlert = true}){
                HStack {
                    Image(systemName: "figure.walk")
                    Text("投降")
                }.font(.title3)
                .foregroundColor(.red)
                }.alert(isPresented: $showGiveUpAlert){ () -> Alert in
                    return Alert(title: Text("投降"), message: Text("您確定真的要投降嗎"),  primaryButton: .default(Text("確定"), action: { myGameData.setGiveUp(user: userNum)
                        }),secondaryButton: .default(Text("取消")))
                })
        }.onAppear {
            myRewardAD.loadAD()
            if userNum == startPlayer {
                playerPieceNum = 1
                if userNum == 0 {
                    dollBGColor = [slimeGreen, pikaPink]
                    dollOLColor = [dpSlimeGreen, dpPikaPink]
                } else {
                    dollBGColor = [pikaPink, slimeGreen]
                    dollOLColor = [dpPikaPink, dpSlimeGreen]
                }
            } else {
                playerPieceNum = 2
                if userNum == 0 {
                    dollBGColor = [pikaPink, slimeGreen]
                    dollOLColor = [dpPikaPink, dpSlimeGreen]
                } else {
                    dollBGColor = [slimeGreen, pikaPink]
                    dollOLColor = [dpSlimeGreen, dpPikaPink]
                }
            }
            print("My Piece Num: " + String(playerPieceNum))
            myGameData.myGameData.roomData = myRoomData.roomData
            FireBase.shared.createGame(rd: myRoomData.roomData, startPlayer: startPlayer) { result in
                switch result {
                    case .success(let msg):
                        myGameData.addGameListener()
                        print("遊戲開始：" + msg)
                    case .failure(_):
                        print("發生錯誤，遊戲開始失敗")
                }
            }
        }
    }
    
    func whoWIN(isGiveUp: Bool = false, giveupUser: Int = -1) -> Void {
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
        if isGiveUp && (giveupUser == 0 || giveupUser == 1) {
            if userNum == 0 {
                myGameData.countWinandLose(user: 1 - giveupUser)
            }
            if userNum == giveupUser {
                gameOverAlert = Alert(title: Text("輸了！"), message: Text("你投降了!"), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
            } else {
                gameOverAlert = Alert(title: Text("獲勝！"), message: Text("對手投降了!"), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()}))
            }
        } else {
            if player1Count > player2Count {
                if playerPieceNum == 1 {
                    if userNum == 0 {
                        myGameData.countWinandLose(user: 0)
                        gameOverAlert = Alert(title: Text("獲勝！"), message: Text(NSLocalizedString("你(", comment: "") + user0N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player1Count) + NSLocalizedString("\n對手(", comment: "") + user1N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()
                        }))
                    } else {
                        gameOverAlert = Alert(title: Text("獲勝！"), message: Text(NSLocalizedString("你(", comment: "") + user1N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player1Count) + NSLocalizedString("\n對手(", comment: "") + user0N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()
                        }))
                    }
                } else {
                    if userNum == 0 {
                        myGameData.countWinandLose(user: 1)
                        gameOverAlert = Alert(title: Text("輸了！"), message: Text(NSLocalizedString("你(", comment: "") + user0N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player2Count) + NSLocalizedString("\n對手(", comment: "") + user1N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player1Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()
                        }))
                    } else {
                        gameOverAlert = Alert(title: Text("輸了！"), message: Text(NSLocalizedString("你(", comment: "") + user0N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player2Count) + NSLocalizedString("\n對手(", comment: "") + user1N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player1Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()
                        }))
                    }
                }
            } else if player2Count > player1Count {
                if playerPieceNum == 1 {
                    if userNum == 0 {
                        myGameData.countWinandLose(user: 1)
                        gameOverAlert = Alert(title: Text("輸了！"), message: Text(NSLocalizedString("你(", comment: "") + user0N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player1Count) + NSLocalizedString("\n對手(", comment: "") + user1N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()
                        }))
                    } else {
                        gameOverAlert = Alert(title: Text("輸了！"), message: Text(NSLocalizedString("你(", comment: "") + user1N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player1Count) + NSLocalizedString("\n對手(", comment: "") + user0N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()
                        }))
                    }
                } else {
                    if userNum == 0 {
                        myGameData.countWinandLose(user: 0)
                        gameOverAlert = Alert(title: Text("獲勝！"), message: Text(NSLocalizedString("你(", comment: "") + user0N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player2Count) + NSLocalizedString("\n對手(", comment: "") + user1N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player1Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()
                        }))
                    } else {
                        gameOverAlert = Alert(title: Text("獲勝！"), message: Text(NSLocalizedString("你(", comment: "") + user1N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player2Count) + NSLocalizedString("\n對手(", comment: "") + user0N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player1Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()
                        }))
                    }
                }
            } else if player1Count == player2Count {
                if userNum == 0 {
                    gameOverAlert = Alert(title: Text("平手！"), message: Text(NSLocalizedString("你(", comment: "") + user0N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player1Count) + NSLocalizedString("\n對手(", comment: "") + user1N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()
                    }))
                } else {
                    gameOverAlert = Alert(title: Text("平手！"), message: Text(NSLocalizedString("你(", comment: "") + user1N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player1Count) + NSLocalizedString("\n對手(", comment: "") + user0N + NSLocalizedString(")的棋子數目: ", comment: "") + String(player2Count)), dismissButton: .default(Text("OK"), action: {turnBackToRoomView()
                    }))
                }
            }
        }
    }
    
    func turnBackToRoomView() -> Void {
        self.myGameData.removeGameListener()
        if self.userNum == 0 {
            self.myGameData.delGameRoom()
            self.myRoomData.setRoomGameStatus(status: false)
        }
        self.myRoomData.cancelReady(userNum: 0)
        self.myRoomData.cancelReady(userNum: 1)
        self.myRoomData.addRoomListener()
        self.gotoGameView = false
    }
}

