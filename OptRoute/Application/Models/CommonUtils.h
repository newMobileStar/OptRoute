//
//  CommonUtils.h
//  OptRoute
//
//  Created by New Star on 1/20/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtils : NSObject {
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) NSMutableDictionary *dicAlertContent;

+ (instancetype)shared;

- (void)showAlert:(NSString *)title withMessage:(NSString *)message;
- (void)showVAlertSimple:(NSString *)title body:(NSString *)body duration:(float)duration;
- (NSString *)getUserDefault:(NSString *)key;
- (void)setUserDefault:(NSString *)key withFormat:(NSString *)val;
- (void)removeUserDefault:(NSString *)key;
- (void) setRoundedRectBorderButton:(UIButton *)button withBorderWidth:(float)width withBorderColor:(UIColor *)color withBorderRadius:(float)radius;

- (void)showActivityIndicatorColored:(UIView *)inView ;
- (void)hideActivityIndicator;

- (void)removeAllSubViews:(UIView *) view;


@end
