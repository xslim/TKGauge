//
//  TKGaugeView.m
//  TKGauge
//
//  Created by Taras Kalapun on 6/18/12.
//

#import "TKGaugeView.h"
#import <QuartzCore/QuartzCore.h>

#define DEGTORAD(x) ((x)*(M_PI/180.0))

@interface TKGaugeView ()
- (UIColor *)colorFromHexString:(NSString *)hexString;
- (UIImage *)imageFromSkinPath:(NSString *)imagePath;
@end

@implementation TKGaugeView

@synthesize skin, skinPath, bg, arrow, cap, warn, digitalLabel, dimentionLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor redColor];
        
        self.bg = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.bg.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        
        self.arrow = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.arrow.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        self.cap = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.cap.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        self.warn = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.warn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        //self.warn.hidden = YES;
        self.warn.alpha = 0.0f;
        
        CGRect digitalLabelFrame = CGRectZero;
        self.digitalLabel = [[UILabel alloc] initWithFrame:digitalLabelFrame];
        self.digitalLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        self.digitalLabel.backgroundColor = [UIColor clearColor];
        self.digitalLabel.textColor = [UIColor redColor];
        self.digitalLabel.textAlignment = UITextAlignmentLeft;
        
        CGRect dimentionLabelFrame = CGRectZero;
        self.dimentionLabel = [[UILabel alloc] initWithFrame:dimentionLabelFrame];
        self.dimentionLabel.font = [UIFont boldSystemFontOfSize:20];
        self.dimentionLabel.backgroundColor = [UIColor clearColor];
        self.dimentionLabel.textColor = [UIColor redColor];
        self.dimentionLabel.textAlignment = UITextAlignmentLeft;
        
        [self addSubview:self.bg];
        [self addSubview:self.warn];
        [self addSubview:self.arrow];
        [self addSubview:self.cap];
        [self addSubview:self.digitalLabel];
        [self addSubview:self.dimentionLabel];
        
        
        [self reloadImages];
        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)reloadImages
{
    if (!self.skinPath) return;
    
    // Background
    self.bg.image = [self imageFromSkinPath:@"bg.png"];
    
    // Arrow
    self.arrow.image = [self imageFromSkinPath:@"arrow.png"];
    
    // Cap
    self.cap.image = [self imageFromSkinPath:@"cap.png"];
    
    // Warn
    self.warn.image = [self imageFromSkinPath:@"warn.png"];
}

- (void)disableLayout {
    disableLayout = YES;
}

- (void)enableLayout {
    disableLayout = NO;
}

- (void)resetArrow
{
    CGFloat minAngle = [[self.skin objectForKey:@"arrowAngleMin"] floatValue];
    self.arrow.transform = CGAffineTransformMakeRotation(DEGTORAD(minAngle));
}

