# Grebe

This repository is intended to improve and simplify the gRPC development workflow for iOS apps and provides a small wrapper to incorporate Swift Combine in gRPC. The Swift Package contains the following parts: 
- A Swift Combine gRPC wrapper. Read more about it in [this section](#swift-combine-grpc-wrapper).
- A code generator to generate Swift code using the previously stated library.
- A CLI tool to simplify the development workflow. You can import the library without using the CLI tool. Read more about it in [this section](#building-the-grebe-swift-package)

## Installation
You can install the Grebe CLI executable via [Homebrew](https://brew.sh). To install run the following command in your command line:
```bash
brew install apodini/tap/grebe
```
Of course you can simply clone the repository or install it via the [Swift Package Manager](https://swift.org/package-manager/).

## Usage
The recommended way to use Grebe is to first define an API using the [Protocol Buffer](https://developers.google.com/protocol-buffers/) language.

### Setting up Grebe
To use Grebe you need to install the [Protocol Buffer Compiler](https://github.com/protocolbuffers/protobuf), the [Swift Protobuf Code Generator Plugin](https://github.com/apple/swift-protobuf) and [Swift gRPC](https://github.com/grpc/grpc-swift) plugins to generate the necessary support code. To do all this in one step, run the following command in your command line. Make sure to specify your shell path.
```bash
grebe setup -e <your shell path>
```

### Building the Grebe Swift Package
This step generates a Swift Package that contains the Protocol Buffer support code, the gRPC interface code and the Grebe interface code. It hides the complete `gRPC` implementation and exposes only the methods, services and message types defined in your proto file. You can easily intergrate it into your project via drag and drop. It is not part of the main target and therefore offers a clear public interface.

After you run the setup command described in the previous step you are ready to build the Swift Package:

```bash
grebe generate -p <proto file path>
```

This command will do the following:
1. Load the latest version of the Grebe code generator (unless otherwise stated) to generate Swift code which projects the service methods defined in your proto file to simple Swift methods using our library.
2. Invoke the `protoc-gen-swift` and `protoc-gen-swiftgrpc` plugins on your proto file.
3. Bundle all generated code in a Swift Package.

#### Parameters

| Flag                 | Values         | Default          | Description                                      |
| -------------------- | -------------- | ---------------- | ------------------------------------------------ |
| `-p`/`--proto`       | `String`       | ``               | The path of your proto file                      |
| `-d`/`--destination` | `String`       | ``               | The path of the generated Swift Package          |
| `-e`/`--executable`  | `String`       | `/usr/local/bin` | Your shell path                                 |
| `-v`/`--version`     | `Double`       | 1.0              | The version number of the Grebe-Generator Plugin |
| `-g`/`--grebe`       | `true`/`false` | `true`           | Wether to generate only Grebe files              |
| `-s`/`--swiftgrpc`   | `true`/`false` | `true`           | Wether to generate only gRPC-Swift files         |

### Using the generated Swift Package
Drag the package folder  into your Xcode project. Then click the Plus button in the "Link Binary with Libraries" section, locate the package in the modal dialog, select the gray library icon inside the package, and add this one. In all files you would like to use the package import `Grebe_Generated`.

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

## Swift Combine gRPC Wrapper
This library provides a [Swift-Combine](https://developer.apple.com/documentation/combine) wrapper for [Swift-gRPC](https://github.com/grpc/grpc-swift/tree/nio). It is a generic abstraction
layer above the `nio` layer provided by the `Swift-gRPC` implementation. It supports all four gRPC API styles (Unary, Server Streaming, Client Streaming, and Bidirectional Streaming).

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
