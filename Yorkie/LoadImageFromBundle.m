//
//  LoadImageFromBundle.m
//  Yorkie
//
//  Created by Carlos Butron on 30/07/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "LoadImageFromBundle.h"

@implementation LoadImageFromBundle

+ (UIImage*)loadImage: (NSString*)imageString 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithString: imageString]];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    
    return image;
}

@end
