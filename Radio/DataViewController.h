//
//  DataViewController.h
//  Radio
//
//  Created by David Collinson on 14/05/2014.
//  Copyright (c) 2014 R/a/dio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;

@end
