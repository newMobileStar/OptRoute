//
//  ViewController.m
//  OptRoute
//
//  Created by New Star on 1/20/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "Place.h"
#import "PlaceMark.h"
//#import "AddLocationTableViewCell.h"
#import "GoogleAutoCompleteViewController.h"

@interface ViewController () <MKMapViewDelegate, GoogleAutoCompleteViewDelegate>{

    
}

@property (strong, nonatomic) IBOutlet UIButton *addLocationBtn;
@property (strong, nonatomic) IBOutlet UIButton *resetBtn;
@property (strong, nonatomic) IBOutlet UIButton *calcOptimizingRouteBtn;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (assign, nonatomic) int numberLocation, colorNum, num;

@property (strong, nonatomic) NSMutableArray *distanceArray, *firstPointArray, *secondPointArray, *thirdPointArray, *fourthPointArray, *locationNameArray;

@property (assign, nonatomic) double  distanceValue;
@property (assign, nonatomic) CLLocationDistance minDistance, distance, d1, d2, d3, d4, d5, d6;

//@property (strong, nonatomic) IBOutlet UITableView *locationTableView;



@end



@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initUI];
    [self initView];
    [self initData];
}

CLGeocoder *geocoder;
CLPlacemark *userSpotPlaceMark, *newSpotPlaceMark, *thePlacemark;
MKRoute *routeDetails, *allRoute;
NSString *addressOfSpot = @"";

- (void) initUI{
    
    [commonUtils setRoundedRectBorderButton:_resetBtn withBorderWidth:1.0f withBorderColor:[UIColor whiteColor] withBorderRadius:5.0f];
    [commonUtils setRoundedRectBorderButton:_calcOptimizingRouteBtn withBorderWidth:1.0f withBorderColor:[UIColor whiteColor] withBorderRadius:5.0f];
    [commonUtils setRoundedRectBorderButton:_addLocationBtn withBorderWidth:1.0f withBorderColor:[UIColor whiteColor] withBorderRadius:5.0f];
    
    [_addLocationBtn setTitleColor:[UIColor whiteColor] forState:normal];
    //[_addLocationBtn setBackgroundColor:]
    [_addLocationBtn setUserInteractionEnabled:YES];
    
    [_calcOptimizingRouteBtn setTitleColor:[UIColor lightGrayColor] forState:normal];
    //[_calcOptimizingRouteBtn setBackgroundColor:]
    [_calcOptimizingRouteBtn setUserInteractionEnabled:NO];
    
    [_resetBtn setTitleColor:[UIColor lightGrayColor] forState:normal];
    //[_resetBtn setBackgroundColor:]
    [_resetBtn setUserInteractionEnabled:NO];
    
    _num = 0;
    //_numberLocation = 0;
    
    
    
}

- (void) initView{
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    [self zoomMapViewToFitAnnotations:self.mapView animated:YES];
    
    
    
    
}

- (void) initData{
    
   
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:tapRecognizer];
    
    //_numberLocation = 0;
    
    _distanceArray = [[NSMutableArray alloc] init];
    
    _firstPointArray = [[NSMutableArray alloc] init];
    _secondPointArray = [[NSMutableArray alloc] init];
    _thirdPointArray = [[NSMutableArray alloc] init];
    _fourthPointArray = [[NSMutableArray alloc] init];
    
    _d1 = 0.0f;_d2 = 0.0f;_d3 = 0.0f;_d4 = 0.0f;_d5 = 0.0f;_d6= 0.0f;

    
    [self getCurrentLocationAddress];
    
    
}

