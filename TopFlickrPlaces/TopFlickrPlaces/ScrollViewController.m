//
//  ScrollViewController.m
//  TopFlickrPlaces
//
//  Created by SATINDAR S DHILLON on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScrollViewController.h"
#import "FlickrFetcher.h"

@interface ScrollViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;
@property (weak, nonatomic) IBOutlet UILabel *toolbarTitle;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@end

@implementation ScrollViewController

@synthesize photo = _photo;
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbarTitle = _toolbarTitle;
@synthesize toolbar = _toolbar;


#define RECENTLY_DISPLAYED_PHOTOS_KEY @"ScrollViewController.RecentlyDisplayedPhotos"
#define MAX_PHOTOS_STORED 20

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)setPhoto:(NSDictionary *)photo
{
    if (_photo != photo) {
        _photo = photo;
    }
    [self fetchPhotoAndSetTitle:photo];
    [self updateUserDefaults];
}

- (void)updateUserDefaults
{
    // Store photo in NSUserDefaults array of recent phtos displayed
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentlyDisplayedPhotos = [[defaults objectForKey:RECENTLY_DISPLAYED_PHOTOS_KEY] mutableCopy];
    if (!recentlyDisplayedPhotos) recentlyDisplayedPhotos = [NSMutableArray array];
    if ([recentlyDisplayedPhotos count] >= MAX_PHOTOS_STORED) [recentlyDisplayedPhotos removeObjectAtIndex:0];
    if (self.photo) {
        [recentlyDisplayedPhotos addObject:self.photo];
        [defaults setObject:recentlyDisplayedPhotos forKey:RECENTLY_DISPLAYED_PHOTOS_KEY];
    } else {
        if ([recentlyDisplayedPhotos count] > 0) self.photo = [recentlyDisplayedPhotos lastObject];
    }
    [defaults synchronize]; 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // Store photo in NSUserDefaults array of recent photos displayed
    [self updateUserDefaults];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return (orientation == UIInterfaceOrientationPortrait);
}

- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Photo Table";
    self.splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.splitViewBarButtonItem = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
	// Do any additional setup after loading the view.
}

                      
- (void)viewDidUnload
{
    [self setToolbarTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView    
{
    return self.imageView;
}

- (void)setupPhotoInView:(UIImage *)image withTitle:(NSString *)title
{
    self.toolbarTitle.text = title;
    self.imageView.image = image;
    self.scrollView.contentSize = self.imageView.bounds.size;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    float heightRatio = self.imageView.bounds.size.height / self.scrollView.bounds.size.height;
    float widthRatio = self.imageView.bounds.size.width / self.scrollView.bounds.size.width;
    
    if (heightRatio > widthRatio) {
        self.scrollView.zoomScale = 1 / widthRatio;
    } else {
        self.scrollView.zoomScale = 1 / heightRatio;
    }
}

- (void)fetchPhotoAndSetTitle:(NSDictionary *)photo
{
    dispatch_queue_t requestQueue = dispatch_queue_create("flickr photo requester", NULL);
    dispatch_async(requestQueue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge]];
        UIImage *image = [UIImage imageWithData:imageData];
        NSString *title = [photo valueForKey:FLICKR_PHOTO_TITLE];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupPhotoInView:image withTitle:title];
        });
    });
    dispatch_release(requestQueue);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
