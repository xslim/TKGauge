//
//  TKSimpleDataFilter.h
//  TKGauge
//
//  Created by Taras Kalapun on 6/18/12.
//


#import <Foundation/Foundation.h>

//float rand_FloatRange(float a, float b);

@interface TKSimpleDataFilter : NSObject {
    int num_average_max;
    int num_average_allocated;
    int num_average_elements;
    float *averageStack;
}

+ (float)floatRandFrom:(float)from to:(float)to;
+ (float)averageFor:(int)num,...;
- (void)setMaxAverageCount:(int)max;
- (int)maxAverageCount;
- (BOOL)addToAverageStack:(float)f orAverage:(float*)average;

@end