- (void) getCurrentLocationAddress{
    
    //_numberLocation = 0;
    _num = 0;
    geocoder = [[CLGeocoder alloc] init];
    appController.locationArray = [[NSMutableArray alloc]init];

    CLLocationCoordinate2D tapPoint;
    //tapPoint = _mapView.userLocation.coordinate;
    tapPoint.latitude = [[commonUtils getUserDefault:@"currentLatitude"] doubleValue];
    tapPoint.longitude = [[commonUtils getUserDefault:@"currentLongitude"] doubleValue];
    //tapPoint.longitude = appController.user_current_longitude;
    
    __block BOOL isGetAdressSuccess;
    
    NSLog(@"Resolving the Address");
    
    __block NSString *returnAddress = @"";
    
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:(float)tapPoint.latitude longitude:(float)tapPoint.longitude];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil) {
            userSpotPlaceMark = [placemarks lastObject];
            returnAddress = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                             userSpotPlaceMark.subThoroughfare, userSpotPlaceMark.thoroughfare,
                             userSpotPlaceMark.postalCode, userSpotPlaceMark.locality,
                             userSpotPlaceMark.administrativeArea,
                             userSpotPlaceMark.country];
            NSLog(@"Tapping Spot: \n%@", returnAddress);
            isGetAdressSuccess = YES;
            
        } else {
            NSLog(@"%@", error.debugDescription);
            isGetAdressSuccess = NO;
            
        }
        if (isGetAdressSuccess) {
            
            Place *home = [[Place alloc] init];
            home.name = userSpotPlaceMark.name;
            home.description = [NSString stringWithFormat:@"%@, %@", userSpotPlaceMark.administrativeArea, userSpotPlaceMark.locality];
            home.latitude = (float)userSpotPlaceMark.location.coordinate.latitude;
            home.longitude = (float)userSpotPlaceMark.location.coordinate.longitude;
            PlaceMark* from = [[PlaceMark alloc] initWithPlace:home];
            from.tag = _num;
            [appController.locationArray addObject: userSpotPlaceMark];
            //[self.mapView addAnnotation:from];
            [self zoomMapViewToFitAnnotations:self.mapView animated:YES];
            
        }
        else{
            
            //                [commonUtils showVAlertSimple:@"Notification!" body:@"Please tap the location again." duration:1.2];
            
        }
        
        
    }];

}

#pragma tap drop pin event
-(IBAction)foundTap:(UITapGestureRecognizer *)recognizer
{
    
//    _numberLocation++;
//    if (_numberLocation > 3) {
//        return;
//    }
//        geocoder = [[CLGeocoder alloc] init];
//        CGPoint point = [recognizer locationInView:self.mapView];
//        CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
//        
//        __block BOOL isGetAdressSuccess;
//        
//        NSLog(@"Resolving the Address");
//        
//        __block NSString *returnAddress = @"";
//        
//        CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:(float)tapPoint.latitude longitude:(float)tapPoint.longitude];
//        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
//            //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
//            if (error == nil) {
//                newSpotPlaceMark = [placemarks lastObject];
//                returnAddress = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
//                                 newSpotPlaceMark.subThoroughfare, newSpotPlaceMark.thoroughfare,
//                                 newSpotPlaceMark.postalCode, newSpotPlaceMark.locality,
//                                 newSpotPlaceMark.administrativeArea,
//                                 newSpotPlaceMark.country];
//                NSLog(@"Tapping Spot: \n%@", returnAddress);
//                isGetAdressSuccess = YES;
//                
//            } else {
//                NSLog(@"%@", error.debugDescription);
//                isGetAdressSuccess = NO;
//                
//            }
//            if (isGetAdressSuccess) {
//
//                Place *home = [[Place alloc] init];
//                home.name = newSpotPlaceMark.name;
//                home.description = [NSString stringWithFormat:@"%@, %@", newSpotPlaceMark.administrativeArea, newSpotPlaceMark.locality];
//                home.latitude = (float)newSpotPlaceMark.location.coordinate.latitude;
//                home.longitude = (float)newSpotPlaceMark.location.coordinate.longitude;
//                PlaceMark* from = [[PlaceMark alloc] initWithPlace:home];
//                from.tag = _numberLocation;
//                [appController.locationArray addObject: newSpotPlaceMark];
//                [self.mapView addAnnotation:from];
//                [self zoomMapViewToFitAnnotations:self.mapView animated:YES];
//
//                
//            }
//            else{
//                
////                [commonUtils showVAlertSimple:@"Notification!" body:@"Please tap the location again." duration:1.2];
//                
//            }
//
//            
//        }];

}
- (IBAction)onClickResetBtn:(id)sender {
    
    //[self.mapView removeAnnotations:self.mapView.annotations];
    appController.locationArray = [NSMutableArray new];
    _distanceArray = [NSMutableArray new];
    _firstPointArray = [NSMutableArray new];
    _secondPointArray = [NSMutableArray new];
    _thirdPointArray = [NSMutableArray new];
    _fourthPointArray = [NSMutableArray new];
    NSArray *pointsArray = [_mapView overlays];
    [_mapView removeOverlays:pointsArray];
    [_mapView removeAnnotations:_mapView.annotations];
    //_mapView = [[MKMapView alloc] init];
    
    [self initUI];
    [self getCurrentLocationAddress];
    


    
}

