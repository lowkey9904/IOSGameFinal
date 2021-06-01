//
//  ViewModel.swift
//  IOSGameHw04
//
//  Created by Joker on 2021/5/24.
//

import Foundation
import SwiftUI
import UIKit

var titleColor = Color(red: 255/255, green: 255/255, blue: 255/255)
var midNightBlue = Color(red: 58/255, green: 69/255, blue: 79/255)
var cbg0 = Color(red: 235/255, green: 178/255, blue: 125/255)
var cbg1 = Color(red: 164/255, green: 122/255, blue: 85/255)

struct MyTextFieldStyle: TextFieldStyle {
    var bgBlue = Color(red: 203/255, green: 217/255, blue: 228/255)
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .foregroundColor(.black)
        .padding(20)
        .background(bgBlue)
            .opacity(0.8)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color(red: 121/255, green: 124/255, blue: 177/255), lineWidth: 2)
        ).padding()
    }
}

struct ButtonView: View {
    var buttonText: String
    var buttonTextSize: Int = 25
    var body: some View {
        Text(buttonText)
            .font(.system(size: CGFloat(buttonTextSize)))
            .foregroundColor(.white)
            .frame(width: 160)
            .padding()
            .background(
            Image("buttonbg")
                .resizable()
                .scaledToFill()
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 130))
//            .cornerRadius(15)
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(Color.black, lineWidth: 2)
//            )
    }
}

struct Button2View: View {
    var buttonText: String
    var body: some View {
        Text(buttonText)
            .font(.title3)
            .bold()
            .foregroundColor(midNightBlue)
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
            .background(Color.yellow)
            .cornerRadius(20)
            .padding(2)
            .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 5)
            )
    }
}

struct UserDataView: View {
    var dataIconStr: String
    var dataInfo: String
    var data: String
    var body: some View {
        HStack{
            Image(systemName: dataIconStr)
            Text(dataInfo + ": " + data)
            Spacer()
        }.padding(.horizontal)
        .padding(.vertical,2)
    }
}

struct PiecePhoto: View {
    var strokeCol: Int
    var body: some View {
        if strokeCol == 0 {
            Image("cbbg" + String(strokeCol))
            .resizable()
            .frame(width: 43, height: 43)
            .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(red: 146/255, green: 127/255, blue: 105/255), lineWidth: 5))
            .cornerRadius(5)
        } else {
            Image("cbbg" + String(strokeCol))
            .resizable()
            .frame(width: 43, height: 43)
            .cornerRadius(5)
            .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(red: 204/255, green: 182/255, blue: 139/255), lineWidth: 5))
            .cornerRadius(5)
        }
    }
}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { UIApplication.shared.endEditing() }
    var secure: Bool
    var isEmail: Bool
    var isNum: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            if secure {
                SecureField("", text: $text, onCommit: commit)
                    .textFieldStyle(MyTextFieldStyle())
            } else {
                if isEmail {
                    TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                        .textFieldStyle(MyTextFieldStyle())
                        .keyboardType(.emailAddress)
                } else if isNum {
                    TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                        .textFieldStyle(MyTextFieldStyle())
                        .keyboardType(.numberPad)
                } else {
                    TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                        .textFieldStyle(MyTextFieldStyle())
                }
            }
            if text.isEmpty {
                placeholder
                    .font(.system(size: 17))
                    .offset(x: 40)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    var body: some View {
        HStack {
            TextField("輸入房號...", text: $text)
                .foregroundColor(.black)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .padding(10)
                .padding(.vertical, 2)
                .padding(.horizontal, 25)
                .background(Color(red: 1, green: 247/255, blue: 235/255, opacity: 0.5))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .keyboardType(.numberPad)
                .onTapGesture {
                    self.isEditing = true
                }
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                            
                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.black)
                                    .padding(.trailing, 15)
                            }
                        }
                    }
                )
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("取消")
                }.foregroundColor(.black)
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }.ignoresSafeArea(.keyboard, edges: .bottom)
    }
}


