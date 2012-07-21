//
//  GraphView.h
//  Grapher
//
//  Created by SATINDAR S DHILLON on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AxesDrawer.h"

@class GraphView;

@protocol GraphViewDataSource
- (NSArray *)programForGraphView:(GraphView *)sender;
- (CGFloat)yValue:(CGFloat)xValue;
- (NSString *)programDescription;
@end

@interface GraphView : UIView

@property (nonatomic) CGFloat axesScale;
@property (nonatomic) CGPoint axesOrigin;
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
