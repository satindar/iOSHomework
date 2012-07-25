//
//  RecentlyViewedPhotosTableViewController.m
//  TopFlickrPlaces
//
//  Created by SATINDAR S DHILLON on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentlyViewedPhotosTableViewController.h"
#import "FlickrFetcher.h"
#import "ScrollViewController.h"

@implementation RecentlyViewedPhotosTableViewController

@synthesize photos = _photos;

- (IBAction)refresh:(id)sender 
{
    // might want to use introspection to be sure sender is UIBarButtonItem
    // (if not, it can skip the spinner)
    // that way this method can be a little more generic
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t dowloadQueue = dispatch_queue_create("flickr recent photos downloader", NULL);
    dispatch_async(dowloadQueue, ^{
        NSArray *photos = [FlickrFetcher recentGeoreferencedPhotos];
//        NSArray *places = [unorderedPlaces sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES]]];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [spinner stopAnimating];
            self.navigationItem.rightBarButtonItem = sender;
            self.photos = photos;
        });
    });
    dispatch_release(dowloadQueue);
}

- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos) {
        _photos = photos;
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [self refresh:self.navigationItem.rightBarButtonItem];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Georeferenced Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setTitle:[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]].textLabel.text];
    if ([segue.identifier isEqualToString:@"Show Recent Georeferenced Photo"]) {
        NSDictionary *photo = [self.photos objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        [segue.destinationViewController setPhoto:photo];
    }
}

@end
