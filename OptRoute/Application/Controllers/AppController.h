//
//  AppController.h
//  OptRoute
//
//  Created by New Star on 1/20/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppController : NSObject

@property (assign, nonatomic) double user_current_latitude, user_current_longitude;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) NSMutableArray *locationArray;
@property (assign, nonatomic) int numberOfLocation;

@property (nonatomic, strong) UIColor *appMainColor;


+ (AppController *)sharedInstance;

@end
