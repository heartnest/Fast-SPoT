//
//  TagsTVCViewController.m
//  Shutterbug
//
//  Created by HeartNest on 7/4/13.
//  Copyright (c) 2013 HeartNest. All rights reserved.
//

#import "TagsTVCViewController.h"
#import "FlickrFetcher.h"

@interface TagsTVCViewController ()

@end

@implementation TagsTVCViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadStanfordPhotos];
    [self.refreshControl addTarget:self
                            action:@selector(loadStanfordPhotos)
                  forControlEvents:UIControlEventValueChanged];
}

-(void)loadStanfordPhotos{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loadQ = dispatch_queue_create("stanford photo loader", NULL);
    dispatch_async(loadQ, ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSArray *sph = [FlickrFetcher stanfordPhotos];

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.photos = sph;
            [self.refreshControl endRefreshing];
        });
    });
}



#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

-(NSString *)titleForRow:(NSUInteger)row{
    return self.tags[row];
}

-(NSString *)subTitleForRow:(NSUInteger)row{
    return [[self.tagStore objectForKey:self.tags[row]] stringByAppendingString:@"photos"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flicker Tag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subTitleForRow:indexPath.row];
    return cell;
}



#pragma mark - Segue

// prepares for the "Show Image" segue by seeing if the destination view controller of the segue
//  understands the method "setImageURL:"
// if it does, it sends setImageURL: to the destination view controller with
//  the URL of the photo that was selected in the UITableView as the argument
// also sets the title of the destination view controller to the photo's title

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show photo by tag"]) {
                
                //IMPORATANT TO BE DEFINED WHEN KNOWN THE DICTIONARY OF PHOTOS
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    
                    NSString *tag = self.tags[indexPath.row];
                    
                    NSMutableArray *selectedPhotos = [[NSMutableArray alloc]init];
                    
                    for(NSDictionary *ft in self.photos){
                        NSString *tags = [ft objectForKey:@"tags"];
                        NSRange r = [tags rangeOfString:tag];
                        if(r.location != NSNotFound){
                            [selectedPhotos addObject:ft];
                        }
                    }
                    NSArray *preparedarr = [selectedPhotos copy];
                    [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:preparedarr];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                }
            }
        }
    }
}

#pragma mark - lazy istantiations and utilities

-(void)tagAnalyzer:(NSString *) tags{
    NSArray *arr = [tags componentsSeparatedByString:@" "];
    for(NSString *tmp in arr){
        
        NSString *tag = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //  NSString *tag = tmp;
        
        if(![tag isEqualToString: @"cs193pspot"]&& ![tag isEqualToString: @"portrait"] && ![tag isEqualToString: @"landscape"] ){
            int counter = [[self.tagStore objectForKey:tag] intValue];
            
            if(counter != 0){
                counter++;
                [self.tagStore setObject:[NSString stringWithFormat:@"%d",counter] forKey:tag];
            }else{
                [self.tagStore setObject:@"1" forKey:tag];
            }
        }
        
    }
    
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;

    for(NSDictionary *tmp in self.photos){
        NSString *tags = [tmp objectForKey:@"tags"];
        [self tagAnalyzer:tags];
        
        
    }
    self.tags = [self.tagStore allKeys];
    
    
    
    [self.tableView reloadData];
}

-(NSMutableDictionary *)tagStore{
    if(!_tagStore)
        _tagStore = [[NSMutableDictionary alloc]init];
    
    return _tagStore;
}


@end
