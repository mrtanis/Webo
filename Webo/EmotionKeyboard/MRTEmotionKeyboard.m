//
//  MRTEmotionKeyboard.m
//  Webo
//
//  Created by mrtanis on 2017/9/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTEmotionKeyboard.h"
#import "MRTEmotionCell.h"
#import "MRTEmotionLayout.h"
#import "MRTDeleteCell.h"
#import "MRTTextAttachment.h"

@interface MRTEmotionKeyboard () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MRTDeleteCellDelegate>

@property (nonatomic, weak) UICollectionView *keyboardView;
@property (nonatomic, weak) UIView *toolBar;
@property (nonatomic, weak) UIPageControl *pageControl;;

@property (nonatomic, strong) NSMutableArray *emotionDicArray;

@property (nonatomic) BOOL cancleDelete;

@end

@implementation MRTEmotionKeyboard

- (NSMutableArray *)emotionDicArray
{
    if (!_emotionDicArray) {
        NSString *bundlePath =
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Emoticons.bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        
        NSString *plistPath = [bundle pathForResource:@"content" ofType:@"plist" inDirectory:@"com.sina.normal"];
        
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];

        _emotionDicArray = plistDic[@"emoticons"];
    }
    
    return _emotionDicArray;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.frame = CGRectMake(0, MRTScreen_Height - 220, MRTScreen_Width, 220);

        [self setUpKeyboardView];
        [self setUpPageControl];
        [self setUpToolBar];
    }
    
    return self;
}

- (void)setUpKeyboardView
{
    MRTEmotionLayout *layout = [[MRTEmotionLayout alloc] init];
    
    layout.itemSize = CGSizeMake(30, 30);
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 40, 20);
    layout.minimumLineSpacing = (MRTScreen_Width - 40 - 30 * 7) / 6.0;
    layout.minimumInteritemSpacing = (179.5 - 60 - 30 * 3) / 2.0;
    
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    
    layout.rowCount = 3;
    layout.itemCountPerRow = 7;
    
    //先添加一条分割线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MRTScreen_Width, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    [self addSubview:line];
    
    UICollectionView *keyboardView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0.5, MRTScreen_Width, 179.5) collectionViewLayout:layout];
    keyboardView.showsHorizontalScrollIndicator = NO;
    keyboardView.backgroundColor = [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1];
    [keyboardView registerClass:[MRTEmotionCell class] forCellWithReuseIdentifier:@"cell"];
    [keyboardView registerClass:[MRTDeleteCell class] forCellWithReuseIdentifier:@"delete"];
    [keyboardView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"clearCell"];
    //keyboardView.contentInset = UIEdgeInsetsMake(25, 25, 40, 25);
    keyboardView.pagingEnabled = YES;
    keyboardView.delegate = self;
    keyboardView.dataSource = self;
    
    [self addSubview:keyboardView];
    _keyboardView = keyboardView;
}

- (void)setUpPageControl
{
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = [self numberOfSectionsInCollectionView:_keyboardView];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    pageControl.center = CGPointMake(self.width * 0.5, self.height - 60);
    
    [self addSubview:pageControl];
    _pageControl = pageControl;
    
}

- (void)setUpToolBar
{
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 220 - 40, MRTScreen_Width, 40)];
    toolBar.backgroundColor = [UIColor whiteColor];
    UIButton *emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emotionButton setImage:[UIImage imageNamed:@"compose_emotion_table_default"] forState:UIControlStateNormal];
    //[emotionButton setBackgroundImage:[UIImage imageNamed:@"compose_toolbar_background_new"] forState:UIControlStateNormal];
    emotionButton.backgroundColor = [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1];
    emotionButton.frame = CGRectMake(0, 0, 50, 40);
    [toolBar addSubview:emotionButton];
    [self addSubview:toolBar];
    _toolBar = toolBar;
}

