//
//  RewardedAdController.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/6/21.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import GoogleMobileAds

class RewardedAdController: NSObject {
    
    private var ad: GADRewardedAd?
    var showAnimation: Bool = false
    
    let db = Firestore.firestore()
    func loadAD() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: request) { ad, error in
            if let error = error {
                print(error)
                return
            }
            ad?.fullScreenContentDelegate = self
            self.ad = ad
        }
    }

    func showAD(currentUserData: UserData) {
        if let ad = ad,
           let controller = UIViewController.getLastPresentedViewController() {
            ad.present(fromRootViewController: controller){
                print("拿到獎勵了")
                let rewardMoney = currentUserData.userMoney + 10
                self.db.collection("users_data").document(currentUserData.userID ?? "").setData(["userMoney": rewardMoney], merge: true)
                self.showAnimation = true
            }
        }

    }
}

extension RewardedAdController: GADFullScreenContentDelegate {

    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print(#function)
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print(#function)
    }

    func ad(_ ad: GADFullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        print(#function, error)

    }

}
