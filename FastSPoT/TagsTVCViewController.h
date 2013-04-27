//
//  TagsTVCViewController.h
//  Shutterbug
//
//  Created by HeartNest on 7/4/13.
//  Copyright (c) 2013 HeartNest. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TagsTVCViewController : UITableViewController


@property (nonatomic,strong)NSArray *photos;
@property (nonatomic,strong) NSMutableDictionary *tagStore;
@property (nonatomic,strong) NSArray *tags;


@end
