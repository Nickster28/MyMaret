//
//  NewspaperStore.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/1/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "NewspaperStore.h"
#import <CoreData/CoreData.h>
#import "NewspaperArticle.h"
#import <Parse/Parse.h>
#import "UIApplication+HasNetworkConnection.h"
#import "AppDelegate.h"

#define NUM_POPULAR_ARTICLES 5
#define NUM_SECS_NEWSPAPER_IS_NEW 604800

// The longest time we go without updating the most popular articles
// (Article popularity is updated whenever a user reads an article,
// and also whenever the user goes to the newspaper section if the popularity
// hasn't been updated in POPULAR_ARTICLE_UPDATE_INTERVAL_SECS seconds).
#define POPULAR_ARTICLE_UPDATE_INTERVAL_SECS 86400

@interface NewspaperStore()
@property (nonatomic, strong) NSDictionary *articlesDictionary;
@property (nonatomic, strong) NSDate *lastNewspaperUpdateDate;

// The last time we refreshed the popular article list
@property (nonatomic, strong) NSDate *lastPopularArticleUpdateDate;

// For newspaper search - if filteredArticles isn't nil,
// then the user is looking at a certain selection of articles.
@property (nonatomic, strong) NSArray *filteredArticles;

// Saves all Core Data changes
- (BOOL)saveChanges;

@end

// NSUserDefaults key
NSString * const MyMaretLastNewspaperUpdateDateKey = @"MyMaretLastNewspaperUpdateDateKey";
NSString * const MyMaretLastPopularArticleUpdateDateKey = @"MyMaretLastPopularArticleUpdateDateKey";


@implementation NewspaperStore
@synthesize lastNewspaperUpdateDate = _lastNewspaperUpdateDate;
@synthesize lastPopularArticleUpdateDate = _lastPopularArticleUpdateDate;



// Singleton instance
+ (NewspaperStore *)sharedStore
{
    static NewspaperStore *sharedStore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[NewspaperStore alloc] init];
    });
    
    return sharedStore;
}



- (void)makeNewArticlesDictionary
{
    [self setArticlesDictionary:[NSDictionary dictionaryWithObjects:@[[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], [NSMutableArray array], [NSMutableArray array], [NSMutableArray array], [NSMutableArray array]]
                                                            forKeys:@[@"Popular", @"News", @"Opinion", @"Features", @"Center Spread", @"Style", @"Sports"]]];
}


- (NSString *)articlesArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get only entry from the list
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"newspaper.archive"];
}


- (NSDictionary *)articlesDictionary
{
    if (!_articlesDictionary) {
        
        // Unarchive our saved one from disk
        _articlesDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self articlesArchivePath]];
        
        // If we haven't saved one yet, make a new one
        if (!_articlesDictionary) [self makeNewArticlesDictionary];
        [self saveChanges];
    }
    
    return _articlesDictionary;
}



- (NSDate *)lastNewspaperUpdateDate
{
    // Read from NSUserDefaults
    if (!_lastNewspaperUpdateDate) {
        _lastNewspaperUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:MyMaretLastNewspaperUpdateDateKey];
    }
    
    return _lastNewspaperUpdateDate;
}


- (void)setLastNewspaperUpdateDate:(NSDate *)lastNewspaperUpdateDate
{
    _lastNewspaperUpdateDate = lastNewspaperUpdateDate;
    
    // Save the update date as well
    [[NSUserDefaults standardUserDefaults] setObject:_lastNewspaperUpdateDate
                                              forKey:MyMaretLastNewspaperUpdateDateKey];
}


- (NSDate *)lastPopularArticleUpdateDate
{
    // Read from NSUserDefaults if we haven't set lastPopularArticleUpdateDate yet
    if (!_lastPopularArticleUpdateDate) {
        _lastPopularArticleUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:MyMaretLastPopularArticleUpdateDateKey];
    }
    
    return _lastPopularArticleUpdateDate;
}


