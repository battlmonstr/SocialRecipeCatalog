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

@interface SRCMasterViewController ()

@property NSArray *objects;
@property SRCSignal *textFieldDidChangeSignal;
@property SRCSearchEngine *searchEngine;

@end

@implementation SRCMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    self.detailViewController = (SRCDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.textFieldDidChangeSignal = [SRCSignal new];
    
    self.searchEngine = [[SRCSearchEngine alloc] initWithQuerySignal:self.textFieldDidChangeSignal];
    __weak SRCMasterViewController *weakSelf = self;
    [self.searchEngine.resultSignal setOutputPromiseSubscriber:^(PMKPromise *promise) {
        promise.then(^(NSArray *recipes) {
            //NSLog(@"%@", recipes);
            weakSelf.objects = recipes;
            [weakSelf.tableView reloadData];
        })
        .catch(^(NSError *error) {
            NSLog(@"searchEngine error: %@", error);
        });
    }];
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
        NSDate *object = self.objects[indexPath.row];
        SRCDetailViewController *controller = (SRCDetailViewController *)[[segue destinationViewController] topViewController];
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
