//
//  JSImagePickerViewController.m
//  iOS8Style-ImagePicker
//
//  Created by Jake Sieradzki on 09/01/2015.
//  Copyright (c) 2015 Jake Sieradzki. All rights reserved.
//

#import "JSImagePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>

#pragma mark - JSImagePickerViewController -

@interface JSImagePickerViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

#define imagePickerHeight 280.0f

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@property (nonatomic, strong) UIViewController *targetController;
@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *imagePickerView;

@property (nonatomic) NSTimeInterval animationTime;

@property (nonatomic) CGRect imagePickerFrame;
@property (nonatomic) CGRect hiddenFrame;

@property (nonatomic) TransitionDelegate *transitionController;


@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *photoLibraryBtn;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *cancelBtn;


@property (nonatomic, strong) NSMutableArray *assets;

@end

@implementation JSImagePickerViewController

@synthesize delegate;
@synthesize transitionController;

- (id)init {
    self = [super init];
    if (self) {
        self.assets = [[NSMutableArray alloc] init];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.view.backgroundColor = [UIColor clearColor];
    self.window = [UIApplication sharedApplication].keyWindow;
    
    
    self.imagePickerFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-imagePickerHeight, [UIScreen mainScreen].bounds.size.width, imagePickerHeight);
    self.hiddenFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, imagePickerHeight);
    self.imagePickerView = [[UIView alloc] initWithFrame:self.hiddenFrame];
    self.imagePickerView.backgroundColor = [UIColor whiteColor];
    
    
    
    self.backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    self.backgroundView.alpha = 0;
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    self.backgroundView.userInteractionEnabled = YES;
    [self.backgroundView addGestureRecognizer:dismissTap];
    
    
    
    self.animationTime = 0.2;
    
    [self.window addSubview:self.backgroundView];
    [self.window addSubview:self.imagePickerView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.imagePickerView.frame.size.width, 50)];
    [btn setTitle:@"Hello!" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setDefaults) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imagePickerView addSubview:btn];
    
    [self imagePickerViewSetup];
    [self getCameraRollImages];
}

- (void)imagePickerViewSetup {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    const CGRect collectionViewFrame = CGRectMake(7, 8, screenWidth-7-7, 122);
    const CGRect libraryBtnFrame = CGRectMake(0, 149, screenWidth, 30);
    const CGRect cameraBtnFrame = CGRectMake(0, 196, screenWidth, 30);
    const CGRect cancelBtnFrame = CGRectMake(0, 242, screenWidth, 30);
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:aFlowLayout];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[JSPhotoCell class] forCellWithReuseIdentifier:@"Cell"];
    
    UIFont *btnFont = [UIFont systemFontOfSize:19.0];
    
    self.photoLibraryBtn = [[UIButton alloc] initWithFrame:libraryBtnFrame];
    [self.photoLibraryBtn setTitle:@"Photo Library" forState:UIControlStateNormal];
    self.photoLibraryBtn.titleLabel.font = btnFont;
    [self.photoLibraryBtn addTarget:self action:@selector(selectFromLibraryWasPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.cameraBtn = [[UIButton alloc] initWithFrame:cameraBtnFrame];
    [self.cameraBtn setTitle:@"Take Photo" forState:UIControlStateNormal];
    self.cameraBtn.titleLabel.font = btnFont;
    [self.cameraBtn addTarget:self action:@selector(takePhotoWasPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelBtn = [[UIButton alloc] initWithFrame:cancelBtnFrame];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = btnFont;
    [self.cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *btn in @[self.photoLibraryBtn, self.cameraBtn, self.cancelBtn]) {
        [btn setTitleColor:UIColorFromRGB(0x0b60fe) forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x70B3FD) forState:UIControlStateHighlighted];
    }
    
    UIView *separator1 = [[UIView alloc] initWithFrame:CGRectMake(0, 140, screenWidth, 1)];
    separator1.backgroundColor = UIColorFromRGB(0xDDDDDD);
    [self.imagePickerView addSubview:separator1];
    
    UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(25, 187, screenWidth-25, 1)];
    separator2.backgroundColor = UIColorFromRGB(0xDDDDDD);
    [self.imagePickerView addSubview:separator2];
    UIView *separator3 = [[UIView alloc] initWithFrame:CGRectMake(25, 234, screenWidth-25, 1)];
    separator3.backgroundColor = UIColorFromRGB(0xDDDDDD);
    [self.imagePickerView addSubview:separator3];
    
    [self.imagePickerView addSubview:self.collectionView];
    [self.imagePickerView addSubview:self.photoLibraryBtn];
    [self.imagePickerView addSubview:self.cameraBtn];
    [self.imagePickerView addSubview:self.cancelBtn];
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(20, self.assets.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[self.assets.count-1 - indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:imageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    ALAsset *asset = self.assets[self.assets.count-1 - indexPath.row];
    UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
    
    if ([delegate respondsToSelector:@selector(imagePickerDidSelectImage:)]) {
        [delegate imagePickerDidSelectImage:image];
    }
    
    [self dismissAnimated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(170, 114);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}

#pragma mark - Image library


- (void)getCameraRollImages {
    _assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    ALAssetsLibrary *assetsLibrary = [JSImagePickerViewController defaultAssetsLibrary];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result)
            {
                [tmpAssets addObject:result];
            }
        }];
        
        ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [self.assets addObject:result];
            }
        };
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        
        [self.collectionView reloadData];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading images %@", error);
    }];
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark - Image picker

