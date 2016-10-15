//
//  SRCSearchEngine.h
//  SocialRecipeCatalog
//
//  Created by Daniel on 15/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SRCSignal;

@interface SRCSearchEngine : NSObject

- (instancetype)initWithQuerySignal:(SRCSignal *)querySignal;

@property (readonly) SRCSignal *resultSignal;

@end
