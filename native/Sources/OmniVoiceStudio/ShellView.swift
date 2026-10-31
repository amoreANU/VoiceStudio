import SwiftUI
import WebKit

// Note: avoids SwiftUI property-wrapper macros (@State/@StateObject/etc.),
// which the Command Line Tools toolchain cannot expand. Uses
// ObservableObject + @Published/@ObservedObject instead.

final class ShellModel: ObservableObject {
    @Published var serverURL: URL = ServerURL.current
    @Published var offlineMessage: String?
    @Published var draftURL: String = ServerURL.current.absoluteString

    func reload() {
        serverURL = ServerURL.current
        draftURL = serverURL.absoluteString
        offlineMessage = nil
    }

    func loadSucceeded() {
        offlineMessage = nil
    }

    func loadFailed() {
        if offlineMessage == nil {
            offlineMessage = "Could not load \(serverURL.absoluteString)"
        }
    }

    func saveDraft() {
        guard let url = URL(string: draftURL), url.scheme != nil else { return }
        ServerURL.override = url.absoluteString
        serverURL = url
        offlineMessage = nil
    }
}

/// Native shell around the OmniVoice web app.
/// Loads http://localhost:5173 by default; the address can be changed in the app's
/// offline screen (persisted in UserDefaults under "serverURL").
struct ShellView: View {
    @ObservedObject var model = ShellModel()

    var body: some View {
        Group {
            if let message = model.offlineMessage {
                OfflineView(model: model, message: message)
            } else {
                WebView(url: model.serverURL, onFailure: { model.loadFailed() })
            }
        }
        .navigationTitle("OmniVoice")
#if os(macOS)
        .frame(minWidth: 960, minHeight: 640)
#endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    model.reload()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .keyboardShortcut("r")
            }
        }
    }
}

private struct OfflineView: View {
    @ObservedObject var model: ShellModel
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("OmniVoice is not reachable")
                .font(.title2.bold())
            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 480)
            Text("Start the web app (cd .. DEV_HINTDEV_HINT npm run dev), then retry. Or point the app at another server:")
                .font(.footnote)
                .foregroundStyle(.secondary)
            HStack {
                TextField("Server URL", text: Binding(
                    get: { model.draftURL },
                    set: { model.draftURL = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 420)
                Button("Save") { model.saveDraft() }
                    .keyboardShortcut(.defaultAction)
            }
            Button("Retry") { model.reload() }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

enum ServerURL {
    static let fallback = URL(string: "http://localhost:5173")!

    static var current: URL {
        if let stored = UserDefaults.standard.string(forKey: "serverURL"),
           let url = URL(string: stored), url.scheme != nil {
            return url
        }
        return fallback
    }

    static var override: String? {
        get { UserDefaults.standard.string(forKey: "serverURL") }
        set { UserDefaults.standard.set(newValue, forKey: "serverURL") }
    }
}

struct WebView: View {
    let url: URL
    let onFailure: () -> Void

    var body: some View {
        PlatformWebView(url: url, onFailure: onFailure)
    }
}

#if os(iOS)
struct PlatformWebView: UIViewRepresentable {
    let url: URL
    let onFailure: () -> Void

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.load(URLRequest(url: url))
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onFailure: onFailure) }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onFailure: () -> Void
        init(onFailure: @escaping () -> Void) { self.onFailure = onFailure }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            onFailure()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            onFailure()
        }
    }
}
#else
struct PlatformWebView: NSViewRepresentable {
    let url: URL
    let onFailure: () -> Void

    func makeNSView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view.navigationDelegate = context.coordinator
        view.load(URLRequest(url: url))
        return view
    }

    func updateNSView(_ view: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onFailure: onFailure) }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onFailure: () -> Void
        init(onFailure: @escaping () -> Void) { self.onFailure = onFailure }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            onFailure()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            onFailure()
        }
    }
}
#endif
