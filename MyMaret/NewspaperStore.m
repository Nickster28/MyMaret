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
#import "NSDate+TwoWeeksAgo.h"
#import <Parse/Parse.h>
#import "UIApplication+HasNetworkConnection.h"
#import "AppDelegate.h"

#define NUM_POPULAR_ARTICLES 5

@interface NewspaperStore()
@property (nonatomic, strong) NSDictionary *articlesDictionary;
@property (nonatomic, strong) NSMutableArray *popularArticles;
@property (nonatomic, strong) NSDate *lastNewspaperUpdate;

// For newspaper search
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSString *filteredArticles;

// Saves all Core Data changes
- (void)saveChanges;

@end

// NSUserDefaults key
NSString * const MyMaretLastNewspaperUpdateKey = @"MyMaretLastNewspaperUpdateKey";

// filter string for getting only popular articles
NSString * const NewspaperStoreFilterStringPopular = @"NewspaperStoreFilterStringPopular";


@implementation NewspaperStore
@synthesize lastNewspaperUpdate = _lastNewspaperUpdate;



+ (void)initialize
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObject:[NSDate dateTwoWeeksAgo]
                                                         forKey:MyMaretLastNewspaperUpdateKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


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


- (id)init {
    self = [super init];
    
    if (self) {
        // Unarchive the articles
        NSString *newspaperArchivePath = [self articlesArchivePath];
        NSString *popularArticlesArchivePath = [self popularArticlesArchivePath];
        
        [self setArticlesDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:newspaperArchivePath]];
        [self setPopularArticles:[NSKeyedUnarchiver unarchiveObjectWithFile:popularArticlesArchivePath]];
        
        // If there aren't any archived, set up a new dictionary
        // (The key is the name of the section, the value is an array of articles)
        if (![self articlesDictionary]) {
            [self makeNewArticlesDictionary];
        }
        
        // If there are no popular articles, make an empty array
        if (![self popularArticles]) {
            [self setPopularArticles:[[NSMutableArray alloc] init]];
        }
    }
    return self;
}


- (void)makeNewArticlesDictionary
{
    [self setArticlesDictionary:[NSDictionary dictionaryWithObjects:@[@[], @[], @[], @[], @[], @[]]
                                                            forKeys:@[@"News", @"Opinion", @"Features", @"Center Spread", @"Style", @"Sports"]]];
}


- (NSString *)articlesArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get only entry from the list
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"newspaper.archive"];
}


- (NSString *)popularArticlesArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get only entry from the list
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"newspaperpopular.archive"];
}



- (NSDate *)lastNewspaperUpdate
{
    // Read from NSUserDefaults if we haven't set lastAnnouncementsUpdate yet
    // (value will default to two weeks ago the very first time)
    if (!_lastNewspaperUpdate) {
        _lastNewspaperUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:MyMaretLastNewspaperUpdateKey];
    }
    
    return _lastNewspaperUpdate;
}


- (void)setLastNewspaperUpdate:(NSDate *)lastNewspaperUpdate
{
    _lastNewspaperUpdate = lastNewspaperUpdate;
    [[NSUserDefaults standardUserDefaults] setObject:_lastNewspaperUpdate
                                              forKey:MyMaretLastNewspaperUpdateKey];
}


// Takes in an array of the newspaper articles sorted by popularity,
// and sorts them into their proper article "buckets" based on their section
- (void)addArticlesToDictionary:(NSArray *)articlesToAdd
{
    // Remove the old edition of the newspaper
    [self makeNewArticlesDictionary];
    
    // Loop through the new articles, adding each one to the appropriate key/value array
    for (int i = 0; i < articlesToAdd.count; i++) {
        PFObject *object = [articlesToAdd objectAtIndex:i];
        
        // The top NUM_POPULAR_ARTICLES are "popular"
        BOOL isPopular = (i < NUM_POPULAR_ARTICLES) ? true : false;
        
        NewspaperArticle *article = [[NewspaperArticle alloc] initWithTitle:[object objectForKey:@"title"]
                                                                       body:[object objectForKey:@"body"]
                                                                     author:[object objectForKey:@"author"]
                                                                    section:[object objectForKey:@"section"]
                                                                publishDate:[object createdAt]
                                                                  isPopular:isPopular];
        
        // If it's a popular article, insert it at the front of its article array
        if (isPopular) {
            [[[self articlesDictionary] objectForKey:[article articleSection]]
             insertObject:article atIndex:0];
        
        // Otherwise add it to the end
        } else [[[self articlesDictionary] objectForKey:[article articleSection]] addObject:article];
    }
}


