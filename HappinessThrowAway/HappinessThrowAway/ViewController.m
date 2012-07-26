//
//  ViewController.m
//  HappinessThrowAway
//
//  Created by SATINDAR S DHILLON on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "FaceView.h"

@interface ViewController()
@property (nonatomic, weak) IBOutlet FaceView *faceView;
@end

@implementation ViewController

@synthesize happiness = _happiness;
@synthesize faceView = _faceView;

- (void)setHappiness:(int)happiness
{
    _happiness = happiness;
    [self.faceView setNeedsDisplay];
}

@end
