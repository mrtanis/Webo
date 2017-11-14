//
//  MRTStatusTestCell.h
//  Webo
//
//  Created by mrtanis on 2017/10/28.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTStatusFrame.h"
#import "MRTPictureView.h"

@interface MRTStatusTestCell : UITableViewCell

@property (nonatomic, strong) MRTStatusFrame *statusFrame;

@property (nonatomic, weak) UIImageView *iconViewOriginal;
@property (nonatomic, weak) UIImageView *vipViewOriginal;
@property (nonatomic, weak) UILabel *timeLabelOriginal;
@property (nonatomic, weak) UILabel *sourceLabelOriginal;
@property (nonatomic, weak) UILabel *nameLabelOriginal;
@property (nonatomic, weak) UITextView *textViewOriginal;
@property (nonatomic, weak) MRTPictureView *pictureViewOriginal;
@property (nonatomic, weak) UIButton *playButtonOriginal;
@property (nonatomic, weak) UIImageView *posterViewOriginal;

@property (nonatomic, weak) UILabel *nameLabelRetweet;
@property (nonatomic, weak) UITextView *textViewRetweet;
@property (nonatomic, weak) MRTPictureView *pictureViewRetweet;
@property (nonatomic, weak) UIButton *playButtonRetweet;
@property (nonatomic, weak) UIImageView *posterViewRetweet;

@end
