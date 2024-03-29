//
//  Module.swift
//  ProjectDescriptionHelpers
//
//  Created by Seo Jae Hoon on 11/17/23.
//

import  ProjectDescription

let moduleAttribute = Template.Attribute.required("name")

let moduleTemplate = Template(
    description: "Module Template",
    attributes: [moduleAttribute, .optional("platform", default: "iOS")],
    items: [
        //Project
        [
            .file(path: "Projects/\(moduleAttribute)/Project.swift",
                  templatePath: "Project.stencil")
        ],
        //Test
        [
            .file(path: "Projects/\(moduleAttribute)/Tests/Sources/\(moduleAttribute)Tests.swift", templatePath: "Tests.stencil"),
        ],
        //Framework
        [
            .file(path: "Projects/\(moduleAttribute)/Sources/\(moduleAttribute).swift", templatePath: "Framework.stencil"),
            .string(path: "Projects/\(moduleAttribute)/Resources/dummy.txt", contents: "_")
        ]
    ].flatMap { $0 }
)
