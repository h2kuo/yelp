//
//  BusinessCell.h
//  Yelp
//
//  Created by Helen Kuo on 2/10/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"

@interface BusinessCell : UITableViewCell

@property (nonatomic, strong) Business *business;

@end