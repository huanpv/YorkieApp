//
//  Weight.h
//  Yorkie
//
//  Created by Carlos Butron on 12/05/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weight : NSObject

@property (nonatomic, strong) NSNumber *weightID;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSString *date;

- (instancetype) initWithWeightID:(NSNumber *)weightID
                    andWithWeight:(NSNumber *)weight
                      andWithDate:(NSString *)date;

@end
