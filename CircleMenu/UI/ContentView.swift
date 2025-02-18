//
//  ContentView.swift
//  CircleMenu
//
//  Created by Thanh Hoang on 17/2/25.
//

import SwiftUI

struct ContentView: View {
    
    //MARK: - Properties
    @State private var path = NavigationPath()
    
    private let colors: [AnyGradient] = [
        Color.red.gradient,
        Color.green.gradient,
        Color.blue.gradient,
        Color.pink.gradient,
        Color.purple.gradient,
        Color.orange.gradient,
        Color.yellow.gradient,
        Color.indigo.gradient,
        Color.mint.gradient,
        Color.teal.gradient
    ]
    
    @State private var menus: [MenuModel] = {
        return [
            MenuModel(icon: "heart.fill", color: .yellow),
            MenuModel(icon: "cloud.fill", color: .red),
            MenuModel(icon: "folder.fill", color: .cyan),
            
            //            MenuModel(icon: "paperplane.fill", color: .blue),
            //            MenuModel(icon: "square.and.arrow.up.fill", color: .green),
            //            MenuModel(icon: "eraser.fill", color: .orange),
            //            MenuModel(icon: "trash.fill", color: .indigo),
            //            MenuModel(icon: "folder.fill", color: .pink),
        ]
    }()
    
    //MARK: - Content
    var body: some View {
        NavigationStack(path: $path) {
            let itemWidth = (screenWidth-60)/2
            let itemHeight = itemWidth * 1.5
            
            ZStack {
                ScrollView(.vertical) {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(spacing: 20),
                            count: 2
                        ),
                        spacing: 20,
                        content: {
                            ForEach(colors, id: \.self) { color in
                                RoundedRectangle(cornerRadius: 20.0)
                                    .fill(color)
                                    .frame(width: itemWidth, height: itemHeight)
                            }
                        })
                    .padding([.leading, .trailing], 20)
                }
                
                CircleView(menus: $menus) { menu in
                    path.append(menu)
                }
                .offset(
                    x: (screenWidth-55)/2 - 20,
                    y: (screenHeight-55)/2-bottomPadding-20
                )
                .navigationDestination(for: MenuModel.self) { menu in
                    ZStack {
                        Rectangle()
                            .fill(menu.color)
                            .ignoresSafeArea()
                        
                        Image(systemName: menu.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.white)
                            .frame(width: 100, height: 100)
                    }
                }
            }
            .tint(.white)
            .font(.system(size: 17.0, weight: .bold, design: .serif))
        }
    }
}

#Preview {
    ContentView()
}
