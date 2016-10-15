//
//  SRCSignal.m
//  SocialRecipeCatalog
//
//  Created by Daniel on 15/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import "SRCSignal.h"
#import <PromiseKit/Promise+Pause.h>

@implementation SRCSignal
{
    PMKResolver _subscriberResolver;
    void (^_promiseSubscriber)(PMKPromise *);
    id _userInfo;
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

- (SRCSignal *)throttleWithTimeout:(NSTimeInterval)timeout
{
    SRCSignal *result = [SRCSignal new];
    __weak SRCSignal *weakSignal = result;
    [self setOutputPromiseSubscriber:^(PMKPromise *promise) {
        promise.then(^(id data) {
            if (weakSignal == nil) return;
            SRCSignal *strongResultSignal = weakSignal;
            NSDate *eventDate = [NSDate date];
            
            // if it's the first event, just send it (and remember the date)
            if (strongResultSignal->_userInfo == nil) {
                strongResultSignal->_userInfo = @[eventDate, [NSDate distantPast]];
                [strongResultSignal resolve:data];
            } else {
                NSArray *userInfo = strongResultSignal->_userInfo;
                NSDate *lastEventDate = userInfo[0];
                NSTimeInterval waitTime = timeout - [eventDate timeIntervalSinceDate:lastEventDate];

                // if enough time passed, we can send it (and remember the date)
                if (waitTime <= 0) {
                    strongResultSignal->_userInfo = @[eventDate, [NSDate distantPast]];
                    [strongResultSignal resolve:data];
                } else {
                    // save the pending event date, and wait
                    strongResultSignal->_userInfo = @[lastEventDate, eventDate];
                    [PMKPromise promiseWithValue:data]
                        .pause(waitTime)
                        .then(^(id sameOldData) {
                            if (weakSignal == nil) return;
                            SRCSignal *strongResultSignal = weakSignal;
                            NSArray *updatedUserInfo = strongResultSignal->_userInfo;
                            NSDate *pendingEventDate = updatedUserInfo[1];
                            
                            // if the current event is still the last one seen after the pause,
                            // we can send it, otherwise it will be just skipped out
                            if ([eventDate isEqual:pendingEventDate]) {
                                strongResultSignal->_userInfo = @[[NSDate date], [NSDate distantPast]];
                                [strongResultSignal resolve:sameOldData];
                            }
                        });
                }
            }
        })
        .catch(^(NSError *error) {
            [weakSignal resolve:error];
        });
    }];
    return result;
}

@end
