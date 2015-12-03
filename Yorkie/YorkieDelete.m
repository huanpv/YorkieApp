//
//  YorkieDelete.m
//  Yorkie
//
//  Created by Carlos Butron on 28/08/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "YorkieDelete.h"
#import "sqlite3.h" //database
#import "FMDatabase.h" // from cocoa pods and github

@implementation YorkieDelete

+ (void)yorkieDelete:(NSInteger)idYorkie {
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"yorkie.sqlite"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
    //DELETE in Yorkie
    [database executeUpdate:@"DELETE FROM yorkie WHERE idYorkie= ?", [NSString stringWithFormat:@"%ld", (long)idYorkie], nil];
    
    
    //DELETE in Weight table
    BOOL successWeight = [database executeUpdate:@"DELETE FROM weight WHERE idYorkie= ?", [NSString stringWithFormat:@"%ld", (long)idYorkie ], nil];
    
    
    if (!successWeight) {
        NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
        
        // do whatever you need to upon error
    }
    
    
    
    
    
    [database close];
    
}

@end
