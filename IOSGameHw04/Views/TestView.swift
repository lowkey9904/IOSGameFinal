//
//  TestView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/30.
//

import SwiftUI
import Kingfisher

struct TestView: View {
    @State private var picContrast: Double = 1
    @State private var showAlert: Bool = false
    var body: some View {
        NavigationView{
        ZStack {
            VStack{
                Button(action:{
                    self.showAlert = true
                }) {
                    Text("點我測試")
                }.alert(isPresented: $showAlert) { () -> Alert in
                    return Alert(title: Text("獲勝！"), message: Text("你(nihao222ao)的棋子數目: 48\n對手(nihao333ao)的棋子數目: 16\n"))
                }
            HStack{
                VStack {
                KFImage(URL(string: "https://firebasestorage.googleapis.com/v0/b/finaliosgame.appspot.com/o/DC62FF70-ED5A-4B87-AEEC-7C3C86A3AEFE.png?alt=media&token=451d0590-4128-4a3f-90b2-0726e32a14e7")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 90)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    Text("nih222ao")
                        .font(.title3)
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
                VStack {
                    VStack {
                        Text("現在輪到")
                            .font(.system(size: 18))
                            .bold()
                            .padding(.bottom)
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .font(.system(size: 40))
                    }.foregroundColor(midNightBlue)
                    .background(
                        Color.yellow
                            .frame(width: 100, height: 170)
                            .cornerRadius(20)
                            .scaledToFill()
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(midNightBlue, lineWidth: 5))
                            )
                    
                }
                
                Spacer()
                VStack {
                KFImage(URL(string: "https://firebasestorage.googleapis.com/v0/b/finaliosgame.appspot.com/o/839A3C40-9B50-4258-8AA0-36AE71D918A7.png?alt=media&token=3d216e8e-e336-4bdc-9e0e-83b4e9ab64ce")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 90)
                    Text("nih333ao")
                        .font(.title3)
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
                .padding(.vertical)
            }.padding()
                Spacer()
            VStack {
                ForEach(0..<8){ index1 in
                    HStack {
                        ForEach(0..<8){ index2 in
                            if ((index1 + index2) % 2 == 0) {
                                Image("cbbg0")
                                    .resizable()
                                    .frame(width: 43, height: 43)
                                    .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color(red: 146/255, green: 127/255, blue: 105/255), lineWidth: 5))
                                    .cornerRadius(5)
                                
                            } else {
                                Image("cbbg1")
                                    .resizable()
                                    .frame(width: 43, height: 43)
                                    .cornerRadius(5)
                                    .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color(red: 204/255, green: 182/255, blue: 139/255), lineWidth: 5))
                                    .cornerRadius(5)
                            }
                        }
                    }.padding(.horizontal, 10)
                }
            }.background(
                RadialGradient(gradient: Gradient(colors: [cbg0, cbg1]), center: .center, startRadius:
                50, endRadius: 200)
                    .frame(height: 420)
                    .cornerRadius(20))
                Spacer()
            }.onAppear {
                picContrast = 2}
        }
        .navigationBarItems(leading: Text("房號: 6987").font(.title).bold())
        .background(Image("bg2").blur(radius: 10).contrast(0.8))
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
