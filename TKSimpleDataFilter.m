//
//  TKSimpleDataFilter.m
//  TKGauge
//
//  Created by Taras Kalapun on 6/18/12.
//


#import "TKSimpleDataFilter.h"


@implementation TKSimpleDataFilter

- (void)dealloc {
    
    // TODO: Test !
    // Deallocate!
    free(averageStack);
    
    //[super dealloc];
}

+ (float)floatRandFrom:(float)from to:(float)to {
    return ((to - from) * ((float)rand() / RAND_MAX)) + from;
}

+ (float)averageFor:(int)num,... {
    float total = 0.0f;
    int count = 0;
    
    va_list va;
    va_start(va, num);
    
    while (count < num) {
        total += va_arg(va, float); //TODO: fix this warning
        count++;
    }

    va_end(va);
    
    return total / count;
}

- (void)setMaxAverageCount:(int)max {
    num_average_max = max;
}

- (int)maxAverageCount {
    return num_average_max;
}

- (BOOL)addToAverageStack:(float)f orAverage:(float*)average {
    //NSLog(@"will add: %f", f);
    
    if (num_average_elements < num_average_max) {
        
        if (num_average_elements == num_average_allocated) {
            if (num_average_allocated == 0)
                num_average_allocated = 5; // Start off with 5 refs
            else
                num_average_allocated *= 2;
            
            // Make the reallocation transactional
            // by using a temporary variable first
            void *_tmp = realloc(averageStack, (num_average_allocated * sizeof(float)));
            
            // If the reallocation didn't go so well,
            // inform the user and bail out
            if (!_tmp)
            {
                fprintf(stderr, "ERROR: Couldn't realloc memory!\n");
                return(-1);
            }
            
            // Things are looking good so far
            averageStack = (float*)_tmp;
        }
        
        averageStack[num_average_elements] = f;
        num_average_elements++;
        
        //NSLog(@"num elements: %d", num_average_elements);
        
        return YES;
        
    } else {
        
        float total = 0.0f;

        int i;
        for (i = 0; i < num_average_elements; i++) {
            total += averageStack[i];
        }
        
        total = total / i;
        
        //NSLog(@"average: %f", total);
        
        *average = total;
        
        num_average_elements = 0;
        num_average_allocated = 0;
        
        // TODO: Crash here !
        //free(averageStack);
        
        return NO;
    }
    
    return NO;
}


@end