- (IBAction)onClickOptimizingRoute:(id)sender {
    
    if ([appController.locationArray count] < 4) {

        //[commonUtils showVAlertSimple:@"Warnning!" body:@"Number of Locations should be at least three." duration:1.2];
        return;
    }
    NSLog(@"LocationArray: \n%@", appController.locationArray);
    
    
    
    
    for (int i = 0; i<6; i++) {
        [_firstPointArray addObject: [NSString stringWithFormat:@"%d", 0]];
    }
    [_secondPointArray addObject: [NSString stringWithFormat:@"%d", 1]];
    [_secondPointArray addObject: [NSString stringWithFormat:@"%d", 1]];
    [_secondPointArray addObject: [NSString stringWithFormat:@"%d", 2]];
    [_secondPointArray addObject: [NSString stringWithFormat:@"%d", 2]];
    [_secondPointArray addObject: [NSString stringWithFormat:@"%d", 3]];
    [_secondPointArray addObject: [NSString stringWithFormat:@"%d", 3]];
    
    [_thirdPointArray addObject: [NSString stringWithFormat:@"%d", 2]];
    [_thirdPointArray addObject: [NSString stringWithFormat:@"%d", 3]];
    [_thirdPointArray addObject: [NSString stringWithFormat:@"%d", 1]];
    [_thirdPointArray addObject: [NSString stringWithFormat:@"%d", 3]];
    [_thirdPointArray addObject: [NSString stringWithFormat:@"%d", 1]];
    [_thirdPointArray addObject: [NSString stringWithFormat:@"%d", 2]];
    
    [_fourthPointArray addObject: [NSString stringWithFormat:@"%d", 3]];
    [_fourthPointArray addObject: [NSString stringWithFormat:@"%d", 2]];
    [_fourthPointArray addObject: [NSString stringWithFormat:@"%d", 3]];
    [_fourthPointArray addObject: [NSString stringWithFormat:@"%d", 1]];
    [_fourthPointArray addObject: [NSString stringWithFormat:@"%d", 2]];
    [_fourthPointArray addObject: [NSString stringWithFormat:@"%d", 1]];
    
    
    [self caclDistancePolyLine: 0];
   
    
}

