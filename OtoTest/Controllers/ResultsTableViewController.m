//
//  ResultsTableViewController.m
//  OtoTest
//
//  Created by alden on 12/31/12.
//  Copyright (c) 2012 alden. All rights reserved.
//

#import "ResultsTableViewController.h"

@interface ResultsTableViewController ()

@end

@implementation ResultsTableViewController

@synthesize managedObjectContext;
@synthesize results;

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
  
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
  
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.results = [self fetchAllResults];
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - New Test Result Notification
- (void)displayNewTestResult:(NSNotification *)notification
{
  OTResult *result = notification.userInfo[@"result"];
  ResultDetailTableViewController *resultVC = [[ResultDetailTableViewController alloc] init];
  NSLog(@"Display New Test %@, %@, %@", result, self.navigationController, self.tabBarController);
  resultVC.result = result;
  self.tabBarController.selectedViewController = self.navigationController;
  [self.navigationController pushViewController:resultVC animated:YES];
}

#pragma mark - Core Data

- (NSMutableArray *)fetchAllResults
{
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"OTResult"];
  [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];

  NSError *error = nil;
  return [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
}

#pragma mark - Table View Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  ResultDetailTableViewController *resultVC = segue.destinationViewController;
  NSInteger row = [[self.tableView indexPathForSelectedRow] row];
  resultVC.result = self.results[row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  return results ? results.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  OTResult *result = [results objectAtIndex:indexPath.row];
  
  static NSDateFormatter *dateFormatter = nil;
  static NSDateFormatter *timeFormatter = nil;
  if (dateFormatter == nil) {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
  }
  if (timeFormatter == nil) {
    timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
  }

  static NSString *CellIdentifier = @"ResultCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  cell.textLabel.text = [dateFormatter stringFromDate:result.date];
  cell.detailTextLabel.text = [timeFormatter stringFromDate:result.date];
  
  return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // Delete the row from the data source
    [self.managedObjectContext deleteObject:self.results[indexPath.row]];
    [self.managedObjectContext save:nil];
    self.results = [self fetchAllResults];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
  else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Navigation logic may go here. Create and push another view controller.
  /*
   DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
   // ...
   // Pass the selected object to the new view controller.
   [self.navigationController pushViewController:detailViewController animated:YES];
   */
}

@end
