import SwiftUI

struct ShiftTipsSection: View {
    @Binding var cashTips: String
    @Binding var cardTips: String
    @Binding var tipOut: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tips").font(.headline)
                Spacer()
                Image(systemName: "banknote.fill").foregroundStyle(.tint)
            }
            Divider()
            VStack(spacing: 0) {
                input("Cash Tips", icon: "banknote.fill", text: $cashTips)
                Divider().padding(.leading, 42)
                input("Credit Card Tips", icon: "creditcard.fill", text: $cardTips)
                Divider().padding(.leading, 42)
                input("Tip Out", icon: "arrow.up.right.circle.fill", text: $tipOut)
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
    }

    private func input(_ title: String, icon: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.tint)
                .frame(width: 30, height: 30)
            Text(title)
            Spacer()
            TextField("0.00", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 140)
                .accessibilityLabel(title)
        }
        .padding(.vertical, 14)
    }
}
