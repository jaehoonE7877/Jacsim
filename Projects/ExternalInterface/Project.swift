import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "ExternalInterface",
    targets: [.unitTest, .dynamicFramework],
    internalDependencies: [
        .domain
    ]
)