- (void)setLastPopularArticleUpdateDate:(NSDate *)lastPopularArticleUpdateDate
{
    lastPopularArticleUpdateDate = lastPopularArticleUpdateDate;
    
    // Save the update date as well
    [[NSUserDefaults standardUserDefaults] setObject:_lastPopularArticleUpdateDate
                                              forKey:MyMaretLastPopularArticleUpdateDateKey];
}


// Takes in an array of the newspaper articles sorted by popularity,
// and sorts them into their proper article "buckets" based on their section
- (void)addArticlesToDictionary:(NSArray *)articlesToAdd
{
    // Remove the old edition of the newspaper
    [self makeNewArticlesDictionary];
    
    // Loop through the new articles, adding each one to the appropriate key/value array
    for (NSUInteger i = 0; i < articlesToAdd.count; i++) {
        PFObject *object = [articlesToAdd objectAtIndex:i];
        
        // The top NUM_POPULAR_ARTICLES are "popular"
        BOOL isPopular = (i < NUM_POPULAR_ARTICLES) ? true : false;
        
        // Get rid of the newlines from sending the article via email
        NSString *body = [object objectForKey:@"body"];
        
        // http://www.textfixer.com/tutorials/javascript-line-breaks.php
        body = [body stringByReplacingOccurrencesOfString:@"\r\n\r\n" withString:@"\n\n"];
        body = [body stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
        
        NewspaperArticle *article = [[NewspaperArticle alloc] initWithTitle:[object objectForKey:@"title"]
                                                                       body:body
                                                                     author:[object objectForKey:@"author"]
                                                                    section:[object objectForKey:@"section"]
                                                                publishDate:[object createdAt]
                                                                  isPopular:isPopular
                                                         isDigitalExclusive:[[object objectForKey:@"isDigitalExclusive"] boolValue]];
        
        // If it's a popular article, insert it at the front of its article array
        // and also add it to the popular articles section
        if (isPopular) {
            [[[self articlesDictionary] objectForKey:[article articleSection]]
             insertObject:article atIndex:0];
            
            [[[self articlesDictionary] objectForKey:@"Popular"] addObject:article];
        
        // Otherwise add it to the end
        } else [[[self articlesDictionary] objectForKey:[article articleSection]] addObject:article];
    }
}


- (void)clearPopularArticles {
    
    // Clear our cache of popular articles
    [[[self articlesDictionary] objectForKey:@"Popular"] removeAllObjects];
    
    // Loop through each section and mark all articles as not popular
    for (NSArray *articles in [[self articlesDictionary] allValues]) {
        
        // Since the articles are sorted by popularity (most popular are first)
        // we can stop as soon as we get to a one that is not marked as popular
        for (NewspaperArticle *article in articles) {
            if (![article isPopularArticle]) break;
            [article setIsPopularArticle:NO];
        }
    }
}


// Takes an array of arrays of most popular article info sorted
// by popularity (most to least) and updates our dictionary with which
// articles are most popular
- (void)updateMostPopularArticlesWithRanking:(NSArray *)articleRanking
{
    // Clear the existing popular articles
    [self clearPopularArticles];
    
    // Find each popular article, mark it as popular, and add it to our popular articles cache
    for (NSArray *popularArticleInfo in articleRanking) {
        
        // In the info array, the title is at index 0, the section at index 1
        NSString *popularArticleTitle = [popularArticleInfo objectAtIndex:0];
        NSString *popularArticleSection = [popularArticleInfo objectAtIndex:1];
        
        NSMutableArray *sectionArticles = [[self articlesDictionary] objectForKey:popularArticleSection];
        
        // Search the articles in the given section
        NSUInteger index = [sectionArticles indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                NewspaperArticle *article = (NewspaperArticle *)obj;
                if ([[article articleTitle] isEqualToString:popularArticleTitle]) {
                    return YES;
                } else return NO;
        }];
            
        // Article should be found - now set it as popular, move it to the top,
        // and add it to our dedicated popular articles array
        if (index != NSNotFound) {
            NewspaperArticle *article = [sectionArticles objectAtIndex:index];
            [article setIsPopularArticle:YES];
            
            [sectionArticles removeObjectAtIndex:index];
            [sectionArticles insertObject:article atIndex:0];
            
            [[[self articlesDictionary] objectForKey:@"Popular"]
             addObject:article];
        }
    }
}


