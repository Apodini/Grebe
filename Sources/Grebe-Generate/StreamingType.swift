import SwiftProtobufPluginLibrary

internal enum StreamingType {
    case unary
    case clientStreaming
    case serverStreaming
    case bidirectionalStreaming
}

internal func streamingType(_ method: MethodDescriptor) -> StreamingType {
    if method.proto.clientStreaming {
        if method.proto.serverStreaming {
            return .bidirectionalStreaming
        } else {
            return .clientStreaming
        }
    } else {
        if method.proto.serverStreaming {
            return .serverStreaming
        } else {
            return .unary
        }
    }
}
