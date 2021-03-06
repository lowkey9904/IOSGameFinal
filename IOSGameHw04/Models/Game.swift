//
//  Game.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/30.
//
import SwiftUI
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
    let gameNormal = NotificationCenter.default.publisher(for: Notification.Name("gn"))
    let giveupP0 = NotificationCenter.default.publisher(for: Notification.Name("giveupP0"))
    let giveupP1 = NotificationCenter.default.publisher(for: Notification.Name("giveupP1"))
    let gameOver = NotificationCenter.default.publisher(for: Notification.Name("gameOver"))
    init() {
        self.myGameData = GameData(roomData: RoomData(id: "", user0: UserData(id: "", userID: "", userName: "", userPhotoURL: "", userGender: "", userBD: "", userFirstLogin: "", userCountry: ""), user0ready: false, user1: UserData(id: "", userID: "", userName: "", userPhotoURL: "", userGender: "", userBD: "", userFirstLogin: "", userCountry: ""), user1ready: false, roundTime: 0, roomPassWord: "", startPlayer: 0, roomGameStatus: false), nowPlayer: 0)
    }
    
    func copyGame(newGame: GameData) -> Void {
        self.myGameData = newGame
    }
    
    
    func addGameListener() -> Void {
        self.listener = self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").addSnapshotListener{
            snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let game = try? snapshot.data(as: GameData.self) else { return }
//            if(self.myGameData.nowPlayer != game.nowPlayer) {
//                NotificationCenter.default.post(name: Notification.Name("changePlayer"), object: nil)
//            }
            self.copyGame(newGame: game)
            print("Game data update!")
            
            //SKIPPED
            if(self.myGameData.user0Skipped) {
                NotificationCenter.default.post(name: Notification.Name("skipP0"), object: nil)
            }
            if(self.myGameData.user1Skipped) {
                NotificationCenter.default.post(name: Notification.Name("skipP1"), object: nil)
            }
            if(self.myGameData.user0GiveUp == false && self.myGameData.user1Skipped == false) {
                NotificationCenter.default.post(name: Notification.Name("gn"), object: nil)
            }
            
            //GIVEUP
            if(self.myGameData.user0GiveUp) {
                NotificationCenter.default.post(name: Notification.Name("giveupP0"), object: nil)
            }
            if(self.myGameData.user1GiveUp) {
                NotificationCenter.default.post(name: Notification.Name("giveupP1"), object: nil)
            }
            
            //SKIP & GAME OVER RULE
            if(self.checkCBAva()) {
                print("????????????")
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
    
    func setGiveUp(user: Int) -> Void {
        self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").setData(["user" + String(user) + "GiveUp": true], merge: true)
    }
    
    func setisFinal(status: Bool, user: Int) -> Void {
        self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").setData(["user" + String(user) + "Skipped": status], merge: true)
    }
    
    //input userNum is winner
    //?????????????????????????????????(Winner+50 Loser-50)
    func countWinandLose(user: Int) -> Void {
        print("Count")
        print(self.myGameData.roomData.user0.userID ?? "")
        print(self.myGameData.roomData.user1.userID ?? "")
        if user == 0 {
            //print(self.myGameData.roomData.user0.userWin, self.myGameData.roomData.user1.userWin)
            self.myGameData.roomData.user0.userWin += 1
            self.myGameData.roomData.user1.userLose += 1
            self.myGameData.roomData.user0.userMoney += 50
            self.myGameData.roomData.user1.userMoney -= 50
            self.db.collection("users_data").document(self.myGameData.roomData.user0.userID ?? "").setData(["userWin": self.myGameData.roomData.user0.userWin], merge: true)
            self.db.collection("users_data").document(self.myGameData.roomData.user1.userID ?? "").setData(["userLose": self.myGameData.roomData.user1.userLose], merge: true)
            self.db.collection("users_data").document(self.myGameData.roomData.user0.userID ?? "").setData(["userMoney": self.myGameData.roomData.user0.userMoney], merge: true)
            self.db.collection("users_data").document(self.myGameData.roomData.user1.userID ?? "").setData(["userMoney": self.myGameData.roomData.user1.userMoney], merge: true)
        } else {
            self.myGameData.roomData.user0.userLose += 1
            self.myGameData.roomData.user1.userWin += 1
            self.myGameData.roomData.user0.userMoney -= 50
            self.myGameData.roomData.user1.userMoney += 50
            self.db.collection("users_data").document(self.myGameData.roomData.user0.userID ?? "").setData(["userLose": self.myGameData.roomData.user0.userLose], merge: true)
            self.db.collection("users_data").document(self.myGameData.roomData.user1.userID ?? "").setData(["userWin": self.myGameData.roomData.user1.userWin], merge: true)
            self.db.collection("users_data").document(self.myGameData.roomData.user0.userID ?? "").setData(["userMoney": self.myGameData.roomData.user0.userMoney], merge: true)
            self.db.collection("users_data").document(self.myGameData.roomData.user1.userID ?? "").setData(["userMoney": self.myGameData.roomData.user1.userMoney], merge: true)
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
    
    //update checkerboard (index1, index2)???????????????
    func updateCB(index1: Int, index2: Int, playerPieceNum: Int, isSkip: Bool = false) -> Void {
        if isSkip == false {
            self.myGameData.checkerboard[String(index1)]![index2] = playerPieceNum
        }
        let rPieces = self.checkCB(index1: index1, index2: index2, playerPieceNum: playerPieceNum, isSkip: isSkip)
        for rp in rPieces {
            if rp != (-1, -1) {
                self.myGameData.rotateDegree[String(rp.0)]![rp.1] += 360.0
            }
        }
        //????????????????????????????????????????????????
        self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").setData(["rotateDegree": self.myGameData.rotateDegree], merge: true)
        self.db.collection("gaming_room").document(self.myGameData.roomData.id ?? "").setData(["checkerboard": self.myGameData.checkerboard], merge: true)
    }
    
    //?????????????????????????????????(???0???true????????????false)
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
    
    func checkCB(index1: Int, index2: Int, playerPieceNum: Int, isSkip: Bool) -> [(Int, Int)] {
        //??????1??????2
        let enemyPieceNum = 3 - playerPieceNum
        //???????????????
        let checkRound = [(index1 - 1, index2 - 1), (index1 - 1, index2), (index1 - 1, index2 + 1),
                     (index1, index2 - 1), (index1, index2 + 1),
                     (index1 + 1, index2 - 1), (index1 + 1, index2), (index1 + 1, index2 + 1)]
        
        //????????????????????????????????????????????????????????????
        for i in 0..<8 {
            for j in 0..<8 {
                if self.myGameData.checkerboard[String(i)]![j] == 0 {
                    self.myGameData.checkerboard[String(i)]![j] = -1
                }
            }
        }
        
        //????????????(????????????????????????)
        var rotatePieces = [(-1, -1)]
        if isSkip == false {
            for c in checkRound {
                //??????????????????????????????????????????????????????
                if c.0 >= 0 && c.0 <= 7 && c.1 >= 0 && c.1 <= 7 &&
                    self.myGameData.checkerboard[String(c.0)]![c.1] == enemyPieceNum {
                    switch (c.0, c.1) {
                    //??????
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
                                    rotatePieces.append((index1 - temp, index2 - temp))
                                    temp = temp + 1
                                }
                            }
                        }
                    //??????
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
                                    rotatePieces.append((index1 - temp, index2))
                                    temp = temp + 1
                                }
                            }
                        }
                    //??????
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
                                    rotatePieces.append((index1 - temp, index2 + temp))
                                    temp = temp + 1
                                }
                            }
                        }
                    //??????
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
                                    rotatePieces.append((index1, index2 - temp))
                                    temp = temp + 1
                                }
                            }
                        }
                    //??????
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
                                    rotatePieces.append((index1, index2 + temp))
                                    temp = temp + 1
                                }
                            }
                        }
                    //??????
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
                                    rotatePieces.append((index1 + temp, index2 - temp))
                                    temp = temp + 1
                                }
                            }
                        }
                    //??????
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
                                    rotatePieces.append((index1 + temp, index2))
                                    temp = temp + 1
                                }
                            }
                        }
                    //??????
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
                                    rotatePieces.append((index1 + temp, index2 + temp))
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
        //????????????????????????
        //?????????????????????????????????(????????????????????????????????????)
        for k in 0..<8 {
            for m in 0..<8 {
                if self.myGameData.checkerboard[String(k)]![m] == enemyPieceNum {
                    let enRound = [(k - 1, m - 1), (k - 1, m), (k - 1, m + 1),
                                   (k, m - 1), (k, m + 1),
                                   (k + 1, m - 1), (k + 1, m), (k + 1, m + 1)]
                    for er in enRound {
                        //????????????????????????????????????????????????????????????
                        if er.0 >= 0 && er.0 <= 7 && er.1 >= 0 && er.1 <= 7 &&
                            self.myGameData.checkerboard[String(er.0)]![er.1] == playerPieceNum {
                            switch (er.0, er.1) {
                            //??????
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
                            //??????
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
                            //??????
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
                            //??????
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
                            //??????
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
                            //??????
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
                            //??????
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
                            //??????
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
        return rotatePieces
    }
}

struct GameData: Codable, Identifiable {
    @DocumentID var id: String?
    var roomData: RoomData
    var nowPlayer: Int
    var user0Skipped: Bool = false
    var user1Skipped: Bool = false
    var user0GiveUp: Bool = false
    var user1GiveUp: Bool = false
    //-1??????????????? 0????????????player???????????? 1??????Player1????????? 2??????Player2?????????
    var checkerboard = ["0": [-1, -1, -1, -1, -1, -1, -1, -1],
                        "1": [-1, -1, -1, -1, -1, -1, -1, -1],
                        "2": [-1, -1, -1,  0, -1, -1, -1, -1],
                        "3": [-1, -1,  0,  2,  1, -1, -1, -1],
                        "4": [-1, -1, -1,  1,  2,  0, -1, -1],
                        "5": [-1, -1, -1, -1,  0, -1, -1, -1],
                        "6": [-1, -1, -1, -1, -1, -1, -1, -1],
                        "7": [-1, -1, -1, -1, -1, -1, -1, -1]]
    var rotateDegree = ["0": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                        "1": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                        "2": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                        "3": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                        "4": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                        "5": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                        "6": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                        "7": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]]
    
}
