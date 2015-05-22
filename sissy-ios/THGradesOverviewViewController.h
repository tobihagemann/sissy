//
//  THGradesOverviewViewController.h
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^THGradeResultsCallback)(NSString *gradeResults);

@interface THGradesOverviewViewController : UIViewController

@property (nonatomic, strong) THGradeResultsCallback callback;

@end
