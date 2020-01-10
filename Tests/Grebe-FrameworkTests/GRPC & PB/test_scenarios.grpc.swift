//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: test_scenarios.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Foundation
import GRPC
import NIO
import NIOHTTP1
import SwiftProtobuf


/// Usage: instantiate UnaryMockServiceClient, then call methods of this protocol to make API calls.
internal protocol UnaryMockService {
  func ok(_ request: EchoRequest, callOptions: CallOptions?) -> UnaryCall<EchoRequest, EchoResponse>
}

internal final class UnaryMockServiceClient: GRPCClient, UnaryMockService {
  internal let connection: ClientConnection
  internal var defaultCallOptions: CallOptions

  /// Creates a client for the UnaryMock service.
  ///
  /// - Parameters:
  ///   - connection: `ClientConnection` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  internal init(connection: ClientConnection, defaultCallOptions: CallOptions = CallOptions()) {
    self.connection = connection
    self.defaultCallOptions = defaultCallOptions
  }

  /// Asynchronous unary call to Ok.
  ///
  /// - Parameters:
  ///   - request: Request to send to Ok.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func ok(_ request: EchoRequest, callOptions: CallOptions? = nil) -> UnaryCall<EchoRequest, EchoResponse> {
    return self.makeUnaryCall(path: "/UnaryMock/Ok",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

}

/// Usage: instantiate ServerStreamingMockServiceClient, then call methods of this protocol to make API calls.
internal protocol ServerStreamingMockService {
  func ok(_ request: EchoRequest, callOptions: CallOptions?, handler: @escaping (EchoResponse) -> Void) -> ServerStreamingCall<EchoRequest, EchoResponse>
}

internal final class ServerStreamingMockServiceClient: GRPCClient, ServerStreamingMockService {
  internal let connection: ClientConnection
  internal var defaultCallOptions: CallOptions

  /// Creates a client for the ServerStreamingMock service.
  ///
  /// - Parameters:
  ///   - connection: `ClientConnection` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  internal init(connection: ClientConnection, defaultCallOptions: CallOptions = CallOptions()) {
    self.connection = connection
    self.defaultCallOptions = defaultCallOptions
  }

  /// Asynchronous server-streaming call to Ok.
  ///
  /// - Parameters:
  ///   - request: Request to send to Ok.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  internal func ok(_ request: EchoRequest, callOptions: CallOptions? = nil, handler: @escaping (EchoResponse) -> Void) -> ServerStreamingCall<EchoRequest, EchoResponse> {
    return self.makeServerStreamingCall(path: "/ServerStreamingMock/Ok",
                                        request: request,
                                        callOptions: callOptions ?? self.defaultCallOptions,
                                        handler: handler)
  }

}

/// Usage: instantiate ClientStreamingMockServiceClient, then call methods of this protocol to make API calls.
internal protocol ClientStreamingMockService {
  func ok(callOptions: CallOptions?) -> ClientStreamingCall<EchoRequest, EchoResponse>
}

internal final class ClientStreamingMockServiceClient: GRPCClient, ClientStreamingMockService {
  internal let connection: ClientConnection
  internal var defaultCallOptions: CallOptions

  /// Creates a client for the ClientStreamingMock service.
  ///
  /// - Parameters:
  ///   - connection: `ClientConnection` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  internal init(connection: ClientConnection, defaultCallOptions: CallOptions = CallOptions()) {
    self.connection = connection
    self.defaultCallOptions = defaultCallOptions
  }

  /// Asynchronous client-streaming call to Ok.
  ///
  /// Callers should use the `send` method on the returned object to send messages
  /// to the server. The caller should send an `.end` after the final message has been sent.
  ///
  /// - Parameters:
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `ClientStreamingCall` with futures for the metadata, status and response.
  internal func ok(callOptions: CallOptions? = nil) -> ClientStreamingCall<EchoRequest, EchoResponse> {
    return self.makeClientStreamingCall(path: "/ClientStreamingMock/Ok",
                                        callOptions: callOptions ?? self.defaultCallOptions)
  }

}

