//
//  GraphViewController.h
//  Grapher
//
//  Created by SATINDAR S DHILLON on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "GrapherBrain.h"

@interface GraphViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) NSArray *program; // pass in through prepare for segue

@end
