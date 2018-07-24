//
//  ViewController.m
//
//  Created by Mahsa .
//

#import "ViewController.h"
#import "TextInPutView.h"
#import "containerView.h"
#import "extraKeyBoard.h"

#define ExtraKeyboardHeight        215
#define TextInputViewHeight        44

@interface ViewController () < containerViewcustomDelegate , TextInputViewDelegete> {
    TextInPutView                   *inputView;
    UIView                          *keyboardView;
    CGRect tempKeyboardFrame;
    CGFloat tempKeyboardHeight;

    BOOL   isExtraKeybard;
}

@property (nonatomic, retain) UIView *TextInputViewNib;
@property (nonatomic, strong) containerView *txtField;
@property(nonatomic,strong) extraKeyBoard * extraView;
@property (nonatomic, retain) UIView *ExtraKeyBoardFromNib;
@property (nonatomic, retain) UIView *stickerKeyBoardFromNib;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerXibFiles];
    [self initialiValues];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObservers];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TapOnView" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    keyboardView = self.txtField.internalTextView.inputAccessoryView.superview;
}

-(void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeKeyboard) name:@"TapOnView" object:nil];
}

-(void)closeKeyboard {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.view endEditing:YES];
        
        self.txtField.internalTextView.inputView = nil;
        [self.txtField.internalTextView reloadInputViews];
    });
}
- (void)initialiValues {
    
    isExtraKeybard = NO;
    keyboardView = self.txtField.internalTextView.inputAccessoryView.superview;
}

-(void)registerExtraKeyBoardxibFile{
    
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"extraKeyBoard"
                                                      owner:self
                                                    options:nil];
    self.extraView = [ nibViews objectAtIndex: 0];
    self.ExtraKeyBoardFromNib =[[UIView alloc] init];
    self.ExtraKeyBoardFromNib = self.extraView;
    ////// we need it because sometimes textView inputaccessoryview is empty...
    /* DO NOT MISS THE INPUT ACCESSORY*/
    [self.txtField.internalTextView setInputAccessoryView:[[UIView alloc] init]];
    
}

-(BOOL)isKeyboardFisrtResponder
{
    if ([self.txtField.internalTextView isFirstResponder]) {
        return YES;
    }
    return NO;
}

-(void)registerXibFiles{
    
    if (self.TextInputViewNib) {
        [self.TextInputViewNib removeFromSuperview];
        self.TextInputViewNib = nil;
    }
    
    NSArray* nbViews = [[NSBundle mainBundle] loadNibNamed:@"TextInPutView"
                                                     owner:self
                                                   options:nil];
    
    TextInPutView *inputTextView = [ nbViews objectAtIndex: 0];

    self.TextInputViewNib =[[UIView alloc] init];
    [inputTextView initialize];
    self.TextInputViewNib = inputTextView;
    ((TextInPutView*)self.TextInputViewNib).customDelegate = self;
    
    self.txtField = inputTextView.textView;

    
    ((TextInPutView*)self.TextInputViewNib).textView.customDelegate = self ;
    CGRect toolBarFrame = self.TextInputViewNib.frame;
    UIDeviceOrientation nextOrientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation sori = [UIApplication sharedApplication].statusBarOrientation;
    if (nextOrientation == UIDeviceOrientationFaceUp && self.view.frame.size.width > self.view.frame.size.height && sori == UIInterfaceOrientationPortrait) {
        
        toolBarFrame.origin.y = self.view.frame.size.width - TextInputViewHeight;
        toolBarFrame.size.width =self.view.frame.size.height;
        toolBarFrame.size.height = TextInputViewHeight;
        
    }else if ((nextOrientation == UIDeviceOrientationLandscapeLeft || nextOrientation == UIDeviceOrientationLandscapeRight) && self.view.frame.size.width < self.view.frame.size.height){
        
        toolBarFrame.origin.y = self.view.frame.size.width - TextInputViewHeight;
        toolBarFrame.size.width =self.view.frame.size.height;
        toolBarFrame.size.height = TextInputViewHeight;
    }
    else{
        
        toolBarFrame.origin.y = self.view.frame.size.height - TextInputViewHeight;
        toolBarFrame.size.width =self.view.frame.size.width;
        toolBarFrame.size.height = TextInputViewHeight;
    }
    self.TextInputViewNib.frame = toolBarFrame;
    [self.view addSubview:self.TextInputViewNib];
    inputTextView = nil;
    [((TextInPutView*)self.TextInputViewNib).textView becomeFirstResponder];
}

