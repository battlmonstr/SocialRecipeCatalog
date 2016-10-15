//
//  MasterViewController.m
//  SocialRecipeCatalog
//
//  Created by Daniel on 14/10/16.
//  Copyright © 2016 Brainroom Ltd. All rights reserved.
//

#import "SRCMasterViewController.h"
#import "SRCDetailViewController.h"
#import "SRCSignal.h"
#import "SRCSearchEngine.h"
#import "SRCF2FRecipe.h"
#import "SRCF2FService.h"

@interface SRCMasterViewController ()

@property NSArray *objects;
@property SRCSignal *textFieldDidChangeSignal;
@property SRCSignal *textAndResultsMismatchSignal;
@property SRCSearchEngine *searchEngine;
@property UIActivityIndicatorView *activityIndicator;

@end

@implementation SRCMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupActivityIndicator];

    self.detailViewController = (SRCDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.textFieldDidChangeSignal = [SRCSignal new];

    __weak SRCMasterViewController *weakSelf = self;
    self.textAndResultsMismatchSignal = [self.textFieldDidChangeSignal map:^id(id valueOrError) {
        weakSelf.objects = @[];
        [weakSelf.tableView reloadData];
        [weakSelf.activityIndicator startAnimating];
        return valueOrError;
    }];
    
    self.searchEngine = [[SRCSearchEngine alloc] initWithQuerySignal:self.textAndResultsMismatchSignal];
    [self.searchEngine.resultSignal setOutputPromiseSubscriber:^(PMKPromise *promise) {
        promise.then(^(SRCF2FServiceSearchResult *searchResult) {
            //NSLog(@"%@", searchResult.recipes);
            // ignore stale results
            if (![searchResult.query isEqualToString:self.searchTextField.text]) {
                return;
            }
            weakSelf.objects = searchResult.recipes;
            [weakSelf.tableView reloadData];
        })
        .catch(^(NSError *error) {
            NSLog(@"searchEngine error: %@", error);
        })
        .finally(^() {
            [weakSelf.activityIndicator stopAnimating];
        });
    }];
    
    [self.searchTextField becomeFirstResponder];
}

- (void)setupActivityIndicator
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *activityIndicatorConstraints = @[
        [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX
            relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f],
        [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY
            relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:0.75f constant:0.0f],
    ];
    [self.view addSubview:self.activityIndicator];
    [self.view addConstraints:activityIndicatorConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textFieldDidChange:(UITextField *)searchTextField
{
    [self.textFieldDidChangeSignal resolve:searchTextField.text];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SRCF2FRecipe *object = self.objects[indexPath.row];
        SRCDetailViewController *controller = (SRCDetailViewController *)[[segue destinationViewController] topViewController];
        controller.service = self.searchEngine.service;
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    SRCF2FRecipe *recipe = self.objects[indexPath.row];
    cell.textLabel.text = recipe.title;
    return cell;
}

@end
