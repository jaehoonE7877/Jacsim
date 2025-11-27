//
//  JacsimNameViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

import Core

final class JacsimNameViewModel {

    private(set) var name: String

    init(name: String = "") {
        self.name = name
    }

    func updateName(_ text: String) -> (isValid: Bool, countText: String) {
        name = text
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed.isNotEmpty, trimmed.count.toString())
    }

    func makeJacsimDTO() -> UserJacsimDTO? {
        let title = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard title.isNotEmpty else { return nil }
        return UserJacsimDTO(title: title)
    }
}
