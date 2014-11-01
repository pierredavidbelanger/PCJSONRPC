# PCJSONRPC

[![CI Status](http://img.shields.io/travis/pierredavidbelanger/PCJSONRPC.svg?style=flat)](https://travis-ci.org/pierredavidbelanger/PCJSONRPC)
[![Version](https://img.shields.io/cocoapods/v/PCJSONRPC.svg?style=flat)](http://cocoadocs.org/docsets/PCJSONRPC)
[![License](https://img.shields.io/cocoapods/l/PCJSONRPC.svg?style=flat)](http://cocoadocs.org/docsets/PCJSONRPC)
[![Platform](https://img.shields.io/cocoapods/p/PCJSONRPC.svg?style=flat)](http://cocoadocs.org/docsets/PCJSONRPC)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

PCJSONRPC is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "PCJSONRPC"

## Usage

Create a JSON-RPC client

```objc
NSURL *url = [NSURL URLWithString:@"http://example.com/json-rpc"];
PCJSONRPC *jsonRPC = [[PCJSONRPC alloc] initWithURL:url];
```

Invoke a method

```objc
NSError *error;
NSString *hello = [jsonRPC invokeMethod:@"echo"
                         withParameters:@[@"World!"] error:&error];
```

Define a protocol

```objc
@protocol EchoService
- (id)echo:(id)params error:(NSError **)error;
@end
```

Create a proxy

```objc
id<EchoService> service =
    [jsonRPC proxyForProtocol:@protocol(EchoService)];
```

Invoke a method

```objc
hello = [service echo:@[@"World!"] error:&error];
```

## Author

Pierre-David Bélanger, pierredavidbelanger@gmail.com

## License

PCJSONRPC is available under the MIT license. See the LICENSE file for more info.
