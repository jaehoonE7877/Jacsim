import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "ExternalInterface",
    targets: [.unitTest, .staticFramework],
    internalDependencies: [
        .domain
    ],
    tags: ["module", "external-interface"]
)
