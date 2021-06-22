//
//  LoginProgressView.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/6/10.
//

import SwiftUI

struct LoginProgressView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                .scaleEffect(3.0)
                .padding()
            Text("自動登入中...")
                .font(.title)
                .bold()
                .foregroundColor(.yellow)
                .padding()
        }.background(Image("bg2").contrast(0.25))
    }
}

struct LoginProgressView_Previews: PreviewProvider {
    static var previews: some View {
        LoginProgressView()
    }
}
