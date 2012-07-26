//
//  MapViewController.h
//  Shutterbug
//
//  Created by SATINDAR S DHILLON on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation;

@end

@interface MapViewController : UIViewController
@property (nonatomic, strong) NSArray *annotations; // array of annotations
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;
@end
