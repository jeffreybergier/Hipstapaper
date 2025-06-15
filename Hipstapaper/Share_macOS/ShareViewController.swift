import Cocoa
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: NSViewController {
    
    override func loadView() {
        self.view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let inputItem = extensionContext?.inputItems.first as? NSExtensionItem
        let url = inputItem?.urlValue() ?? inputItem?.plainTextValue()
        
        let sharedContent = url?.absoluteString ?? "No valid content shared."
        let childView = NSHostingController(rootView: ShareExtension(sharedText: sharedContent))

        addChild(childView)
        view.addSubview(childView.view)

        childView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.view.topAnchor.constraint(equalTo: view.topAnchor),
            childView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        NSApp.activate(ignoringOtherApps: true)
    }

    func completeExtensionRequest() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}

private extension NSExtensionItem {
    func urlValue() -> URL? {
        attachments?.compactMap { $0 as? NSItemProvider }
            .first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) })?
            .loadItemAndCast(as: URL.self)
    }

    func plainTextValue() -> URL? {
        attachments?.compactMap { $0 as? NSItemProvider }
            .first(where: { $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) })?
            .loadItemAndCast(as: String.self)
            .flatMap { URL(string: $0) } // attempt to parse as URL if it’s in text form
    }
}

private extension NSItemProvider {
    func loadItemAndCast<T>(as type: T.Type) -> T? {
        var result: T?
        let semaphore = DispatchSemaphore(value: 0)

        loadItem(forTypeIdentifier: registeredTypeIdentifiers.first ?? "", options: nil) { item, _ in
            result = item as? T
            semaphore.signal()
        }

        semaphore.wait()
        return result
    }
}
