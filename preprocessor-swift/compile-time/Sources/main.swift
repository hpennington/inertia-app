// import SwiftSyntax
// import SwiftParser
// import Foundation

// func findSwiftFiles(in directory: URL) -> [URL] {
//     var swiftFiles = [URL]()
//     let fileManager = FileManager.default
    
//     if let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) {
//         for case let fileURL as URL in enumerator {
//             let lastPathComponent = fileURL.lastPathComponent
            
//             // Skip directories named "build", "Pods", and any SPM build directories
//             if lastPathComponent == "build" || lastPathComponent == "Pods" || fileURL.pathComponents.contains(where: { $0.hasPrefix("build") && $0 != "build" }) {
//                 enumerator.skipDescendants()
//                 continue
//             }
            
//             // Check if the file has a ".swift" extension
//             if fileURL.pathExtension == "swift" {
//                 swiftFiles.append(fileURL)
//             }
//         }
//     }
//     return swiftFiles
// }

// func appendVibeModifier(of fileURL: URL) throws {
//     let sourceFileContent = try String(contentsOf: fileURL)
//     let sourceFile = Parser.parse(source: sourceFileContent)
    
//     class ViewHierarchyRewriter: SyntaxRewriter {
//         override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
//             guard let binding = node.bindings.first(where: {
//                 $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "body"
//                 // - TODO: Also somehow check that the same body is of some View
//             }) else {
//                 return DeclSyntax(node)
//             }
                        
//             guard let accessorBlock = binding.accessorBlock else {
//                 return DeclSyntax(node)
//             }
            
//             let accessors = accessorBlock.accessors
//             let newAccessors = accessors.with(\.trailingTrivia, Trivia(arrayLiteral: .unexpectedText(".vibeHello()")))
//             let newAccessorBlock = accessorBlock.with(\.accessors, newAccessors)
//             let newBinding = binding.with(\.accessorBlock, newAccessorBlock)
//             let newBindings = PatternBindingListSyntax(arrayLiteral: newBinding)
            
//             return DeclSyntax(node.with(\.bindings, newBindings))
//         }
        
//         func findFunctionCalls(in node: Syntax) -> [FunctionCallExprSyntax] {
//             var stack: [Syntax] = [node]
//             var functionCallExprSyntaxCollection: [FunctionCallExprSyntax] = []
            
//             while !stack.isEmpty {
//                 let currentNode = stack.removeLast()
                
//                 if let functionCallExpr = currentNode.as(FunctionCallExprSyntax.self) {
//                     functionCallExprSyntaxCollection.append(functionCallExpr)
//                 }
                
//                 for child in currentNode.children(viewMode: .sourceAccurate) {
//                     stack.append(child)
//                 }
//             }
            
//             return functionCallExprSyntaxCollection
//         }
//     }

//     let rewriter = ViewHierarchyRewriter()
//     let updatedSource = rewriter.rewrite(sourceFile)
//     print(updatedSource)
//     try updatedSource.description.write(to: fileURL, atomically: true, encoding: .utf8)
// }

// // Entry point
// if CommandLine.arguments.count < 2 {
//     print("Usage: compile-time <path-to-directory>")
//     exit(1)
// }

// let directoryPath = CommandLine.arguments[1]
// let directoryURL = URL(fileURLWithPath: directoryPath)

// let swiftFiles = findSwiftFiles(in: directoryURL)
// for file in swiftFiles {
//     print("Processing file: \(file.path)")
//     do {
//         try appendVibeModifier(of: file)
//     } catch {
//         print("Error parsing file \(file.path): \(error)")
//     }
// }
import SwiftSyntax
import SwiftParser
import Foundation

func findSwiftFiles(in directory: URL) -> [URL] {
    var swiftFiles = [URL]()
    let fileManager = FileManager.default
    
    if let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) {
        for case let fileURL as URL in enumerator {
            let lastPathComponent = fileURL.lastPathComponent
            
            // Skip directories named "build", "Pods", and any SPM build directories
            if lastPathComponent == "build" || lastPathComponent == "Pods" || fileURL.pathComponents.contains(where: { $0.hasPrefix("build") && $0 != "build" }) {
                enumerator.skipDescendants()
                continue
            }
            
            // Check if the file has a ".swift" extension
            if fileURL.pathExtension == "swift" {
                swiftFiles.append(fileURL)
            }
        }
    }
    return swiftFiles
}

func appendVibeModifier(of fileURL: URL) throws {
    var sourceFileContent = try String(contentsOf: fileURL)
    let sourceFile = Parser.parse(source: sourceFileContent)
    
    class ViewHierarchyRewriter: SyntaxRewriter {
        override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
            guard let binding = node.bindings.first(where: {
                $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "body"
                // TODO: Also somehow check that the same body is of some View
            }) else {
                return DeclSyntax(node)
            }
                        
            guard let accessorBlock = binding.accessorBlock else {
                return DeclSyntax(node)
            }
            
            let accessors = accessorBlock.accessors
            let newAccessors = accessors.with(\.trailingTrivia, Trivia(arrayLiteral: .unexpectedText(".vibeHello()")))
            let newAccessorBlock = accessorBlock.with(\.accessors, newAccessors)
            let newBinding = binding.with(\.accessorBlock, newAccessorBlock)
            let newBindings = PatternBindingListSyntax(arrayLiteral: newBinding)
            
            return DeclSyntax(node.with(\.bindings, newBindings))
        }
    }

    let rewriter = ViewHierarchyRewriter()
    let updatedSource = rewriter.rewrite(sourceFile).description
    sourceFileContent = updatedSource
    // If "import Inertia" is not already present, find the insertion point after comments and imports
    if !sourceFileContent.contains("import Inertia") {
        // Split by lines for easier processing
        var lines = sourceFileContent.components(separatedBy: "\n")
        
        // Find the index after the last import statement
        var insertIndex = 0
        for (index, line) in lines.enumerated() {
            if line.starts(with: "import ") {
                insertIndex = index + 1
            } else if !line.trimmingCharacters(in: .whitespaces).hasPrefix("//") && !line.isEmpty {
                break
            }
        }
        
        // Insert "import Inertia" at the correct position
        lines.insert("import Inertia", at: insertIndex)
        sourceFileContent = lines.joined(separator: "\n")
    }
    
    // Save the updated source back to the original file
    try sourceFileContent.write(to: fileURL, atomically: true, encoding: .utf8)
    print("Updated file saved: \(fileURL.path)")
}

// Entry point
if CommandLine.arguments.count < 2 {
    print("Usage: compile-time <path-to-directory>")
    exit(1)
}

let directoryPath = CommandLine.arguments[1]
let directoryURL = URL(fileURLWithPath: directoryPath)

let swiftFiles = findSwiftFiles(in: directoryURL)
for file in swiftFiles {
    print("Processing file: \(file.path)")
    do {
        try appendVibeModifier(of: file)
    } catch {
        print("Error parsing file \(file.path): \(error)")
    }
}
