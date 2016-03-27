//
//  Yorkie.m
//  Yorkie
//
//  Created by Carlos Butron on 12/05/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "Yorkie.h"

@implementation Yorkie

- (instancetype) initWithYorkieID:(NSInteger )yorkieID
                   andWithPicture:(NSString *)photo
                      andWithName:(NSString *)name
                    andWithGender:(NSString *)gender
                  andWithBornDate:(NSString *)bornDate
                    andWithWeight:(Weight *)weight {
    
    if (self = [super init]) {
        _yorkieID = yorkieID;
        _photo = photo;
        _name = name;
        _gender = gender;
        _bornDate = bornDate;
        _weight = weight;
    }
    
    return self;
}

@end
