//
//  Features.swift
//  ProjectDescriptionHelpers
//
//  Created by Seo Jae Hoon on 11/19/23.
//

import  ProjectDescription

let featureAttribute = Template.Attribute.required("name")

let template = Template(
    description: "Feature Template",
    attributes: [featureAttribute, .optional("platform", default: "iOS")],
    items: [
        //Project
        [
            .file(path: "Projects/Features/\(featureAttribute)Feature/Project.swift",
                  templatePath: "Project.stencil")
        ],
        //Test
        [
            .file(path: "Projects/Features/\(featureAttribute)Feature/Tests/Sources/\(featureAttribute)FeatureTests.swift", templatePath: "Tests.stencil"),
        ],
        //Framework
        [
            .file(path: "Projects/Features/\(featureAttribute)Feature/Sources/\(featureAttribute)Feature.swift", templatePath: "Framework.stencil"),
            .string(path: "Projects/Features/\(featureAttribute)Feature/Resources/dummy.txt", contents: "_")
        ],
        //Demo
        [
            .file(path: "Projects/Features/\(featureAttribute)Feature/Demo/Sources/AppDelegate.swift", templatePath: "AppDelegate.stencil"),
            .file(path: "Projects/Features/\(featureAttribute)Feature/Demo/Resources/Assets.xcassets/AppIcon.appiconset/contents.json", templatePath: "AppIcon.stencil"),
            .file(path: "Projects/Features/\(featureAttribute)Feature/Demo/Resources/LaunchScreen.storyboard",
                  templatePath: "LaunchScreen.stencil"),
        ],
        //Interface
        [
            .file(path: "Projects/Features/\(featureAttribute)Feature/Interface/Sources/\(featureAttribute)FeatureInterface.swift",
                  templatePath: "Interface.stencil")
        ]
    ].flatMap { $0 }
)
