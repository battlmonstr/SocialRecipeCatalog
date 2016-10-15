//
//  SRCF2FServiceTests.m
//  SocialRecipeCatalog
//
//  Created by Daniel on 15/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SRCF2FService.h"
#import "SRCF2FRecipe.h"

@interface SRCF2FServiceTests : XCTestCase

@end

@interface SRCF2FService (SRCF2FServiceTests)
+ (SRCF2FRecipe *)decodeRecipeFromDictionary:(NSDictionary *)dict;
@end


@implementation SRCF2FServiceTests

- (void)testAllRecipeFieldsAreDecoded {
    NSDictionary *dict = @{
        @"source_url": @"http://mysite.com/recipe123",
        @"image_url": @"http://mysite.com/recipe123.png",
        @"recipe_id": @"123",
        @"publisher_url": @"http://mysite.com",
        @"publisher": @"mysite",
        @"f2f_url": @"http://food2fork.com/view/123",
        @"title": @"recipe123",
        @"social_rank": @(77.7),
        @"ingredients": @[ @"sugar", @"wheat", @"milk" ],
    };
    SRCF2FRecipe *recipe = [SRCF2FService decodeRecipeFromDictionary:dict];
    XCTAssertNotNil(recipe);
    XCTAssertNotNil(recipe.source_url);
    XCTAssertNotNil(recipe.image_url);
    XCTAssertNotNil(recipe.recipe_id);
    XCTAssertNotNil(recipe.publisher_url);
    XCTAssertNotNil(recipe.publisher);
    XCTAssertNotNil(recipe.f2f_url);
    XCTAssertNotNil(recipe.title);
    XCTAssertNotNil(recipe.title);
    XCTAssertGreaterThan(recipe.social_rank, 1);
    XCTAssertNotNil(recipe.ingredients);
    XCTAssertEqual(recipe.ingredients.count, [dict[@"ingredients"] count]);
}

@end
