//
//  Yorkie.h
//  Yorkie
//
//  Created by Carlos Butron on 12/05/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Weight.h"

@interface Yorkie : NSObject

@property (nonatomic) NSInteger yorkieID;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *bornDate;
@property (nonatomic, strong) Weight   *weight;


- (instancetype) initWithYorkieID:(NSInteger )yorkieID
                   andWithPicture:(NSString *)photo
                      andWithName:(NSString *)name
                    andWithGender:(NSString *)gender
                  andWithBornDate:(NSString *)bornDate
                    andWithWeight:(Weight *)weight;


@end
