import Foundation

// MARK: - WWDCKeynote

/// An  WWDC Keynote
struct WWDCKeynote: Codable, Hashable, Sendable {
    
    /// The year
    let year: Int
    
    /// The YouTube URL
    let youTubeURL: String
    
}

// MARK: - Identifable

extension WWDCKeynote: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    var id: Int {
        self.year
    }
    
}

// MARK: - Comparable

extension WWDCKeynote: Comparable {
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.year < rhs.year
    }
    
}

// MARK: - CaseIterableCaseIterable

extension WWDCKeynote: CaseIterable {
    
    /// All  WWDC Keynotes
    static let allCases: [WWDCKeynote] = [
        .wwdc2014,
        .wwdc2015,
        .wwdc2016,
        .wwdc2017,
        .wwdc2018,
        .wwdc2019,
        .wwdc2020,
        .wwdc2021,
        .wwdc2022,
        .wwdc2023,
        .wwdc2024
    ]
    
    static let wwdc2014: Self = .init(
        year: 2014,
        youTubeURL: "https://www.youtube.com/watch?v=w87fOAG8fjk"
    )
    
    static let wwdc2015: Self = .init(
        year: 2015,
        youTubeURL: "https://www.youtube.com/watch?v=_p8AsQhaVKI"
    )
    
    static let wwdc2016: Self = .init(
        year: 2016,
        youTubeURL: "https://www.youtube.com/watch?v=n5jXg_NNiCA"
    )
    
    static let wwdc2017: Self = .init(
        year: 2017,
        youTubeURL: "https://www.youtube.com/watch?v=oaqHdULqet0"
    )
    
    static let wwdc2018: Self = .init(
        year: 2018,
        youTubeURL: "https://www.youtube.com/watch?v=UThGcWBIMpU"
    )
    
    static let wwdc2019: Self = .init(
        year: 2019,
        youTubeURL: "https://www.youtube.com/watch?v=psL_5RIBqnY"
    )
    
    static let wwdc2020: Self = .init(
        year: 2020,
        youTubeURL: "https://www.youtube.com/watch?v=GEZhD3J89ZE"
    )
    
    static let wwdc2021: Self = .init(
        year: 2021,
        youTubeURL: "https://www.youtube.com/watch?v=0TD96VTf0Xs"
    )
    
    static let wwdc2022: Self = .init(
        year: 2022,
        youTubeURL: "https://www.youtube.com/watch?v=q5D55G7Ejs8"
    )
    
    static let wwdc2023: Self = .init(
        year: 2023,
        youTubeURL: "https://www.youtube.com/watch?v=GYkq9Rgoj8E"
    )
    
    static let wwdc2024: Self = .init(
        year: 2024,
        youTubeURL: "https://www.youtube.com/watch?v=RXeOiIDNNek"
    )
    
}
