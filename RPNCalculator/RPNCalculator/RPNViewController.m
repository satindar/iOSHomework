//
//  RPNViewController.m
//  RPNCalculator
//
//  Created by SATINDAR S DHILLON on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPNViewController.h"
#import "RPNBrain.h"
#import "RPNGraphViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface RPNViewController()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) RPNBrain *brain;
@property (nonatomic, strong) NSMutableDictionary *variableTestValues;

@end


@implementation RPNViewController

@synthesize display = _display;
@synthesize inputDisplay = _inputDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize variableTestValues = _variableTestValues;

- (RPNGraphViewController *)splitViewGraphViewController
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[RPNGraphViewController class]]) {
        gvc = nil;
    }
    return gvc;
}


- (RPNBrain *)brain
{
    if (!_brain) _brain = [[RPNBrain alloc] init];
    return _brain;
}

- (NSMutableDictionary *)variableTestValues
{
    if (!_variableTestValues) _variableTestValues = [[NSMutableDictionary alloc] init];
    return _variableTestValues;
}

- (void)updateDisplays
{
    self.inputDisplay.text = [RPNBrain descriptionOfProgram:self.brain.program];
    if ([self splitViewGraphViewController]) {
        [self.splitViewGraphViewController setProgram:self.brain.program];
    } 
}


- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = [sender currentTitle];
    // NSLog(@"user touched %@", digit);
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}


- (IBAction)decimalPointPressed:(UIButton *)sender // change implementation to remove bool property
{
    NSString *decimal = @".";
    NSRange range = [self.display.text rangeOfString:decimal];
    if (range.location == NSNotFound) {
        if (self.userIsInTheMiddleOfEnteringANumber) {
            self.display.text = [self.display.text stringByAppendingString:decimal];
        } else {
            self.display.text = [NSString stringWithFormat:@"0%@", decimal];
            self.userIsInTheMiddleOfEnteringANumber = YES;
        } 
    }
}

- (IBAction)enterPressed 
{
    if (!([self.display.text isEqualToString:@"x"])) {
        [self.brain pushOperand:[self.display.text doubleValue]];
    }
    [self updateDisplays];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)variablePressed:(id)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *variable = [sender currentTitle];
    [self.brain pushVariable:variable];
    self.display.text = variable;
    [self updateDisplays];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}


- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation usingVariableValues:nil];
    [self updateDisplays];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)clearPressed:(UIButton *)sender 
{
    [self.brain clearProgramStack];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.display.text = @"0";
    self.inputDisplay.text = @"";
}

- (IBAction)undoPressed:(id)sender // needs work
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
        if (([self.display.text length] < 1) || [self.display.text isEqualToString:@"0"]) {
            self.userIsInTheMiddleOfEnteringANumber = NO;
            double priorResult = [RPNBrain runProgram:self.brain.program usingVariableValues:self.variableTestValues];
            self.display.text = [NSString stringWithFormat:@"%g", priorResult];
            [self updateDisplays];
        }
    } else if ([self.brain.program count] > 0) {
        [self.brain clearLastOperand];
        double priorOperationAnswer = [RPNBrain runProgram:self.brain.program usingVariableValues:self.variableTestValues];
        self.display.text = [NSString stringWithFormat:@"%g", priorOperationAnswer];
        [self updateDisplays];
    } else {
        self.display.text = @"0";
        [self updateDisplays];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender   
{
    if ([segue.identifier isEqualToString:@"Show Graph"]) {
        [segue.destinationViewController setProgram:self.brain.program];
    } 
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.splitViewController.delegate = self; 
}


- (void)viewDidUnload {
    [self setInputDisplay:nil];
    [super viewDidUnload];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self; 
    if ([self splitViewGraphViewController]) {
        [self.splitViewGraphViewController setProgram:self.brain.program];
    }
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return self.splitViewBarButtonItemPresenter ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Calculator";
    // tell the detail view to put the button up
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end











