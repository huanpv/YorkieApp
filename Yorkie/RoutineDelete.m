//
//  RoutineDelete.m
//  Yorkie
//
//  Created by Carlos Butron on 28/08/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "RoutineDelete.h"
#import "sqlite3.h" //database
#import "FMDatabase.h" // from cocoa pods and github
#import "NotificationDelete.h"

@implementation RoutineDelete

+ (void)routineDelete:(NSInteger)idYorkie withRoutineNumber:(NSInteger)routineNumber {
 
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"yorkie.sqlite"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];

    
    int idRoutine=0;
    //get the idYorkie
    FMResultSet *results = [database executeQuery:@"SELECT idRoutine FROM routine WHERE idYorkie= ? and idRoutineType= ?", [NSString stringWithFormat:@"%ld", (long)idYorkie ], [NSString stringWithFormat:@"%ld", (long)routineNumber], nil];
    
    while([results next]) {
        
        idRoutine = [results intForColumn:@"idRoutine"];
        
    }
    
    if (!results) {
        NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
        
        // do whatever you need to upon error
    }
    
    
    
    
    //DELETE ROUTINES
    BOOL successRoutine = [database executeUpdate:@"DELETE FROM routine WHERE idYorkie= ? and idRoutineType= ?", [NSString stringWithFormat:@"%ld", (long)idYorkie ], [NSString stringWithFormat:@"%ld", (long)routineNumber]];
    
    
    if (!successRoutine) {
        NSLog(@"%s: insert error: %@", __FUNCTION__, [database lastErrorMessage]);
        
        // do whatever you need to upon error
    }

    
    [database close];
    
    //delete notification of this routine if exists
    [NotificationDelete notificationDelete:idRoutine];
    
    

    
}

@end
