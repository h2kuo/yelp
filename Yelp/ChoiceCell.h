//
//  ChoiceCell.h
//  Yelp
//
//  Created by Helen Kuo on 2/12/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChoiceCell;

@protocol ChoiceCellDelegate <NSObject>

-(void)choiceCell:(ChoiceCell *)cell;

@end

@interface ChoiceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, weak) id<ChoiceCellDelegate> delegate;

@end
