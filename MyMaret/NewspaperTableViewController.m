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


@interface NewspaperTableViewController () <UIScrollViewDelegate, UISearchDisplayDelegate>

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
    
    // Refresh the popular article list in the store
    // if we haven't in a while
    [[NewspaperStore sharedStore] refreshPopularArticles];
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
    
    // Thanks to http://stackoverflow.com/questions/1081381/iphone-hide-uitableview-search-bar-by-default
    // for help auto-hiding the search bar
    [self.tableView setContentOffset:CGPointMake(0.0, self.searchDisplayController.searchBar.bounds.size.height) animated:YES];
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
    
    /* Hide the search bar
    [self.tableView setContentOffset:CGPointMake(0.0, self.searchDisplayController.searchBar.bounds.size.height) animated:YES];
    */
    
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
        [self.leftArrowButton setBackgroundColor:[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0]];
        [self.leftArrowButton addTarget:self
                                 action:@selector(changeSection:)
                       forControlEvents:UIControlEventTouchUpInside];
        
        [self.leftArrowButton setImage:[UIImage imageNamed:@"LeftArrow"]
                              forState:UIControlStateNormal];
        
        [_sectionsHeaderView addSubview:self.leftArrowButton];
        
        
        // Add the right button
        self.rightArrowButton = [[UIButton alloc] initWithFrame:CGRectMake(280.0, 3.0, 40.0, 40.0)];
        [self.rightArrowButton setBackgroundColor:[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0]];
        [self.rightArrowButton addTarget:self
                                  action:@selector(changeSection:)
                        forControlEvents:UIControlEventTouchUpInside];
        
        [self.rightArrowButton setImage:[UIImage imageNamed:@"RightArrow"]
                               forState:UIControlStateNormal];
        
        [_sectionsHeaderView addSubview:self.rightArrowButton];
        
        
        // Enable or disable each arrow button
        [self setArrowButtonsForSection:[self sectionIndex]];
        
        // Add a divider line under the section picker
        CALayer *dividerLayer = [[CALayer alloc] init];
        [dividerLayer setBounds:CGRectMake(0,0,self.sectionsHeaderView.frame.size.width, 1.0)];
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
    for (NSUInteger i = 0; i < fromCount; i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i
                                             inSection:0];
        [rowsToDelete addObject:ip];
    }
    
    
    // Insert all of the new articles onscreen with an animation
    // Make an array of all the indexpaths to insert
    NSMutableArray *rowsToInsert = [NSMutableArray array];
    for (NSUInteger i = 0; i < toCount; i++) {
        
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

// Track when the user finishes scrolling through sections and update the articles being displayed
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Since we're also the TABLEVIEW'S scrollviewdelegate,
    // we need to make sure we only listen for the headerview's
    // scrollview
    if (scrollView == self.tableView) return;
    
    CGPoint offset = [scrollView contentOffset];
    NSUInteger newSectionIndex = offset.x / self.sectionsHeaderScrollView.frame.size.width;
    [self setSectionIndex:newSectionIndex];
}



#pragma mark - Table view data source


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return (tableView == self.tableView) ? [self sectionsHeaderView] : nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (tableView == self.tableView) ?
        self.sectionsHeaderView.bounds.size.height : 0.0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // If this is for search results, the store disregards the section title
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
    
    // Get the article at the given index (if this is for search results,
    // the store will disregard the section title).
    NSString *sectionTitle = [[NewspaperStore sharedStore] sectionTitleForIndex:[self sectionIndex]];
    NewspaperArticle *article = [[NewspaperStore sharedStore] articleInSection:sectionTitle atIndex:[indexPath row]];
    
    [cell bindArticle:article];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showArticle"
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showArticle"] && [[segue destinationViewController] isKindOfClass:[ArticleDetailViewController class]]) {
        
        ArticleDetailViewController *articleDVC = [segue destinationViewController];
        
        UITableView *currentTableView = (self.searchDisplayController.isActive) ?
            self.searchDisplayController.searchResultsTableView : self.tableView;
     
        // Get the selected article from the correct tableview
        NSIndexPath *selectedIP = [currentTableView indexPathForCell:sender];
        
        NSString *sectionTitle = [[NewspaperStore sharedStore] sectionTitleForIndex:[self sectionIndex]];
        
        // If the user is searching, the store will disregard the section title
        // and will know the index pertains to the search results
        NewspaperArticle *selectedArticle = [[NewspaperStore sharedStore] articleInSection:sectionTitle atIndex:[selectedIP row]];
        
        // Mark the article as read
        [[NewspaperStore sharedStore] markArticleAsReadInSection:sectionTitle
                                                         atIndex:[selectedIP row]];
        
        // Reload the cell to reflect that it's been read,
        // but make sure it's still selected!
        [currentTableView reloadRowsAtIndexPaths:@[selectedIP]
                         withRowAnimation:UITableViewRowAnimationNone];
        [currentTableView selectRowAtIndexPath:selectedIP animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
        
        // Give the article to the detail view controller
        [articleDVC setArticle:selectedArticle];
    }
}

#pragma mark Search Display Controller

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    // Set the newspaper store search string so it filters out
    // the articles we want
    [[NewspaperStore sharedStore] setSearchFilterString:searchString];
    
    return YES;
}


- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    // Set the filter string to nil so the newspaper store knows
    // we're done searching and want normal article info now
    [[NewspaperStore sharedStore] setSearchFilterString:nil];
    
    [self.tableView reloadData];
}

@end
