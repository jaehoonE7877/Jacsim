import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeFrameworkProject(
    name: "Ports",
    swiftLanguageVersion: .v6,
    internalDependencies: [
        .domain
    ],
    tags: ["module", "ports"]
)
