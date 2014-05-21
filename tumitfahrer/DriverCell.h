//
//  DriverCell.h
//  tumitfahrer
//
//  Created by Pawel Kwiecien on 5/2/14.
//  Copyright (c) 2014 Pawel Kwiecien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DriverCell : UITableViewCell<MKMapViewDelegate>

+ (DriverCell*)driverCell;

@property (weak, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverRatingLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
