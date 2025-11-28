//
//  File.swift
//  StoryPlugin
//
//  Created by 曾政桦 on 2025/11/28.
//

import PackagePlugin
import Foundation

@main
struct StoryPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        // 查找目标中的 zip 文件
        let sourceFiles = target.sourceModule?.sourceFiles
        guard let zipFile = sourceFiles?.first(where: { $0.url.pathExtension == "zip" }) else {
            throw StoryPluginError.noZipFileFound
        }
        
        // 确定输出目录
        let outputDir = context.pluginWorkDirectoryURL.appending(component: "StoriesOutput")
        
        // 在插件中直接执行解压操作
        try extractZipFile(at: zipFile.url, to: outputDir)
        
        // 返回输出目录，让 SwiftPM 知道这个目录是构建产物
        return [
            .prebuildCommand(
                displayName: "Extract Stories ZIP for visionOS",
                executable: context.package.directoryURL.appendingPathComponent("Plugins/StoryPlugin/dummy.sh"),
                arguments: [],
                outputFilesDirectory: outputDir
            )
        ]
    }
    
    private func extractZipFile(at zipPath: URL, to outputDir: URL) throws {
        let fileManager = FileManager.default
        let targetURL = outputDir
        
        // 检查 ZIP 文件是否存在
        guard fileManager.fileExists(atPath: zipPath.path(percentEncoded: false)) else {
            throw StoryPluginError.zipFileNotFound(zipPath.path(percentEncoded: false))
        }
        
        // 创建目标目录
        try fileManager.createDirectory(at: targetURL, withIntermediateDirectories: true)
        
        // 使用 Process 执行 unzip 命令
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-o", "-q", zipPath.path(percentEncoded: false), "-d", outputDir.path(percentEncoded: false)]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw StoryPluginError.unzipFailed(exitCode: process.terminationStatus, error: errorString)
        }
        
        print("✅ Successfully extracted stories from \(zipPath.lastPathComponent) to App Bundle")
    }
}

enum StoryPluginError: Error, CustomStringConvertible {
    case noZipFileFound
    case zipFileNotFound(String)
    case unzipFailed(exitCode: Int32, error: String)
    
    var description: String {
        switch self {
        case .noZipFileFound:
            return "No zip file found in target resources. Add a .zip file to your resources to include stories."
        case .zipFileNotFound(let path):
            return "ZIP file not found at path: \(path)"
        case .unzipFailed(let exitCode, let error):
            return "Unzip failed with exit code \(exitCode): \(error)"
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension StoryPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        // 在 Xcode 项目中查找 zip 文件
        let sourceFiles = target.inputFiles
        guard let zipFile = sourceFiles.first(where: { $0.url.pathExtension == "zip" }) else {
            print("ℹ️ No zip file found in target resources. If you have stories to include, add a .zip file to your resources.")
            return []
        }
        
        // 输出到插件工作目录
        let outputDir = context.pluginWorkDirectoryURL.appending(component: "StoriesOutput")
        
        // 在插件中直接执行解压操作
        try extractZipFile(at: zipFile.url, to: outputDir)
        
        return [
            .prebuildCommand(
                displayName: "Extract Stories ZIP for visionOS App",
                executable: context.xcodeProject.directoryURL.appending(component: "Plugins/StoryPlugin/dummy.sh"),
                arguments: [],
                outputFilesDirectory: outputDir
            )
        ]
    }
}
#endif
