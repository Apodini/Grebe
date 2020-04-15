//
//  ReadmeConent.wift
//
//
//  Created by Tim Mewe on 24.01.20.
//

import Foundation

internal struct Readme: IWritableFile {
    let name: String = "/README.md"

    let content: String = """
    ### Using this Swift Package
    Drag the package folder  into your Xcode project. Then click the Plus button in the
    "Link Binary with Libraries" section, locate the package in the modal dialog, select the gray
    library icon inside the package, and add this one. In all files you would like to use the
    package import `Grebe_Generated`.

    #### Example
    Consider the following protobuf definition for a simple echo service. The service defines
    one unary RPC. You send one message and it echoes the message back to you.
    ```proto
    syntax = "proto3";

    service EchoService {
      rpc echo (EchoRequest) returns (EchoResponse);
    }

    message EchoRequest {
      string message = 1;
    }

    message EchoResponse {
      string message = 1;
    }
    ```

    The code generator will create following Swift file:
    ```swift
    extension EchoServiceService: GRPCClientInitializable {
      func echo(
        request: EchoRequest,
        callOptions: CallOptions? = defaultCallOptions
      ) -> AnyPublisher<EchoResponse, GRPCStatus> {
        GUnaryCall(request: request, callOptions: callOptions, closure: echo).execute()
      }
    }
    ```
    Now just call the generated method:
    ```swift
    echo(request: EchoRequest.with { $0.message = "hello"})
    ```
    """
}