-(void) keyboardWillShow:(NSNotification *)note{
    
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    CGRect containerFrame = self.TextInputViewNib.frame;
    tempKeyboardHeight =  CGRectGetHeight(keyboardBounds);

    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    self.TextInputViewNib.frame = containerFrame;
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect containerFrame = self.TextInputViewNib.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    self.TextInputViewNib.frame = containerFrame;
    [UIView commitAnimations];

    
    
}

- (void)customTextView:(containerView *)customTextView willChangeHeight:(float)height
{
    float diff = (customTextView.frame.size.height - height);
    
    CGRect r = self.TextInputViewNib.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.TextInputViewNib.frame = r;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [UIView animateWithDuration:0.1 animations:^{
        [((TextInPutView*)self.TextInputViewNib).textView resignFirstResponder];
    }];
    
    UIInterfaceOrientation sori = [UIApplication sharedApplication].statusBarOrientation;
    /* handle textInPutView position in rotation
     */
    if (size.height == self.view.frame.size.height ) {
        
        double refW = self.view.frame.size.height;
        double refH = self.view.frame.size.width;
        
        if (sori == UIInterfaceOrientationPortrait) {
            refW = self.view.frame.size.width;
            refH = self.view.frame.size.height;
        }
        
        [self.TextInputViewNib removeFromSuperview];
        CGRect toolBarFrame = self.TextInputViewNib.frame;
        toolBarFrame.origin.y = refW - toolBarFrame.size.height;
        toolBarFrame.size.width =refH;
        self.TextInputViewNib.frame = toolBarFrame;
        
        [self.view addSubview:self.TextInputViewNib];
        
    }
    
    else
    {
        [self.TextInputViewNib removeFromSuperview];
        CGRect toolBarFrame = self.TextInputViewNib.frame;
        toolBarFrame.origin.y = self.view.frame.size.width - toolBarFrame.size.height;
        toolBarFrame.size.width =self.view.frame.size.height;
        self.TextInputViewNib.frame = toolBarFrame;
        [self.view addSubview:self.TextInputViewNib];
        
    }
}


-(void)extraKeyBoardPressed{
    
    [self registerExtraKeyBoardxibFile];

    if (!isExtraKeybard) {
        self.txtField.internalTextView.inputView = self.ExtraKeyBoardFromNib;
        [self.ExtraKeyBoardFromNib removeFromSuperview];
        [self.txtField.internalTextView reloadInputViews];
        [self.txtField.internalTextView becomeFirstResponder];
        CGRect toolBarFrame = self.TextInputViewNib.frame;
        toolBarFrame.origin.y = self.view.frame.size.height - (self.TextInputViewNib.frame.size.height + ExtraKeyboardHeight);
        toolBarFrame.size.width = self.view.frame.size.width;

        self.TextInputViewNib.frame = toolBarFrame;
        isExtraKeybard = YES;
    } else {
        self.txtField.internalTextView.inputView = nil;
        [self.txtField.internalTextView reloadInputViews];
        isExtraKeybard =NO;
    }
}

- (void)didExtraKeyboardButtonPress {
    
    [self extraKeyBoardPressed];
}

- (void)textViewPressed {
    
    self.txtField.internalTextView.inputView = nil;
    [self.txtField.internalTextView reloadInputViews];
    isExtraKeybard = NO;
}
@end
