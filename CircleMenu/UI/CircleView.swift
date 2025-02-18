//
//  CircleView.swift
//  CircleMenu
//
//  Created by Thanh Hoang on 17/2/25.
//

import SwiftUI

struct CircleView: View {
    
    //MARK: - Properties
    var buttonHeight: CGFloat = 55.0 //Chiều cao nút
    var distance: CGFloat = 120.0 //Khoảng cách từ nút Plus (offset)
    
    var startAngle: Double = 0.0 //Góc bắt đầu
    var endAngle: Double = 120.0 //Góc kết thúc
    
    var duration: Double = 0.33 //Thời gian hoạt ảnh
    
    @Binding var menus: [MenuModel]
    
    var completion: ((MenuModel) -> ())
    
    //Circular: Vòng tròn ngoài cùng
    //Xoay hình vuông đến góc tương ứng khi nhấn nút
    @State private var cirAngle: Double = 0.0
    
    //Mặc định, ẩn hình vuông có Stroke đi, sau khi nhấn nút thì hiển thị
    @State private var cirOpacity: Double = 0.0
    
    //Stroke
    //Hoạt ảnh, vẽ Stroke đi từ 0 -> cirStrokeTo
    @State private var cirStrokeTo: CGFloat = 0.0
    
    //Hoạt ảnh, màu Stroke đi từ 0 -> 1
    @State private var cirStrokeColor: Color = .clear
    @State private var cirStrokeColorOpacity: CGFloat = 0.0
    
    //Hoạt ảnh, tạo độ nảy cho Stroke
    @State private var cirStrokeScale: CGFloat = 1.0
    
    //Hoạt ảnh, độ mờ cho Stroke từ 0 -> 1
    @State private var cirStrokeOpacity: CGFloat = 1.0
    
    //Plus Button
    @State private var plusDegrees: Double = 0.0
    @State private var plusOpacity: Double = 1.0
    @State private var plusScale = false
    
    //Không thể nhấn nút Plus liên tục 2 lần
    @State private var isBounceAnimating = false
    
    //Khoảng cách (offset) của nút
    @State private var setDistance: Double = 0.0
    
    //MARK: - Content
    var body: some View {
        //Bộ chứa tất cả các nút và vòng tròn Stroke
        Rectangle()
            .fill(.clear)
            .frame(
                width: distance*2+buttonHeight,
                height: distance*2+buttonHeight
            )
            .overlay {
                ZStack {
                    //Nút Plus
                    CreatePlusButtonView()
                    
                    //Các nút con
                    ForEach(0..<menus.count, id: \.self) { index in
                        let menu = menus[index]
                        CreateButtonView(menu)
                        
                        /*
                         - Khi Stroke và Nút hoạt ảnh
                         - Giữ lại 1 vòng tròn màu tương ứng với nút
                         - Vì khi nút di chuyển, sẽ để lại khoảng trống,
                         do Stroke ban đầu có opacity == 0
                         */
                        if cirStrokeColor != .clear {
                            RoundedRectangle(cornerRadius: buttonHeight/2)
                                .fill(cirStrokeColor)
                                .frame(width: buttonHeight, height: buttonHeight)
                                .offset(x: -setDistance)
                                .rotationEffect(.degrees(cirAngle))
                        }
                    }
                    
                    //Stroke
                    CreateCircularView()
                }
            }
            .onAppear {
                updateMenus()
            }
    }
}

//MARK: - Plus Button View

extension CircleView {
    
