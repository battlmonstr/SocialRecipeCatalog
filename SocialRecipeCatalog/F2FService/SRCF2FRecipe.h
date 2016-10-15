//
//  SRCF2FRecipe.h
//  SocialRecipeCatalog
//
//  Created by Daniel on 14/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRCF2FRecipe : NSObject

@property NSURL *source_url;
@property NSURL *image_url;
@property NSString *recipe_id;
@property NSURL *publisher_url;
@property NSString *publisher;
@property NSURL *f2f_url;
@property double social_rank;
@property NSString *title;
@property NSArray<NSString *> *ingredients;

@end
