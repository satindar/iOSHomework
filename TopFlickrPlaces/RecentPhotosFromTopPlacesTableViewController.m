//
//  RecentPhotosFromTopPlacesTableViewController.m
//  TopFlickrPlaces
//
//  Created by SATINDAR S DHILLON on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentPhotosFromTopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "ScrollViewController.h"

@implementation RecentPhotosFromTopPlacesTableViewController

@synthesize recentPhotosFromTopPlaces = _recentPhotosFromTopPlaces;

- (void)setRecentPhotosFromTopPlaces:(NSArray *)recentPhotosFromTopPlaces
{
    if (_recentPhotosFromTopPlaces != recentPhotosFromTopPlaces) {
        _recentPhotosFromTopPlaces = recentPhotosFromTopPlaces;
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.recentPhotosFromTopPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Top Photos For Top Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSDictionary *photo = [self.recentPhotosFromTopPlaces objectAtIndex:indexPath.row];
    
    NSString *title = [photo objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if ([title length] > 0){
        cell.textLabel.text = title;
        cell.detailTextLabel.text = description;
    } else if ([description length] > 0) {
        cell.textLabel.text = description;
        cell.detailTextLabel.text = @"";
    } else {
        cell.textLabel.text = @"Unknown";
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

- (ScrollViewController *)splitViewScrollViewController
{
    id svc = [self.splitViewController.viewControllers lastObject];
    if (![svc isKindOfClass:[ScrollViewController class]]) {
        svc = nil;
    }
    return svc;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self splitViewScrollViewController]) {
        NSDictionary *photo = [self.recentPhotosFromTopPlaces objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        [[self splitViewScrollViewController] setPhoto:photo];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setTitle:[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]].textLabel.text];
    if ([segue.identifier isEqualToString:@"Show Recent Photo From Top Place"]) {
        NSDictionary *photo = [self.recentPhotosFromTopPlaces objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        [segue.destinationViewController setPhoto:photo];
    }
}

@end














