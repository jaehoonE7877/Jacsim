import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeFrameworkProject(
    name: "Adapters",
    swiftLanguageVersion: .v6,
    internalDependencies: [
        .domain,
        .ports
    ],
    tags: ["module", "adapters"]
)