- (void) caclDistancePolyLine: (int) ID{
    
   
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    //__block BOOL returnValu = NO;
    [commonUtils showActivityIndicatorColored:self.view];
    switch (ID) {
        case 0:
            
            _distance = 0;
            
            if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                
                
                MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
                // firstLine
                __block MKPlacemark *sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:0]];
                directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
                __block MKPlacemark *destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                __block MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                
                //__block BOOL isCompleting = NO;
                
                
                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@", error.description);
                        
                    } else {
                        routeDetails = response.routes.lastObject;
                        allRoute = response.routes.lastObject;
                        _distance += allRoute.distance;
                        
                        //SecondLine
                        sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                        destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                        directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                        directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                        
                        
                        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                            if (error) {
                                NSLog(@"Error %@", error.description);
                            } else {
                                routeDetails = response.routes.lastObject;
                                allRoute = response.routes.lastObject;
                                _distance += allRoute.distance;
                                //Third Line
                                
                                sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                                destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_fourthPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                                directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                                
                                
                                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                                    if (error) {
                                        NSLog(@"Error %@", error.description);
                                    } else {
                                        routeDetails = response.routes.lastObject;
                                        allRoute = response.routes.lastObject;
                                        _distance += allRoute.distance;
                                        _d1 = _distance;
                                        [self caclDistancePolyLine:1];
                                        //isCompleting = YES;
                                        //returnValu = isCompleting;
                                        //[commonUtils hideActivityIndicator];
                                        
                                    }
                                }];

                                
                            }
                        }];

                    }
                }];
                
            }
            
            break;
        case 1:
            _distance = 0;

            if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                
                MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
                // firstLine
                __block MKPlacemark *sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:0]];
                directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
                __block MKPlacemark *destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                __block MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                
                //__block BOOL isCompleting = NO;
                
                //[commonUtils showActivityIndicatorColored:self.view];
                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@", error.description);
                    } else {
                        routeDetails = response.routes.lastObject;
                        allRoute = response.routes.lastObject;
                        _distance += allRoute.distance;
                        //SecondLine
                        
                        sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                        destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                        directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                        directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                        
                        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                            if (error) {
                                NSLog(@"Error %@", error.description);
                            } else {
                                routeDetails = response.routes.lastObject;
                                allRoute = response.routes.lastObject;
                                _distance += allRoute.distance;
                                //Third Line
                                
                                sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                                destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_fourthPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                                directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                                
                                
                                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                                    if (error) {
                                        NSLog(@"Error %@", error.description);
                                    } else {
                                        routeDetails = response.routes.lastObject;
                                        allRoute = response.routes.lastObject;
                                        _distance += allRoute.distance;
                                        //[commonUtils hideActivityIndicator];
                                        _d2 = _distance;
                                        [self caclDistancePolyLine:2];
                                        //isCompleting = YES;
                                        //returnValu = isCompleting;
                                    }
                                }];

                                
                            }
                        }];

                        
                    }
                }];
            }
            break;
        case 2:
            _distance = 0;
            if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                
                
                MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
                // firstLine
                __block MKPlacemark *sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:0]];
                directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
                __block MKPlacemark *destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                __block MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                
                //__block BOOL isCompleting = NO;

                
                //[commonUtils showActivityIndicatorColored:self.view];
                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@", error.description);
                    } else {
                        routeDetails = response.routes.lastObject;
                        allRoute = response.routes.lastObject;
                        _distance += allRoute.distance;
                        //SecondLine
                        
                        sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                        destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                        directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                        directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                        
                        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                            if (error) {
                                NSLog(@"Error %@", error.description);
                            } else {
                                routeDetails = response.routes.lastObject;
                                allRoute = response.routes.lastObject;
                                _distance += allRoute.distance;
                                //Third Line
                                
                                sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                                destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_fourthPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                                directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                                    if (error) {
                                        NSLog(@"Error %@", error.description);
                                    } else {
                                        routeDetails = response.routes.lastObject;
                                        allRoute = response.routes.lastObject;
                                        _distance += allRoute.distance;
                                        _d3 = _distance;
                                        [self caclDistancePolyLine:3];
                                        //[commonUtils hideActivityIndicator];
                                        //isCompleting = YES;
                                        //returnValu = isCompleting;
                                    }
                                }];

                                
                            }
                        }];
                    }
                }];
             }
            break;
        case 3:
            _distance = 0;
            if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                
                
                MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
                // firstLine
                __block MKPlacemark *sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:0]];
                directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
                __block MKPlacemark *destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                __block MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                
                //__block BOOL isCompleting = NO;

                
                //[commonUtils showActivityIndicatorColored:self.view];
                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@", error.description);
                    } else {
                        routeDetails = response.routes.lastObject;
                        allRoute = response.routes.lastObject;
                        _distance += allRoute.distance;
                        //SecondLine
                        
                        sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                        destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                        directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                        directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                        
                        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                            if (error) {
                                NSLog(@"Error %@", error.description);
                            } else {
                                routeDetails = response.routes.lastObject;
                                allRoute = response.routes.lastObject;
                                _distance += allRoute.distance;
                                //Third Line
                                
                                sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                                destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_fourthPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                                directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                                
                                
                                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                                    if (error) {
                                        NSLog(@"Error %@", error.description);
                                    } else {
                                        routeDetails = response.routes.lastObject;
                                        allRoute = response.routes.lastObject;
                                        _distance += allRoute.distance;
                                        _d4 = _distance;
                                        [self caclDistancePolyLine:4];
                                        
                                        //[commonUtils hideActivityIndicator];
                                        //isCompleting = YES;
                                        //returnValu = isCompleting;
                                        
                                    }
                                }];
                                
                            }
                        }];

                    }
                }];
                
            }
            break;
        case 4:
            _distance = 0;

            if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                
                
                MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
                // firstLine
                __block MKPlacemark *sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:0]];
                directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
                __block MKPlacemark *destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                __block MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                
                //__block BOOL isCompleting = NO;

                
                //[commonUtils showActivityIndicatorColored:self.view];
                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@", error.description);
                    } else {
                        routeDetails = response.routes.lastObject;
                        allRoute = response.routes.lastObject;
                        _distance += allRoute.distance;
                        //SecondLine
                        
                        sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                        destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                        directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                        directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                        
                        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                            if (error) {
                                NSLog(@"Error %@", error.description);
                            } else {
                                routeDetails = response.routes.lastObject;
                                allRoute = response.routes.lastObject;
                                _distance += allRoute.distance;
                                //Third Line
                                
                                sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                                destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_fourthPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                                directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                                
                                
                                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                                    if (error) {
                                        NSLog(@"Error %@", error.description);
                                    } else {
                                        routeDetails = response.routes.lastObject;
                                        allRoute = response.routes.lastObject;
                                        _distance += allRoute.distance;
                                        _d5 = _distance;
                                        [self caclDistancePolyLine:5];
                                        //[commonUtils hideActivityIndicator];
                                        //isCompleting = YES;
                                        //returnValu = isCompleting;
                                        
                                    }
                                }];
                                
                            }
                        }];
                    }
                }];

            }
            break;
        case 5:
            _distance = 0;

            if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                
                
                MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
                // firstLine
                __block MKPlacemark *sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:0]];
                directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
                __block MKPlacemark *destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                __block MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                
                //__block BOOL isCompleting = NO;

                
                //[commonUtils showActivityIndicatorColored:self.view];
                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@", error.description);
                    } else {
                        routeDetails = response.routes.lastObject;
                        allRoute = response.routes.lastObject;
                        _distance += allRoute.distance;
                        //SecondLine
                        
                        sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                        destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                        directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                        directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                        
                        
                        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                            if (error) {
                                NSLog(@"Error %@", error.description);
                            } else {
                                routeDetails = response.routes.lastObject;
                                allRoute = response.routes.lastObject;
                                _distance += allRoute.distance;
                                //Third Line
                                
                                sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                                destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_fourthPointArray objectAtIndex:ID] intValue]]];
                                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                                directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                                
                                
                                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                                    if (error) {
                                        NSLog(@"Error %@", error.description);
                                    } else {
                                        routeDetails = response.routes.lastObject;
                                        allRoute = response.routes.lastObject;
                                        _distance += allRoute.distance;
                                        _d6 = _distance;
                                        [commonUtils hideActivityIndicator];
                                        
                                        [_distanceArray addObject: [NSString stringWithFormat:@"%f", _d1]];
                                        [_distanceArray addObject: [NSString stringWithFormat:@"%f", _d2]];
                                        [_distanceArray addObject: [NSString stringWithFormat:@"%f", _d3]];
                                        [_distanceArray addObject: [NSString stringWithFormat:@"%f", _d4]];
                                        [_distanceArray addObject: [NSString stringWithFormat:@"%f", _d5]];
                                        [_distanceArray addObject: [NSString stringWithFormat:@"%f", _d6]];
                                        
                                        
                                        
                                        CLLocationDistance minDistance = [[_distanceArray objectAtIndex:0] doubleValue];
                                        int minID = 0;
                                        for (int i = 1; i < 6; i++) {
                                            
                                            if (minDistance > [[_distanceArray objectAtIndex:i] doubleValue]) {
                                                minDistance = [[_distanceArray objectAtIndex:i] doubleValue];
                                                minID = i;
                                            }
                                            
                                        }
                                        
                                        [self drawoptimizingPolyLine:minID];

                                        //isCompleting = YES;
                                        //returnValu = isCompleting;
                                        
                                    }
                                }];

                                
                            }
                        }];
                        
                    }
                }];
            }
            break;
            
        default:
            break;
            
            

    }
    
    
   
}

