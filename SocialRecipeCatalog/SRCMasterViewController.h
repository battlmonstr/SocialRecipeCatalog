//
//  MasterViewController.h
//  SocialRecipeCatalog
//
//  Created by Daniel on 14/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRCDetailViewController;

@interface SRCMasterViewController : UITableViewController

@property (strong, nonatomic) SRCDetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

- (IBAction)textFieldDidChange:(UITextField *)searchTextField;

@end

