import SwiftUI

struct ShareExtension: View {
    let sharedText: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Shared Content")
                .font(.title2)
                .bold()

            Text(sharedText)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Button("Done") {
                NSApplication.shared.keyWindow?.close()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}