- (void) drawoptimizingPolyLine: (int) ID{
    
    
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    //__block CLLocationDistance distanceDirection;
    if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        
        MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
        // firstLine
        __block MKPlacemark *sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:0]];
        directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
        __block MKPlacemark *destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
        directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
        directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
        __block MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
        
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error.description);
            } else {
                routeDetails = response.routes.lastObject;
                allRoute = response.routes.lastObject;
                //_distance += allRoute.distance;
                _colorNum = 1;
                [self.mapView addOverlay:routeDetails.polyline];
                
                sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_secondPointArray objectAtIndex:ID] intValue]]];
                directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                
                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@", error.description);
                    } else {
                        routeDetails = response.routes.lastObject;
                        allRoute = response.routes.lastObject;
                        //_distance += allRoute.distance;
                        _colorNum = 2;
                        [self.mapView addOverlay:routeDetails.polyline];
                        
                        sourceplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_thirdPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:sourceplacemark];
                        destinationplacemark = [[MKPlacemark alloc] initWithPlacemark:[appController.locationArray objectAtIndex:[[_fourthPointArray objectAtIndex:ID] intValue]]];
                        directionsRequest.destination =[[MKMapItem alloc] initWithPlacemark:destinationplacemark];
                        directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                        directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                        
                        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                            if (error) {
                                NSLog(@"Error %@", error.description);
                            } else {
                                routeDetails = response.routes.lastObject;
                                allRoute = response.routes.lastObject;
                                _colorNum = 3;
                                //_distance += allRoute.distance;
                                [self.mapView addOverlay:routeDetails.polyline];
                                
                                [_resetBtn setTitleColor:[UIColor whiteColor] forState:normal];
                                //[_resetBtn setBackgroundColor:]
                                [_resetBtn setUserInteractionEnabled:YES];
                                
                                [_calcOptimizingRouteBtn setTitleColor:[UIColor lightGrayColor] forState:normal];
                                //[_calcOptimizingRouteBtn setBackgroundColor:]
                                [_calcOptimizingRouteBtn setUserInteractionEnabled:NO];
                                
                                //self.allSteps = @"";
                                for (int i = 0; i < routeDetails.steps.count; i++) {
                                    MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
                                    NSString *newStep = step.instructions;
                                    //self.allSteps = [self.allSteps stringByAppendingString:newStep];
                                    //self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
                                    //self.steps.text = self.allSteps;
                                }
                            }
                        }];
                        //self.allSteps = @"";
                        for (int i = 0; i < routeDetails.steps.count; i++) {
                            MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
                            NSString *newStep = step.instructions;
                            //self.allSteps = [self.allSteps stringByAppendingString:newStep];
                            //self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
                            //self.steps.text = self.allSteps;
                        }
                    }
                }];

                //self.allSteps = @"";
                for (int i = 0; i < routeDetails.steps.count; i++) {
                    MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
                    NSString *newStep = step.instructions;
                    //self.allSteps = [self.allSteps stringByAppendingString:newStep];
                    //self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
                    //self.steps.text = self.allSteps;
                }
            }
        }];
        
    }
    
    
}