- (void)takePhotoWasPressed {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)selectFromLibraryWasPressed {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([delegate respondsToSelector:@selector(imagePickerDidSelectImage:)]) {
            [delegate imagePickerDidSelectImage:chosenImage];
        }
        [self dismissAnimated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Show

- (void)showImagePickerInController:(UIViewController *)controller {
    [self showImagePickerInController:controller animated:YES];
}

- (void)showImagePickerInController:(UIViewController *)controller animated:(BOOL)animated {
    if (self.isVisible != YES) {
        if ([delegate respondsToSelector:@selector(imagePickerWillOpen)]) {
            [delegate imagePickerWillOpen];
        }
        self.isVisible = YES;
        
        [self setTransitioningDelegate:transitionController];
        self.modalPresentationStyle = UIModalPresentationCustom;
        [controller presentViewController:self animated:NO completion:nil];
        
        if (animated) {
            [UIView animateWithDuration:self.animationTime
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [self.imagePickerView setFrame:self.imagePickerFrame];
                                 [self.backgroundView setAlpha:1];
                             }
                             completion:^(BOOL finished) {
                                 if ([delegate respondsToSelector:@selector(imagePickerDidOpen)]) {
                                     [delegate imagePickerDidOpen];
                                 }
                             }];
        } else {
            [self.imagePickerView setFrame:self.imagePickerFrame];
            [self.backgroundView setAlpha:0];
        }
    }
}

#pragma mark - Dismiss

- (void)dismiss {
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
    if (self.isVisible == YES) {
        if ([delegate respondsToSelector:@selector(imagePickerWillClose)]) {
            [delegate imagePickerWillClose];
        }
        if (animated) {
            [UIView animateWithDuration:self.animationTime
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 [self.imagePickerView setFrame:self.hiddenFrame];
                                 [self.backgroundView setAlpha:0];
                             }
                             completion:^(BOOL finished) {
                                 [self.imagePickerView removeFromSuperview];
                                 [self.backgroundView removeFromSuperview];
                                 [self dismissViewControllerAnimated:NO completion:nil];
                                 if ([delegate respondsToSelector:@selector(imagePickerDidClose)]) {
                                     [delegate imagePickerDidClose];
                                 }
                             }];
        } else {
            [self.imagePickerView setFrame:self.imagePickerFrame];
            [self.backgroundView setAlpha:0];
        }
        
        // Set everything to nil
    }
}

@end



#pragma mark - TransitionDelegate -
@implementation TransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc] init];
    controller.isPresenting = YES;
    return controller;
}

@end




#pragma mark - AnimatedTransitioning -
@implementation AnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *inView = [transitionContext containerView];
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [inView addSubview:toVC.view];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [toVC.view setFrame:CGRectMake(0, screenRect.size.height, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}


@end



#pragma mark - JSPhotoCell -
@interface JSPhotoCell ()

@end

@implementation JSPhotoCell

@end
