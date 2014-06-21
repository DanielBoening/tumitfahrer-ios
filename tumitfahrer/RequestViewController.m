//
//  RequestViewController.m
//  tumitfahrer
//
//  Created by Pawel Kwiecien on 6/14/14.
//  Copyright (c) 2014 Pawel Kwiecien. All rights reserved.
//

#import "RequestViewController.h"
#import "Ride.h"
#import "RideInformationCell.h"
#import "ActionManager.h"
#import "KGStatusBar.h"
#import "RidesStore.h"
#import "RideSectionHeaderCell.h"
#import "HeaderContentView.h"
#import "RideRequestInformationCell.h"
#import "WebserviceRequest.h"
#import "RideDetailActionCell.h"
#import "RidePersonCell.h"
#import "User.h"
#import "AddRideViewController.h"
#import "SimpleChatViewController.h"
#import "ProfileViewController.h"
#import "ConversationUtilities.h"
#import "CurrentUser.h"

@interface RequestViewController () <UIGestureRecognizerDelegate, RideStoreDelegate, HeaderContentViewDelegate>

@end

@implementation RequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _headerView.backgroundColor = [UIColor darkerBlue];
    [self.view bringSubviewToFront:_headerView];
    [[RidesStore sharedStore] addObserver:self];
    
    self.rideDetail.headerView = _headerView;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.headerViewLabel.text = [@"To " stringByAppendingString:self.ride.destination];
    self.headerTitles = [NSArray arrayWithObjects:@"Details", @"Passenger", @"", nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 2) {
        return 60;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == [self.headerTitles count] -1) {
        return 0;
    }
    return 30;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.headerTitles objectAtIndex:section];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    RideSectionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideNoticeCell"];
    if(cell == nil) {
        cell = [RideSectionHeaderCell rideSectionHeaderCell];
    }
    cell.noticeLabel.text = [self.headerTitles objectAtIndex:section];
    [cell.editButton addTarget:self action:@selector(editButtonTapped) forControlEvents:UIControlEventTouchDown];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        
        RideRequestInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideRequestInformationCell"];
        if(cell == nil){
            cell = [RideRequestInformationCell rideRequestInformationCell];
        }
        cell.requestInfoLabel.text = self.ride.departurePlace;
        return cell;
        
    } else if(indexPath.section == 1) {
        RidePersonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RidePersonCell"];
        if(cell == nil){
            cell = [RidePersonCell ridePersonCell];
        }
        cell.personNameLabel.text = self.ride.rideOwner.firstName;
        cell.leftButton.hidden = YES;
        [cell.rightButton addTarget:self action:@selector(contactRequestorButtonPressed) forControlEvents:UIControlEventTouchDown];
        return cell;
    } else {  // show delete button
        RideDetailActionCell *actionCell = [RideDetailActionCell offerRideCell];
        [actionCell.actionButton setTitle:@"Offer ride" forState:UIControlStateNormal];
        [actionCell.actionButton addTarget:self action:@selector(addRideButtonPressed) forControlEvents:UIControlEventTouchDown];
        return actionCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        ProfileViewController *profileVC = [[ProfileViewController alloc] init];
        profileVC.user = self.ride.rideOwner;
        profileVC.returnEnum = ViewController;
        [self.navigationController pushViewController:profileVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)dealloc {
    [[RidesStore sharedStore] removeObserver:self];
}

-(void)addRideButtonPressed {
    AddRideViewController *addRideVC = [[AddRideViewController alloc] init];
    addRideVC.TableType = Driver;
    addRideVC.RideType = ContentTypeCampusRides;
    [self.navigationController pushViewController:addRideVC animated:YES];
}

-(void)contactRequestorButtonPressed {
    SimpleChatViewController *simpleChatVC = [[SimpleChatViewController alloc] init];
    simpleChatVC.conversation = [ConversationUtilities findConversationBetweenUser:[CurrentUser sharedInstance].user otherUser:self.ride.rideOwner conversationArray:[self.ride.conversations allObjects]];
    simpleChatVC.otherUser = self.ride.rideOwner;
    [self.navigationController pushViewController:simpleChatVC animated:YES];
}

@end
