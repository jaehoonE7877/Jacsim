import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "Domain",
    swiftLanguageVersion: .v6,
    targets: [.unitTest, .staticFramework],
    internalDependencies: [
        
    ],
    tags: ["module", "domain"]
)
