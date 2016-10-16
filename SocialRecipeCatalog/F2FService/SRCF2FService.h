//
//  F2FService.h
//  SocialRecipeCatalog
//
//  Created by Daniel on 14/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PMKPromise;
@class SRCF2FRecipe;


@interface SRCF2FServiceSearchResult : NSObject

@property NSString *query;
@property NSArray<SRCF2FRecipe *> *recipes;

@end


@interface SRCF2FService : NSObject

- (PMKPromise *)search:(NSString *)query page:(NSUInteger)page;
- (PMKPromise *)getRecipe:(NSString *)recipeID;
- (void)cancelPendingRequests;

@end
