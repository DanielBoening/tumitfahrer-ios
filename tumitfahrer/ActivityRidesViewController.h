//
//  ActivityRidesViewController.h
//  tumitfahrer
//
//  Created by Pawel Kwiecien on 4/1/14.
//  Copyright (c) 2014 Pawel Kwiecien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SlideNavigationController.h>

@interface ActivityRidesViewController : UIViewController<SlideNavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIScrollViewDelegate, UINavigationControllerDelegate>

- (IBAction)menuButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *departurePlaceView;

@end