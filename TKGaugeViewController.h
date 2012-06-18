//
//  TKGaugeViewController.h
//  TKGauge
//
//  Created by Taras Kalapun on 6/18/12.
//

// NOTE: Include in your subclass header to use sound !
//#include <AudioToolbox/AudioToolbox.h>

#import <UIKit/UIKit.h>

@class TKSimpleDataFilter, TKGaugeView;

@interface TKGaugeViewController : UIViewController {
    float scaleMin;
    float scaleMax;
    
    float arrowAngleMin;
    float arrowAngleMax;
    
    float warnHigh;
    float warnLow;
    BOOL warnSound;
    BOOL isWelcome;
    
    BOOL viewLoaded;
}

@property (nonatomic, strong) TKGaugeView *gaugeView;

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString *gaugePath;
@property (nonatomic, retain) NSString *skinPath;
@property (nonatomic, retain) NSString *conversion;
@property (nonatomic, retain) NSDictionary *mainConfig;
@property (nonatomic, retain) NSDictionary *skinConfig;
@property (nonatomic, retain) TKSimpleDataFilter *dataFilter;
@property (nonatomic, readonly) BOOL isFramePreset;

@property (nonatomic, assign) BOOL allowDrag;
@property (nonatomic, assign) BOOL allowResizeOnPinch;
@property (nonatomic, assign) BOOL savePositionAndSize;
@property (nonatomic, assign) BOOL warnOnDoubleTap;


- (void)savePosition;
- (void)randomRotate;
- (void)setValue:(float)aValue;
- (void)warn;
- (void)welcome;

- (float)minValue;
- (float)maxValue;

@end
