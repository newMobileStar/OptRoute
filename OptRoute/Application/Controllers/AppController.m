//
//  AppController.m
//  OptRoute
//
//  Created by New Star on 1/20/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import "AppController.h"
#import <UIKit/UIKit.h>

static AppController *_appController;

@implementation AppController

+ (AppController *)sharedInstance {
    static dispatch_once_t predicate;
    if (_appController == nil) {
        dispatch_once(&predicate, ^{
            _appController = [[AppController alloc] init];
        });
    }
    return _appController;
}

- (id)init {
    self = [super init];
    if (self) {
        
        //My variable Init
        
        _numberOfLocation = 3;
        
        _locationArray = [[NSMutableArray alloc]init];
//        _locationArray = [@[
//                            [@[@"34.003254", @"-122.230215"] mutableCopy],
//                            [@[@"34.003254", @"-122.230215"] mutableCopy],
//                            [@[@"34.003254", @"-122.230215"] mutableCopy],
//                            [@[@"34.003254", @"-122.230215"] mutableCopy]
//                            ] mutableCopy];
        
        _appMainColor = [UIColor redColor];

    }
    return self;
}

@end
