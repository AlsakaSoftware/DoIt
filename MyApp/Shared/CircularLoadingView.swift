import SwiftUI

struct CircularProgressView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3)
                .opacity(0.1)
                .foregroundColor(.designSystem(.primaryControlBackground))

            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .foregroundColor(.designSystem(.primaryControlBackground))
                .rotationEffect(Angle(degrees: rotation))
                .onAppear {
                    startSpinning()
                }
        }
        .frame(width: 40, height: 40)
    }

    private func startSpinning() {
        withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
}

#Preview {
    CircularProgressView()
}
