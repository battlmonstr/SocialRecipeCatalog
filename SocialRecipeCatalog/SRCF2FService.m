//
//  F2FService.m
//  SocialRecipeCatalog
//
//  Created by Daniel on 14/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import "SRCF2FService.h"
#import <PromiseKit/Promise.h>
#import "SRCF2FRecipe.h"
#import "SRCF2FTestURLProtocol.h"

static NSString * const kSRCBaseURLString = @"http://food2fork.com/api/";
static NSString * const kSRCAPIKey = @"77c80ca9368e24336a7185a9e569e599";


@interface SRCF2FService ()

@property (readonly) NSURLSession *urlSession;
@property (readonly) NSString *baseURLScheme;

@end


@implementation SRCF2FService

@synthesize urlSession = _urlSession;
@synthesize baseURLScheme = _baseURLScheme;

- (instancetype)init
{
    self = [super init];
    if (self == nil) return nil;

    _baseURLScheme = [NSURL URLWithString:kSRCBaseURLString].scheme;
    Class protocolClass = NULL;

    BOOL isTestMode = YES;
    if (isTestMode) {
        _baseURLScheme = [SRCF2FTestURLProtocol scheme];
        protocolClass = [SRCF2FTestURLProtocol class];
    }
    
    _urlSession = [SRCF2FService createURLSessionWithProtocol:protocolClass];
    return self;
}

+ (NSURLSession *)createURLSessionWithProtocol:(Class)protocolClass
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (protocolClass) {
        config.protocolClasses = @[ protocolClass ];
    }
    return [NSURLSession sessionWithConfiguration:config];
}

+ (id)decodeJSONResponse:(NSURLResponse *)response withData:(NSData *)data error:(NSError **)error
{
    NSAssert(![NSThread isMainThread], @"Invalid thread for network data processing.");
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = [httpResponse statusCode];
        if ((statusCode < 200) || (statusCode >= 300)) {
            NSDictionary *info = @{
                NSLocalizedDescriptionKey: @"The server returned a bad HTTP response code",
                NSURLErrorFailingURLStringErrorKey: response.URL.absoluteString,
                NSURLErrorFailingURLErrorKey: response.URL
            };
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:info];
            return nil;
        }
    }
    
    NSError *err = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:PMKJSONDeserializationOptions error:&err];
    if (err) {
        id userInfo = err.userInfo.mutableCopy;
        long long length = [response expectedContentLength];
        id bytes = length <= 0 ? @"" : [NSString stringWithFormat:@"%lld bytes", length];
        id fmt = @"The server claimed a%@ JSON response, but decoding failed with: %@";
        userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:fmt, bytes, userInfo[NSLocalizedDescriptionKey]];
        *error = [NSError errorWithDomain:err.domain code:err.code userInfo:userInfo];
        return nil;
    }
    
    return jsonObject;
}

+ (NSError *)parsingError:(NSString *)errorMessage
{
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Parsing error: %@", errorMessage],
    };
    return [NSError errorWithDomain:@"SRCF2FService" code:1 userInfo:userInfo];
}

+ (SRCF2FRecipe *)decodeRecipeFromDictionary:(NSDictionary *)dict
{
    SRCF2FRecipe *recipe = [SRCF2FRecipe new];
    recipe.source_url = [NSURL URLWithString:dict[@"source_url"]];
    recipe.image_url = [NSURL URLWithString:dict[@"image_url"]];
    recipe.recipe_id = dict[@"recipe_id"];
    recipe.publisher_url = [NSURL URLWithString:dict[@"publisher_url"]];
    recipe.publisher = dict[@"publisher"];
    recipe.f2f_url = [NSURL URLWithString:dict[@"f2f_url"]];
    recipe.title = dict[@"title"];

    id socialRankJsonValue = dict[@"social_rank"];
    if ([socialRankJsonValue isKindOfClass:[NSNumber class]]) {
        NSNumber *socialRankNum = (NSNumber *)socialRankJsonValue;
        recipe.social_rank = [socialRankNum doubleValue];
    }
    
    id ingredientsJsonValue = dict[@"ingredients"];
    if ([ingredientsJsonValue isKindOfClass:[NSArray class]]) {
        recipe.ingredients = ingredientsJsonValue;
    }
    
    return recipe;
}

