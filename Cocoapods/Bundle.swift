private class BundleFinder {}

extension Foundation.Bundle {
    static var module: Bundle = {
        return Bundle(for: BundleFinder.self)
    }()
}