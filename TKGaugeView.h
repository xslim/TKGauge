//
//  TKGaugeView.h
//  TKGauge
//
//  Created by Taras Kalapun on 6/18/12.
//

#import <UIKit/UIKit.h>

@interface TKGaugeView : UIView {
    BOOL disableLayout;
}

@property (nonatomic, retain) NSString *skinPath;
@property (nonatomic, retain) NSDictionary *skin;

@property (nonatomic, retain) UIImageView *bg;
@property (nonatomic, retain) UIImageView *arrow;
@property (nonatomic, retain) UIImageView *cap;
@property (nonatomic, retain) UIImageView *warn;

@property (nonatomic, retain) UILabel *digitalLabel;

- (void)reloadImages;
- (void)disableLayout;
- (void)enableLayout;
- (void)resetArrow;

@end