// Returns the array of articles that is currently being accessed
// (filtered or popular articles or articles for a given section)
- (NSArray *)currentRelevantArticlesArrayForSection:(NSString *)section
{
    // If there are filtered articles, we want those
    if (self.filteredArticles) {
        return self.filteredArticles;
    }
    
    return [[self articlesDictionary] objectForKey:section];
}


// Save changes to our articles dictionary
- (BOOL)saveChanges
{
    // save our articles dictionary
    BOOL success = [NSKeyedArchiver archiveRootObject:[self articlesDictionary]
                                               toFile:[self articlesArchivePath]];
    
    if (!success) {
        NSLog(@"Could not save all articles.");
    }
    
    return success;
}


#pragma mark Public API

- (void)fetchNewspaperWithCompletionBlock:(void (^)(BOOL, NSError *))completionBlock
{
    // If we're not connected to the internet, send an error back
    if (![UIApplication hasNetworkConnection]) {
        
        // Make the error info dictionary
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Looks like you're not connected to the Internet.  Check your WiFi or Cellular connection and try refreshing again."
                                                         forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [NSError errorWithDomain:@"NSConnectionErrorDomain"
                                             code:2012
                                         userInfo:dict];
        
        completionBlock(false, error);
        return;
    }

    
    
    // Query for a new edition of the newspaper
    PFQuery *query = [PFQuery queryWithClassName:@"Article"];
    
    // If we have updated before, set a constraint for update date
    if (self.lastNewspaperUpdateDate) {
        [query whereKey:@"createdAt" greaterThan:[self lastNewspaperUpdateDate]];
    }
    
    [query whereKey:@"isPublished" equalTo:[NSNumber numberWithBool:YES]];
    [query orderByDescending:@"readCount"];
    
    // Make a weak version of self to avoid retain cycles
    NewspaperStore * __weak weakSelf = self;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *articles, NSError *error) {
        
        // If there was no error and there are new articles
        if (!error && articles && [articles count] > 0) {
            
            // Update lastNewspaperUpdate to now
            [weakSelf setLastNewspaperUpdateDate:[NSDate date]];
            
            // Add the new announcements to our current array of announcements
            [weakSelf addArticlesToDictionary:articles];
            
            // Save all changes
            [weakSelf saveChanges];
            
            completionBlock(true, nil);
            
        // If there was no error but there are no new articles
        } else if (!error) {
            completionBlock(false, nil);
            
        // If there was an error
        } else {
            completionBlock(false, error);
        }
    }];
}



// Returns the count of the array of articles we're currently interested in
-(NSUInteger)numberOfArticlesInSection:(NSString *)section
{
    return [[self currentRelevantArticlesArrayForSection:section] count];
}


// Return the article at the given index in the array of articles we're interested in
- (NewspaperArticle *)articleInSection:(NSString *)section atIndex:(NSUInteger)index
{
    return [[self currentRelevantArticlesArrayForSection:section] objectAtIndex:index];
}


- (NSString *)sectionTitleForIndex:(NSUInteger)index
{
    if (index >= 7) return @"ERROR";
    
    return [@[@"Popular", @"News", @"Opinion", @"Features", @"Center Spread", @"Style", @"Sports"] objectAtIndex:index];
}


- (NSUInteger)numberOfSections
{
    return [[self articlesDictionary] count];
}


