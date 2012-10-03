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

@end

@implementation ProfileViewController

- (IBAction)uploadPhotoAction:(id)sender {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSLog(@"[TELLME] Camera is not available on this device.");
    }
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    [self presentModalViewController:photoPicker animated:YES];
    [self presentViewController:photoPicker animated:YES completion:NULL];
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
    [super viewDidUnload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.firstName || theTextField == self.lastName) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

@end
