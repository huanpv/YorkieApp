//
//  Weight.m
//  Yorkie
//
//  Created by Carlos Butron on 12/05/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "Weight.h"

@implementation Weight

- (instancetype) initWithWeightID:(NSNumber *)weightID
                    andWithWeight:(NSNumber *)weight
                      andWithDate:(NSString   *)date {
 
    if (self = [super init]) {
        _weightID = weightID;
        _weight = weight;
        _date = date;
    }
    
    return self;
}

@end
