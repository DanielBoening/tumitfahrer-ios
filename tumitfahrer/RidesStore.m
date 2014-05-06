//
//  RidesStore.m
//  tumitfahrer
//
//  Created by Pawel Kwiecien on 4/11/14.
//  Copyright (c) 2014 Pawel Kwiecien. All rights reserved.
//

#import "RidesStore.h"
#import "Ride.h"
#import "User.h"
#import "Request.h"

@interface RidesStore () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSMutableArray *campusRides;
@property (nonatomic) NSMutableArray *activityRides;
@property (nonatomic) NSMutableArray *rideRequests;
@property (nonatomic) NSMutableArray *userRideRequests;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *observers;

@end

@implementation RidesStore

-(instancetype)init {
    self = [super init];
    if (self) {
        
        self.observers = [[NSMutableArray alloc] init];
        [self loadAllRides];
        [self fetchLocationForAllRides];
        
        [self fetchRidesFromWebservice:^(BOOL ridesFetched) {
            if(ridesFetched) {
                [self loadAllRides];
                [self fetchLocationForAllRides];
            }
        }];
    }
    return self;
}

-(void)loadAllRides {
    [self fetchRidesFromCoreDataByType:ContentTypeActivityRides];
    [self fetchRidesFromCoreDataByType:ContentTypeCampusRides];
    [self fetchRidesFromCoreDataByType:ContentTypeExistingRequests];
}

+(instancetype)sharedStore {
    static RidesStore *ridesStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ridesStore = [[self alloc] init];
    });
    return ridesStore;
}

#pragma mark - core data/webservice fetch methods

-(void)fetchRidesFromCoreDataByType:(ContentType)contentType {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [NSEntityDescription entityForName:@"Ride"
                                         inManagedObjectContext:[RKManagedObjectStore defaultStore].
                              mainQueueManagedObjectContext];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"(rideType = %d)", contentType];
    
    [request setPredicate:predicate];
    [request setReturnsObjectsAsFaults:NO];
    
    request.entity = e;
    
    NSError *error;
    NSArray *fetchedObjects = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:&error];
    if (!fetchedObjects) {
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    if(contentType == ContentTypeCampusRides){
        self.campusRides =[[NSMutableArray alloc] initWithArray:fetchedObjects];
    }
    else if(contentType == ContentTypeActivityRides) {
        self.activityRides = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    }
    else if(contentType == ContentTypeExistingRequests) {
        self.rideRequests = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    }
}

// select ride from rides from ride inner join request where ride.id = request.ride_id and request.requested_from = user.id
- (void)fetchUserRequestedRidesFromCoreData:(NSInteger)userId {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [NSEntityDescription entityForName:@"Ride"
                                         inManagedObjectContext:[RKManagedObjectStore defaultStore].
                              mainQueueManagedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY self.requests.passengerId = %d", userId];
    
    [request setPredicate:predicate];

    request.entity = e;
    
    NSError *error;
    NSArray *fetchedObjects = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:&error];
    if (!fetchedObjects) {
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    self.userRideRequests = [NSMutableArray arrayWithArray:fetchedObjects];
    
    for (Ride *ride in fetchedObjects) {
        NSLog(@"Ride id: %d", ride.rideId);
    }
}

-(NSArray *)rideRequestForUserWithId:(NSInteger)userId {
    [self fetchUserRequestedRidesFromCoreData:userId];
    return self.userRideRequests;
}

-(void)fetchRidesFromWebservice:(boolCompletionHandler)block {
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    //    [objectManager.HTTPClient setDefaultHeader:@"Authorization: Basic" value:[self encryptCredentialsWithEmail:self.emailTextField.text password:self.passwordTextField.text]];
    
    [objectManager getObjectsAtPath:API_RIDES parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        block(YES);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
        block(NO);
    }];
}

-(NSFetchedResultsController *)fetchedResultsController
{
    if (self.fetchedResultsController != nil) {
        return self.fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Ride"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    NSError *error = nil;
    
    // Setup fetched results
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:[RKManagedObjectStore defaultStore].
                                     mainQueueManagedObjectContext
                                     sectionNameKeyPath:nil cacheName:@"Ride"];
    self.fetchedResultsController.delegate = self;
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error fetching from db: %@", [error localizedDescription]);
    }
    
    return self.fetchedResultsController;
}

-(void)fetchLocationForAllRides {
    for(Ride *ride in [self allRides]) {
        [self fetchLocationForRide:ride];
    }
}

