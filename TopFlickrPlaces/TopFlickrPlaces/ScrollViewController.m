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
@end

@implementation ScrollViewController

@synthesize photo = _photo;
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;

- (void)setPhoto:(NSDictionary *)photo
{
    if (_photo != photo) {
        _photo = photo;
    }
    [self fetchPhotoAndSetTitle:photo];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
	// Do any additional setup after loading the view.
}

                      
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView    
{
    return self.imageView;
}

- (void)fetchPhotoAndSetTitle:(NSDictionary *)photo
{
//    self.titleBar.title = [photo valueForKey:FLICKR_PHOTO_TITLE];
//    self.toolbarTitle.title = [photo valueForKey:FLICKR_PHOTO_TITLE];
    dispatch_queue_t requestQueue = dispatch_queue_create("flickr photo requester", NULL);
    dispatch_async(requestQueue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge]];
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
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
