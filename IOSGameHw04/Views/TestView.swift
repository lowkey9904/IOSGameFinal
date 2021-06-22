//
//  TestView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/30.
//

import SwiftUI
import Kingfisher
import GoogleMobileAds

struct TestView: View {
    @State private var picContrast: Double = 1
    @State private var showAnimation: Bool = false
    @State private var showText = false
    @State private var yourContrast = 1.0
    @State private var roomPW = ""
    @State private var gameMsg = "沒有地方可以下，你被跳過了"
    @State var percent : CGFloat = 0
    @State var animationOffset: CGFloat = 40
    @State var animationOpacity: Double = 0
    
    let myRAD = RewardedAdController()
    
    var body: some View {
        NavigationView{
            VStack {
                if self.showAnimation {
                    HStack {
                        Image(systemName: "dollarsign.circle")
                        Text("+10")
                            .bold()
                    }.font(.largeTitle)
                    .offset(y: self.animationOffset)
                    .foregroundColor(.red)
                    .opacity(self.animationOpacity)
                    .padding(.horizontal)
                    .onAppear {
                        self.animationOffset -= 40
                        self.animationOpacity += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                            self.animationOpacity -= 1
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.showAnimation = false
                                self.animationOffset += 40
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 1.5))
                }
            }.onAppear {
                self.showAnimation = true
            }
        .navigationBarItems(leading: Text("房號: 6987").font(.title).bold())
            //.background(Color.black.blur(radius: 10).contrast(0.8))
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}


