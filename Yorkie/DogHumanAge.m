//
//  DogHumanAge.m
//  Yorkie
//
//  Created by Carlos Butron on 13/09/15.
//  Copyright (c) 2015 Carlos Butron. All rights reserved.
//

#import "DogHumanAge.h"

@implementation DogHumanAge

/* CALCULATE AGE OF THE DOG
**
**  1 year dog - 15 human years
**  2 years dog - 24 human years
**  3 years dog - 28 human years
**  every year+ - 4+ human years
*/

+ (NSInteger)dogAge:(NSDate *)dateOfBirth {
    
    NSInteger years;
    NSInteger months;
    NSInteger days = 0;
    NSInteger myDogAge = 0;
    
    //Date between actual date and birth day of the dog
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) || (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
        years = [dateComponentsNow year] - [dateComponentsBirth year] - 1;
    } else {
        years = [dateComponentsNow year] - [dateComponentsBirth year];
    }
    
    if ([dateComponentsNow year] == [dateComponentsBirth year]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    } else if ([dateComponentsNow year] > [dateComponentsBirth year] && [dateComponentsNow month] > [dateComponentsBirth month]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    } else if ([dateComponentsNow year] > [dateComponentsBirth year] && [dateComponentsNow month] < [dateComponentsBirth month]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month] + 12;
    } else {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    }
    
    if ([dateComponentsNow year] == [dateComponentsBirth year] && [dateComponentsNow month] == [dateComponentsBirth month]) {
        days = [dateComponentsNow day] - [dateComponentsBirth day];
    }
    
    //GET Date between actual date and birth day of the dog
    NSLog(@"%ld,%ld,%ld",(long)days,(long)months,(long)years);

    //calculate human years in first real year of the dog
    int firstYears = (int)(days + months*30 + years*365);  //date in days
    
    if (firstYears<=365) {
        //if 1 year old of the dog is equal to 15 human years then every 24.3 days is equal to 1 year
        myDogAge = firstYears / 24.3;
    }
    
    //calculate human years in second real year of the dog
    if ((firstYears>365) &&(firstYears<=730) ) {
        //in second year if 1 year old of the dog is equal to 9 human years then every 40.5 days is equal to 1 year
        myDogAge = 15 + ((firstYears-365) / 40.5);
    }
    
    //calculate human years in third or more real years of the dog
    int moreThanTwoYears = (int)(months + years*12); //date in months
    
    if (moreThanTwoYears>24) {  //more than two years old
        myDogAge = 24 + ((moreThanTwoYears-24) / 3);
    }
    
    return myDogAge;
}

@end
