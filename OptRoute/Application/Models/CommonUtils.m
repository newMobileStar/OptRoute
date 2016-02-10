//
//  CommonUtils.m
//  OptRoute
//
//  Created by New Star on 1/20/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils

+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)showVAlertSimple:(NSString *)title body:(NSString *)body duration:(float)duration {
    _dicAlertContent = [[NSMutableDictionary alloc] init];
    [_dicAlertContent setObject:title forKey:@"title"];
    [_dicAlertContent setObject:body forKey:@"body"];
    [_dicAlertContent setObject:[NSString stringWithFormat:@"%f", duration] forKey:@"duration"];
    
    [self performSelector:@selector(vAlertSimpleThread) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}

- (void)showActivityIndicatorColored:(UIView *)inView {
    //    [[ActivityIndicator currentIndicator] show];
    if (activityIndicator) {
        [self hideActivityIndicator];
    }
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator setHidden:NO];
    activityIndicator.center = inView.center;
    activityIndicator.color = appController.appMainColor;
    [activityIndicator startAnimating];
    [activityIndicator.layer setZPosition:999];
    [inView addSubview:activityIndicator];
    //    [inView setUserInteractionEnabled:NO];
}
- (void)hideActivityIndicator {
    //    [[ActivityIndicator currentIndicator] hide];
    //    [activityIndicator.superview setUserInteractionEnabled:YES];
    [activityIndicator setHidden:YES];
    [activityIndicator removeFromSuperview];
    activityIndicator = nil;
}
- (id)getUserDefault:(NSString *)key {
    id val = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    //if([val isKindOfClass:[NSMutableArray class]] && val == nil) return @"";
    if([val isKindOfClass:[NSString class]] && (val == nil || val == NULL || [val isEqualToString:@"0"])) val = nil;
    return val;
}
- (void)setUserDefault:(NSString *)key withFormat:(id)val {
    if([val isKindOfClass:[NSString class]] && [val isEqualToString:@""]) val = @"0";
    [[NSUserDefaults standardUserDefaults] setObject:val forKey:key];
}
- (void)removeUserDefault:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (void) removeAllSubViews:(UIView *) view {
    for (long i=view.subviews.count-1; i>=0; i--) {
        [[view.subviews objectAtIndex:i] removeFromSuperview];
    }
}

- (void) setRoundedRectBorderButton:(UIButton *)button withBorderWidth:(float) borderWidth withBorderColor:(UIColor *) color withBorderRadius:(float)radius{
    button.clipsToBounds = YES;
    button.layer.cornerRadius = radius;
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = borderWidth;
}

@end
