//
//  GameRule.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/6/19.
//

import SwiftUI

struct GameRule: View {
    var body: some View {
        ScrollView {
            VStack {
                VStack (alignment: .leading) {
                    Text("遊戲規則")
                        .font(.title)
                        .bold()
                    Text("棋盤共有8行8列共64格。\n開局時,棋盤正中央的4格先置放黑白相隔的4枚棋子,雙方輪流落子。\n只要落子和棋盤上任一枚己方的棋子在一條線上(橫,直,斜線皆可)夾著對方棋子,就能將對方的這些棋子轉變為我己方(翻面即可)。\n如果在任一位置落子都不能夾住對手的任一顆棋子,就要讓對手下子。\n當雙方皆不能下子時,遊戲就結束,子多的一方勝。")
                        .font(.title2)
                }.padding()
            }.foregroundColor(midNightBlue)
            .background(Color.yellow)
            .padding(2)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(midNightBlue, lineWidth: 10))
            .cornerRadius(20)
            VStack {
                VStack (alignment: .leading) {
                    Text("遊戲策略")
                        .font(.title)
                        .bold()
                    Text("因為黑白棋獨特的規則,很容易出現雙方比分的劇烈變化,在遊戲後期可能僅用幾個回合就將大量對方棋子變成己方,從而扭轉局勢。\n因此,太著眼於比分是沒有必要的,更重要的是占據有利位置。\n中間位置的棋子最容易受到夾擊,有橫,直,斜線共四個方向的可能。而邊緣的棋子則只有一個可能被夾擊的方向,四個角落上的位置被占據後,則完全不可能被攻擊。\n遊戲的後期是關鍵位置的爭奪,而前期的布局,就是為搶占關鍵位置作準備。例如:若不想讓對方占據棋盤邊緣的有利位置,那麼自己就應避免在靠近邊緣的那一排落子。")
                        .font(.title2)
                }.padding()
            }.foregroundColor(midNightBlue)
            .background(Color.yellow)
            .padding(2)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(midNightBlue, lineWidth: 10))
            .cornerRadius(20)
            VStack {
                VStack (alignment: .leading) {
                    Text("入場費")
                        .font(.title)
                        .bold()
                    Text("每次入場會花費50金幣，若金幣不足，則無法進場\n金幣可透過贏得比賽(贏得一場比賽加100)或是透過看廣告的方式取得獎勵(看一次加10)")
                        .font(.title2)
                }.padding()
            }.foregroundColor(midNightBlue)
            .background(Color.yellow)
            .padding(2)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(midNightBlue, lineWidth: 10))
            .cornerRadius(20)
            
        }.padding()
        .background(Image("bg2").blur(radius: 10).contrast(0.69))
    }
}

struct GameRule_Previews: PreviewProvider {
    static var previews: some View {
        GameRule()
    }
}
