//
//  SocialRecipeCatalogUITests.m
//  SocialRecipeCatalogUITests
//
//  Created by Daniel on 14/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SRCSocialRecipeCatalogUITests : XCTestCase

@end

@implementation SRCSocialRecipeCatalogUITests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGoThroughAllScreens
{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *masterNavigationBar = app.navigationBars[@"Master"];
    XCTAssert(masterNavigationBar.exists);
    
    XCUIElement *textField = [masterNavigationBar childrenMatchingType:XCUIElementTypeTextField].element;
    XCTAssert(textField.exists);
    XCTAssert(textField.isHittable);
    [textField tap];
    [textField typeText:@"asd"];
    
    XCUIElementQuery *tablesQuery = app.tables;
    XCUIElement *recipeRow = tablesQuery.staticTexts[@"Penne a la Betsy"];
    XCTAssert(recipeRow.exists);
    [recipeRow tap];
    
    XCUIElement *ingredientRow = tablesQuery.staticTexts[@"1 pound Shrimp"];
    XCTAssert(ingredientRow.exists);
    XCTAssert(ingredientRow.isHittable);
    [ingredientRow tap];

    XCUIElement *ingredientAlert = app.alerts[@"Ingredient"];
    XCTAssert(ingredientAlert.exists);
    XCUIElement *ingredientAlertButton = ingredientAlert.collectionViews.buttons[@"OK"];
    XCTAssert(ingredientAlertButton.exists);
    [ingredientAlertButton tap];
}

@end
