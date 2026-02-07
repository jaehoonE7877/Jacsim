import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "Core",
    targets: [.unitTest, .staticFramework],
    internalDependencies: [
        .Modules.thirdPartyLibs
    ],
    tags: ["module", "core"]
)