/// Usage: instantiate BidirectionalStreamingMockServiceClient, then call methods of this protocol to make API calls.
internal protocol BidirectionalStreamingMockService {
  func ok(callOptions: CallOptions?, handler: @escaping (EchoResponse) -> Void) -> BidirectionalStreamingCall<EchoRequest, EchoResponse>
}

internal final class BidirectionalStreamingMockServiceClient: GRPCClient, BidirectionalStreamingMockService {
  internal let connection: ClientConnection
  internal var defaultCallOptions: CallOptions

  /// Creates a client for the BidirectionalStreamingMock service.
  ///
  /// - Parameters:
  ///   - connection: `ClientConnection` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  internal init(connection: ClientConnection, defaultCallOptions: CallOptions = CallOptions()) {
    self.connection = connection
    self.defaultCallOptions = defaultCallOptions
  }

  /// Asynchronous bidirectional-streaming call to Ok.
  ///
  /// Callers should use the `send` method on the returned object to send messages
  /// to the server. The caller should send an `.end` after the final message has been sent.
  ///
  /// - Parameters:
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ClientStreamingCall` with futures for the metadata and status.
  internal func ok(callOptions: CallOptions? = nil, handler: @escaping (EchoResponse) -> Void) -> BidirectionalStreamingCall<EchoRequest, EchoResponse> {
    return self.makeBidirectionalStreamingCall(path: "/BidirectionalStreamingMock/Ok",
                                               callOptions: callOptions ?? self.defaultCallOptions,
                                               handler: handler)
  }

}

/// To build a server, implement a class that conforms to this protocol.
internal protocol UnaryMockProvider: CallHandlerProvider {
  func ok(request: EchoRequest, context: StatusOnlyCallContext) -> EventLoopFuture<EchoResponse>
}

extension UnaryMockProvider {
  internal var serviceName: String { return "UnaryMock" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handleMethod(_ methodName: String, callHandlerContext: CallHandlerContext) -> GRPCCallHandler? {
    switch methodName {
    case "Ok":
      return UnaryCallHandler(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.ok(request: request, context: context)
        }
      }

    default: return nil
    }
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol ServerStreamingMockProvider: CallHandlerProvider {
  func ok(request: EchoRequest, context: StreamingResponseCallContext<EchoResponse>) -> EventLoopFuture<GRPCStatus>
}

extension ServerStreamingMockProvider {
  internal var serviceName: String { return "ServerStreamingMock" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handleMethod(_ methodName: String, callHandlerContext: CallHandlerContext) -> GRPCCallHandler? {
    switch methodName {
    case "Ok":
      return ServerStreamingCallHandler(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.ok(request: request, context: context)
        }
      }

    default: return nil
    }
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol ClientStreamingMockProvider: CallHandlerProvider {
  func ok(context: UnaryResponseCallContext<EchoResponse>) -> EventLoopFuture<(StreamEvent<EchoRequest>) -> Void>
}

extension ClientStreamingMockProvider {
  internal var serviceName: String { return "ClientStreamingMock" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handleMethod(_ methodName: String, callHandlerContext: CallHandlerContext) -> GRPCCallHandler? {
    switch methodName {
    case "Ok":
      return ClientStreamingCallHandler(callHandlerContext: callHandlerContext) { context in
        return self.ok(context: context)
      }

    default: return nil
    }
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol BidirectionalStreamingMockProvider: CallHandlerProvider {
  func ok(context: StreamingResponseCallContext<EchoResponse>) -> EventLoopFuture<(StreamEvent<EchoRequest>) -> Void>
}

extension BidirectionalStreamingMockProvider {
  internal var serviceName: String { return "BidirectionalStreamingMock" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handleMethod(_ methodName: String, callHandlerContext: CallHandlerContext) -> GRPCCallHandler? {
    switch methodName {
    case "Ok":
      return BidirectionalStreamingCallHandler(callHandlerContext: callHandlerContext) { context in
        return self.ok(context: context)
      }

    default: return nil
    }
  }
}

