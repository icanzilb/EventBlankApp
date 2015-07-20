# JSImagePickerController
A photo picker controller that resembles the style of the image picker in iOS 8's messages app.

![Screenshot](https://github.com/jacobsieradzki/JSImagePickerController/blob/master/Screenshots/imagePicker1.png)

## Installation

Just drop the two files for the JSImagePickerViewController class into your project and import them into whichever view controllers you want:

```Objective-C
#import "JSImagePickerViewController.h"
```

Next, put this code in your project to create and show the image picker:

```Objective-C
JSImagePickerViewController *imagePicker = [[JSImagePickerViewController alloc] init];
imagePicker.delegate = self;
[imagePicker showImagePickerInController:self animated:YES];
```

and add this delegate method to your code:

```Objective-C
- (void)imagePickerDidSelectImage:(UIImage *)image;
```

and if you want there are a choice of different delegate methods to choose from:

```Objective-C
- (void)imagePickerDidOpen;
- (void)imagePickerWillOpen;

- (void)imagePickerWillClose;
- (void)imagePickerDidClose;

- (void)imagePickerDidCancel;
```

and for personalization you can edit the public property's of the image picker:

```Objective-C
@property (nonatomic) NSTimeInterval animationTime;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *photoLibraryBtn;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
```
## License

You can use this freely in your projects as you wish but please email me at some point at jacob.sieradzki@gmail.com just so I can see how you have used it, thanks.

```
The MIT License (MIT)

Copyright (c) 2015 jacobsieradzki

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```



