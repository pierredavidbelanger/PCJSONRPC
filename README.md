# PCJSONRPC

[![CI Status](http://img.shields.io/travis/pierredavidbelanger/PCJSONRPC.svg?style=flat)](https://travis-ci.org/pierredavidbelanger/PCJSONRPC)
[![Version](https://img.shields.io/cocoapods/v/PCJSONRPC.svg?style=flat)](http://cocoadocs.org/docsets/PCJSONRPC)
[![License](https://img.shields.io/cocoapods/l/PCJSONRPC.svg?style=flat)](http://cocoadocs.org/docsets/PCJSONRPC)
[![Platform](https://img.shields.io/cocoapods/p/PCJSONRPC.svg?style=flat)](http://cocoadocs.org/docsets/PCJSONRPC)

Simple yet extensible synchronous JSON-RPC client.

It's simple. Maybe so simple that it probably is not feature complete or even spec compliant. But it works for real world projects.

It's extensible because [easily subclassable](https://github.com/pierredavidbelanger/PCJSONRPC/blob/master/Pod/Classes/PCJSONRPCSubclass.h). Redefine one or all of the methods used in the process.

It's synchronous because sometime we know what we want and we know what we do. And we certainly know not to invoke a remote method on the main thread, right?

## Tests

To run the - far from complete - tests, clone the repo, and run `pod install` from the Example directory before opening `PCJSONRPC.xcworkspace`.

Or, in one easy step, in a terminal:

```bash
$ pod try PCJSONRPC
```

## Installation

PCJSONRPC is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "PCJSONRPC"

## Usage

```objc
#import <PCJSONRPC.h>
```

Create a JSON-RPC client

```objc
NSURL *url = [NSURL URLWithString:@"http://example.com/json-rpc"];
PCJSONRPC *jsonRPC = [[PCJSONRPC alloc] initWithURL:url];
```

Invoke a method

```objc
NSError *error;
NSString *hello = [jsonRPC invokeMethod:@"echo"
                         withParameters:@[@"World!"]
                                  error:&error];
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
