
import Foundation
import SwiftProtobuf
import SwiftProtobufPluginLibrary

extension Generator {
    internal var serviceClassName: String {
        return service.name + "Service"
    }
}
