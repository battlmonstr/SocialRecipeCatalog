//
//  SRCSearchEngine.m
//  SocialRecipeCatalog
//
//  Created by Daniel on 15/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import "SRCSearchEngine.h"
#import "SRCF2FService.h"
#import "SRCSignal.h"

static const NSTimeInterval kSRCThrottleTimeout = 1;

@implementation SRCSearchEngine
{
    SRCF2FService *_service;
    SRCSignal *_throttledQuerySignal;
}

@synthesize resultSignal = _resultSignal;
@synthesize service = _service;

- (instancetype)initWithQuerySignal:(SRCSignal *)querySignal
{
    self = [super init];
    if (self == nil) return nil;
    _service = [SRCF2FService new];
    _throttledQuerySignal = [querySignal throttleWithTimeout:kSRCThrottleTimeout];
    _resultSignal = [_throttledQuerySignal flatMap:^PMKPromise *(id valueOrError) {
        if ([valueOrError isKindOfClass:[NSError class]]) {
            return [PMKPromise promiseWithValue:valueOrError];
        }
        
        NSString *query = valueOrError;
        if (query.length == 0) {
            SRCF2FServiceSearchResult *result = [SRCF2FServiceSearchResult new];
            result.query = query;
            result.recipes = @[];
            return [PMKPromise promiseWithValue:result];
        }
        
        return [_service search:query page:0];
    }];
    return self;
}

@end
