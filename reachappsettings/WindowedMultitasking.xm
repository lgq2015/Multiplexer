#import <Preferences/Preferences.h>
#import <SettingsKit/SKListControllerProtocol.h>
#import <SettingsKit/SKTintedListController.h>
#import <Preferences/PSSwitchTableCell.h>
#import <AppList/AppList.h>
#import <substrate.h>
#import <notify.h>
#import "RAHeaderView.h"
#import "PDFImage.h"
#import "RASettings.h"

#define PLIST_NAME @"/var/mobile/Library/Preferences/com.efrederickson.reachapp.settings.plist"

@interface PSViewController (Protean)
-(void) viewDidLoad;
-(void) viewWillDisappear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
@end

@interface PSViewController (SettingsKit2)
-(UINavigationController*)navigationController;
-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;
@end

@interface ALApplicationTableDataSource (Private)
- (void)sectionRequestedSectionReload:(id)section animated:(BOOL)animated;
@end

@interface ReachAppWindowSettingsListController: SKTintedListController<SKListControllerProtocol>
@end

@implementation ReachAppWindowSettingsListController
-(UIView*) headerView
{
    RAHeaderView *header = [[RAHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    header.colors = @[ 
        (id) [UIColor colorWithRed:255/255.0f green:94/255.0f blue:58/255.0f alpha:1.0f].CGColor,
        (id) [UIColor colorWithRed:255/255.0f green:149/255.0f blue:0/255.0f alpha:1.0f].CGColor, 
    ];
    header.shouldBlend = NO;
    header.image = [[PDFImage imageWithContentsOfFile:@"/Library/PreferenceBundles/ReachAppSettings.bundle/EmpoleonHeader.pdf"] imageWithOptions:[PDFImageOptions optionsWithSize:CGSizeMake(32, 32)]];

    UIView *notHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    [notHeader addSubview:header];

    return notHeader;
}
-(UIColor*) tintColor { return [UIColor colorWithRed:255/255.0f green:94/255.0f blue:58/255.0f alpha:1.0f]; }
-(UIColor*) switchTintColor { return [[UISwitch alloc] init].tintColor; }
-(NSString*) customTitle { return @"Empoleon"; }
-(BOOL) showHeartImage { return NO; }

-(NSArray*) customSpecifiers
{
    return @[
                 @{ @"footerText": @"" },
             @{
                 @"cell": @"PSSwitchCell",
                 @"default": @YES,
                 @"defaults": @"com.efrederickson.reachapp.settings",
                 @"key": @"windowedMultitaskingEnabled",
                 @"label": @"Enabled",
                 @"PostNotification": @"com.efrederickson.reachapp.settings/reloadSettings",
                 },

             @{ @"label": @"Swipe Up From Bottom..."},
             @{
                 @"cell": @"PSSegmentCell",
                 @"validTitles": @[ @"Left (Default)",            @"Middle",                      @"Right" ],
                 @"validValues": @[ @(RAGrabAreaBottomLeftThird), @(RAGrabAreaBottomMiddleThird), @(RAGrabAreaBottomRightThird), ],
                 @"default": @(RAGrabAreaBottomLeftThird),
                 @"key": @"windowedMultitaskingGrabArea",
                 @"defaults": @"com.efrederickson.reachapp.settings",
                 @"PostNotification": @"com.efrederickson.reachapp.settings/reloadSettings",
                 },

             @{ @"footerText": @"If this is off, you cannot resize, rotate, etc. windows unless the overlay is showing." },
             @{
                 @"cell": @"PSSwitchCell",
                 @"default": @YES,
                 @"defaults": @"com.efrederickson.reachapp.settings",
                 @"key": @"alwaysEnableGestures",
                 @"label": @"Always enable gestures",
                 @"PostNotification": @"com.efrederickson.reachapp.settings/reloadSettings",
                 },

             @{ @"footerText": @"Unobtrusively snaps windows" },
             @{
                 @"cell": @"PSSwitchCell",
                 @"default": @YES,
                 @"defaults": @"com.efrederickson.reachapp.settings",
                 @"key": @"snapWindows",
                 @"label": @"Snap Windows",
                 @"PostNotification": @"com.efrederickson.reachapp.settings/reloadSettings",
                 },
             @{
                 @"cell": @"PSSwitchCell",
                 @"default": @YES,
                 @"defaults": @"com.efrederickson.reachapp.settings",
                 @"key": @"snapRotation",
                 @"label": @"Rotation Snapping",
                 @"PostNotification": @"com.efrederickson.reachapp.settings/reloadSettings",
                 },

             @{ @"label": @"Lock button action" },
             @{
                 @"cell": @"PSSegmentCell",
                 @"validTitles": @[ @"Lock all rotation", @"Lock app rotation" ],
                 @"validValues": @[ @0, @1 ],
                 @"default": @0,
                 @"key": @"windowRotationLockMode",
                 @"defaults": @"com.efrederickson.reachapp.settings",
                 @"PostNotification": @"com.efrederickson.reachapp.settings/reloadSettings",
                 },

             @{ @"footerText": @"Launches app into windows instead of fullscreen" },
             @{
                 @"cell": @"PSSwitchCell",
                 @"default": @NO,
                 @"defaults": @"com.efrederickson.reachapp.settings",
                 @"key": @"launchIntoWindows",
                 @"label": @"Launch into Window",
                 @"PostNotification": @"com.efrederickson.reachapp.settings/reloadSettings",
                 },
             ];
}
@end