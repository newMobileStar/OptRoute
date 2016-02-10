//
//  Place.h
//  iTransitBuddy
//
//  Created by Blue Technology Solutions LLC 09/09/2008.
//  Copyright 2010 Blue Technology Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Place : NSObject {

	NSString* name;
	NSString* description;
	double latitude;
	double longitude;
}

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* description;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
