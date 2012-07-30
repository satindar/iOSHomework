//
//  MapViewController.m
//  TopFlickrPlaces
//
//  Created by SATINDAR S DHILLON on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "PhotoAnnotation.h"
#import "TopPlacesTableViewController.h"
#import "RecentlyViewedPhotosTableViewController.h"
#import "RecentPhotosFromTopPlacesTableViewController.h"

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize annotations =_annotations;

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
    NSLog(@"%d", [self.annotations count]);
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}
     
- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    return aView;
}


//- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)aView
//{
//    UIImage *image = nil;
//    [(UIImageView *)aView
//}
     
     
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.mapView.delegate = self;
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (NSArray *)topPlaces
{
    NSMutableArray *topPlaces = [NSMutableArray arrayWithCapacity:[self.annotations count]];
    for (PhotoAnnotation *annotation in self.annotations) {
        [topPlaces addObject:annotation.topPlace];
    }
    return topPlaces;
}

- (NSArray *)photos
{
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:[self.annotations count]];
    for (PhotoAnnotation *annotation in self.annotations) {
        [photos addObject:annotation.photo];
    }
    return photos;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show List Of Top Places"]) {
        [segue.destinationViewController setTopPlaces:[self topPlaces]];
    }
    
    if ([segue.identifier isEqualToString:@"Show List Of Recent Photos From Top Places"]) {
        [segue.destinationViewController setRecentPhotosFromTopPlaces:[self photos]];
    }
    
    if ([segue.identifier isEqualToString:@"Show List Of Recently Viewed Photos"]) {
        [segue.destinationViewController setPhotos:[self photos]];
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

@end
