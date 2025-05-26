private class BundleFinder {}

extension Foundation.Bundle {
    static let module: Bundle = {
        return Bundle(for: BundleFinder.self)
    }()
}