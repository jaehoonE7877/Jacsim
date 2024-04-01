import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin
import EnvironmentPlugin

let project = Project.makeModule(
    name: Environment.workspaceName,
    targets: [.app],
    packages: [Package.remote(url: "https://github.com/QMUI/LookinServer.git",
                              requirement: .upToNextMajor(from: "1.1.7"))],
    internalDependencies: [
        .Modules.dsKit
    ]
)