-(void)fetchLocationForRide:(Ride *)ride {
    [[LocationController sharedInstance] fetchLocationForAddress:ride.destination rideId:ride.rideId];
}

-(void)addRideToStore:(Ride *)ride {
    switch (ride.rideType) {
        case ContentTypeActivityRides:
            [self.activityRides addObject:ride];
            break;
        case ContentTypeCampusRides:
            [self.campusRides addObject:ride];
            break;
        case ContentTypeExistingRequests:
            [self.rideRequests addObject:ride];
            break;
        default:
            break;
    }
}

# pragma mark - delegate methods

-(void)didReceiveLocationForAddress:(CLLocation *)location rideId:(NSInteger)rideId {
    Ride *ride = [self getRideWithId:rideId];
    NSLog(@"ride id is: %d and fetched location lat: %f and destination was: %@", ride.rideId, location.coordinate.latitude, ride.destination);
    
    ride.destinationLatitude = location.coordinate.latitude;
    ride.destinationLongitude = location.coordinate.longitude;
    [[PanoramioUtilities sharedInstance] fetchPhotoForLocation:location rideId:rideId];
}

-(void)didReceivePhotoForLocation:(UIImage *)image rideId:(NSInteger)rideId{
    Ride *ride = [self getRideWithId:rideId];
    ride.destinationImage = image;
    [self notifyAllAboutNewImageForRideId:rideId];
}

#pragma mark - utility funtioncs

-(NSArray *)allRides {
    NSMutableArray *rides = nil;
    rides = [[NSMutableArray alloc] init];
    if([[self allActivityRides] count] >0 )
        [rides addObjectsFromArray:[self allActivityRides]];
    if([[self allCampusRides] count] > 0)
        [rides addObjectsFromArray:[self allCampusRides]];
    if([[self allRideRequests] count] > 0)
        [rides addObjectsFromArray:[self allRideRequests]];
    return rides;
}

-(NSArray *)allRidesByType:(ContentType)contentType {
    switch (contentType) {
        case ContentTypeActivityRides:
            return self.allActivityRides;
            break;
        case ContentTypeCampusRides:
            return self.campusRides;
            break;
        case ContentTypeExistingRequests:
            return self.rideRequests;
            break;
        default:
            return nil;
    }
}

-(NSArray *)allCampusRides {
    if(!self.campusRides) {
        [self fetchRidesFromCoreDataByType:ContentTypeCampusRides];
    }
    return self.campusRides;
}

-(NSArray *)allActivityRides {
    if(!self.activityRides) {
        [self fetchRidesFromCoreDataByType:ContentTypeActivityRides];
    }
    return self.activityRides;
}

-(NSArray *)allRideRequests {
    if(!self.rideRequests) {
        [self fetchRidesFromCoreDataByType:ContentTypeExistingRequests];
    }
    return self.rideRequests;
}

- (Ride *)getRideWithId:(NSInteger)rideId {
    
    for (Ride *ride in [self allRides]) {
        NSLog(@"Ride is %@", ride);
        NSLog(@"ride id: %ld", (long)rideId);
        if (ride.rideId == (int16_t)rideId) {
            return ride;
        }
    }
    return nil;
}

- (void)printAllRides {
    for (Ride *ride in [self allRides]) {
        NSLog(@"Ride: %@", ride);
        NSLog(@"Driver: %d %@", ride.driver.userId, ride.driver.firstName);
        NSLog(@"ride: %@", ride);
        NSLog(@"Number of passengers: %d", [ride.passengers count]);
        for (User *user in [ride passengers]) {
            NSLog(@"User: %d", user.userId);
        }
        
        NSLog(@"Number of requests: %d", [ride.requests count]);
        for (Request *reques in [ride requests]) {
            NSLog(@"Request: %d %@", reques.requestId, reques.requestedFrom);
        }
        
    }
}

# pragma mark - observer methods

-(void)addObserver:(id<RideStoreDelegate>)observer {
    [self.observers addObject:observer];
}

-(void)notifyAllAboutNewImageForRideId:(NSInteger)rideId {
    for (id<RideStoreDelegate> observer in self.observers) {
        if ([observer respondsToSelector:@selector(didReceivePhotoForRide:)]) {
            [observer didReceivePhotoForRide:rideId];
        }
    }
}

-(void)removeObserver:(id<RideStoreDelegate>)observer {
    [self.observers removeObject:observer];
}

@end
