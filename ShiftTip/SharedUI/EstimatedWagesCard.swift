import SwiftUI

struct EstimatedWagesCard: View {
    let amount: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Estimated gross wages").font(.headline)
            Text(amount, format: .currency(code: "USD"))
                .font(.title2.bold())
            Text("Hours × hourly rate, before payroll deductions. Paid separately by paycheck; the actual check may be $0. Not included in tips.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}
