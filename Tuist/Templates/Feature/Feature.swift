import ProjectDescription

let featureAttribute = Template.Attribute.required("name")

let template = Template(
    description: "Jacsim Presentation Feature Template",
    attributes: [featureAttribute],
    items: [
        [
            .file(
                path: "Projects/Jacsim/Sources/Presentation/\(featureAttribute)/\(featureAttribute)Feature.swift",
                templatePath: "Framework.stencil"
            )
        ],
        [
            .file(
                path: "Projects/Jacsim/Sources/Presentation/\(featureAttribute)/\(featureAttribute)View.swift",
                templatePath: "View.stencil"
            )
        ],
        [
            .file(
                path: "Projects/Jacsim/Tests/Sources/Presentation/\(featureAttribute)FeatureTests.swift",
                templatePath: "Tests.stencil"
            )
        ]
    ].flatMap { $0 }
)
