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

- (SRCSignal *)map:(id (^)(id valueOrError))transformer
{
    SRCSignal *result = [SRCSignal new];
    __weak SRCSignal *weakSignal = result;
    [self setOutputPromiseSubscriber:^(PMKPromise *promise) {
        promise.then(^(id data) {
            [weakSignal resolve:transformer(data)];
        })
        .catch(^(NSError *error) {
            [weakSignal resolve:transformer(error)];
        });
    }];
    return result;
}

- (SRCSignal *)flatMap:(PMKPromise *(^)(id valueOrError))promiseConstructor
{
    SRCSignal *result = [SRCSignal new];
    __weak SRCSignal *weakSignal = result;
    [self setOutputPromiseSubscriber:^(PMKPromise *promise) {
        void (^transformAndAwait)(id) = ^(id valueOrError) {
            PMKPromise *subPromise = promiseConstructor(valueOrError);
            subPromise.then(^(id subValue) {
                [weakSignal resolve:subValue];
            })
            .catch(^(NSError *subError) {
                [weakSignal resolve:subError];
            });
        };
        promise.then(transformAndAwait).catch(transformAndAwait);
    }];
    return result;
}

@end
