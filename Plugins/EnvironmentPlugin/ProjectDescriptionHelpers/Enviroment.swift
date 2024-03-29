//
//  Enviroment.swift
//  EnvironmentPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public enum Environment {
    public static let workspaceName = "Jacsim"
}

public extension Project {
    enum Environment {
        public static let workspaceName: String = "Jacsim"
        public static let deploymentTarget = DeploymentTargets.iOS("15.0")
        public static let platform = Destinations.iOS
        public static let bundlePrefix = "com.jaehoon.jaksim"
        public static let appVersion: String = "1.5.0"
    }
}
