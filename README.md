# Grebe

This repository contains a Swift-Combine gRPC API, a code generator and a CLI to setup and generate everything necessary to use Grebe.
We intend only the CLI for public usage, because it abstracts all neccessary steps in simple command line commands. If you want to use the Swift-Combine gRPC API directly, please see the following [section](#swift-combine-grpc-api).

## Installation
Grebe is currently only available via [Homebrew](https://brew.sh). To install run the following command in your command line:
```bash
brew install grebe
```

## Usage
The recommended way to use Grebe is to first define an API using the [Protocol Buffer](https://developers.google.com/protocol-buffers/) language.

### Setting up Grebe
To use Grebe you need to install the [Protocol Buffer Compiler](https://github.com/protocolbuffers/protobuf), the [Swift Protobuf Code Generator Plugin](https://github.com/apple/swift-protobuf) and [Swift gRPC](https://github.com/grpc/grpc-swift) plugins to generate the necessary support code. To do all this in one step, run the following command in your command line. Make sure to specify your search path.
```bash
grebe setup -e <your search path>
```

### Building the Grebe Swift-Package
After you run the setup command described in the previous step you are ready to build the Swift-Package:
```bash
grebe generate -p <proto file path>
```

This command will do the following:
1. Load the latest version of the Grebe code generator (unless otherwise stated) to generate Swift code which projects the service methods defined in your proto file to simple Swift methods using our library.
2. Invoke the `protoc-gen-swift` and `protoc-gen-swiftgrpc` plugins on your proto file.
3. Bundle all generated code in Swift-Package.

#### Parameters

| Flag                 | Values         | Default          | Description                                      |
| -------------------- | -------------- | ---------------- | ------------------------------------------------ |
| `-p`/`--proto`       | `String`       | ``               | The path of your proto file                      |
| `-d`/`--destination` | `String`       | ``               | The path of the generated Swift Package          |
| `-e`/`--executable`  | `String`       | `/usr/local/bin` | Your search path                                 |
| `-v`/`--version`     | `Double`       | 1.0              | The version number of the Grebe-Generator Plugin |
| `-g`/`--grebe`       | `true`/`false` | `true`           | Wether to generate only Grebe files              |
| `-s`/`--swiftgrpc`   | `true`/`false` | `true`           | Wether to generate only gRPC-Swift files         |

### Using the generated Swift-Package
Just drag and drop the Swift-Package in your project and you are ready to go.

#### Example
Consider the following protobuf definition for a simple echo service. The service defines one unary RPC. You send one message and it echoes the message back to you.
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

## Swift-Combine gRPC API
This library provides a [Swift-Combine](https://developer.apple.com/documentation/combine) integration for [Swift-gRPC](https://github.com/grpc/grpc-swift/tree/nio). It is based on the `nio`-implementation of `Swift-gRPC`. It supports all four gRPC API styles (Unary, Server Streaming, Client Streaming, and Bidirectional Streaming).

### Example
Again consider the following protobuf definition for a simple echo service.
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

Let's set up the client:
```swift
let client = GClient<EchoServiceServiceClient>(target: .hostAndPort("localhost", 62801))
```

To call the service, create a `GUnaryCall` and use it's `execute` method. You provide it with a `EchoRequest` and get back a stream `AnyPublisher<EchoResponse, GRPCStatus` of responses (in this case only one) from the server.

```swift
let call = GUnaryCall(request: EchoRequest.with { $0.message = "hello"}, closure: client.service.echo)
call.execute()
```

## License
Grebe is licensed under

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. Please make sure to update tests as appropriate.
