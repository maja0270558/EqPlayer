//
//  EqPlayerUITests.m
//  EqPlayerUITests
//
//  Created by 大容 林 on 2018/7/23.
//  Copyright © 2018年 Django. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface EqPlayerUITests : XCTestCase
@property(nonatomic) XCUIApplication *app;
@end

@implementation EqPlayerUITests

- (void)setUp {
    [super setUp];
    self.app = [[XCUIApplication alloc] init];
    [self.app launch];
}

- (void)tearDown {
    self.app = nil;
    [super tearDown];
}

-(void) testUserAddTrackInProject_ProjectTrackCellShouldExistsInProjectViewController {
    [NSThread sleepForTimeInterval:5];

    XCUIElementQuery *tablesQuery = self.app.scrollViews.otherElements.tables;
    XCUIElement *addProjectButton = [[XCUIApplication alloc] init]/*@START_MENU_TOKEN@*/.buttons[@"AddButton"]/*[[".buttons[@\"rounded add button\"]",".buttons[@\"AddButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
    [addProjectButton tap];
    XCUIElement *addTrackButton = self.app.buttons[@"add"];
    [addTrackButton tap];
    
    [tablesQuery/*@START_MENU_TOKEN@*/.cells.staticTexts[@"Lalaland buzz"]/*[[".cells.staticTexts[@\"Lalaland buzz\"]",".staticTexts[@\"Lalaland buzz\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/ tap];
    [tablesQuery/*@START_MENU_TOKEN@*/.cells.staticTexts[@"Another Day Of Sun - From \"La La Land\" Soundtrack"]/*[[".cells.staticTexts[@\"Another Day Of Sun - From \\\"La La Land\\\" Soundtrack\"]",".staticTexts[@\"Another Day Of Sun - From \\\"La La Land\\\" Soundtrack\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/ tap];
    [self.app.collectionViews/*@START_MENU_TOKEN@*/.cells.buttons[@"arrow down sign to navigate"]/*[[".cells.buttons[@\"arrow down sign to navigate\"]",".buttons[@\"arrow down sign to navigate\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElement *addedCell = self.app.tables/*@START_MENU_TOKEN@*/.cells.staticTexts[@"Another Day Of Sun - From \"La La Land\" Soundtrack"]/*[[".cells.staticTexts[@\"Another Day Of Sun - From \\\"La La Land\\\" Soundtrack\"]",".staticTexts[@\"Another Day Of Sun - From \\\"La La Land\\\" Soundtrack\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/ ;
    BOOL addedTrackCellExists = [addedCell exists];
    XCTAssertTrue(addedTrackCellExists);
}

@end
