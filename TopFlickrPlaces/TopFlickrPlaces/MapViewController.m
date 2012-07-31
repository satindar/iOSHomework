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
#import "FlickrFetcher.h"
#import "ScrollViewController.h"

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize annotations =_annotations;


- (MKCoordinateRegion)regionForAnnotations
{
    CLLocationDegrees minLatitude, maxLatitude, minLongitude, maxLongitude;
    NSMutableArray *longitudeSet = [[NSMutableArray alloc] init];
    NSMutableArray *latitudeSet = [[NSMutableArray alloc] init];
    
    for (PhotoAnnotation *annotation in self.annotations) {
        NSNumber *longitude = [NSNumber numberWithDouble:annotation.coordinate.longitude];
        [longitudeSet addObject:longitude];
        NSNumber *latitude = [NSNumber numberWithDouble:annotation.coordinate.latitude];
        [latitudeSet addObject:latitude];
    }
    
    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *sortedLatitudeSet = [latitudeSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortOrder]];
    NSArray *sortedLongitudeSet = [longitudeSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortOrder]];
    
    minLatitude = [[sortedLatitudeSet objectAtIndex:0] doubleValue];
    maxLatitude = [[sortedLatitudeSet lastObject] doubleValue];
    minLongitude = [[sortedLongitudeSet objectAtIndex:0] doubleValue];
    maxLongitude = [[sortedLongitudeSet lastObject] doubleValue];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLatitude + minLatitude) / 2, (maxLongitude + minLongitude) / 2);
    MKCoordinateSpan span = MKCoordinateSpanMake((maxLatitude - minLatitude) * 1.1, (maxLongitude - minLongitude) * 1.1);
    return MKCoordinateRegionMake(center, span);
}

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) {
        [self.mapView addAnnotations:self.annotations];
        [self.mapView setRegion:[self regionForAnnotations]]; 
    }
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
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    return aView;
}

- (UIImage *)imageForAnnotation:(PhotoAnnotation *)annotation
{
    PhotoAnnotation *pa = (PhotoAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:pa.photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    UIImage *image = [self imageForAnnotation:aView.annotation]; // should be delegated. not sure what class should be delgate. ??
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
    
}

- (ScrollViewController *)splitViewScrollViewController
{
    id svc = [self.splitViewController.viewControllers lastObject];
    if (![svc isKindOfClass:[ScrollViewController class]]) {
        svc = nil;
    }
    return svc;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control
{
    PhotoAnnotation *pa = (PhotoAnnotation *)aView.annotation;
    NSDictionary *photo = pa.photo;
    NSDictionary *place = pa.topPlace;
    if ([self splitViewScrollViewController] && photo != nil) {
        [[self splitViewScrollViewController] setPhoto:photo];
    }
    if (place) {
        [self performSegueWithIdentifier:@"Show Recent Photos From Top Places On Map" sender:place];
    }
}




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
    
    if ([segue.identifier isEqualToString:@"Show Recent Photos From Top Places On Map"]) {        
        dispatch_queue_t requestQueue = dispatch_queue_create("flickr requester", NULL); // should be delegated
        dispatch_async(requestQueue, ^{
            NSArray *photosForPlace = [FlickrFetcher photosInPlace:sender maxResults:20];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[photosForPlace count]];
                for (NSDictionary *photo in photosForPlace) {
                    [annotations addObject:[PhotoAnnotation annotationForPhoto:photo]];
                }
                [segue.destinationViewController setAnnotations:annotations];
            });
        });
        dispatch_release(requestQueue);
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
