//
//  SRCSignal.h
//  SocialRecipeCatalog
//
//  Created by Daniel on 15/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>

@interface SRCSignal : NSObject

- (void)resolve:(id)valueOrError;
- (void)setOutputPromiseSubscriber:(void (^)(PMKPromise *))promiseSubscriber;
- (SRCSignal *)map:(id (^)(id valueOrError))transformer;
- (SRCSignal *)flatMap:(PMKPromise *(^)(id valueOrError))promiseConstructor;
- (SRCSignal *)throttleWithTimeout:(NSTimeInterval)timeout;

@end
