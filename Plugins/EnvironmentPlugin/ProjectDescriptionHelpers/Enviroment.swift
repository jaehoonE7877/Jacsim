//
//  Enviroment.swift
//  EnvironmentPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public enum Enviroment {
    public static let workspaceName = "Jacsim"
}

public extension Project {
    enum Enviroment {
        public static let workspaceName = "Jacsim"
        public static let deplymentTarget = DeploymentTarget.iOS(targetVersion: "15.0",
                                                                 devices: [.iphone])
        public static let platform = Platform.iOS
        public static let bundlePrefix = "com.jaehoon.jaksim"
    }
}
