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
#import <SafariServices/SafariServices.h>

@interface SRCDetailViewController () <UITableViewDelegate, UITableViewDataSource>

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
        self.publisherLabel.text = self.detailItem.publisher;
        if (self.detailItem.social_rank < 1) {
            self.socialRankLabel.text = @"";
        } else {
            NSString *formatString = NSLocalizedString(@"Social rank: %d", nil);
            self.socialRankLabel.text = [NSString stringWithFormat:formatString, (int)self.detailItem.social_rank];
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

// UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 0;
        case 1: return 2;
        default: return 0;
    }
    return 0;
}

// UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        // TODO
        return nil;
    }
    if (section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecipeInfoCellId"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RecipeInfoCellId"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSString *infoCellText;
        switch (indexPath.row) {
            case 0:
                infoCellText = NSLocalizedString(@"View on the web site", nil);
                break;
            case 1:
                infoCellText = NSLocalizedString(@"View on author's site", nil);
                break;
            default:
                infoCellText = @"";
                break;
        }
        cell.textLabel.text = infoCellText;
        
        return cell;
    }
    return nil;
}

// UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// UITableViewDataSource
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return NSLocalizedString(@"Ingredients", nil);
        case 1: return NSLocalizedString(@"Info", nil);
        default: return @"???";
    }
}

// UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSURL *url = indexPath.row ? self.detailItem.source_url : self.detailItem.f2f_url;
        if (url) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
            [self.navigationController pushViewController:safariVC animated:YES];
        }
    }
}

@end
