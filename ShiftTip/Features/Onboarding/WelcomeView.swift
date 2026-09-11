//
//  WelcomeView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/9/26.
//

import SwiftUI

struct WelcomeView: View {

    @AppStorage("hasSeenWelcome")
    private var hasSeenWelcome = false

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    var body: some View {

        ZStack {

            LinearGradient(
                colors: [
                    Color.black,
                    Color(
                        red: 0.16,
                        green: 0.01,
                        blue: 0.07
                    ),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(
                    accentColor.opacity(0.18)
                )
                .frame(
                    width: 330,
                    height: 330
                )
                .blur(radius: 90)
                .offset(
                    x: -100,
                    y: -220
                )

            Circle()
                .fill(
                    accentColor.opacity(0.12)
                )
                .frame(
                    width: 300,
                    height: 300
                )
                .blur(radius: 90)
                .offset(
                    x: 130,
                    y: 300
                )

            VStack(spacing: 30) {

                Spacer()

                logo

                VStack(spacing: 10) {

                    HStack(spacing: 0) {

                        Text("Shift")
                            .foregroundStyle(.white)

                        Text("Tip")
                            .foregroundStyle(
                                accentColor
                            )
                    }
                    .font(
                        .system(
                            size: 44,
                            weight: .heavy,
                            design: .rounded
                        )
                    )

                    Text(
                        "Track Shifts. See Your Tips.\nReach Your Goals."
                    )
                    .font(.title3)
                    .foregroundStyle(
                        .white.opacity(0.70)
                    )
                    .multilineTextAlignment(
                        .center
                    )
                    .lineSpacing(5)
                }

                Spacer()

                VStack(spacing: 18) {

                    Button {

                        hasSeenWelcome = true

                    } label: {

                        HStack {

                            Text("Get Started")
                                .fontWeight(.bold)

                            Spacer()

                            Image(
                                systemName:
                                    "arrow.right"
                            )
                            .fontWeight(.bold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 22)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 20,
                                style: .continuous
                            )
                            .fill(accentColor)
                        )
                    }
                    .buttonStyle(.plain)

                    Text(
                        "Your shifts. Your tips. Your progress."
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .white.opacity(0.45)
                    )
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 25)
        }
    }

    private var logo: some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: 30,
                style: .continuous
            )
            .fill(
                LinearGradient(
                    colors: [
                        Color(
                            white: 0.12
                        ),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(
                width: 145,
                height: 145
            )
            .overlay {

                RoundedRectangle(
                    cornerRadius: 30,
                    style: .continuous
                )
                .stroke(
                    accentColor,
                    lineWidth: 4
                )
            }
            .shadow(
                color:
                    accentColor.opacity(0.35),
                radius: 25
            )

            Image(
                systemName:
                    "dollarsign"
            )
            .font(
                .system(
                    size: 75,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                accentColor
            )
        }
    }
}

#Preview {
    WelcomeView()
}
