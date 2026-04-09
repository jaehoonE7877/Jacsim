import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeFrameworkProject(
    name: "Workflows",
    swiftLanguageVersion: .v6,
    internalDependencies: [
        .Modules.shared,
        .domain,
        .ports
    ],
    tags: ["module", "workflows"]
)
