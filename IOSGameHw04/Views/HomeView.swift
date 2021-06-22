//
//  HomeView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/6/4.
//

import SwiftUI
import FirebaseAuth
import AVFoundation
import AppTrackingTransparency

struct HomeView: View {
    var body: some View {
        Home()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct Home: View {
    @State var offset: CGSize = .zero
    @State var showHome = false
    //Music Player
    @State var looper: AVPlayerLooper?
    @State private var hPlayer = AVQueuePlayer()
    var body: some View {
        ZStack {
            Image("bg")
                .resizable()
                .ignoresSafeArea()
                .contrast(0.4)
                .overlay(
                    VStack(alignment: .leading, spacing: 10, content: {
                        Button(action:{
                            if hPlayer.timeControlStatus == .playing {
                                hPlayer.pause()
                            } else {
                                hPlayer.play()
                            }
                        }){
                            HStack {
                                Text("Music")
                                Image(systemName: "play.circle.fill")
                            }.font(.title2)
                            .foregroundColor(.white)
                        }
//                        Button(action:{
//                            self.testCrashFunc()
//                        }){
//                            Text("測試閃退")
//                                .bold()
//                                .foregroundColor(.white)
//                        }
                        Text("你知道嗎...\n")
                            .font(.system(size: 50))
                            .bold()
                        Text("黑白棋是19世紀末英國人發明的。直到上個世紀70年代日本人長谷川五郎將其發展，借用莎士比亞名劇奧賽羅為這個遊戲重新命名。\n\n\n奧賽羅是一個黑人，妻子是白人，因受小人挑撥，懷疑妻子不忠一直情海翻波，最終親手把妻子殺死。後來真相大白，奧賽羅懊悔不已，自殺而死。黑白棋就是借用這個黑人白人鬥爭的故事。")
                            .font(.title2)
                            .bold()
                    })
                    .foregroundColor(titleColor)
                    .padding(.horizontal, 30)
                    .offset(x: -15)
                    
                )
                .clipShape(LiquidSwipe(offset: offset))
                .ignoresSafeArea()
                .overlay(
                    Image(systemName: "chevron.left")
                        .font(.largeTitle)
                        .frame(width: 50, height: 50)
                        .contentShape(Rectangle())
                        .gesture(DragGesture().onChanged({ (value) in
                            withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.6, blendDuration: 0.6)) {
                                offset = value.translation
                            }
                        }).onEnded({ (value) in
                            let screen = UIScreen.main.bounds
                            withAnimation(.spring()) {
                                if -offset.width > screen.width / 2 {
                                    offset.width = -screen.height
                                    hPlayer.pause()
                                    showHome.toggle()
                                } else {
                                    offset = .zero
                                }
                            }
                        }))
                        .offset(x: 15, y:60)
                        .opacity(offset == .zero ? 1: 0)
                    ,alignment: .topTrailing
                ).padding(.trailing)
            if showHome{
                ContentView()
            }
        }
        .onAppear {
            if hPlayer.timeControlStatus != .playing {
                let fileUrlH = Bundle.main.url(forResource: "bgm2", withExtension: "mp3")!
                let itemH = AVPlayerItem(url: fileUrlH)
                self.looper = AVPlayerLooper(player: hPlayer, templateItem: itemH)
                hPlayer.volume = UserDefaults.standard.object(forKey: "myPlayerVol") as? Float ?? 0.1
                if UserDefaults.standard.object(forKey: "myPlayerStatus") as? Bool ?? true {
                    hPlayer.play()
                }
            }
            self.requestTracking()
        }
    }
    
    private func requestTracking() -> String {
        var requestTrackingAuthorizationStatus = ""
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .notDetermined:
                print("notDetermined")
                requestTrackingAuthorizationStatus = "notDetermined"
            case .restricted:
                print("restricted")
                requestTrackingAuthorizationStatus = "restricted"
            case .denied:
                print("denied")
                requestTrackingAuthorizationStatus = "denied"
            case .authorized:
                print("authorized")
                requestTrackingAuthorizationStatus = "authorized"
            @unknown default:
                print("unknown")
                requestTrackingAuthorizationStatus = "unknown"
                break
            }
        }
        return requestTrackingAuthorizationStatus
    }
    
    private func testCrashFunc() {
        fatalError()
    }
}