- (void)refreshPopularArticles
{
    if ([self lastPopularArticleUpdateDate] && [[self lastPopularArticleUpdateDate] timeIntervalSinceDate:[NSDate date]] < POPULAR_ARTICLE_UPDATE_INTERVAL_SECS) {
    
        return;
    }
    
    // Make a weak version of self to avoid retain cycles
    NewspaperStore * __weak weakSelf = self;
    
    // Call the cloud function that returns an array of the most popular articles' info
    [PFCloud callFunctionInBackground:@"getMostPopularArticles"
                       withParameters:@{}
                                block:^(NSArray *popularArticles, NSError *error) {
                                    
                                    if (!error) {
                                        [weakSelf updateMostPopularArticlesWithRanking:popularArticles];
                                        [weakSelf setLastPopularArticleUpdateDate:[NSDate date]];
                                        [weakSelf saveChanges];
                                        
                                    } else {
                                        NSLog(@"Error: %@", [[error userInfo] objectForKey:@"error"]);
                                    }
                                    
                                }
     ];
}


- (void)markArticleAsReadInSection:(NSString *)section atIndex:(NSUInteger)readIndex
{
    // Get the array of articles we're currently interested in
    NSArray *articlesArray = [self currentRelevantArticlesArrayForSection:section];
    
    NewspaperArticle *readArticle = [articlesArray objectAtIndex:readIndex];
    
    // Change to read if the article is unread,
    // and download the new article ranking
    if ([readArticle isUnreadArticle]) {
        [readArticle setIsUnreadArticle:NO];
        
        // Make a weak version of self to avoid retain cycles
        NewspaperStore * __weak weakSelf = self;
        
        [PFCloud callFunctionInBackground:@"incrementArticleReadCount"
                           withParameters: @{@"title": [readArticle articleTitle]}
                                    block:^(NSArray *popularArticles, NSError *error) {
                                        
                                        if (!error) {
                                            [weakSelf updateMostPopularArticlesWithRanking:popularArticles];
                                            [weakSelf setLastPopularArticleUpdateDate:[NSDate date]];
                                            [weakSelf saveChanges];
                                            
                                        } else {
                                            NSLog(@"Error: %@", [[error userInfo] objectForKey:@"error"]);
                                        }
                                        
                                    }];
    }
}



- (void)setSearchFilterString:(NSString *)searchString
{
    // Otherwise, filter them by whether they contain the given searchString
    if (searchString) {
        // Use NSPredicate - http://ygamretuta.me/2011/08/10/ios-implementing-a-basic-search-uisearchdisplaycontroller-and-interface-builder/
        NSPredicate *predicate =
            [NSPredicate predicateWithFormat: @"(articleAuthor contains[cd] %@) OR (articleBody contains[cd] %@) OR (articleTitle contains[cd] %@)", searchString, searchString, searchString];
        
        // Make an array of all articles so we can search all of them
        NSArray *allArticles = [[NSArray alloc] init];
        
        for (NSArray *sectionArticles in [[self articlesDictionary] allValues]) {
            
            // We don't want to double the popular articles
            if ([[self articlesDictionary] objectForKey:@"Popular"] == sectionArticles) continue;
            
            allArticles = [allArticles arrayByAddingObjectsFromArray:sectionArticles];
        }
        
        [self setFilteredArticles:[allArticles filteredArrayUsingPredicate:predicate]];
        
        // Otherwise, we want all articles now
    } else {
        [self setFilteredArticles:nil];
    }
}


- (BOOL)isNewEditionOfNewspaper
{
    // Find the number of seconds since the newspaper was published
    NSTimeInterval publishInterval = [[self lastNewspaperUpdateDate] timeIntervalSinceDate:[NSDate date]];
    
    return abs(publishInterval) <= NUM_SECS_NEWSPAPER_IS_NEW;
}


// Deletes all store data
- (BOOL)clearStore {
    
    [self makeNewArticlesDictionary];
    [self setLastNewspaperUpdateDate:nil];
    [self setLastPopularArticleUpdateDate:nil];
    return [self saveChanges];
}

@end
