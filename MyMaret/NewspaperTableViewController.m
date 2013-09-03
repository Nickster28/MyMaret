//
//  NewspaperTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "NewspaperTableViewController.h"
#import "NewspaperStore.h"
#import "NewspaperArticle.h"
#import "NewspaperCell.h"
#import "UIColor+SchoolColor.h"
#import "ArticleDetailViewController.h"
#import "AppDelegate.h"


@interface NewspaperTableViewController () <UIScrollViewDelegate>

// The index of the currently selected section
@property (nonatomic) NSUInteger sectionIndex;

// The header views used to switch between newspaper sections
@property (nonatomic, weak) IBOutlet UIView *sectionsHeaderView;
@property (nonatomic, weak) IBOutlet UIScrollView *sectionsHeaderScrollView;
@property (nonatomic, weak) IBOutlet UIView *headerContentView;
@property (nonatomic, strong) UIButton *leftArrowButton;
@property (nonatomic, strong) UIButton *rightArrowButton;

// A way to keep track of if the user scrolled vertically and ignore it
@property (nonatomic) BOOL isScrollingVertically;

// Boolean to keep track of whether it should check for a new newspaper
// (we want this to happen when the user launches the app
// by tapping on a New Newspaper push notification)
@property (nonatomic) BOOL shouldUpdateNewspaper;

@end

// NSUserDefaults key for storing the section index
NSString * const MyMaretNewspaperSectionPrefKey = @"MyMaretNewspaperSectionPrefKey";

@implementation NewspaperTableViewController
@synthesize sectionIndex = _sectionIndex;



- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Override the superclass's notification action
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MyMaretNewNewspaperNotification
                                                  object:nil];
    
    // Refresh if we get a newspaper notification while the app is running
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshNewspaper)
                                                 name:MyMaretNewNewspaperNotification
                                               object:nil];
}


// Part of the PushNotificationUpdateable protocol
// to get the newspaperstore to refresh immediately upon launch
- (void)reloadWhenShown
{
    [self setShouldUpdateNewspaper:YES];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Add the tableView's refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor schoolColor]];
    [self.refreshControl addTarget:self
                            action:@selector(refreshNewspaper)
                  forControlEvents:UIControlEventValueChanged];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If we got a push notification saying a new edition is
    // available and the user tapped on the notification,
    // download the new edition!
    if ([self shouldUpdateNewspaper]) {
        [self refreshNewspaper];
        [self setShouldUpdateNewspaper:NO];
    }
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
    if (sectionIndex == _sectionIndex) return;
    
    // Fade/Unfade the arrow buttons if necessary
    [self setArrowButtonsForSection:sectionIndex];
    
    // Figure out if the user navigated left or right
    BOOL navigatedLeft = (sectionIndex < _sectionIndex) ? YES : NO;
    
    // Get the number of articles we're currently displaying
    NSUInteger numArticlesOnscreen = [self.tableView numberOfRowsInSection:0];
    
    // Set the section index
    _sectionIndex = sectionIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:_sectionIndex forKey:MyMaretNewspaperSectionPrefKey];
    
    // Get the new article count
    NSString *newSectionTitle = [[NewspaperStore sharedStore] sectionTitleForIndex:sectionIndex];
    NSUInteger numArticlesToDisplay = [[NewspaperStore sharedStore] numberOfArticlesInSection:newSectionTitle];
    
    // Have the articles fly in from different directions depending on which way the user navigated
    if (navigatedLeft) {
        [self changeArticleCountFrom:numArticlesOnscreen
                                  to:numArticlesToDisplay
                 withRemoveAnimation:UITableViewRowAnimationRight
                     insertAnimation:UITableViewRowAnimationLeft];
    } else {
        [self changeArticleCountFrom:numArticlesOnscreen
                                  to:numArticlesToDisplay
                 withRemoveAnimation:UITableViewRowAnimationLeft
                     insertAnimation:UITableViewRowAnimationRight];
    }

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


// Animates buttons either in or out by animating the opacity
// and enabling/disabling the buttons
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
        [self.leftArrowButton setBackgroundColor:[UIColor whiteColor]];
        [self.leftArrowButton addTarget:self
                                 action:@selector(changeSection:)
                       forControlEvents:UIControlEventTouchUpInside];
        
        [self.leftArrowButton setImage:[UIImage imageNamed:@"LeftArrowEnabled"]
                              forState:UIControlStateNormal];
        
        [_sectionsHeaderView addSubview:self.leftArrowButton];
        
        
        // Add the right button
        self.rightArrowButton = [[UIButton alloc] initWithFrame:CGRectMake(280.0, 3.0, 40.0, 40.0)];
        [self.rightArrowButton setBackgroundColor:[UIColor whiteColor]];
        [self.rightArrowButton addTarget:self
                                  action:@selector(changeSection:)
                        forControlEvents:UIControlEventTouchUpInside];
        
        [self.rightArrowButton setImage:[UIImage imageNamed:@"RightArrowEnabled"]
                               forState:UIControlStateNormal];
        
        [_sectionsHeaderView addSubview:self.rightArrowButton];
        
        
        // Enable or disable each arrow button
        [self setArrowButtonsForSection:[self sectionIndex]];
        
        // Add a divider line under the section picker
        CALayer *dividerLayer = [[CALayer alloc] init];
        [dividerLayer setBounds:CGRectMake(0,0,self.sectionsHeaderView.frame.size.width - 20.0, 1.0)];
        [dividerLayer setPosition:CGPointMake(self.sectionsHeaderView.frame.size.width / 2.0,
                                              self.sectionsHeaderView.frame.size.height)];
        
        [dividerLayer setBackgroundColor:[[UIColor schoolColor] CGColor]];
        
        [[self.sectionsHeaderView layer] addSublayer:dividerLayer];
        
        // Scroll to the right section
        [[self sectionsHeaderScrollView] setContentOffset:CGPointMake([self sectionsHeaderScrollView].frame.size.width * [self sectionIndex], 0.0)];
    }
    
    return _sectionsHeaderView;
}


