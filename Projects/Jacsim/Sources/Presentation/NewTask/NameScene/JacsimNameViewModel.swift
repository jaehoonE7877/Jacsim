//
//  JacsimNameViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Combine
import Foundation

import Core

@MainActor
final class JacsimNameViewModel {

    @Published private(set) var name: String
    @Published private(set) var isNextButtonEnabled: Bool
    @Published private(set) var textCount: String

    init(name: String = "") {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.name = name
        self.isNextButtonEnabled = trimmed.isNotEmpty
        self.textCount = trimmed.count.toString()
    }

    func updateName(_ text: String) {
        name = text
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        textCount = trimmed.count.toString()
        isNextButtonEnabled = trimmed.isNotEmpty
    }

    func makeJacsimDTO() -> UserJacsimDTO? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isNotEmpty else { return nil }
        return UserJacsimDTO(title: trimmed)
    }
}
