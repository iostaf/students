//
//  StudentsViewController.m
//  Students
//
//  Created by Ivan on 03.10.12.
//  Copyright (c) 2012 Ivan. All rights reserved.
//

#import "StudentsViewController.h"
#import "Student.h"
#import "RestKit/RestKit.h"

@interface StudentsViewController () {
    NSMutableArray *_students;
}
@end

@implementation StudentsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    
    [self fillStudents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _students.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Student"];
    Student *student = _students[indexPath.row];
    cell.textLabel.text = [student description];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - My code

- (void) initObjectManager
{
    RKObjectManager * manager     = [RKObjectManager managerWithBaseURLString:@"http://localhost:9292"];
    manager.acceptMIMEType        = RKMIMETypeJSON;
    manager.serializationMIMEType = RKMIMETypeJSON;
}

- (void) setupStudentMapping
{
    // Set up mapping
    RKObjectMapping* studentMapping = [RKObjectMapping mappingForClass:[Student class]];
    [studentMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    [studentMapping mapKeyPath:@"fname" toAttribute:@"fname"];
    [studentMapping mapKeyPath:@"lname" toAttribute:@"lname"];
    [[RKObjectManager sharedManager].mappingProvider setMapping:studentMapping forKeyPath:@"students"];
    
    // Set up searialization mapping
    RKObjectMapping *studentSerializationMapping = [RKObjectMapping
                                                    mappingForClass:[NSMutableDictionary class]];
    [studentSerializationMapping mapKeyPath:@"identifier" toAttribute:@"id"];
    [studentSerializationMapping mapKeyPath:@"fname" toAttribute:@"fname"];
    [studentSerializationMapping mapKeyPath:@"lname" toAttribute:@"lname"];
    [[RKObjectManager sharedManager].mappingProvider setSerializationMapping:studentSerializationMapping forClass:[Student class]];
    
    // Set up routes
    [[RKObjectManager sharedManager].router routeClass:[Student class] toResourcePath:@"/students/:identifier"];
    [[RKObjectManager sharedManager].router routeClass:[Student class] toResourcePath:@"/students" forMethod:RKRequestMethodPOST];
}

- (void) fillStudents
{
    if (!_students) {
        _students = [[NSMutableArray alloc] init];
    }
    [_students removeAllObjects];
    
    [self initObjectManager];
    [self setupStudentMapping];
    
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/students" usingBlock:^(RKObjectLoader *loader)
     {
         [loader setOnDidLoadObjects:^(NSArray *students)
          {
              int index = 0;
              for (Student *student in students) {
                  NSLog(@"Student's first name is: %@", student.fname);
                  [_students addObject:student];
                  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index++ inSection:0];
                  [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
              }
          }];
         [loader setOnDidFailLoadWithError:^(NSError *error)
          {
              NSLog(@"Error is %@", error);
          }];
     }];
}

@end
