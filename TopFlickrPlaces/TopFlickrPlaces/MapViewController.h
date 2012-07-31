//
//  MapViewController.h
//  TopFlickrPlaces
//
//  Created by SATINDAR S DHILLON on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>



@interface MapViewController : UIViewController
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>
@end
