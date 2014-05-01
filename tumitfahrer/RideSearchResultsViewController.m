//
//  AnotherActivitiesViewController.m
//  tumitfahrer
//
//  Created by Pawel Kwiecien on 4/4/14.
//  Copyright (c) 2014 Pawel Kwiecien. All rights reserved.
//

#import "RideSearchResultsViewController.h"
#import "ActionManager.h"
#import "RideDetailsViewController.h"
#import "RideSearchStore.h"
#import "RideSearch.h"
#import "CvLayout.h"

@interface RideSearchResultsViewController ()

@end

@implementation RideSearchResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:@"RideSearchResultCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"RideSearchCell"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    CvLayout *cvLayout = [[CvLayout alloc] init];
    [self.collectionView setCollectionViewLayout:cvLayout];
}

-(void)viewWillAppear:(BOOL)animated {
    [self setupNavbar];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)setupNavbar {
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBarHidden = NO;
    self.title = @"SEARCH RESULTS";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

-(void)showUnimplementedAlertView {
    [ActionManager showAlertViewWithTitle:@"Add a ride"];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    self.title = item.title;
}

-(BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}


#pragma mark - Collection view

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[RideSearchStore sharedStore] allSearchResults] count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"RideSearchCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:5];
    RideSearch *ride = [[[RideSearchStore sharedStore] allSearchResults] objectAtIndex:indexPath.row];
    if(ride.destinationImage == nil) {
        imageView.image = [UIImage imageNamed:@"PlaceholderImage"];
    } else {
        imageView.image = ride.destinationImage;
    }
    
    [imageView setClipsToBounds:YES];
    
    UILabel *departureLabel = (UILabel *)[cell.contentView viewWithTag:8];
    UILabel *destinationLabel = (UILabel *)[cell.contentView viewWithTag:9];
    UILabel *departureTimeLabel = (UILabel *)[cell.contentView viewWithTag:10];
    destinationLabel.text = ride.destination;
    departureLabel.text = ride.departurePlace;
    departureTimeLabel.text = [ActionManager stringFromDate:ride.departureTime];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RideDetailsViewController *rideDetailsVC = [[RideDetailsViewController alloc] init];
    rideDetailsVC.selectedRide = [[[RideSearchStore sharedStore] allSearchResults] objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:rideDetailsVC animated:YES];
}

#pragma mark – UICollectionViewDelegateFlowLayout
-(void)reloadDataAtIndex:(NSInteger)index {
    [self.collectionView reloadData];
    //    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndex:index];
    //    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
}

@end