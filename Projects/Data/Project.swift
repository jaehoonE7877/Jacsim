import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "Data",
    targets: [.unitTest, .dynamicFramework],
    internalDependencies: [
        .domain,
        .externalInterface
    ]
)
