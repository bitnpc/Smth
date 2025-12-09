//
//  ProfileDetail.swift
//  Smth
//
//  个人资料详情视图，展示用户详细信息
//  Created by tony
//

import SwiftUI

struct ProfileDetail: View {
    
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
