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

@interface PCJSONRPC ()

/**
 Subclass can override this selector to implements it's own JSON serialization.
 
 @param object The object to serialize.
 @param error A `NSError` output parameter.
 
 @return The JSON serialized object as `NSData`.
 */
- (NSData *)dataWithJSONObject:(id)object error:(NSError **)error;

/**
 Subclass can override this selector to implements it's own JSON deserialization.
 
 @param data The JSON serialized object as `NSData`.
 @param error A `NSError` output parameter.
 
 @return The deserialized object.
 */
- (id)JSONObjectWithData:(NSData *)data error:(NSError **)error;

/**
 Subclass can override this selector to implements it's own request ID generation.
 
 @param payload The JSON-RPC request payload without an ID.
 @param error A `NSError` output parameter.
 
 @return The generated request ID.
 */
- (NSString *)requestIdForPartialPayload:(NSDictionary *)payload error:(NSError **)error;

/**
 Subclass can override this selector to implements it's own request payload creation.

 @param method The JSON-RPC request method name.
 @param parameters The JSON-RPC request parameters object.
 @param error A `NSError` output parameter.
 
 @return The request payload.
 */
- (NSDictionary *)requestPayloadForMethod:(NSString *)method andParameters:(id)parameters error:(NSError **)error;

/**
 Subclass can override this selector to implements it's own URL request creation.
 
 @param url The service URL.
 @param payloadData The JSON serialized request payload as `NSData`.
 @param error A `NSError` output parameter.
 
 @return The URL request.
 */
- (NSURLRequest *)requestWithURL:(NSURL *)url andPayloadData:(NSData *)payloadData error:(NSError **)error;

/**
 Subclass can override this selector to implements it's own URL request execution.
 
 @param request The URL request.
 @param error A `NSError` output parameter.
 
 @return The JSON serialized response payload as `NSData`.
 */
- (NSData *)responsePayloadDataFromRequest:(NSURLRequest *)request error:(NSError **)error;

/**
 Subclass can override this selector to implements it's own response payload result/error parsing.
 
 @param request The response payload.
 @param error A `NSError` output parameter.
 
 @return The JSON-RPC result.
 */
- (id)resultFromResponsePayload:(NSDictionary *)payload error:(NSError **)error;

@end
