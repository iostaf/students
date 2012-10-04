//
//  ProfileViewController.m
//  Students
//
//  Created by Ivan on 03.10.12.
//  Copyright (c) 2012 Ivan. All rights reserved.
//

#import "ProfileViewController.h"
#import "RestKit/RestKit.h"
#import "Student.h"

@interface ProfileViewController ()

@property (strong, nonatomic) Student *student;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation ProfileViewController

- (IBAction)uploadPhotoAction:(id)sender {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSLog(@"[TELLME] Camera is not available on this device.");
    }
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    [self presentModalViewController:photoPicker animated:YES];
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    // Dismiss the image selection, hide the picker and
    // show the image view with the picked image
    [picker dismissModalViewControllerAnimated:YES];
    // Show image on the screen
    self.profileImageView.image = image;
    
    // Upload image to the server
    RKParams *params = [RKParams params];
    NSData *imageData = UIImagePNGRepresentation(image);
    [params setData:imageData MIMEType:@"image/png" forParam:@"image1"];
    [[RKClient sharedClient] post:@"/students/image" params:params delegate:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)setStudentProfile:(id)newStudentProfile
{
    if (_student != newStudentProfile) {
        _student = newStudentProfile;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.firstName.text = _student.fname;
    self.lastName.text  = _student.lname;
}

- (void)viewWillDisappear:(BOOL)animated
{
    _student.fname = self.firstName.text;
    _student.lname = self.lastName.text;
    
    [[RKObjectManager sharedManager] putObject:_student usingBlock:^(RKObjectLoader *loader)
     {
         [loader setOnDidFailLoadWithError:^(NSError *error)
          {
              NSLog(@"Error is %@", error);
          }];
     }];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setFirstName:nil];
    [self setLastName:nil];
    [self setProfileImageView:nil];
    [super viewDidUnload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.firstName || theTextField == self.lastName) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

@end
