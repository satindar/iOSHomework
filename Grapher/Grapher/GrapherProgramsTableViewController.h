//
//  GrapherProgramsTableViewController.h
//  Grapher
//
//  Created by SATINDAR S DHILLON on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GrapherProgramsTableViewController;

@protocol GrapherProgramsTableViewControllerDelegate 
@optional
- (void)grapherProgramsTableViewControllerDelegate:(GrapherProgramsTableViewController *)sender choseProgam:(id)program;

@end

@interface GrapherProgramsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *programs; // array of calculator programs
@property (nonatomic, weak) id <GrapherProgramsTableViewControllerDelegate> delegate;

@end
