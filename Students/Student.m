//
//  Student.m
//  Students
//
//  Created by Ivan on 03.10.12.
//  Copyright (c) 2012 Ivan. All rights reserved.
//

#import "Student.h"

@implementation Student

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ %@", _fname, _lname];
}

@end