#pragma MapView Custom Method
- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated {
    
    NSArray *annotations = self.mapView.annotations;
    int count = (int)[self.mapView.annotations count];
    if ( count == 0) { return; } //bail if no annotations
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //this is center of region
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:animated];
}
- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        self.mapView.showsUserLocation = YES;
        return nil;
    }
    MKAnnotationView *pin = (MKAnnotationView *) [map dequeueReusableAnnotationViewWithIdentifier: @"location"];
    if (pin == nil){
        pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: @"location"];
    }else{
        pin.annotation = annotation;
    }
    pin.canShowCallout = YES;
    pin.userInteractionEnabled = YES;
    //pin.animatesDrop = NO;
    PlaceMark *ann = (PlaceMark *)annotation;
    NSString *pinImageStr = @"spot_pin_red";
    pin.image = [UIImage imageNamed:pinImageStr];
    
    //    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //    //  [ pin removeFromSuperview];
    CGRect frame = CGRectMake(2, 2, 20, 20);
    UILabel *spot = [[UILabel alloc] initWithFrame:frame];
    [ spot setFont:[UIFont systemFontOfSize:10]];
    spot.textAlignment = NSTextAlignmentCenter;
    spot.textColor = [UIColor whiteColor];
    //NSUInteger indexVal = [map.annotations indexOfObject:annotation];
    spot.text = [NSString stringWithFormat:@"%d",ann.tag];
    [ pin addSubview:spot];
    
    return pin;
    
}
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *annotationView;
    
    for (annotationView in views) {
        
        // Don't pin drop if annotation is user location
        if ([annotationView.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        
        // Check if current annotation is inside visible map rect, else go to next one
        MKMapPoint point =  MKMapPointForCoordinate(annotationView.annotation.coordinate);
        if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
            continue;
        }
        
        CGRect endFrame = annotationView.frame;
        
        // Move annotation out of view
        annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y - self.view.frame.size.height, annotationView.frame.size.width, annotationView.frame.size.height);
        
        // Animate drop
        [UIView animateWithDuration:0.4
                              delay:0.04*[views indexOfObject:annotationView]
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             annotationView.frame = endFrame;
                             
                             // Animate squash
                         }
                         completion:^(BOOL finished){
                             if (finished) {
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      annotationView.transform = CGAffineTransformMakeScale(1.0, 0.8);
                                                      
                                                  }
                                                  completion:^(BOOL finished){
                                                      if (finished) {
                                                          [UIView animateWithDuration:0.1 animations:^{
                                                              annotationView.transform = CGAffineTransformIdentity;
                                                          }];
                                                      }
                                                  }];
                             }
                         }];
    }
}


