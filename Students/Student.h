//
//  Student.h
//  Students
//
//  Created by Ivan on 03.10.12.
//  Copyright (c) 2012 Ivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject

- (NSString *)description;

@property (nonatomic, retain) NSNumber* identifier;
@property (nonatomic, retain) NSString* fname;
@property (nonatomic, retain) NSString* lname;

@end
