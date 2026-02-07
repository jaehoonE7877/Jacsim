import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "Domain",
    targets: [.unitTest, .staticFramework],
    internalDependencies: [
        
    ],
    tags: ["module", "domain"]
)
