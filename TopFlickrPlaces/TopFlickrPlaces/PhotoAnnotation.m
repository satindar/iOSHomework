//
//  PhotoAnnotation.m
//  TopFlickrPlaces
//
//  Created by SATINDAR S DHILLON on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoAnnotation.h"
#import "FlickrFetcher.h"

@implementation PhotoAnnotation

@synthesize photo = _photo;
@synthesize topPlace = _topPlace;

+ (PhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo; // Flickr photo dictionary
{
    PhotoAnnotation *annotation = [[PhotoAnnotation alloc] init];
    annotation.photo = photo;
    return annotation;
}

+ (PhotoAnnotation *)annotationForPlace:(NSDictionary *)place; // Flickr photo dictionary
{
    PhotoAnnotation *annotation = [[PhotoAnnotation alloc] init];
    annotation.topPlace = place;
    return annotation;
}

- (NSString *)title
{
    if (self.photo) return [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    if (self.topPlace) return [self.topPlace objectForKey:FLICKR_PLACE_NAME];
    return nil;
}

- (NSString *)subtitle
{
    if (self.photo) return [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    return nil;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    if (self.photo){
        coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue];
        coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    }
    
    if (self.topPlace) {
        coordinate.latitude = [[self.topPlace objectForKey:FLICKR_LATITUDE] doubleValue];
        coordinate.longitude = [[self.topPlace objectForKey:FLICKR_LONGITUDE] doubleValue];
    }
    return coordinate;
}



@end
