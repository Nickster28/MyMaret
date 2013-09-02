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

extern NSString * const NewspaperStoreFilterStringPopular;

// Get the singleton instance of NewspaperStore
+ (NewspaperStore *)sharedStore;


- (void)saveChanges;

// **** ALL ARTICLE ACCESS IS DONE VIA INDICES **** //
// This works more easily with tableViews/row indices

// Fetches new articles from Parse and executes the passed-in
// block by either passing in nil or an error if there was one,
// and true/false depending on whether new articles were downloaded.
- (void)fetchNewspaperWithCompletionBlock:(void (^)(BOOL, NSError *err))completionBlock;


// Get the article in a given section at a given index
- (NewspaperArticle *)articleInSection:(NSString *)section
                               atIndex:(NSUInteger)index;


// Mark the article at readIndex in the given section as read,
// upload that information to Parse, and download the newest article rankings
- (void)markArticleAsReadInSection:(NSString *)section
                           atIndex:(NSUInteger)readIndex;


// Returns the total number of articles in a given section
- (NSUInteger)numberOfArticlesInSection:(NSString *)section;



// ****** FOR ONLY ACCESSING CERTAIN ANNOUNCEMENTS (FILTERING) ******** //
// Set the string to filter by


//-(void)setSearchFilterString:(NSString *)searchString;



@end
