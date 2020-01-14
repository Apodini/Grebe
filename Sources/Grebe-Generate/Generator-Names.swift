
import Foundation
import SwiftProtobuf
import SwiftProtobufPluginLibrary

internal func nameForPackageService(_ file: FileDescriptor,
                                    _ service: ServiceDescriptor) -> String {
    if !file.package.isEmpty {
        return SwiftProtobufNamer().typePrefix(forFile: file) + service.name
    } else {
        return service.name
    }
}

internal func nameForPackageServiceMethod(_ file: FileDescriptor,
                                          _ service: ServiceDescriptor,
                                          _ method: MethodDescriptor) -> String {
    return nameForPackageService(file, service) + method.name
}

extension Generator {
    internal var serviceClassName: String {
        return nameForPackageService(file, service) + "Service"
    }

    internal var providerName: String {
        return nameForPackageService(file, service) + "Provider"
    }

    internal var callName: String {
        return nameForPackageServiceMethod(file, service, method) + "Call"
    }

    internal var methodFunctionName: String {
        let name = method.name
        return name.prefix(1).lowercased() + name.dropFirst()
    }

    internal var methodInputName: String {
        return protobufNamer.fullName(message: method.inputType)
    }

    internal var methodOutputName: String {
        return protobufNamer.fullName(message: method.outputType)
    }

    internal var servicePath: String {
        if !file.package.isEmpty {
            return file.package + "." + service.name
        } else {
            return service.name
        }
    }

    internal var methodPath: String {
        return "\"/" + servicePath + "/" + method.name + "\""
    }
}
