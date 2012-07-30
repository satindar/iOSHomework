//
//  PhotoAnnotation.h
//  TopFlickrPlaces
//
//  Created by SATINDAR S DHILLON on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PhotoAnnotation : NSObject <MKAnnotation>

+ (PhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo; // Flickr photo dictionary
+ (PhotoAnnotation *)annotationForPlace:(NSDictionary *)place; // Flickr place dictionary


@property (nonatomic, strong) NSDictionary *photo;
@property (nonatomic, strong) NSDictionary *topPlace; // array of Flickr photo dictionaries


@end

