//
//  SRCSignal.m
//  SocialRecipeCatalog
//
//  Created by Daniel on 15/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import "SRCSignal.h"

@implementation SRCSignal
{
    PMKResolver _subscriberResolver;
    void (^_promiseSubscriber)(PMKPromise *);
}

- (void)resolve:(id)valueOrError
{
    [self sendEvent:valueOrError];
    [self resubscribe];
}

- (void)sendEvent:(id)event
{
    if (_subscriberResolver) {
        PMKResolver resolver = _subscriberResolver;
        _subscriberResolver = nil;
        resolver(event);
    }
}

- (void)resubscribe
{
    if (_promiseSubscriber == nil) return;
    __weak SRCSignal *weakSelf = self;
    PMKPromise *promise = [PMKPromise promiseWithResolver:^(PMKResolver resolver) {
        if (weakSelf == nil) return;
        __strong SRCSignal *strongSelf = weakSelf;
        strongSelf->_subscriberResolver = resolver;
    }];
    _promiseSubscriber(promise);
}

- (void)setOutputPromiseSubscriber:(void (^)(PMKPromise *))promiseSubscriber
{
    _promiseSubscriber = promiseSubscriber;
    [self resubscribe];
}

- (void)pipeToSignal:(SRCSignal *)signal
{
    __weak SRCSignal *weakSignal = signal;
    [self setOutputPromiseSubscriber:^(PMKPromise *promise) {
        promise.then(^(id data) {
            [weakSignal resolve:data];
        })
        .catch(^(NSError *error) {
            [weakSignal resolve:error];
        });
    }];
}

@end
