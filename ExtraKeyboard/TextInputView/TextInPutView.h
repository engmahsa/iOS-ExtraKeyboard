//
//  TextInPutView.h
//  Created by Mahsa
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "containerView.h"

@protocol TextInputViewDelegete <NSObject>
- (void)didExtraKeyboardButtonPress;
@end

@interface TextInPutView : UIView <UIGestureRecognizerDelegate>

- (void)initialize;
@property (nonatomic , weak) id<TextInputViewDelegete> customDelegate;
@property (weak, nonatomic) IBOutlet containerView *textView;

@end
