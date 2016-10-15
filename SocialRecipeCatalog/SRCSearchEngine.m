//
//  SRCSearchEngine.m
//  SocialRecipeCatalog
//
//  Created by Daniel on 15/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import "SRCSearchEngine.h"
#import "SRCSignal.h"
#import "SRCF2FService.h"

@implementation SRCSearchEngine
{
    SRCF2FService *_service;
}

@synthesize resultSignal = _resultSignal;

- (instancetype)initWithQuerySignal:(SRCSignal *)querySignal
{
    self = [super init];
    if (self == nil) return nil;
    _service = [SRCF2FService new];
    _resultSignal = [querySignal flatMap:^PMKPromise *(id valueOrError) {
        if ([valueOrError isKindOfClass:[NSError class]]) {
            return [PMKPromise promiseWithValue:valueOrError];
        }
        
        NSString *query = valueOrError;
        if (query.length == 0) {
            return [PMKPromise promiseWithValue:@[]];
        }
        
        return [_service search:query page:0];
    }];
    return self;
}

@end