+ (NSArray<SRCF2FRecipe *> *)decodeRecipeListFromJSONObject:(id)jsonObject error:(NSError **)error
{
    NSAssert(![NSThread isMainThread], @"Invalid thread for network data processing.");

    if (![jsonObject isKindOfClass:[NSDictionary class]]) {
        *error = [self parsingError:@"RecipeList has an invalid top-level object."];
        return nil;
    }
    NSDictionary *jsonDict = (NSDictionary *)jsonObject;
    
    id jsonRecipes = jsonDict[@"recipes"];
    if (![jsonRecipes isKindOfClass:[NSArray class]]) {
        *error = [self parsingError:@"RecipeList['recipes'] is not an array."];
        return nil;
    }
    NSArray *jsonRecipeArray = (NSArray *)jsonRecipes;
    
    NSMutableArray<SRCF2FRecipe *> *recipes = [NSMutableArray new];
    for (id jsonRecipe in jsonRecipeArray) {
        if (![jsonRecipe isKindOfClass:[NSDictionary class]]) {
            *error = [self parsingError:@"RecipeList['recipes'] element is not a dictionary."];
            return nil;
        }
        NSDictionary *jsonRecipeDict = (NSDictionary *)jsonRecipe;
        
        SRCF2FRecipe *recipe = [self decodeRecipeFromDictionary:jsonRecipeDict];
        [recipes addObject:recipe];
    }

    return recipes;
}

+ (SRCF2FRecipe *)decodeRecipeFromJSONObject:(id)jsonObject error:(NSError **)error
{
    NSAssert(![NSThread isMainThread], @"Invalid thread for network data processing.");

    if (![jsonObject isKindOfClass:[NSDictionary class]]) {
        *error = [self parsingError:@"Recipe has an invalid top-level object."];
        return nil;
    }
    NSDictionary *jsonDict = (NSDictionary *)jsonObject;

    id jsonRecipe = jsonDict[@"recipe"];
    if (![jsonRecipe isKindOfClass:[NSDictionary class]]) {
        *error = [self parsingError:@"Recipe['recipe'] element is not a dictionary."];
        return nil;
    }
    NSDictionary *jsonRecipeDict = (NSDictionary *)jsonRecipe;
    
    SRCF2FRecipe *recipe = [self decodeRecipeFromDictionary:jsonRecipeDict];
    return recipe;
}

- (PMKPromise *)search:(NSString *)query page:(NSUInteger)page
{
    NSString *encodedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:kSRCBaseURLString];
    urlComponents.scheme = self.baseURLScheme;
    urlComponents.path = [urlComponents.path stringByAppendingString:@"search"];
    urlComponents.query = [NSString stringWithFormat:@"sort=r&page=%d&q=%@&key=%@",
       (int)page + 1, encodedQuery, kSRCAPIKey];
    NSURL *url = urlComponents.URL;
    __weak SRCF2FService *weakSelf = self;
    
    return [PMKPromise promiseWithResolver:^(PMKResolver resolver) {
        NSURLSession *session = weakSelf.urlSession;
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data,
                NSURLResponse * _Nullable response, NSError * _Nullable networkError) {
            if (networkError) {
                resolver(networkError);
                return;
            }
            NSError *error = nil;
            id result = [SRCF2FService decodeJSONResponse:response withData:data error:&error];
            resolver(error ? error : result);
        }];
        [task resume];
    }]
    .thenInBackground(^(id jsonObject) {
        return [PMKPromise promiseWithResolver:^(PMKResolver resolver) {
            NSError *error = nil;
            id result = [SRCF2FService decodeRecipeListFromJSONObject:jsonObject error:&error];
            resolver(error ? error : result);
        }];
    });
}

- (PMKPromise *)getRecipe:(NSString *)recipeID
{
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:kSRCBaseURLString];
    //urlComponents.scheme = self.baseURLScheme;
    urlComponents.path = [urlComponents.path stringByAppendingString:@"get"];
    urlComponents.query = [NSString stringWithFormat:@"rId=%@&key=%@", recipeID, kSRCAPIKey];
    NSURL *url = urlComponents.URL;
    __weak SRCF2FService *weakSelf = self;
    
    return [PMKPromise promiseWithResolver:^(PMKResolver resolver) {
        NSURLSession *session = weakSelf.urlSession;
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data,
                NSURLResponse * _Nullable response, NSError * _Nullable networkError) {
            if (networkError) {
                resolver(networkError);
                return;
            }
            NSError *error = nil;
            id result = [SRCF2FService decodeJSONResponse:response withData:data error:&error];
            resolver(error ? error : result);
        }];
        [task resume];
    }]
    .thenInBackground(^(id jsonObject) {
        return [PMKPromise promiseWithResolver:^(PMKResolver resolver) {
            NSError *error = nil;
            id result = [SRCF2FService decodeRecipeFromJSONObject:jsonObject error:&error];
            resolver(error ? error : result);
        }];
    });
}

@end
