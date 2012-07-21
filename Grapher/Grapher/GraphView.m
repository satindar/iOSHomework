//
//  GraphView.m
//  Grapher
//
//  Created by SATINDAR S DHILLON on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize axesScale = _axesScale;
@synthesize axesOrigin = _axesOrigin;
@synthesize display = _display;

#define DEFAULT_SCALE 2.0


- (CGFloat)axesScale
{
    if (!_axesScale) {
        return DEFAULT_SCALE;
    } else {
        return _axesScale;
    }
}

- (CGPoint)axesOrigin
{
    if (!_axesOrigin.x) {
        _axesOrigin = self.center;
    } 
    return _axesOrigin;
}

- (void)setAxesScale:(CGFloat)axesScale
{
    if (_axesScale != axesScale) {
        _axesScale = axesScale;
        [self setNeedsDisplay];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:self.axesScale forKey:@"AXES_SCALE"];
        [defaults synchronize];
    }
}

- (void)setAxesOrigin:(CGPoint)axesOrigin
{
    if ((_axesOrigin.x != axesOrigin.x) && (_axesOrigin.y != axesOrigin.y)) {
        _axesOrigin = axesOrigin;
        [self setNeedsDisplay];
        // setUserDefaults here
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:self.axesOrigin.x forKey:@"AXES_ORIGIN_X"];
        [defaults setFloat:self.axesOrigin.y forKey:@"AXES_ORIGIN_Y"];
        [defaults synchronize];
    }
}

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw;  
    // get userdefaults for scale and origin here
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.axesScale = [defaults floatForKey:@"AXES_SCALE"];
    float xAxisOrigin = [defaults floatForKey:@"AXES_ORIGIN_X"];
    float yAxisOrigin = [defaults floatForKey:@"AXES_ORIGIN_Y"];
    if (xAxisOrigin && yAxisOrigin) {
        CGPoint axisOrigin;
        axisOrigin.x = xAxisOrigin;
        axisOrigin.y = yAxisOrigin;
        self.axesOrigin = axisOrigin;
    }
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        self.axesScale *= gesture.scale;
        gesture.scale = 1;
    }
}

- (void)tripleTap:(UITapGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint newOrigin = [gesture locationInView:self];
        self.axesOrigin = CGPointMake(newOrigin.x, newOrigin.y);
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        self.axesOrigin = CGPointMake(self.axesOrigin.x + translation.x, self.axesOrigin.y + translation.y);
    }
}

- (void)drawRect:(CGRect)rect
{
    self.display.text = [self.dataSource programDescription];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blackColor] setStroke];
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.axesOrigin scale:self.axesScale];
    
    // Graph the equation from the calculator program
    [[UIColor redColor] setStroke];
    CGPoint previousPoint;
    CGPoint nextPoint;
    CGFloat maxPixelRange = self.bounds.size.width * self.contentScaleFactor;
    for (int pixelCount = 0; pixelCount < maxPixelRange; pixelCount++) {
        CGFloat xValue = ((pixelCount / self.contentScaleFactor) - self.axesOrigin.x) / self.axesScale; // provides xvalue in points (View's coordinate system)
        CGFloat calculatedYValue = [self.dataSource yValue:xValue];
        CGFloat yValue = (self.axesOrigin.y - (calculatedYValue * self.axesScale)); // provides yvalue in points (View's coordinate system
        nextPoint = CGPointMake((pixelCount / self.contentScaleFactor), yValue);
        if (previousPoint.y && pixelCount > 0) {
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, previousPoint.x, previousPoint.y);
            CGContextAddLineToPoint(context, nextPoint.x, nextPoint.y);
            CGContextStrokePath(context); 
        }
        previousPoint = nextPoint; 
    }
}


@end
