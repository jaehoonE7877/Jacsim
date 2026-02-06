import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin
import EnvironmentPlugin

let project = Project.makeModule(
    name: Environment.workspaceName,
    targets: [.app],
    internalDependencies: [
        .Modules.dsKit,
        .domain,
        .externalInterface,
        .data
    ]
)
