//
//  Copyright (c) 2014 itok. All rights reserved.
//


#import "TableViewController.h"

#import "ITKAppList.h"

@interface TableViewController ()

@property (nonatomic, strong) NSArray* list;

@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
//	[ITKAppListRequest clearAllCache];
	ITKAppListRequest* req = [[ITKAppListRequest alloc] init];
	[req performRequest:@"290525994" handler:^(NSArray *list, NSError *error) {
		self.list = list;
		[self.tableView reloadData];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	
	ITKAppListApp* app = [self.list objectAtIndex:indexPath.row];
	cell.textLabel.text = app.name;
	cell.detailTextLabel.text = app.desc;
	cell.imageView.image = app.artwork;
	
	return cell;
}

@end
