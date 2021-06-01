//
//  User.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/28.
//

import Foundation
import FirebaseAuth
import AVFoundation

class MyUserData: ObservableObject {
    @Published var currentUser: User?
    @Published var currentUserData: UserData
    init() {
        self.currentUser = Auth.auth().currentUser
        self.currentUserData = UserData(id: "", userName: "", userPhotoURL: "", userGender: "", userBD: "", userFirstLogin: "", userCountry: "")
    }
}

var myPlayer = AVQueuePlayer()

