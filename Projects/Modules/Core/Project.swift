import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeFrameworkProject(
    name: "Shared",
    swiftLanguageVersion: .v6,
    internalDependencies: [
        .Modules.thirdPartyLibs
    ],
    tags: ["module", "shared"]
)
