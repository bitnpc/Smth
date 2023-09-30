//
//  ProfileView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/30.
//

import SwiftUI

struct ProfileView: View {
    
    let account: Account
    
    var body: some View {
        List {
            Text("头像")
            Section {
                HStack {
                    Text("昵称")
                    Spacer()
                    Text(account.nick).foregroundColor(.gray)
                }
                HStack {
                    Text("性别")
                    Spacer()
                    Text(account.gender == 1 ? "男": "女").foregroundColor(.gray)
                }
                HStack {
                    Text("生日")
                    Spacer()
                    Text(account.birthday ?? "2000-01-01" ).foregroundColor(.gray)
                }
            }
        }.navigationTitle("修改资料")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(account: Account.defaultAccount)
    }
}