    @ViewBuilder
    private func CreatePlusButtonView() -> some View {
        Button {
            guard !isBounceAnimating else {
                return
            }
            isBounceAnimating = true
            
            plusDidTap()
            
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: buttonHeight, height: buttonHeight)
                .tint(.white)
                .foregroundStyle(.black)
                .opacity(plusOpacity)
                .clipShape(.rect(cornerRadius: buttonHeight/2))
        }
        .zIndex(5.0)
        .rotationEffect(.degrees(plusDegrees))
        .scaleEffect(plusScale ? 0.9 : 1.0)
    }
    
    fileprivate func plusDidTap() {
        plusScale.toggle()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            plusDegrees = plusDegrees == 45 ? 0 : 45
            plusOpacity = plusDegrees == 45 ? 0.4 : 1.0
            
            plusScale.toggle()
            
            setDistance = plusDegrees == 45 ? (distance <= 80 ? 80 : distance) : 0.0
            
        } completion: {
            isBounceAnimating = false
        }
    }
    
    fileprivate func updateMenus() {
        let step = getArcStep()
        
        for i in 0..<menus.count {
            let angle: Double = startAngle + Double(i) * step
            
            menus[i].id = i
            menus[i].angle = angle
        }
    }
    
    fileprivate func getArcStep() -> Double {
        var arcLength = endAngle - startAngle
        var stepCount = menus.count
        
        if arcLength < endAngle {
            stepCount -= 1
            
        } else if arcLength > endAngle {
            arcLength = endAngle
        }
        
        return arcLength / Double(stepCount)
    }
}

//MARK: - Button View

extension CircleView {
    
    @ViewBuilder
    private func CreateButtonView(_ menu: MenuModel) -> some View {
        RoundedRectangle(cornerRadius: buttonHeight/2)
            .fill(.clear)
            .frame(width: buttonHeight, height: buttonHeight)
            .overlay {
                Button {
                    guard let index = menus.firstIndex(where: {
                        $0.id == menu.id
                        
                    }) else {
                        return
                    }
                    
                    cirAngle = menu.angle
                    cirOpacity = 1.0
                    cirStrokeColor = menu.color
                    
                    withAnimation(.easeInOut(duration: duration)) {
                        menus[index].angle = menu.angle + 360
                        menus[index].zIndex = 2
                        
                        cirStrokeTo = 1.0
                        cirStrokeColorOpacity = 1.0
                        
                    } completion: {
                        menus[index].angle = menu.angle
                        menus[index].zIndex = 1
                        
                        withAnimation(.easeOut, completionCriteria: .removed) {
                            cirStrokeScale = 1.2
                            cirStrokeOpacity = 0.0
                            
                        } completion: {
                            completion(menu)
                            
                            cirStrokeScale = 1.0
                            
                            cirStrokeTo = 0.0
                            cirStrokeColorOpacity = 0.0
                            
                            cirAngle = 0.0
                            cirOpacity = 0.0
                            cirStrokeColor = .clear
                            
                            cirStrokeOpacity = 1.0
                            
                            plusDidTap()
                        }
                    }
                    
                } label: {
                    Image(systemName: menu.icon)
                        .frame(width: buttonHeight, height: buttonHeight)
                        .tint(.white)
                        .background(menu.color)
                        .clipShape(.rect(cornerRadius: buttonHeight/2))
                }
                .background(.clear)
                .rotationEffect(.degrees(-menu.angle))
            }
            .zIndex(menu.zIndex)
            .background(.clear)
            .offset(x: -setDistance)
            .rotationEffect(.degrees(menu.angle))
            .scaleEffect(setDistance == 0 ? 0.0 : 1.0)
            .opacity(setDistance == 0 ? 0.0 : 1.0)
            .id(menu.id)
    }
}

//MARK: - Circular View

extension CircleView {
    
    @ViewBuilder
    private func CreateCircularView() -> some View {
        Rectangle()
            .fill(.clear)
            .zIndex(1.0)
            .frame(
                width: (setDistance*2)+buttonHeight,
                height: (setDistance*2)+buttonHeight
            )
            .overlay {
                Circle()
                    .trim(from: 0.0, to: cirStrokeTo)
                    .stroke(
                        cirStrokeColor.opacity(cirStrokeColorOpacity),
                        style:
                            StrokeStyle(
                                lineWidth: buttonHeight,
                                lineCap: .round,
                                lineJoin: .round
                            )
                    )
                    .scaleEffect(x: cirStrokeScale, y: cirStrokeScale)
                    .opacity(cirStrokeOpacity)
                    .frame(
                        width: setDistance*2,
                        height: setDistance*2
                    )
            }
            .rotationEffect(.degrees(-180+cirAngle))
            .opacity(cirOpacity)
    }
}
