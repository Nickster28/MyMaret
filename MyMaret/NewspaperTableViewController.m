//
//  NewspaperTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "NewspaperTableViewController.h"
#import "NewspaperStore.h"

@interface NewspaperTableViewController () <UIScrollViewDelegate>
@property (nonatomic) NSUInteger sectionIndex;
@property (nonatomic, weak) IBOutlet UIView *sectionsHeaderView;
@property (nonatomic, weak) IBOutlet UIScrollView *sectionsHeaderScrollView;
@property (nonatomic) BOOL isScrollingVertically;
@property (nonatomic, weak) IBOutlet UIView *headerContentView;
@property (nonatomic, strong) UIButton *leftArrowButton;
@property (nonatomic, strong) UIButton *rightArrowButton;
@end

NSString * const MyMaretNewspaperSectionPrefKey = @"MyMaretNewspaperSectionPrefKey";

@implementation NewspaperTableViewController
@synthesize sectionIndex = _sectionIndex;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (NSUInteger)sectionIndex
{
    if (!_sectionIndex) {
        // Load from NSUserDefaults
        _sectionIndex = [[NSUserDefaults standardUserDefaults] integerForKey:MyMaretNewspaperSectionPrefKey];
    }
    
    return _sectionIndex;
}


- (void)setSectionIndex:(NSUInteger)sectionIndex
{
    [self setArrowButtonsForSection:sectionIndex];
    
    _sectionIndex = sectionIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:_sectionIndex forKey:MyMaretNewspaperSectionPrefKey];
}


- (void)setArrowButtonsForSection:(NSUInteger)sectionIndex
{
    // Enable and disable the arrow buttons accordingly
    if (sectionIndex == 0) {
        [self makeButton:[self leftArrowButton] active:NO];
        [self makeButton:[self rightArrowButton] active:YES];
    } else if (sectionIndex == [[NewspaperStore sharedStore] numberOfSections] - 1) {
        [self makeButton:[self leftArrowButton] active:YES];
        [self makeButton:[self rightArrowButton] active:NO];
    } else {
        [self makeButton:[self leftArrowButton] active:YES];
        [self makeButton:[self rightArrowButton] active:YES];
    }
}


- (void)makeButton:(UIButton *)button active:(BOOL)active
{
    // Return if we don't need to change anything
    if (active && [button isEnabled]) return;
    if (!active && ![button isEnabled]) return;
    
    // Figure out what the to and from opacity values are
    NSNumber *fromValue = (active) ? [NSNumber numberWithFloat:0.0] : [NSNumber numberWithFloat:1.0];
    NSNumber *toValue = (active) ? [NSNumber numberWithFloat:1.0] : [NSNumber numberWithFloat:0.0];
    
    // Make the fade animation
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeAnimation setDuration:0.3];
    [fadeAnimation setFromValue:fromValue];
    [fadeAnimation setToValue:toValue];
    
    // Update the model layer
    [button.layer setOpacity:[toValue floatValue]];
    
    [button.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
    [button setEnabled:active];
}


- (UIView *)sectionsHeaderView
{
    if (!_sectionsHeaderView) {
        
        // Load the XIB file
        [[NSBundle mainBundle] loadNibNamed:@"SectionHeaderView"
                                      owner:self
                                    options:nil];
        
        // Configure the scrollview's contents
        [[self sectionsHeaderScrollView] addSubview:[self headerContentView]];
        [[self sectionsHeaderScrollView] setContentSize:[self headerContentView].bounds.size];
        
        
        // Add the left button
        self.leftArrowButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 3.0, 40.0, 40.0)];
        [self.leftArrowButton addTarget:self
                                 action:@selector(changeSection:)
                       forControlEvents:UIControlEventTouchUpInside];
        
        [self.leftArrowButton setImage:[UIImage imageNamed:@"LeftArrowEnabled"]
                              forState:UIControlStateNormal];
        
        [_sectionsHeaderView addSubview:self.leftArrowButton];
        
        
        // Add the right button
        self.rightArrowButton = [[UIButton alloc] initWithFrame:CGRectMake(280.0, 3.0, 40.0, 40.0)];
        [self.rightArrowButton addTarget:self
                                  action:@selector(changeSection:)
                        forControlEvents:UIControlEventTouchUpInside];
        
        [self.rightArrowButton setImage:[UIImage imageNamed:@"RightArrowEnabled"]
                               forState:UIControlStateNormal];
        
        [_sectionsHeaderView addSubview:self.rightArrowButton];
        
        
        // Enable or disable each arrow button
        [self setArrowButtonsForSection:[self sectionIndex]];
        
        // Scroll to the right section
        [[self sectionsHeaderScrollView] setContentOffset:CGPointMake([self sectionsHeaderScrollView].frame.size.width * [self sectionIndex], 0.0)];
    }
    
    return _sectionsHeaderView;
}


- (void)changeSection:(UIButton *)sender
{
    // Increment or decrement the section index
    if (sender == [self leftArrowButton]) {
        [self setSectionIndex:[self sectionIndex] - 1];
    } else if (sender == [self rightArrowButton]) {
        [self setSectionIndex:[self sectionIndex] + 1];
    }
    
    // Scroll the scrollview to the appropriate section label
    [[self sectionsHeaderScrollView] setContentOffset:CGPointMake([self sectionsHeaderScrollView].frame.size.width * [self sectionIndex], 0.0) animated:YES];
}



#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self isScrollingVertically]) {
        [self setIsScrollingVertically:NO];
        return;
    }
    
    CGPoint offset = [scrollView contentOffset];
    NSUInteger newSectionIndex = offset.x / self.sectionsHeaderScrollView.frame.size.width;
    [self setSectionIndex:newSectionIndex];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self isScrollingVertically]) return;
    if ([scrollView contentOffset].y != 0.0) [self setIsScrollingVertically:YES];
}



#pragma mark - Table view data source


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self sectionsHeaderView];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self sectionsHeaderView] bounds].size.height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [[NewspaperStore sharedStore] sectionTitleForIndex:[self sectionIndex]];
    return [[NewspaperStore sharedStore] numberOfArticlesInSection:sectionTitle];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

@end
