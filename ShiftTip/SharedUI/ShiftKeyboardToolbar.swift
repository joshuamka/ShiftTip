import SwiftUI
import UIKit

/// Includes nested tip fields, whose decimal keypad has no return key.
private struct ShiftKeyboardToolbar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                    .fontWeight(.semibold)
                    .accessibilityHint("Dismisses the keyboard")
                }
            }
    }
}

extension View {
    func shiftKeyboardToolbar() -> some View {
        modifier(ShiftKeyboardToolbar())
    }
}
