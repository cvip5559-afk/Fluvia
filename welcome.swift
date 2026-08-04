//
//  welcome.swift
//  fluvia
//
//  Created by Aleen Aldosari on 20/02/1448 AH.
//
import SwiftUI

struct WelcomeView: View {

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            ZStack {
                // الخلفية
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: screenWidth,
                        height: screenHeight
                    )
                    .clipped()
                    .ignoresSafeArea()

                // العنوان
                Text("Welcome to")
                    .font(
                        .system(
                            size: 38,
                            weight: .regular,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.black.opacity(0.88))
                    .position(
                        x: screenWidth / 2,
                        y: screenHeight * 0.29
                    )

                // اللوجو
                Image("logo1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth * 0.78)
                    .position(
                        x: screenWidth / 2,
                        y: screenHeight * 0.43
                    )

                // الجملة تحت اللوجو مباشرة
                Text("Every voice deserves to be heard")
                    .font(
                        .system(
                            size: 16,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.black.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: screenWidth * 0.85)
                    .position(
                        x: screenWidth / 2,
                        y: screenHeight * 0.515
                    )

                // الزر
                Button {
                    print("Get Started button tapped")
                } label: {
                    Text("Get Started")
                        .font(
                            .system(
                                size: 24,
                                weight: .regular,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.black.opacity(0.86))
                        .frame(maxWidth: .infinity)
                        .frame(height: 68)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.96))
                        )
                        .shadow(
                            color: .black.opacity(0.22),
                            radius: 6,
                            x: 0,
                            y: 5
                        )
                }
                .buttonStyle(.plain)
                .frame(width: screenWidth * 0.82)
                .position(
                    x: screenWidth / 2,
                    y: screenHeight * 0.87
                )
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    WelcomeView()
}
