//
//  ContentView.swift
//  VibeDemo
//
//  Created by Hayden Pennington on 8/9/24.
//

import SwiftUI
import Inertia

struct BarView : View {
    let value: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.accentColor)
            .frame(width: 16, height: value * 100).inertiaEditable("FDBAC660-968D-46BA-AE17-B13427C47930")
    }
}

struct BarChart: View {
    var body: some View {
        HStack(alignment: .bottom) {
            BarView(value: 0.5)
            BarView(value: 0.75)
            BarView(value: 0.34)
            BarView(value: 0.10)
            BarView(value: 0.12)
            BarView(value: 0.11)
            BarView(value: 0.09)
            BarView(value: 0.89)
            BarView(value: 0.87)
            BarView(value: 0.71)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8).inertiaEditable("8788C6A2-B4AB-4791-B95B-8ACA15DD0786")
    }
}

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    CircleImage()
                    Spacer()
                    Text("iPhony")
                        .font(.largeTitle)
                }
                .padding()
                
                .padding(.horizontal).inertiaEditable("BCEC0509-8614-4D19-971F-4FDC214FCE8C")
                Spacer(minLength: 40).inertiaEditable("653A2C62-FB73-4EFD-A047-C4CB2F7238A2")
                ZStack {
                    Circle()
                        .stroke(Color.black.opacity(0.5))
                        .frame(width: 64, height: 64).inertiaEditable("C032F1B8-9927-45BA-B87F-A457137BF355")
                    Rectangle()
                        .fill(Color.black.opacity(0.75))
                        .frame(width: 2, height: 64)
                        .rotationEffect(Angle(degrees: 30)).inertiaEditable("C0C04443-1F75-4CA5-9148-31299D203ABF")
                }.inertiaEditable("03E4057A-B6E4-426E-ACA1-A4583198F7D7")
                
                Spacer(minLength: 40).inertiaEditable("FDA3975F-C12B-4E4D-A936-35274482A831")
                
                BarChart().inertiaEditable("32CB3AB5-87B1-4899-BDC6-F3B715A17FD3")
                Spacer(minLength: 40).inertiaEditable("F9B3FA98-FCCA-4136-A065-6A1E7B657395")
                Divider()
                    .padding(.horizontal).inertiaEditable("D31CE03C-98B4-49E8-8BB6-2BACFFFB752F")
                
                Text("App")
                    .font(.largeTitle)
                    .fontWeight(.light).inertiaEditable("49A7ADCB-06CF-4E35-8855-6370B0346341")
                
                Image("landing_image_1")
                    .resizable()
                    .aspectRatio(contentMode: .fit).inertiaEditable("B227038D-E54D-4504-8806-94133AA756A9")
                Spacer(minLength: 40).inertiaEditable("EBEFBE01-10A1-43BD-AF15-E71A2585DEB1")
                Button {
                    
                } label: {
                    Text("Sign up")
                        .frame(width: 212, height: 48)
                        .background(Color.black.opacity(0.9))
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain).inertiaEditable("4A71BA5D-1E3D-4694-A5F8-646E4168FB89")
            }.inertiaEditable("7AA9D95E-3C43-42B2-8784-8825E8379C3D")
        }.inertiaEditable("1E9376F4-8A67-48B0-9F9B-71ACA3BD2FB1")
    }
}

#Preview {
    ContentView()
}