// Triggered by the arrow buttons being pressed
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


// Called when the user swaps between sections
// or a new edition of the newspaper comes in
- (void)changeArticleCountFrom:(NSUInteger)fromCount
                            to:(NSUInteger)toCount
           withRemoveAnimation:(UITableViewRowAnimation)removeAnimation
               insertAnimation:(UITableViewRowAnimation)insertAnimation
{
    // Remove all the old articles onscreen with an animation
    // Make an array of all the NSIndexPaths to delete
    NSMutableArray *rowsToDelete = [NSMutableArray array];
    for (int i = 0; i < fromCount; i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i
                                             inSection:0];
        [rowsToDelete addObject:ip];
    }
    
    
    // Insert all of the new articles onscreen with an animation
    // Make an array of all the indexpaths to insert
    NSMutableArray *rowsToInsert = [NSMutableArray array];
    for (int i = 0; i < toCount; i++) {
        
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i
                                             inSection:0];
        [rowsToInsert addObject:ip];
    }
    
    // Update the table
    [self.tableView beginUpdates];
    
    [self.tableView insertRowsAtIndexPaths:rowsToInsert
                          withRowAnimation:insertAnimation];
    [self.tableView deleteRowsAtIndexPaths:rowsToDelete
                          withRowAnimation:removeAnimation];
    
    [self.tableView endUpdates];
}


// Triggered by the UIRefreshControl
- (void)refreshNewspaper
{
    [self.refreshControl beginRefreshing];
    NSUInteger numArticlesOnScreen = [self.tableView numberOfRowsInSection:0];
    
    // Have the store check for a new edition of the newspaper
    [[NewspaperStore sharedStore] fetchNewspaperWithCompletionBlock:^(BOOL didAddArticles, NSError *err) {
        
        if (err) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                         message:[err localizedDescription]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
            
        } else {
            
            // There may or may not have been new articles to download
            if (didAddArticles) {
                NSString *sectionTitle = [[NewspaperStore sharedStore] sectionTitleForIndex:[self sectionIndex]];
                NSUInteger numNewArticles = [[NewspaperStore sharedStore] numberOfArticlesInSection:sectionTitle];
                
                [self changeArticleCountFrom:numArticlesOnScreen
                                          to:numNewArticles
                         withRemoveAnimation:UITableViewRowAnimationBottom
                             insertAnimation:UITableViewRowAnimationTop];
            }
        }
        
        [self.refreshControl endRefreshing];
    }];
    
}


#pragma mark UIScrollViewDelegate

// Track when the user finishes scrolling and update the articles being displayed
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


// Track if the user scrolls vertically so we know
// NOT to change the section
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0;
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
    // Register the cell's NIB file
    [tableView registerNib:[UINib nibWithNibName:@"NewspaperCell"
                                          bundle:nil]
    forCellReuseIdentifier:@"newspaperCell"];
    
    NewspaperCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newspaperCell"
                                                          forIndexPath:indexPath];
    
    // Get the article at the given index
    NSString *sectionTitle = [[NewspaperStore sharedStore] sectionTitleForIndex:[self sectionIndex]];
    NewspaperArticle *article = [[NewspaperStore sharedStore] articleInSection:sectionTitle atIndex:[indexPath row]];
    
    [cell bindArticle:article];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showArticle"
                              sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showArticle"] && [[segue destinationViewController] isKindOfClass:[ArticleDetailViewController class]]) {
        
        ArticleDetailViewController *articleDVC = [segue destinationViewController];
     
        // Get the selected article
        NSIndexPath *selectedIP = [self.tableView indexPathForCell:sender];
        NSString *sectionTitle = [[NewspaperStore sharedStore] sectionTitleForIndex:[self sectionIndex]];
        NewspaperArticle *selectedArticle = [[NewspaperStore sharedStore] articleInSection:sectionTitle atIndex:[selectedIP row]];
        
        // Mark the article as read
        [[NewspaperStore sharedStore] markArticleAsReadInSection:sectionTitle
                                                         atIndex:[selectedIP row]];
        
        // Give the article to the detail view controller
        [articleDVC setArticle:selectedArticle];
    }
}

@end
