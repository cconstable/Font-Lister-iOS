//
//  ViewController.m
//  FontLister
//
//  Created by Christopher Constable on 1/21/14.
//  Copyright (c) 2014 Christopher Constable. All rights reserved.
//

#import "ViewController.h"
#import "OrderedDictionary.h"

@interface ViewController ()

- (IBAction)findTypefacesPressed:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBackground];
}

- (void)setupBackground
{
    UIColor *topColor = [UIColor colorWithRed:0.53
                                        green:0.49
                                         blue:0.94
                                        alpha:1.0];
    
    UIColor *bottomColor = [UIColor colorWithRed:0.28
                                           green:0.29
                                            blue:0.78
                                           alpha:1.0];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.layer.bounds;
    
    gradientLayer.colors = @[(id)[topColor CGColor], (id)[bottomColor CGColor]];
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}

#pragma mark - Actions

- (IBAction)findTypefacesPressed:(id)sender {
    
    //
    // Find all the fonts and organize them alphabetically.
    //
    
    NSUInteger totalNumberOfFonts = 0;
    OrderedDictionary *jsonDictMutable = [OrderedDictionary dictionary];
    NSArray *fontFamilyNames = [UIFont familyNames];
    fontFamilyNames = [fontFamilyNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *fontFamily in fontFamilyNames) {
        
        NSMutableArray *fontNames = [NSMutableArray array];
        NSArray *fontNameList = [UIFont fontNamesForFamilyName:fontFamily];
        fontNameList = [fontNameList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for (NSString *fontName in fontNameList) {
            [fontNames addObject:fontName];
            totalNumberOfFonts++;
        }
        
        if (fontNames.count) {
            [jsonDictMutable setObject:fontNames forKey:fontFamily];
        }
    }
    
    //
    // Convert to JSON
    //
    
    NSDictionary *jsonDict = @{@"fonts": jsonDictMutable};

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    //
    // Write everything to disk.
    //
    
    NSURL *documentsUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                  inDomains:NSUserDomainMask] lastObject];
    NSString *path = [documentsUrl.path
                      stringByAppendingPathComponent:@"fontlist.json"];
    
    BOOL success = [jsonString writeToFile:path
                                atomically:YES
                                  encoding:NSUTF8StringEncoding
                                     error:nil];
    
    if (success) {
        NSString *successString = [NSString stringWithFormat:@"%d fonts written to %@", totalNumberOfFonts, path];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                        message:successString
                                                       delegate:nil
                                              cancelButtonTitle:@"Great!"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aw"
                                                        message:@"There was trouble writing your font names to the disk."
                                                       delegate:nil
                                              cancelButtonTitle:@"Shucks"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
