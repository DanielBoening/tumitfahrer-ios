 //
//  ParentPageViewController.m
//  tumitfahrer
//
//  Created by Pawel Kwiecien on 5/10/14.
//  Copyright (c) 2014 Pawel Kwiecien. All rights reserved.
//

#import "TimelinePageViewController.h"
#import "TimelineViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "LogoView.h"
#import "CurrentUser.h"
#import "LoginViewController.h"
#import "ActivityStore.h"
#import "CustomBarButton.h"

@interface TimelinePageViewController () <TimelineViewControllerDelegate>

@property NSArray *pageTitles;
@property NSArray *pageColors;

// activity about new: rides (who add new activity ride, ride request, campus ride), who requests a ride, ride search, rating {activities : { activity_rides : { }, campus_ride: {}, ride_requests: {}, rating{}, }

@end

@implementation TimelinePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pageTitles = [NSArray arrayWithObjects:@"Timeline", @"Around you", @"Your activity", nil];
        self.pageColors = [NSArray arrayWithObjects:[UIColor colorWithRed:0.757 green:0.153 blue:0.176 alpha:1], [UIColor colorWithRed:0.667 green:0.149 blue:0.188 alpha:1], [UIColor colorWithRed:0.529 green:0.122 blue:0.153 alpha:1] , nil];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    TimelineViewController *initialViewController = [self viewControllerAtIndex:0];
    initialViewController.delegate = self;
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    // get current user
    NSString *emailLoggedInUser = [[NSUserDefaults standardUserDefaults] valueForKey:@"emailLoggedInUser"];
    
    if (emailLoggedInUser != nil) {
        [CurrentUser fetchUserFromCoreDataWithEmail:emailLoggedInUser];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"Current user: %@", [CurrentUser sharedInstance].user);
    if([CurrentUser sharedInstance].user == nil)
    {
        [self showLoginScreen:NO];
    }
    
    [self setupLeftMenuButton];
    [self setupNavigationBar];
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)setupNavigationBar {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.navigationController.navigationBar setBarTintColor:[self.pageColors objectAtIndex:0]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.logo = [[LogoView alloc] initWithFrame:CGRectMake(0, 0, 200, 41) title:[self.pageTitles objectAtIndex:0]];
    [self.navigationItem setTitleView:self.logo];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden = NO;
    
    // right button of the navigation bar
    CustomBarButton *mapButton = [[CustomBarButton alloc] initWithTitle:@"Map"];
    [mapButton addTarget:self action:@selector(mapButtonPressed) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *mapButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mapButton];
    self.navigationItem.rightBarButtonItem = mapButtonItem;
}

-(void)mapButtonPressed {
    
}

-(void)showLoginScreen:(BOOL)animated
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self presentViewController:loginVC animated:animated completion:nil];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TimelineViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TimelineViewController *)viewController index];
    
    index++;
    
    if (index == 3) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (TimelineViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    TimelineViewController *timelineViewController = [[TimelineViewController alloc] init];
    timelineViewController.index = index;
    timelineViewController.delegate = self;
    
    self.title = [NSString stringWithFormat:@"Screen #%d", index];
    
    return timelineViewController;
    
}


#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.sideBarController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


-(void)willAppearViewWithIndex:(NSInteger)index {
    self.logo.titleLabel.text = [self.pageTitles objectAtIndex:index];
    self.logo.pageControl.currentPage = index;
    [self.navigationController.navigationBar setBarTintColor:[self.pageColors objectAtIndex:index]];
}

@end