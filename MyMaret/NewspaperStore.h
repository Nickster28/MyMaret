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

/*! Get the singleton instance of NewspaperStore
 * @return the singleton instance of NewspaperStore.
 */
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

/*! Sets the store-wide filter string (text you are searching for in an
 * article).  This is used to access only articles
 * that fit a given filter string.  If searchString is non-nil,
 * NewspaperStore will respond differently when calling certain methods
 * such as numberOfArticlesInSection because these methods
 * will now return information about just the articles that fit the given
 * filter string.  To go back to accessing all articles, set the filter
 * string to nil.
 * @param searchString the string you are looking for inside an article.
 */
- (void)setSearchFilterString:(NSString *)searchString;


/*! Returns the number of newspaper sections in the store.
 * @return the number of sections in the store.
 */
- (NSUInteger)numberOfSections;


/*! Returns the title of the section at the given index
 * @param index the index of the newspaper section to return the name of.
 * @return the name of the newspaper section with the given index.
 */
- (NSString *)sectionTitleForIndex:(NSUInteger)index;


/*! Returns a boolean indicating whether or not the current
 * edition of the newspaper in the store is less than a week old.
 */
- (BOOL)isNewEditionOfNewspaper;


/*! Deletes ALL articles in the entire store.
 * @return a boolean indicating whether the clean was successful or not.
 */
- (BOOL)clearStore;



@end
