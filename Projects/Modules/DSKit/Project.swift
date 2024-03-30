import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "DSKit",
    targets: [.staticFramework],
    internalDependencies: [
        .Modules.core
    ],
    hasResources: true
)
