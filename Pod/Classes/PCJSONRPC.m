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

#import "PCJSONRPC.h"
#import "PCJSONRPCSubclass.h"

#import <objc/runtime.h>

#define IS_NULL(OBJ) (OBJ == nil || OBJ == [NSNull null])

NSString * const PCJSONRPCErrorDomain = @"PCJSONRPCErrorDomain";

NSInteger const PCJSONRPCErrorCodeUnknow = -100;
NSInteger const PCJSONRPCErrorCodeNotOk = -200;

NSString * const PCJSONRPCErrorDataKey = @"PCJSONRPCErrorDataKey";

@interface PCJSONRPCProxy : NSProxy

- (instancetype)initWithJSONRPC:(PCJSONRPC *)jsonRPC andProtocol:(Protocol *)protocol;

@end

@interface PCJSONRPC ()

@property (strong) NSURL *url;

@end

@implementation PCJSONRPC

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        self.url = url;
        self.trace = NO;
    }
    return self;
}

- (id)proxyForProtocol:(Protocol *)protocol {
    return [[PCJSONRPCProxy alloc] initWithJSONRPC:self andProtocol:protocol];
}

- (id)invokeMethod:(NSString *)method withParameters:(id)parameters error:(NSError **)error {
    NSError *localError = nil;
    
    NSDictionary *requestPayload = [self requestPayloadForMethod:method andParameters:parameters error:&localError];
    if (localError) {
        if (error) *error = localError;
        return nil;
    }
    
    NSData *requestPayloadData = [self dataWithJSONObject:requestPayload error:&localError];
    if (localError) {
        if (error) *error = localError;
        return nil;
    }
    
    NSURLRequest *request = [self requestWithURL:self.url andPayloadData:requestPayloadData error:&localError];
    if (localError) {
        if (error) *error = localError;
        return nil;
    }
    
    NSData *responsePayloadData = [self responsePayloadDataFromRequest:request error:&localError];
    if (localError) {
        if (error) *error = localError;
        return nil;
    }
    
    NSDictionary *responsePayload = [self JSONObjectWithData:responsePayloadData error:&localError];
    if (localError) {
        if (error) *error = localError;
        return nil;
    }
    
    id result = [self resultFromResponsePayload:responsePayload error:&localError];
    if (localError) {
        if (error) *error = localError;
        return nil;
    }
    
    if (error) *error = nil;
    
    return result;
}

- (NSData *)dataWithJSONObject:(id)object error:(NSError **)error {
    NSError *localError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:(NSJSONWritingOptions)0 error:&localError];
    if (localError) {
        if (error) *error = localError;
        return nil;
    }
    if (error) *error = nil;
    return data;
}

- (id)JSONObjectWithData:(NSData *)data error:(NSError **)error {
    NSError *localError = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&localError];
    if (localError) {
        if (error) *error = localError;
        return nil;
    }
    if (error) *error = nil;
    return object;
}

- (NSString *)requestIdForPartialPayload:(NSDictionary *)payload error:(NSError **)error {
    NSString *requestId =  [[NSUUID UUID] UUIDString];
    if (error) *error = nil;
    return requestId;
}

- (NSDictionary *)requestPayloadForMethod:(NSString *)method andParameters:(id)parameters error:(NSError **)error {
    NSError *localError = nil;
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithCapacity:4];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"method"] = method ? method : @"";
    payload[@"params"] = !IS_NULL(parameters) ? parameters : @[];
    payload[@"id"] = [self requestIdForPartialPayload:payload error:&localError];
    if (localError) {
        if (error) *error = localError;
        return nil;
    }
    if (error) *error = nil;
    return payload;
}

- (NSURLRequest *)requestWithURL:(NSURL *)url andPayloadData:(NSData *)payloadData error:(NSError **)error {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = payloadData;
    if (error) *error = nil;
    return request;
}

- (NSData *)responsePayloadDataFromRequest:(NSURLRequest *)request error:(NSError **)error {
    NSError *localError = nil;
    if (self.trace) {
        NSLog(@"JSONRPC REQUEST: %@", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
    }
    NSHTTPURLResponse *response = nil;
    NSData *payloadData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&localError];
    if (localError) {
        if (error) *error = localError;
        return nil;
    }
    if (response.statusCode != 200) {
        if (error) *error = [NSError errorWithDomain:PCJSONRPCErrorDomain
                                                code:PCJSONRPCErrorCodeNotOk
                                            userInfo:@{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]}];
        return nil;
    }
    if (self.trace) {
        NSLog(@"JSONRPC RESPONSE: %@", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[NSJSONSerialization JSONObjectWithData:payloadData options:0 error:nil] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
    }
    if (error) *error = nil;
    return payloadData;
}

- (id)resultFromResponsePayload:(NSDictionary *)payload error:(NSError **)error {
    NSError *localError = nil;
    id payloadError = payload[@"error"];
    if (!IS_NULL(payloadError)) {
        NSInteger code = PCJSONRPCErrorCodeUnknow;
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        if ([payloadError isKindOfClass:[NSDictionary class]]) {
            if (!IS_NULL(payloadError[@"code"]))
                code = [payloadError[@"code"] integerValue];
            if (!IS_NULL(payloadError[@"message"]))
                userInfo[NSLocalizedDescriptionKey] = [payloadError[@"message"] description];
            else
                userInfo[NSLocalizedDescriptionKey] = @"Unknow error";
            if (!IS_NULL(payloadError[@"data"]))
                userInfo[PCJSONRPCErrorDataKey] = payloadError[@"data"];
        } else {
            userInfo[NSLocalizedDescriptionKey] = @"Unknow error";
            userInfo[PCJSONRPCErrorDataKey] = payloadError;
        }
        localError = [NSError errorWithDomain:PCJSONRPCErrorDomain code:code userInfo:userInfo];
    }
    if (localError) {
        if (error) *error = localError;
        return nil;
    }
    id payloadResult = payload[@"result"];
    if (error) *error = nil;
    return !IS_NULL(payloadResult) ? payloadResult : nil;
}

@end

@interface PCJSONRPCProxy ()

@property (strong) PCJSONRPC *jsonRPC;
@property (strong) Protocol *protocol;

@end

@implementation PCJSONRPCProxy

- (instancetype)initWithJSONRPC:(PCJSONRPC *)jsonRPC andProtocol:(Protocol *)protocol {
    self.jsonRPC = jsonRPC;
    self.protocol = protocol;
    return self;
}

- (BOOL)respondsToSelector:(SEL)sel {
    return [self methodSignatureForSelector:sel] != nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    struct objc_method_description methodDescription = protocol_getMethodDescription(self.protocol, sel, YES, YES);
    if (!methodDescription.name) return nil;
    return [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSError *localError = nil;
    
    NSString *method = [[NSStringFromSelector(invocation.selector) componentsSeparatedByString:@":"] firstObject];
    
    __unsafe_unretained id parameters = nil;
    if (invocation.methodSignature.numberOfArguments > 2)
        [invocation getArgument:&parameters atIndex:2];
    
    NSError *__autoreleasing *error = nil;
    if (invocation.methodSignature.numberOfArguments > 3)
        [invocation getArgument:&error atIndex:3];

    id __autoreleasing result = [self.jsonRPC invokeMethod:method
                                            withParameters:(parameters ? parameters : @[])
                                                     error:&localError];
    if (localError) {
        if (error) *error = localError;
        return;
    } else {
        if (error) *error = nil;
        if (result) [invocation setReturnValue:&result];
    }
}

@end
