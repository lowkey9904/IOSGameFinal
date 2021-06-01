//
//  Game.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/30.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class MyGame: ObservableObject {
    @Published var myGameData: GameData
    private var listener: ListenerRegistration?
    let db = Firestore.firestore()
    let changePlayer = NotificationCenter.default.publisher(for: Notification.Name("changePlayer"))
    let skipP0 = NotificationCenter.default.publisher(for: Notification.Name("skipP0"))
    let skipP1 = NotificationCenter.default.publisher(for: Notification.Name("skipP1"))
    let gameOver = NotificationCenter.default.publisher(for: Notification.Name("gameOver"))
    init() {
        self.myGameData = GameData(roomData: RoomData(id: "", user0: UserData(id: "", userName: "", userPhotoURL: "", userGender: "", userBD: "", userFirstLogin: "", userCountry: ""), user0ready: false, user1: UserData(id: "", userName: "", userPhotoURL: "", userGender: "", userBD: "", userFirstLogin: "", userCountry: ""), user1ready: false, startPlayer: 0), nowPlayer: 0, user0Skipped: false, user1Skipped: false)
    }
    
    func copyGame(newGame: GameData) -> Void {
        self.myGameData = newGame
    }
    
    
    func addGameListener() -> Void {
        self.listener = self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").addSnapshotListener{
            snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let game = try? snapshot.data(as: GameData.self) else { return }
            self.copyGame(newGame: game)
            print("Game data update!")
            if(self.myGameData.nowPlayer != game.nowPlayer) {
                NotificationCenter.default.post(name: Notification.Name("changePlayer"), object: nil)
            }
            
            //SKIP & GAME OVER RULE
            if(self.checkCBAva()) {
                print("恢復正常")
                if self.myGameData.nowPlayer == 0 && self.myGameData.user0Skipped {
                    self.setisFinal(status: false, user: 0)
                }
                if self.myGameData.nowPlayer == 1 && self.myGameData.user1Skipped{
                    self.setisFinal(status: false, user: 1)
                }
            }
            if(self.myGameData.user0Skipped && self.myGameData.user1Skipped) {
                NotificationCenter.default.post(name: Notification.Name("gameOver"), object: nil)
            }
            if(self.myGameData.nowPlayer == 0 && self.myGameData.user0Skipped) {
                NotificationCenter.default.post(name: Notification.Name("skipP0"), object: nil)
            }
            if(self.myGameData.nowPlayer == 1 && self.myGameData.user1Skipped) {
                NotificationCenter.default.post(name: Notification.Name("skipP1"), object: nil)
            }
            
        }
            
    }
    
    func setisFinal(status: Bool, user: Int) -> Void {
        if user == 0 {
            self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").setData(["user0Skipped": status], merge: true)
        } else if user == 1 {
            self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").setData(["user1Skipped": status], merge: true)
        }
        
    }
    
    func removeGameListener() -> Void {
        self.listener?.remove()
    }
    
    func delGameRoom() -> Void {
        self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").delete() { err in
            if let err = err {
                print("Error removing room: \(err)")
            } else {
                print("Room successfully deleted!")
            }
        }
    }
    
    func turnPlayer(nowPlayer: Int) -> Void {
        if nowPlayer == 0 {
            self.myGameData.nowPlayer = 1
            self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").setData(["nowPlayer": 1], merge: true)
            print("Change to Player2")
        } else if nowPlayer == 1 {
            self.myGameData.nowPlayer = 0
            self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").setData(["nowPlayer": 0], merge: true)
            print("Change to Player1")
        }
    }
    
    //update checkerboard (index1, index2)為下的地方
    func updateCB(index1: Int, index2: Int, playerPieceNum: Int, isSkip: Bool = false) -> Void {
        if isSkip == false {
            self.myGameData.checkerboard[String(index1)]![index2] = playerPieceNum
        }
        self.checkCB(index1: index1, index2: index2, playerPieceNum: playerPieceNum, isSkip: isSkip)
        self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").setData(["checkerboard":self.myGameData.checkerboard], merge: true)
    }
    
    //確認有沒有可以下的地方(有0是true，沒有則false)
    func checkCBAva() -> Bool {
        for i in 0..<8 {
            for j in 0..<8 {
                if self.myGameData.checkerboard[String(i)]![j] == 0 {
                    return true
                }
            }
        }
        return false
    }
    
    func checkCB(index1: Int, index2: Int, playerPieceNum: Int, isSkip: Bool) -> Void {
        //不是1就是2
        let enemyPieceNum = 3 - playerPieceNum
        //確認八方位
        let checkRound = [(index1 - 1, index2 - 1), (index1 - 1, index2), (index1 - 1, index2 + 1),
                     (index1, index2 - 1), (index1, index2 + 1),
                     (index1 + 1, index2 - 1), (index1 + 1, index2), (index1 + 1, index2 + 1)]
        
        //先將前一手可下的地方通通刪除，變為不能下
        for i in 0..<8 {
            for j in 0..<8 {
                if self.myGameData.checkerboard[String(i)]![j] == 0 {
                    self.myGameData.checkerboard[String(i)]![j] = -1
                }
            }
        }
        
        //棋子翻面(被跳過的不須執行)
        if isSkip == false {
            for c in checkRound {
                //超出棋盤範圍或不是敵人棋子都不用確認
                if c.0 >= 0 && c.0 <= 7 && c.1 >= 0 && c.1 <= 7 &&
                    self.myGameData.checkerboard[String(c.0)]![c.1] == enemyPieceNum {
                    switch (c.0, c.1) {
                    //左上
                    case (index1 - 1, index2 - 1):
                        var temp = 1
                        var findSelf = false
                        while(index1 - temp >= 0 && index2 - temp >= 0) {
                            if self.myGameData.checkerboard[String(index1 - temp)]![index2 - temp] == playerPieceNum {
                                findSelf = true
                                break
                            } else if self.myGameData.checkerboard[String(index1 - temp)]![index2 - temp] == -1 {
                                break
                            } else {
                                temp = temp + 1
                            }
                        }
                        if findSelf {
                            temp = 1
                            while(index1 - temp >= 0 && index2 - temp >= 0) {
                                if self.myGameData.checkerboard[String(index1 - temp)]![index2 - temp] == playerPieceNum {
                                    break
                                } else {
                                    self.myGameData.checkerboard[String(index1 - temp)]![index2 - temp] = playerPieceNum
                                    temp = temp + 1
                                }
                            }
                        }
                    //中上
                    case (index1 - 1, index2):
                        var temp = 1
                        var findSelf = false
                        while(index1 - temp >= 0) {
                            if self.myGameData.checkerboard[String(index1 - temp)]![index2] == playerPieceNum {
                                findSelf = true
                                break
                            } else if self.myGameData.checkerboard[String(index1 - temp)]![index2] == -1 {
                                break
                            } else {
                                temp = temp + 1
                            }
                        }
                        if findSelf {
                            temp = 1
                            while(index1 - temp >= 0) {
                                if self.myGameData.checkerboard[String(index1 - temp)]![index2] == playerPieceNum {
                                    break
                                } else {
                                    self.myGameData.checkerboard[String(index1 - temp)]![index2] = playerPieceNum
                                    temp = temp + 1
                                }
                            }
                        }
                    //右上
                    case (index1 - 1, index2 + 1):
                        var temp = 1
                        var findSelf = false
                        while(index1 - temp >= 0 && index2 + temp <= 7) {
                            if self.myGameData.checkerboard[String(index1 - temp)]![index2 + temp] == playerPieceNum {
                                findSelf = true
                                break
                            } else if self.myGameData.checkerboard[String(index1 - temp)]![index2 + temp] == -1 {
                                break
                            } else {
                                temp = temp + 1
                            }
                        }
                        if findSelf {
                            temp = 1
                            while(index1 - temp >= 0 && index2 + temp <= 7) {
                                if self.myGameData.checkerboard[String(index1 - temp)]![index2 + temp] == playerPieceNum {
                                    break
                                } else {
                                    self.myGameData.checkerboard[String(index1 - temp)]![index2 + temp] = playerPieceNum
                                    temp = temp + 1
                                }
                            }
                        }
                    //左中
                    case (index1, index2 - 1):
                        var temp = 1
                        var findSelf = false
                        while(index2 - temp >= 0) {
                            if self.myGameData.checkerboard[String(index1)]![index2 - temp] == playerPieceNum {
                                findSelf = true
                                break
                            } else if self.myGameData.checkerboard[String(index1)]![index2 - temp] == -1{
                                break
                            } else {
                                temp = temp + 1
                            }
                        }
                        if findSelf {
                            temp = 1
                            while(index2 - temp >= 0) {
                                if self.myGameData.checkerboard[String(index1)]![index2 - temp] == playerPieceNum {
                                    break
                                } else {
                                    self.myGameData.checkerboard[String(index1)]![index2 - temp] = playerPieceNum
                                    temp = temp + 1
                                }
                            }
                        }
                    //右中
                    case (index1, index2 + 1):
                        var temp = 1
                        var findSelf = false
                        while(index2 + temp <= 7) {
                            if self.myGameData.checkerboard[String(index1)]![index2 + temp] == playerPieceNum {
                                findSelf = true
                                break
                            } else if self.myGameData.checkerboard[String(index1)]![index2 + temp] == -1 {
                                break
                            } else {
                                temp = temp + 1
                            }
                        }
                        if findSelf {
                            temp = 1
                            while(index2 + temp <= 7) {
                                if self.myGameData.checkerboard[String(index1)]![index2 + temp] == playerPieceNum {
                                    break
                                } else {
                                    self.myGameData.checkerboard[String(index1)]![index2 + temp] = playerPieceNum
                                    temp = temp + 1
                                }
                            }
                        }
                    //左下
                    case (index1 + 1, index2 - 1):
                        var temp = 1
                        var findSelf = false
                        while(index1 + temp <= 7 && index2 - temp >= 0) {
                            if self.myGameData.checkerboard[String(index1 + temp)]![index2 - temp] == playerPieceNum {
                                findSelf = true
                                break
                            } else if self.myGameData.checkerboard[String(index1 + temp)]![index2 - temp] == -1{
                                break
                            } else {
                                temp = temp + 1
                            }
                        }
                        if findSelf {
                            temp = 1
                            while(index1 + temp <= 7 && index2 - temp >= 0) {
                                if self.myGameData.checkerboard[String(index1 + temp)]![index2 - temp] == playerPieceNum {
                                    break
                                } else {
                                    self.myGameData.checkerboard[String(index1 + temp)]![index2 - temp] = playerPieceNum
                                    temp = temp + 1
                                }
                            }
                        }
                    //中下
                    case (index1 + 1, index2):
                        var temp = 1
                        var findSelf = false
                        while(index1 + temp <= 7) {
                            if self.myGameData.checkerboard[String(index1 + temp)]![index2] == playerPieceNum {
                                findSelf = true
                                break
                            } else if self.myGameData.checkerboard[String(index1 + temp)]![index2] == -1 {
                                break
                            } else {
                                //self.myGameData.checkerboard[String(index1 + temp)]![index2] = playerPieceNum
                                temp = temp + 1
                            }
                        }
                        if findSelf {
                            temp = 1
                            while(index1 + temp <= 7) {
                                if self.myGameData.checkerboard[String(index1 + temp)]![index2] == playerPieceNum {
                                    break
                                } else {
                                    self.myGameData.checkerboard[String(index1 + temp)]![index2] = playerPieceNum
                                    temp = temp + 1
                                }
                            }
                        }
                    //右下
                    case (index1 + 1, index2 + 1):
                        var temp = 1
                        var findSelf = false
                        while(index1 + temp <= 7 && index2 + temp <= 7) {
                            if self.myGameData.checkerboard[String(index1 + temp)]![index2 + temp] == playerPieceNum {
                                findSelf = true
                                break
                            } else if self.myGameData.checkerboard[String(index1 + temp)]![index2 + temp] == -1 {
                                break
                            } else {
                                //self.myGameData.checkerboard[String(index1 + temp)]![index2 + temp] = playerPieceNum
                                temp = temp + 1
                            }
                        }
                        if findSelf {
                            temp = 1
                            while(index1 + temp <= 7 && index2 + temp <= 7) {
                                if self.myGameData.checkerboard[String(index1 + temp)]![index2 + temp] == playerPieceNum {
                                    break
                                } else {
                                    self.myGameData.checkerboard[String(index1 + temp)]![index2 + temp] = playerPieceNum
                                    temp = temp + 1
                                }
                            }
                        }
                    default:
                        print("BUGGGG!!")
                        break
                    }
                }
            }
        }
        //更新可以下的地方
        //重新尋找現在可下之地方(自己下完了所以要找對手的)
        for k in 0..<8 {
            for m in 0..<8 {
                if self.myGameData.checkerboard[String(k)]![m] == enemyPieceNum {
                    let enRound = [(k - 1, m - 1), (k - 1, m), (k - 1, m + 1),
                                   (k, m - 1), (k, m + 1),
                                   (k + 1, m - 1), (k + 1, m), (k + 1, m + 1)]
                    for er in enRound {
                        //確保在棋盤內且旁邊不是空白或是自己的棋子
                        if er.0 >= 0 && er.0 <= 7 && er.1 >= 0 && er.1 <= 7 &&
                            self.myGameData.checkerboard[String(er.0)]![er.1] == playerPieceNum {
                            switch (er.0, er.1) {
                            //左上
                            case (k - 1, m - 1):
                                var temp = 1
                                while(k - temp >= 0 && m - temp >= 0 &&
                                    (self.myGameData.checkerboard[String(k - temp)]![m - temp] == playerPieceNum)) {
                                        let temp2 = temp + 1
                                        if (k - temp2 >= 0 && m - temp2 >= 0 &&
                                            (self.myGameData.checkerboard[String(k - temp2)]![m - temp2] == -1)) {
                                            self.myGameData.checkerboard[String(k - temp2)]![m - temp2] = 0
                                            break
                                        } else {
                                            temp += 1
                                        }
                                }
                            //中上
                            case (k - 1, m):
                                var temp = 1
                                while(k - temp >= 0 &&
                                    (self.myGameData.checkerboard[String(k - temp)]![m] == playerPieceNum)) {
                                        let temp2 = temp + 1
                                        if (k - temp2 >= 0 &&
                                            (self.myGameData.checkerboard[String(k - temp2)]![m] == -1)) {
                                            self.myGameData.checkerboard[String(k - temp2)]![m] = 0
                                            break
                                        } else {
                                            temp += 1
                                        }
                                }
                            //右上
                            case (k - 1, m + 1):
                                var temp = 1
                                while(k - temp >= 0 && m + temp <= 7 &&
                                    (self.myGameData.checkerboard[String(k - temp)]![m + temp] == playerPieceNum)) {
                                        let temp2 = temp + 1
                                        if (k - temp2 >= 0 && m + temp2 <= 7 &&
                                            (self.myGameData.checkerboard[String(k - temp2)]![m + temp2] == -1)) {
                                            self.myGameData.checkerboard[String(k - temp2)]![m + temp2] = 0
                                            break
                                        } else {
                                            temp += 1
                                        }
                                }
                            //左中
                            case (k, m - 1):
                                var temp = 1
                                while(m - temp >= 0 &&
                                    (self.myGameData.checkerboard[String(k)]![m - temp] == playerPieceNum)) {
                                        let temp2 = temp + 1
                                        if (m - temp2 >= 0 &&
                                            (self.myGameData.checkerboard[String(k)]![m - temp2] == -1)) {
                                            self.myGameData.checkerboard[String(k)]![m - temp2] = 0
                                            break
                                        } else {
                                            temp += 1
                                        }
                                }
                            //右中
                            case (k, m + 1):
                                var temp = 1
                                while(m + temp <= 7 &&
                                    (self.myGameData.checkerboard[String(k)]![m + temp] == playerPieceNum)) {
                                        let temp2 = temp + 1
                                        if (m + temp2 <= 7 &&
                                            (self.myGameData.checkerboard[String(k)]![m + temp2] == -1)) {
                                            self.myGameData.checkerboard[String(k)]![m + temp2] = 0
                                            break
                                        } else {
                                            temp += 1
                                        }
                                }
                            //左下
                            case (k + 1, m - 1):
                                var temp = 1
                                while(k + temp <= 7 && m - temp >= 0 &&
                                    (self.myGameData.checkerboard[String(k + temp)]![m - temp] == playerPieceNum)) {
                                        let temp2 = temp + 1
                                        if (k + temp2 <= 7 && m - temp2 >= 0 &&
                                            (self.myGameData.checkerboard[String(k + temp2)]![m - temp2] == -1)) {
                                            self.myGameData.checkerboard[String(k + temp2)]![m - temp2] = 0
                                            break
                                        } else {
                                            temp += 1
                                        }
                                }
                            //中下
                            case (k + 1, m):
                                var temp = 1
                                while(k + temp <= 7 &&
                                    (self.myGameData.checkerboard[String(k + temp)]![m] == playerPieceNum)) {
                                        let temp2 = temp + 1
                                        if (k + temp2 <= 7 &&
                                            (self.myGameData.checkerboard[String(k + temp2)]![m] == -1)) {
                                            self.myGameData.checkerboard[String(k + temp2)]![m] = 0
                                            break
                                        } else {
                                            temp += 1
                                        }
                                }
                            //右下
                            case (k + 1, m + 1):
                                var temp = 1
                                while(k + temp <= 7 && m + temp <= 7 &&
                                    (self.myGameData.checkerboard[String(k + temp)]![m + temp] == playerPieceNum)) {
                                        let temp2 = temp + 1
                                        if (k + temp2 <= 7 && m + temp2 <= 7 &&
                                            (self.myGameData.checkerboard[String(k + temp2)]![m + temp2] == -1)) {
                                            self.myGameData.checkerboard[String(k + temp2)]![m + temp2] = 0
                                            break
                                        } else {
                                            temp += 1
                                        }
                                }
                            default:
                                print("A BUGGGG!!")
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}

struct GameData: Codable, Identifiable {
    @DocumentID var id: String?
    var roomData: RoomData
    var nowPlayer: Int
    var user0Skipped: Bool
    var user1Skipped: Bool
    var checkerboard = ["0": [-1, -1, -1, -1, -1, -1, -1, -1],
                        "1": [-1, -1, -1, -1, -1, -1, -1, -1],
                        "2": [-1, -1, -1,  0, -1, -1, -1, -1],
                        "3": [-1, -1,  0,  2,  1, -1, -1, -1],
                        "4": [-1, -1, -1,  1,  2,  0, -1, -1],
                        "5": [-1, -1, -1, -1,  0, -1, -1, -1],
                        "6": [-1, -1, -1, -1, -1, -1, -1, -1],
                        "7": [-1, -1, -1, -1, -1, -1, -1, -1]]
    //-1代表不能下 0代表當前player可下位置 1代表Player1的棋子 2代表Player2的棋子
}