#pragma mark - UICollectionView Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return ceilf(self.emotionDicArray.count / 20.0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return 21;
    

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [collectionView numberOfSections] - 1) {
        if (indexPath.item == 20) {
            static NSString *ID = @"delete";
            MRTDeleteCell *deleteCell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
            deleteCell.delegate = self;
            
            return deleteCell;
        } else {
            static NSString *ID = @"cell";
            MRTEmotionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
            
            NSInteger index = indexPath.section * 20 + indexPath.row;
            cell.emoDic = self.emotionDicArray[index];
            
            NSLog(@"indexPath:%@, index:%ld", indexPath, index);
            //cell.backgroundColor = [UIColor greenColor];
            
            return cell;
        }
    } else {
        if (indexPath.item < self.emotionDicArray.count % 20) {
            static NSString *ID = @"cell";
            MRTEmotionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
            
            NSInteger index = indexPath.section * 20 + indexPath.row;
            cell.emoDic = self.emotionDicArray[index];
            
            NSLog(@"indexPath:%@, index:%ld", indexPath, index);
            //cell.backgroundColor = [UIColor greenColor];
            
            return cell;
        } else if (indexPath.item == 20) {
            static NSString *ID = @"delete";
            MRTDeleteCell *deleteCell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
            deleteCell.delegate = self;
            
            return deleteCell;
        } else {
            static NSString *ID = @"clearCell";
            UICollectionViewCell *clearCell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
            
            return clearCell;
        }
    }
    
    
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selectedIndexPath:%@", indexPath);
    
    NSRange range = [_textView selectedRange];
    if (indexPath.item == 20) {
        if (range.length == 0) {
            if (_textView.attributedText.length) {
                NSMutableAttributedString *attText = [_textView.attributedText mutableCopy];
                [attText replaceCharactersInRange:NSMakeRange(range.location - 1, 1) withAttributedString:[[NSAttributedString alloc] initWithString:@""]];
                _textView.attributedText = attText;
            } else if (_textView.text.length) {
                NSMutableString *text = [_textView.text mutableCopy];
                [text replaceCharactersInRange:NSMakeRange(range.location - 1, 1) withString:@""];
                _textView.text = text;
            }
            if (range.location) {
                _textView.selectedRange = NSMakeRange(range.location - 1, 0);
            }
        } else {
            if (_textView.attributedText.length) {
                NSMutableAttributedString *attText = [_textView.attributedText mutableCopy];
                [attText replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:@""]];
                _textView.attributedText = attText;
            } else if (_textView.text.length) {
                NSMutableString *text = [_textView.text mutableCopy];
                [text replaceCharactersInRange:range withString:@""];
                _textView.text = text;
            }
            _textView.selectedRange = NSMakeRange(range.location, 0);
        }
    
    } else if (!((indexPath.section == [collectionView numberOfSections] - 1) && (indexPath.item >= self.emotionDicArray.count % 20))) {
        _textView.placeHolder.hidden = YES;
        NSMutableDictionary *textAttrDic = [NSMutableDictionary dictionary];
        textAttrDic[NSFontAttributeName] = [UIFont systemFontOfSize:16];
        textAttrDic[NSForegroundColorAttributeName] = [UIColor darkTextColor];
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] init];
        if (_textView.attributedText.length) {
            attText = [_textView.attributedText mutableCopy];
        } else {
            attText = [[NSMutableAttributedString alloc] initWithString:_textView.text attributes:textAttrDic];
        }
        
        MRTEmotionCell *cell = (MRTEmotionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        
        MRTTextAttachment *textAttachment = [[MRTTextAttachment alloc] init];
        textAttachment.emoChs = cell.emoDic[@"chs"];
        //给附件添加图片
        textAttachment.image = [UIImage imageNamed:cell.emoDic[@"png"]];
        NSMutableAttributedString *emoStr = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy];
        //设置字体和颜色，否则在表情后粘贴文字字体很小
        [emoStr addAttributes:textAttrDic range:NSMakeRange(0, 1)];
        
        [attText replaceCharactersInRange:range withAttributedString:emoStr];
        
        _textView.attributedText = attText;
        
        //改变光标位置
        NSRange newRange = NSMakeRange(range.location + 1, 0);
        _textView.selectedRange = newRange;
    }
    
}

- (void)longPressDelete
{
    _cancleDelete = NO;
    [self deleteCharacter];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"dispatch_after");
        if (_textView.textStorage.length == 0 || _cancleDelete) {
            NSLog(@"_textView.textStorage.length = %ld", _textView.textStorage.length);
            NSLog(@"return");
            return;
        } else {
            NSLog(@"deleteCharacter");
            [self longPressDelete];
        }
    });
}

- (void)endDelete
{
    NSLog(@"endDelete");
    _cancleDelete = YES;
}

- (void)deleteCharacter
{
    NSRange range = [_textView selectedRange];
    if (range.length == 0) {
        if (_textView.attributedText.length) {
            NSMutableAttributedString *attText = [_textView.attributedText mutableCopy];
            [attText replaceCharactersInRange:NSMakeRange(range.location - 1, 1) withAttributedString:[[NSAttributedString alloc] initWithString:@""]];
            _textView.attributedText = attText;
        } /*else if (_textView.text.length) {
            NSMutableString *text = [_textView.text mutableCopy];
            [text replaceCharactersInRange:NSMakeRange(range.location - 1, 1) withString:@""];
            _textView.text = text;
        }*/
        if (range.location) {
            _textView.selectedRange = NSMakeRange(range.location - 1, 0);
        }
    } else {
        if (_textView.attributedText.length) {
            NSMutableAttributedString *attText = [_textView.attributedText mutableCopy];
            [attText replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:@""]];
            _textView.attributedText = attText;
        }/* else if (_textView.text.length) {
            NSMutableString *text = [_textView.text mutableCopy];
            [text replaceCharactersInRange:range withString:@""];
            _textView.text = text;
        }*/
        _textView.selectedRange = NSMakeRange(range.location, 0);
    }
    
    if (_textView.attributedText.length == 0) {
        _textView.placeHolder.hidden = NO;
        _textView.rightItem.enabled = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x / MRTScreen_Width + 0.5;
    _pageControl.currentPage = page;
}

/*
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 20) {
        return CGSizeMake(40, 30);
    } else {
        return CGSizeMake(30, 30);
    }
}*/






@end
