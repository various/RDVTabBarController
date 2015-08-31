// RDVTabBar.m
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RDVTabBar.h"
#import "RDVTabBarItem.h"

@interface RDVTabBar ()

@property (nonatomic) CGFloat categoryItemWidth;
@property (nonatomic) CGFloat nonCategoryItemWidth;

@property (nonatomic) UIView *backgroundView;

@end

@implementation RDVTabBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (void)commonInitialization {
    _backgroundView = [[UIView alloc] init];
    [self addSubview:_backgroundView];
    
    [self setTranslucent:NO];
}

- (void)layoutSubviews {
    CGSize frameSize = self.frame.size;
    CGFloat minimumContentHeight = [self minimumContentHeight];
    
    [[self backgroundView] setFrame:CGRectMake(0, frameSize.height - minimumContentHeight,
                                            frameSize.width, frameSize.height)];
    
//    [self setItemWidth:roundf((frameSize.width - [self contentEdgeInsets].left -
//                               [self contentEdgeInsets].right) / [[self items] count])];
    
    float categoryItemWidth = ((frameSize.width * (2048 - 605))/2048) / 8;
    float nonCategoryItemWidth = ((frameSize.width * (605))/2048) / 2;
    [self setCategoryItemWidth:categoryItemWidth];
    [self setNonCategoryItemWidth:nonCategoryItemWidth];

    
    // Layout items
    NSArray *itemsArray = [self items];
    for (int i = 0; i < itemsArray.count; i++) {
        RDVTabBarItem *item = [itemsArray objectAtIndex:i];
        CGFloat itemHeight = [item itemHeight];
        
        if (!itemHeight) {
            itemHeight = frameSize.height;
        }
        
        
        if (i < 8) {
            [item setFrame:CGRectMake(self.contentEdgeInsets.left + (i * self.categoryItemWidth),
                                      roundf(frameSize.height - itemHeight) - self.contentEdgeInsets.top,
                                      self.categoryItemWidth, itemHeight - self.contentEdgeInsets.bottom)];
            NSLog(@"%@",NSStringFromCGRect(CGRectMake(self.contentEdgeInsets.left + (i * self.categoryItemWidth),
                                                      roundf(frameSize.height - itemHeight) - self.contentEdgeInsets.top,
                                                      self.categoryItemWidth, itemHeight - self.contentEdgeInsets.bottom)));
        }else{
            [item setFrame:CGRectMake(self.categoryItemWidth * 8 + ((i-8) * self.nonCategoryItemWidth),
                                      roundf(frameSize.height - itemHeight) - self.contentEdgeInsets.top,
                                      self.nonCategoryItemWidth, itemHeight - self.contentEdgeInsets.bottom)];
            NSLog(@"%@",NSStringFromCGRect(CGRectMake(self.categoryItemWidth * 8 + (i * self.nonCategoryItemWidth),
                                                      roundf(frameSize.height - itemHeight) - self.contentEdgeInsets.top,
                                                      self.nonCategoryItemWidth, itemHeight - self.contentEdgeInsets.bottom)));
        }

        
        [item setNeedsDisplay];

    }

}

#pragma mark - Configuration


- (void)setCategoryItemWidth:(CGFloat)categoryItemWidth {
    if (categoryItemWidth > 0) {
        _categoryItemWidth = categoryItemWidth;
    }
}

- (void)setNonCategoryItemWidth:(CGFloat)nonCategoryItemWidth {
    if (nonCategoryItemWidth > 0) {
        _nonCategoryItemWidth = nonCategoryItemWidth;
    }
}

- (void)setItems:(NSArray *)items {
    for (RDVTabBarItem *item in _items) {
        [item removeFromSuperview];
    }
    
    _items = [items copy];
    for (RDVTabBarItem *item in _items) {
        [item addTarget:self action:@selector(tabBarItemWasSelected:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:item];
    }
}

- (void)setHeight:(CGFloat)height {
    [self setFrame:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame),
                              CGRectGetWidth(self.frame), height)];
}

- (CGFloat)minimumContentHeight {
    CGFloat minimumTabBarContentHeight = CGRectGetHeight([self frame]);
    
    for (RDVTabBarItem *item in [self items]) {
        CGFloat itemHeight = [item itemHeight];
        if (itemHeight && (itemHeight < minimumTabBarContentHeight)) {
            minimumTabBarContentHeight = itemHeight;
        }
    }
    
    return minimumTabBarContentHeight;
}

#pragma mark - Item selection

- (void)tabBarItemWasSelected:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(tabBar:shouldSelectItemAtIndex:)]) {
        NSInteger index = [self.items indexOfObject:sender];
        if (![[self delegate] tabBar:self shouldSelectItemAtIndex:index]) {
            return;
        }
    }
    
    [self setSelectedItem:sender];
    
    if ([[self delegate] respondsToSelector:@selector(tabBar:didSelectItemAtIndex:)]) {
        NSInteger index = [self.items indexOfObject:self.selectedItem];
        [[self delegate] tabBar:self didSelectItemAtIndex:index];
    }
}

- (void)setSelectedItem:(RDVTabBarItem *)selectedItem {
    if (selectedItem == _selectedItem) {
        return;
    }
    [_selectedItem setSelected:NO];
    
    _selectedItem = selectedItem;
    [_selectedItem setSelected:YES];
}

#pragma mark - Translucency

- (void)setTranslucent:(BOOL)translucent {
    _translucent = translucent;
    
    CGFloat alpha = (translucent ? 0.9 : 1.0);
    
    [_backgroundView setBackgroundColor:[UIColor colorWithRed:245/255.0
                                                        green:245/255.0
                                                         blue:245/255.0
                                                        alpha:alpha]];
}

@end
