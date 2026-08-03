import SwiftUI
import WebKit

struct LocalWebView: UIViewRepresentable {
    let filename: String

    func makeUIView(context: Context) -> WKWebView { WKWebView() }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "html") else { return }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}

struct HelpMenuView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                NavigationLink("Privacy Policy") {
                    LocalWebView(filename: "PrivacyPolicy")
                        .navigationTitle("Privacy Policy")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("Terms of Service") {
                    LocalWebView(filename: "TOS")
                        .navigationTitle("Terms of Service")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("Security") {
                    LocalWebView(filename: "security")
                        .navigationTitle("Security")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("How It Works") {
                    LocalWebView(filename: "get")
                        .navigationTitle("How It Works")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .navigationTitle("Policies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(.redmedAccent)
                }
            }
        }
    }
}

#Preview {
    HelpMenuView()
}
