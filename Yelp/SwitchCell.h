//
//  SwitchCell.h
//  Yelp
//
//  Created by Helen Kuo on 2/10/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchCell;

@protocol SwitchCellDelegate <NSObject>

-(void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value;

@end

@interface SwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) BOOL on;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;
@property (nonatomic, weak) id<SwitchCellDelegate> delegate;

-(void)setOn:(BOOL)on animated:(BOOL)animated;

@end