// Save changes to our articles dictionary
- (void)saveChanges
{
    // save our articles dictionary
    BOOL success = [NSKeyedArchiver archiveRootObject:[self articlesDictionary]
                                               toFile:[self articlesArchivePath]];
    
    if (!success) {
        NSLog(@"Could not save all articles.");
    }
    
    // save our popular articles array
    success = [NSKeyedArchiver archiveRootObject:[self popularArticles]
                                          toFile:[self popularArticlesArchivePath]];
    
    if (!success) {
        NSLog(@"Could not save popular articles.");
    }
}


- (void)clearPopularArticles {
    
    // Clear our cache of popular articles
    [self setPopularArticles:[[NSMutableArray alloc] init]];
    
    // Loop through each section and mark all articles as not popular
    for (NSArray *articles in [self articlesDictionary]) {
        
        if ([articles count] == 0) continue;
        
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
            
        // Article should be found - now set it as popular and add it to
        // our dedicated popular articles array
        if (index != NSNotFound) {
            [[sectionArticles objectAtIndex:index] setIsPopularArticle:YES];
            [[self popularArticles] addObject:[sectionArticles objectAtIndex:index]];
        }
    }
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
    [query whereKey:@"createdAt" greaterThan:[self lastNewspaperUpdate]];
    [query whereKey:@"isPublished" equalTo:[NSNumber numberWithBool:YES]];
    [query orderByDescending:@"readCount"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *articles, NSError *error) {
        
        // If there was no error and there are new articles
        if (!error && articles && [articles count] > 0) {
            
            // Update lastNewspaperUpdate to now
            [self setLastNewspaperUpdate:[NSDate date]];
            
            // Add the new announcements to our current array of announcements
            [self addArticlesToDictionary:articles];
            
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


-(NSUInteger)numberOfArticlesInSection:(NSString *)section
{
    return [[[self articlesDictionary] objectForKey:section] count];
}



- (NewspaperArticle *)articleInSection:(NSString *)section atIndex:(NSUInteger)index
{
    // Get the array of articles for the given section, and return the article at "index"
    return [[[self articlesDictionary] objectForKey:section] objectAtIndex:index];
}


- (void)markArticleAsReadInSection:(NSString *)section atIndex:(NSUInteger)readIndex
{
    /* If we're currently working with the filtered announcements,
    * we need to convert readIndex to be an index in the full announcements
    * array
    if (self.filteredAnnouncements) {
        Announcement *selectedFilteredAnnouncement = [self.filteredAnnouncements objectAtIndex:readIndex];
        readIndex = [self.announcements indexOfObject:selectedFilteredAnnouncement];
    }*/
    
    NewspaperArticle *readArticle = [self articleInSection:section atIndex:readIndex];
    
    // Change to read if the article is unread,
    // and download the new article ranking
    if ([readArticle isUnreadArticle]) {
        [readArticle setIsUnreadArticle:NO];
        
        [PFCloud callFunctionInBackground:@"incrementArticleReadCount"
                           withParameters: @{@"title": [readArticle articleTitle]}
                                    block:^(NSArray *topFiveArticleRanking, NSError *error) {
                                        if (!error) {
                                            [self updateMostPopularArticlesWithRanking:topFiveArticleRanking];
                                        } else {
                                            NSLog(@"Error: %@", [[error userInfo] objectForKey:@"error"]);
                                        }
                                    }];
    }
}





/*- (void)setSearchFilterString:(NSString *)searchString
{
    // If we want only today's announcements, filter out those whose postDateAsString is "Today"
    if (searchString && [searchString isEqualToString:NewspaperStoreFilterStringPopular]) {
        NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"postDateAsString like \"Today\""];
        
        [self setFilteredAnnouncements:[self.announcements filteredArrayUsingPredicate:todayPredicate]];
        
        // Otherwise, filter them by whether they contain the given searchString
    } else if (searchString) {
        // Use NSPredicate - http://ygamretuta.me/2011/08/10/ios-implementing-a-basic-search-uisearchdisplaycontroller-and-interface-builder/
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(description contains[cd] %@) OR (title contains[cd] %@)", searchString, searchString];
        
        [self setFilteredAnnouncements:[self.announcements filteredArrayUsingPredicate:predicate]];
        
        // Otherwise, we want all announcements now
    } else {
        [self setFilteredAnnouncements:nil];
    }
}*/




@end
