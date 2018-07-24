
//
//  Created by Mahsa .
//

#import <UIKit/UIKit.h>

@protocol customTextViewDelegate <NSObject>

-(void)pastHappendOnTextView;
-(void)internalTtextFieldPressed;

@end

@interface customTextView : UITextView
@property (nonatomic, weak) UIResponder *inputNextResponder;
@property(nonatomic,weak)id <customTextViewDelegate> textInternalViewDelegate;



@end


