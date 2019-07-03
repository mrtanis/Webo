//
//  MRTDeleteCell.m
//  Webo
//
//  Created by mrtanis on 2017/9/16.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTDeleteCell.h"

@interface MRTDeleteCell ()

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@end

@implementation MRTDeleteCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        UIImageView *deleteView = [UIImageView new];
        deleteView.image = [UIImage imageNamed:@"compose_emotion_delete"];
        deleteView.frame = self.bounds;
        [self addSubview:deleteView];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        
        longPress.minimumPressDuration = 0.5;
        
        [self addGestureRecognizer:longPress];
        
        _longPress = longPress;
        
        [longPress addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}
/*
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(endDelete)]) {
        [self.delegate endDelete];
    }
}
*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == _longPress) {
        switch (_longPress.state) {
            case UIGestureRecognizerStateBegan:
                NSLog(@"长按began");
                if ([self.delegate respondsToSelector:@selector(longPressDelete)]) {
                    [self.delegate longPressDelete];
                }
                break;
            case UIGestureRecognizerStateEnded:
                NSLog(@"长按ended");
                if ([self.delegate respondsToSelector:@selector(endDelete)]) {
                    [self.delegate endDelete];
                }
                break;
                
            default:
                break;
        }
    }
}


- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    NSLog(@"长按");
    
    
}

- (void)dealloc
{
    [_longPress removeObserver:self forKeyPath:@"state"];
}

@end