#pragma the route in custom MapView

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeDetails.polyline];
    switch (_colorNum) {
        case 1:
            routeLineRenderer.strokeColor = [UIColor redColor];
            break;
        case 2:
            routeLineRenderer.strokeColor = [UIColor blueColor];
            break;
        case 3:
            routeLineRenderer.strokeColor = [UIColor greenColor];
            break;
        default:
            routeLineRenderer.strokeColor = [UIColor yellowColor];
            break;
    }
    
    routeLineRenderer.lineWidth = 5.0f;
    return routeLineRenderer;
}

#pragma mark - GoogleAutoComplete Delegate

-(void) GoogleAutoCompleteViewControllerDismissedWithAddress:(NSString *)address AndPlacemark:(CLPlacemark *)placeMark ForTextObj:(NSInteger *)textObjTag {
    
    [appController.locationArray addObject:placeMark];
    
}

- (void)GoogleAutoCompleteViewControllerDismissedWithAddress:(NSString *)address AndLocation:(CLLocation *)location ForTextObj:(NSInteger *)textObjTag{
    //    NSLog(@"selected address : %@", address);
    NSString *addLocationAddress = @"";
    //    addLocationAddress = [commonUtils removeCharactersFromString:address withFormat:@[@"&"]];
    addLocationAddress = [address stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
    //    NSLog(addLocationAddress);
    
    if([addLocationAddress isEqualToString:@""]) {
        [commonUtils showVAlertSimple:@"Warning" body:@"Please try again with different address to add" duration:1.3f];
    } else {
        
        //NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        [_locationNameArray addObject:addLocationAddress];
        
        Place *home = [[Place alloc] init];
        home.name = addLocationAddress;
        home.description = @"";
        home.latitude = (float)location.coordinate.latitude;
        home.longitude = (float)location.coordinate.longitude;
        PlaceMark* from = [[PlaceMark alloc] initWithPlace:home];
        from.tag = _num;
        [self.mapView addAnnotation:from];
        [self zoomMapViewToFitAnnotations:self.mapView animated:YES];
//        //[_locationTableView reloadData];
//        
//                geocoder = [[CLGeocoder alloc] init];
//        
//                __block BOOL isGetAdressSuccess;
//        
//                NSLog(@"Resolving the Address");
//        
//     
//               [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//                   
//                    if (error == nil) {
//                        newSpotPlaceMark = [placemarks lastObject];
//
//                        isGetAdressSuccess = YES;
//        
//                    } else {
//                        NSLog(@"%@", error.debugDescription);
//                        isGetAdressSuccess = NO;
//        
//                    }
//                    if (isGetAdressSuccess) {
//        
//                        [appController.locationArray addObject: newSpotPlaceMark];
//       
//                        
//                    }
//                    else{
//                        
//        //                [commonUtils showVAlertSimple:@"Notification!" body:@"Please tap the location again." duration:1.2];
//                        
//                    }
//        
//                    
//                }];

        
     }
}
- (IBAction) onAddLocation:(UIButton *)sender {
    
    _num++;
    if (_num > 3) {
        
        //[_addLocationBtn setUserInteractionEnabled:NO];
        
        return;
    }
    if (_num == 3) {
        [_calcOptimizingRouteBtn setTitleColor:[UIColor whiteColor] forState:normal];
        //[_calcOptimizingRouteBtn setBackgroundColor:]
        [_calcOptimizingRouteBtn setUserInteractionEnabled:YES];
        
        [_addLocationBtn setTitleColor:[UIColor lightGrayColor] forState:normal];
        //[_addLocationBtn setBackgroundColor:]
        [_addLocationBtn setUserInteractionEnabled:NO];

    }
    
    _locationNameArray = [[NSMutableArray alloc]init];
    
    GoogleAutoCompleteViewController *pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"googleAutoCompletePage"];
    pageViewController.GoogleAutoCompleteViewDelegate = self;
    [self presentViewController:pageViewController animated:YES completion:nil];
    //    [self.navigationController pushViewController:pageViewController animated:YES];
}


//#pragma TableView Delegate
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    
//    return _num;
//    
//}
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    AddLocationTableViewCell* cell = (AddLocationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"locationTableCell"];
//    
//    cell.locationName.text = [_locationNameArray objectAtIndex:indexPath.row];
//    
//    return cell;
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
