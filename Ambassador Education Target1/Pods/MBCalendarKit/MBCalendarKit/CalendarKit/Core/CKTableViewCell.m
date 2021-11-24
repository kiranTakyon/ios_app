//
//  CKTableViewCell.m
//  MBCalendarKit
//
//  Created by Rachel Hyman on 6/2/14.
//  Copyright (c) 2014 Moshe Berman. All rights reserved.
//

#import "CKTableViewCell.h"

@implementation CKTableViewCell

- (void)layoutSubviews
{
    //Moves cell text label over to make space for color square on left
    self.textLabel.frame = CGRectMake(10, 0, 260, 60);
    [super layoutSubviews];
}

@end
