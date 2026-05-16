import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "Core",
    swiftLanguageVersion: .v6,
    targets: [.unitTest, .staticFramework],
    tags: ["module", "core"]
)
