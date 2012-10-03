//
//  StudentsViewController.m
//  Students
//
//  Created by Ivan on 03.10.12.
//  Copyright (c) 2012 Ivan. All rights reserved.
//

#import "StudentsViewController.h"
#import "ProfileViewController.h"
#import "Student.h"
#import "RestKit/RestKit.h"

@interface StudentsViewController () {
    NSMutableArray *_students;
    NSIndexPath    *currentIndexPath;
    IBOutlet UITableView *studentsTableView;
}
@end

@implementation StudentsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        currentIndexPath = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewStudentAction:)];
    
    [self fillStudents];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (currentIndexPath != nil) {
        [studentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)insertNewStudentAction:(id)sender
{
    // Create new student
    Student *johnDoe = [Student new];
    johnDoe.identifier = [[NSNumber alloc] initWithInt: 3];
    johnDoe.fname =  @"John";
    johnDoe.lname =  @"Doe";
    
    // POST to '/students'
    [[RKObjectManager sharedManager] postObject:johnDoe usingBlock:^(RKObjectLoader *loader)
     {
         [loader setOnDidFailLoadWithError:^(NSError *error)
          {
              NSLog(@"Error is %@", error);
          }];
     }];
    
    [_students insertObject:johnDoe atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSInteger rowToDelete = indexPath.row;
        [[RKObjectManager sharedManager] deleteObject:[_students objectAtIndex:rowToDelete] usingBlock:^(RKObjectLoader *loader)
         {
             [loader setOnDidFailLoadWithError:^(NSError *error)
              {
                  NSLog(@"Error is %@", error);
              }];
         }];
        
        [_students removeObjectAtIndex:rowToDelete];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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

#pragma mark - Storyboard Segue notifications

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showProfile"]) {
        currentIndexPath = [self.tableView indexPathForSelectedRow];
        Student *student = _students[currentIndexPath.row];
        [[segue destinationViewController] setStudentProfile:student];
    }
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

- (void)viewDidUnload {
    [self setTableView:nil];
    studentsTableView = nil;
    [super viewDidUnload];
}
@end
