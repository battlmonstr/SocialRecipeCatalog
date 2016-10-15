//
//  DetailViewController.h
//  SocialRecipeCatalog
//
//  Created by Daniel on 14/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SRCF2FRecipe;

@interface SRCDetailViewController : UIViewController

@property (strong, nonatomic) SRCF2FRecipe *detailItem;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *socialRankLabel;
@property (weak, nonatomic) IBOutlet UITableView *infoTableView;

@end

