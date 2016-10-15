//
//  DetailViewController.m
//  SocialRecipeCatalog
//
//  Created by Daniel on 14/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import "SRCDetailViewController.h"
#import "SRCF2FRecipe.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SRCDetailViewController ()

@end

@implementation SRCDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(SRCF2FRecipe *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.title = self.detailItem.title;
        if (self.detailItem.image_url) {
            [self.imageView sd_setImageWithURL:self.detailItem.image_url placeholderImage:nil];
        } else {
            self.imageView.image = nil;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
