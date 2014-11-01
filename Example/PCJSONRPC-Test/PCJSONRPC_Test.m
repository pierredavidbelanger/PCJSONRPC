// PCJSONRPC
//
// Copyright (c) 2014 Pierre-David Bélanger <pierredavidbelanger@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <XCTest/XCTest.h>

#import <PCJSONRPC.h>
#import <PCJSONRPCSubclass.h>

@interface MyPCJSONRPC : PCJSONRPC

@end

@implementation MyPCJSONRPC

- (NSData *)responsePayloadDataFromRequest:(NSURLRequest *)request error:(NSError **)error {
    id payload = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:error];
    id result = [payload[@"params"] count] ? payload[@"params"][0] : [NSNull null];
    return [NSJSONSerialization dataWithJSONObject:@{@"result": result} options:0 error:error];
}

@end

@protocol EchoService
- (id)echo;
- (id)echo:(id)params;
- (id)echo:(id)params error:(NSError **)error;
@end

@interface PCJSONRPC_Test : XCTestCase

@end

@implementation PCJSONRPC_Test

- (void)testProxy {
    
    NSURL *url = [NSURL URLWithString:@"http://example.com/json-rpc"];
    PCJSONRPC *jsonRPC = [[MyPCJSONRPC alloc] initWithURL:url];
    XCTAssertNotNil(jsonRPC);
    
    NSError *error;
    NSString *hello = [jsonRPC invokeMethod:@"echo"
                             withParameters:@[@"World!"]
                                      error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(hello, @"World!");
    
    id<EchoService> service =
        [jsonRPC proxyForProtocol:@protocol(EchoService)];
    XCTAssertNotNil(service);
    
    hello = [service echo];
    XCTAssertNil(hello);
    
    hello = [service echo:@[@"World!"]];
    XCTAssertEqualObjects(hello, @"World!");
    
    hello = [service echo:@[@"World!"] error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(hello, @"World!");
}

@end
