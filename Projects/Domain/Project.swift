import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeFrameworkProject(
    name: "Domain",
    swiftLanguageVersion: .v6,
    internalDependencies: [
    ],
    tags: ["module", "domain"]
)