- (void)layoutSubviews {
    
    if (disableLayout) return;
    
    [super layoutSubviews];
    
    // Hack not to layout after dismissing modal
    /*
     CGRect sb = [UIScreen mainScreen].bounds;
     if (self.bounds.size.width == sb.size.width || self.bounds.size.height == sb.size.height) {
     NSLog(@"Applied layout Hack");
     return;
     }
     */
    
    
    if (!self.skin) return;
    
    //NSLog(@"Layouting Gauge subviews");
    
    //NSLog(@"Setting Gauges: %@", info);
    
    CGRect imRect;
    CGSize imSize;
    CGSize bgSize = CGSizeFromString([self.skin objectForKey:@"bgSize"]);
    
    // Calculate aspect for other images
    CGFloat aspect = bgSize.width / self.bounds.size.width;
    
    // Background
    imSize = bgSize;
    imRect.origin = CGPointZero;
    imRect.size = CGSizeMake(imSize.width / aspect, imSize.height / aspect);
    self.bg.frame = imRect;
    
    // Arrow
    imSize = CGSizeFromString([self.skin objectForKey:@"arrowSize"]);
    
    // Calculate arrow position
    CGPoint bgAxis = CGPointFromString([self.skin objectForKey:@"bgAxis"]);
    CGPoint arrowAxis = CGPointFromString([self.skin objectForKey:@"arrowAxis"]);
    CGPoint arrowAxisAspect = CGPointMake((bgAxis.x - arrowAxis.x)/aspect, (bgAxis.y - arrowAxis.y)/aspect);
    imRect.origin = arrowAxisAspect;
    
    imRect.size = CGSizeMake(imSize.width / aspect, imSize.height / aspect);
    CGPoint arrowAnchorPoint = CGPointMake(arrowAxis.x/imSize.width, arrowAxis.y/imSize.height);
    self.arrow.layer.anchorPoint = arrowAnchorPoint;
    
    self.arrow.frame = imRect;
    //self.arrow.backgroundColor = [UIColor lightGrayColor];
    
    
    // Cap
    imSize = CGSizeFromString([self.skin objectForKey:@"capSize"]);
    CGFloat capAxisX = bgSize.width/2/aspect - imSize.width / 2 / aspect;
    imRect.origin = CGPointMake(capAxisX, capAxisX);
    CGSize capSize = CGSizeMake(imSize.width / aspect, imSize.height / aspect);
    imRect.size = capSize;
    self.cap.frame = imRect;
    
    // Warn
    imSize = CGSizeFromString([self.skin objectForKey:@"warnSize"]);
    CGPoint warnAxis = CGPointFromString([self.skin objectForKey:@"warnPosition"]);
    imRect.origin = CGPointMake(warnAxis.x/aspect, warnAxis.y/aspect);
    imRect.size = CGSizeMake(imSize.width / aspect, imSize.height / aspect);
    self.warn.frame = imRect;
    
    //digitalLabel
    
    CGRect digitalLabelFrame = CGRectFromString([self.skin objectForKey:@"digitalLabelFrame"]);
    digitalLabelFrame.origin.x = digitalLabelFrame.origin.x /aspect;
    digitalLabelFrame.origin.y = digitalLabelFrame.origin.y /aspect;
    digitalLabelFrame.size.width = digitalLabelFrame.size.width /aspect;
    digitalLabelFrame.size.height = digitalLabelFrame.size.height /aspect;
    
    CGRect dimentionLabelFrame = CGRectFromString([self.skin objectForKey:@"dimentionLabelFrame"]);
    dimentionLabelFrame.origin.x = dimentionLabelFrame.origin.x /aspect;
    dimentionLabelFrame.origin.y = dimentionLabelFrame.origin.y /aspect;
    dimentionLabelFrame.size.width = dimentionLabelFrame.size.width /aspect;
    dimentionLabelFrame.size.height = dimentionLabelFrame.size.height /aspect;
    
    NSString *dlColor = nil;
    dlColor = [self.skin objectForKey:@"digitalLabelColor"];
    if (dlColor) {
        UIColor *c = [self colorFromHexString:dlColor];
        if (c) self.digitalLabel.textColor = c;
    }
    
    self.digitalLabel.frame = digitalLabelFrame;
    self.dimentionLabel.frame = dimentionLabelFrame;
}

#pragma mark - Helpers

#define UIColorFromRGBA(rgbValue, alphaValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:alphaValue])
#define UIColorFromRGB(rgbValue) (UIColorFromRGBA((rgbValue), 1.0))

- (UIColor *)colorFromHexString:(NSString *)hexString {
    
    if (!hexString) return nil;
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hex;
    BOOL success = [scanner scanHexInt:&hex];
    
    if (!success) return nil;
    
    UIColor *color = UIColorFromRGB(hex);
    return color;
}

- (UIImage *)imageFromSkinPath:(NSString *)imagePath {
    return [UIImage imageWithContentsOfFile:[self.skinPath stringByAppendingPathComponent:imagePath]];
}

@end
