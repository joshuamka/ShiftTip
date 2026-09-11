import SwiftUI

extension View {
    func storageStatus(message: String?, canReload: Bool, reload: @escaping () -> Void) -> some View {
        safeAreaInset(edge: .top) {
            if let message {
                VStack(alignment: .leading, spacing: 8) {
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .font(.callout)
                    if canReload {
                        Button("Retry Loading", action: reload)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial)
                .accessibilityElement(children: .contain)
            }
        }
    }
}
