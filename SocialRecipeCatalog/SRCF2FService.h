//
//  F2FService.h
//  SocialRecipeCatalog
//
//  Created by Daniel on 14/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PMKPromise;

@interface SRCF2FService : NSObject

- (PMKPromise *)search:(NSString *)query page:(NSUInteger)page;
- (PMKPromise *)getRecipe:(NSString *)recipeID;

@end
