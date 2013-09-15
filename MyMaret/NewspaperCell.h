//
//  NewspaperCell.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/2/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewspaperArticle;

@interface NewspaperCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *bodyLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *popularLabel;
@property (nonatomic, strong) NSAttributedString *titleAttrString;

- (void)bindArticle:(NewspaperArticle *)article;

@end
