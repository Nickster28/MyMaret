//
//  NewspaperStore.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/1/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NewspaperArticle;

@interface NewspaperStore : NSObject

// Get the singleton instance of NewspaperStore
+ (NewspaperStore *)sharedStore;


// **** ALL ARTICLE ACCESS IS DONE VIA INDICES **** //
// This works more easily with tableViews/row indices

// Fetches new articles from Parse and executes the passed-in
// block by either passing in nil or an error if there was one,
// and true/false depending on whether new articles were downloaded.
- (void)fetchNewspaperWithCompletionBlock:(void (^)(BOOL didAddArticles, NSError *err))completionBlock;


// Get the article in a given section at a given index (filtered and non-filtered)
- (NewspaperArticle *)articleInSection:(NSString *)section
                               atIndex:(NSUInteger)index;


// Mark the article at readIndex in the given section as read,
// upload that information to Parse, and download the newest article rankings
// (filtered and non-filtered)
- (void)markArticleAsReadInSection:(NSString *)section
                           atIndex:(NSUInteger)readIndex;


// Returns the total number of articles in a given section (filtered and non-filtered)
- (NSUInteger)numberOfArticlesInSection:(NSString *)section;



// ****** FOR ONLY ACCESSING CERTAIN ARTICLES (FILTERING) ******** //
// Set the string to filter by

// If this string is set to something other than nil, the
// articleInSection:atIndex, markArticleAsReadInSection:atIndex:,
// and the numberOfArticlesInSection: methods will change their output.
// Ex. if you set the filter string to "Nick", you can call the above 3 methods
// with section as nil and you'll get data back based only on the articles that
// match the string "Nick".  The section string is only referenced when the search
// string is nil.  You must set the search string to nil before you can access all
// articles like normal.

- (void)setSearchFilterString:(NSString *)searchString;


- (NSUInteger)numberOfSections;


// Get section titles by index so we can keep our list of sections
// in one place and so the tableviewcontroller can just keep track
// of a number in NSUserDefaults
- (NSString *)sectionTitleForIndex:(NSUInteger)index;


// Returns whether or not the current edition is new
// (considered to be within 1 week of download date)
- (BOOL)isNewEditionOfNewspaper;



@end
