//
//  TopPlacesTableViewController.m
//  TopFlickrPlaces
//
//  Created by SATINDAR S DHILLON on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "RecentPhotosFromTopPlacesTableViewController.h"
#import "MapViewController.h"
#import "PhotoAnnotation.h"

@interface TopPlacesTableViewController ()

@end

@implementation TopPlacesTableViewController

@synthesize topPlaces = _topPlaces;

- (IBAction)refresh:(id)sender 
{
    // might want to use introspection to be sure sender is UIBarButtonItem
    // (if not, it can skip the spinner)
    // that way this method can be a little more generic
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t dowloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(dowloadQueue, ^{
        NSArray *unorderedPlaces = [FlickrFetcher topPlaces];
        NSArray *places = [unorderedPlaces sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
            self.topPlaces = places;
        });
    });
    dispatch_release(dowloadQueue);
}

- (void)setTopPlaces:(NSArray *)topPlaces
{
    if (_topPlaces != topPlaces) {
        _topPlaces = topPlaces;
    }
    [self.tableView reloadData];
}

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
    if (!self.topPlaces) [self refresh:self.navigationItem.rightBarButtonItem];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.topPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Top Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    
    NSDictionary *topPlace = [self.topPlaces objectAtIndex:indexPath.row];
    NSMutableArray *placeDescription = [[[topPlace objectForKey:FLICKR_PLACE_NAME] componentsSeparatedByString:@","] mutableCopy];
    cell.textLabel.text = [placeDescription objectAtIndex:0];
    [placeDescription removeObjectAtIndex:0];
    NSString *detailDescription;
    for (NSString *element in placeDescription) {
        if (!detailDescription) {
            detailDescription = element;
        } else {
            detailDescription = [detailDescription stringByAppendingString:[@"," stringByAppendingString:element]];
        }
    }
    if (detailDescription) {
        cell.detailTextLabel.text = detailDescription;
    }
//    NSLog(@"%@", detailDescription);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.topPlaces count]];
    for (NSDictionary *place in self.topPlaces) {
        [annotations addObject:[PhotoAnnotation annotationForPlace:place]];
    }
    return annotations;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Recent Photos From Top Places"]) {
        [segue.destinationViewController setTitle:[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]].textLabel.text];
        
        dispatch_queue_t requestQueue = dispatch_queue_create("flickr requester", NULL);
        dispatch_async(requestQueue, ^{
            NSArray *photosForPlace = [FlickrFetcher photosInPlace:[self.topPlaces objectAtIndex:[self.tableView indexPathForSelectedRow].row] maxResults:50];
            dispatch_async(dispatch_get_main_queue(), ^{
                [segue.destinationViewController setRecentPhotosFromTopPlaces:photosForPlace];
            });
        });
        dispatch_release(requestQueue);
    }
    
    if ([segue.identifier isEqualToString:@"Show Top Places in Map View"]) {
        // set annotations for MapView of Top Places
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    }
}



@end
