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

#import <Foundation/Foundation.h>

extern NSString * const PCJSONRPCErrorDomain;

extern NSInteger const PCJSONRPCErrorCodeHTTPNotOk;

extern NSInteger const PCJSONRPCErrorCodeUnknow;
extern NSInteger const PCJSONRPCErrorCodeJSONRPCServerErrorMin;
extern NSInteger const PCJSONRPCErrorCodeJSONRPCServerErrorMax;
extern NSInteger const PCJSONRPCErrorCodeJSONRPCInvalidRequest;
extern NSInteger const PCJSONRPCErrorCodeJSONRPCMethodNotFound;
extern NSInteger const PCJSONRPCErrorCodeJSONRPCInvalidParams;
extern NSInteger const PCJSONRPCErrorCodeJSONRPCInternalError;
extern NSInteger const PCJSONRPCErrorCodeJSONRPCParseError;

extern NSString * const PCJSONRPCErrorUserInfoDataKey;

/**
 `PCJSONRPC` is a client used to communicate with JSON-RPC 2.0 services.
 */
@interface PCJSONRPC : NSObject

/**
 The service URL.
 */
@property (strong, readonly) NSURL *url;

/**
 Trace communications. Defaults to `NO`.
 */
@property BOOL trace;

/**
 Initializes a JSON-RPC client.
 
 @param url The service URL.
 
 @return An initialized `PCJSONRPC` instance.
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 Create a JSON-RPC proxy given a `Protocol`.
 
 The proxy object intercepts all the `Protocol` methods.
 
 When a message is sent to one of the `Protocol` selector:
 
 It uses the first part of the `NSInvocation` selector as the JSON-RPC method name.
 
 If the `NSInvocation` contains at least one parameter,
 the first parameter is used as the JSON-RPC method parameters.
 
 If the `NSInvocation` contains at least two parameters,
 the second parameter is used as an error output (`NSError **`).
 
 If the `NSInvocation` contains more than two parameters,
 the third and the subsequents are ignored.
 
 @param protocol The `Protocol` that contains the methods to be proxied.
 
 @return The JSON-RPC proxy.
 */
- (id)proxyForProtocol:(Protocol *)protocol;

/**
 Synchronously invoke a remote JSON-RPC method with parameters and optional error output.
 
 @param method The remote method to invoke.
 @param parameters The parameters `NSArray` (for positional parameters) or `NSDictionary` (for named parameters) or `nil`.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 
 @return The JSON-RPC method result value.
 */
- (id)invokeMethod:(NSString *)method withParameters:(id)parameters error:(NSError **)error;

@end
