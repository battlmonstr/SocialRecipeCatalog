//
//  SRCF2FTestURLProtocol.m
//  SocialRecipeCatalog
//
//  Created by Daniel on 15/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import "SRCF2FTestURLProtocol.h"

@implementation SRCF2FTestURLProtocol

+ (NSString *)scheme
{
    return @"f2f-test";
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return [request.URL.scheme isEqualToString:[self scheme]];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSString *responseName = [self.request.URL.path hasSuffix:@"/search"]
        ? @"test_canned_search_response"
        : @"test_canned_recipe_response";
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:responseName ofType:@"json"]];
    NSAssert(data, @"Test response data not found.");
    NSDictionary<NSString *, NSString *> *headers = @{
        @"Content-Type": @"application/json",
        @"Content-Length": [@(data.length) description],
    };
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
        statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:headers];

    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
}

@end
