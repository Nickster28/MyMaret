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

/*! Fetches new newspaper articles, if any, and replaces the old
 * newspaper articles with the new ones.
 * @param completionBlock a block to be executed after completing downloading articles.
 * didAddArticles will be either true or false depending on whether there were new articles available.
 * err will be nil unless an error occurred.
 */
- (void)fetchNewspaperWithCompletionBlock:(void (^)(BOOL didAddArticles, NSError *err))completionBlock;


/*! Returns the newspaper article at the given section index and article index.
 * If a filter string has been set (via setSearchFilterString:) then the section is ignored and the article returned is at index relative to the results of the given search.
 * @param section the name of the article's section.
 * @param index the index of the article within its section.
 * @return the article in the given section at the given index.
 */
- (NewspaperArticle *)articleInSection:(NSString *)section
                               atIndex:(NSUInteger)index;


/*! Marks the article in the given section at the given index as read if it is
 * still marked as unread.  The store syncs this data with the server so the server has an up-to-date count of how many times each article has been read.  If a filter string has been set (via setSearchFilterString:) then the section is ignored and the article returned is at index relative to the results of the given search.
 * @param section the name of the article's section.
 * @param index the index of the article within its section.
 */
- (void)markArticleAsReadInSection:(NSString *)section
                           atIndex:(NSUInteger)readIndex;


/*! Downloads the most recent ranking of popular articles from the server and
 * updates the store with the results.
 */
- (void)refreshPopularArticles;


/*! Returns the number of articles in the specified section.
 * @param section the name of the section you want the article count for.
 * @return the number of articles in the given section.
 */
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


// Deletes all store data
- (BOOL)clearStore;



@end
