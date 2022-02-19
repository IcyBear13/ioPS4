//
//  Banner.swift
//  Created by Even for ioPS4 
//  19/02/2022
//  

import SwiftUI

struct BannerModifier: ViewModifier {
    
    struct BannerData {
        var title:String
        var detail:String
        var type: BannerType
    }
    
    enum BannerType {
        case Info
        case Warning
        case Success
        case Error
        
        var tintColor: Color {
            switch self {
            case .Info:
                return Color(red: 67/255, green: 154/255, blue: 215/255)
            case .Success:
                return Color.green
            case .Warning:
                return Color.orange
            case .Error:
                return Color.red
            }
        }
        
        var statusImage: Image {
            switch self {
            case .Info:
                return Image(systemName: "info.circle.fill")
            case .Warning:
                return Image(systemName: "exclamationmark.triangle.fill")
            case .Success:
                return Image(systemName: "checkmark.circle.fill")
            case .Error:
                return Image(systemName: "exclamationmark.triangle.fill")
            }
        }
    }
    
    // Members for the Banner
    @Binding var data:BannerData
    @Binding var show:Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                VStack {
                    HStack {
                        data.type.statusImage
                            .font(.system(size: 30))
                            .padding(.trailing, 6)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.title)
                                .bold()
                            Text(data.detail)
                        }
                        Spacer()
                    }
                    .foregroundColor(Color.white)
                    .padding(12)
                    .background(data.type.tintColor)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    Spacer()
                }
                .padding()
                .animation(.easeInOut)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation {
                        self.show = false
                    }
                }
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded({ value in
                    withAnimation {
                        self.show = false
                    }
                }))
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            self.show = false
                        }
                    }
                })
            }
        }
    }

}

extension View {
    func banner(data: Binding<BannerModifier.BannerData>, show: Binding<Bool>) -> some View {
        self.modifier(BannerModifier(data: data, show: show))
    }
}

struct Banner_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello")
        }
    }
}
