#import "headers.h"
#import "RARecentAppsWidget.h"
#import "RAReachabilityManager.h"
#import "RAWidgetSectionManager.h"
#import "RASettings.h"
#import "RAAppSliderProvider.h"
#import "RAAppSliderProviderView.h"
#import "RAHostedAppView.h"

@interface RARecentAppsWidget () {
	CGRect viewFrame;
}
@end

@implementation RARecentAppsWidget
-(BOOL) enabled { return [RASettings.sharedInstance showRecentAppsInWidgetSelector]; }

-(NSInteger) sortOrder { return 1; }
-(NSString*) displayName { return LOCALIZE(@"RECENTS"); }
-(NSString*) identifier { return @"com.efrederickson.reachapp.widgets.sections.recentapps"; }

-(UIView*) viewForFrame:(CGRect)frame preferredIconSize:(CGSize)size_ iconsThatFitPerLine:(NSInteger)iconsPerLine spacing:(CGFloat)spacing
{
	viewFrame = frame;
	CGSize size = [%c(SBIconView) defaultIconSize];
	spacing = (frame.size.width - (iconsPerLine * size.width)) / iconsPerLine;
	NSString *currentBundleIdentifier = [[UIApplication sharedApplication] _accessibilityFrontMostApplication].bundleIdentifier;
	if (!currentBundleIdentifier)
		return nil;
	CGSize contentSize = CGSizeMake(10, 10);
	CGFloat interval = (size.width + spacing) * iconsPerLine;
	NSInteger intervalCount = 1;
	BOOL isTop = YES;
	BOOL hasSecondRow = NO;
	SBApplication *app = nil;
	CGFloat width = interval;
	NSInteger index = 0;

	NSMutableArray *recents = [[[%c(SBAppSwitcherModel) sharedInstance] snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] mutableCopy];
	[recents removeObject:currentBundleIdentifier];
	if (recents.count == 0)
		return nil;

	UIScrollView *recentsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 200)];
	recentsView.backgroundColor = [UIColor clearColor];
	recentsView.pagingEnabled = [RASettings.sharedInstance pagingEnabled];
	for (NSString *str in recents)
	{
		app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:str];
        SBIcon *icon = [[[%c(SBIconViewMap) homescreenMap] iconModel] applicationIconForBundleIdentifier:app.bundleIdentifier];
        SBIconView *iconView = [[%c(SBIconViewMap) homescreenMap] _iconViewForIcon:icon];
        if (!iconView)
        	continue;
        
        if (interval != 0 && contentSize.width + iconView.frame.size.width > interval * intervalCount)
		{
			if (isTop)
			{
				contentSize.height += size.height + 10;
				contentSize.width -= interval;
			}
			else
			{
				intervalCount++;
				contentSize.height -= (size.height + 10);
				width += interval;
			}
			hasSecondRow = YES;
			isTop = !isTop;
		}

        iconView.frame = CGRectMake(contentSize.width, contentSize.height, iconView.frame.size.width, iconView.frame.size.height);

        iconView.tag = index++;
        iconView.restorationIdentifier = app.bundleIdentifier;
        UITapGestureRecognizer *iconViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(appViewItemTap:)];
        [iconView addGestureRecognizer:iconViewTapGestureRecognizer];

        [recentsView addSubview:iconView];

        contentSize.width += iconView.frame.size.width + spacing;
	}
	contentSize.width = width;
	contentSize.height = 10 + ((size.height + 10) * (hasSecondRow ? 2 : 1));
	frame = recentsView.frame;
	frame.size.height = contentSize.height;
	recentsView.frame = frame;
	[recentsView setContentSize:contentSize];
	return recentsView;
}

-(void) appViewItemTap:(UIGestureRecognizer*)gesture
{
	//[[%c(SBWorkspace) sharedInstance] appViewItemTap:gesture];
	
	RAAppSliderProvider *provider = [[RAAppSliderProvider alloc] init];
	provider.availableIdentifiers = [[[%c(SBAppSwitcherModel) sharedInstance] snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] mutableCopy];
	[((NSMutableArray*)provider.availableIdentifiers) removeObject:[[UIApplication sharedApplication] _accessibilityFrontMostApplication].bundleIdentifier];
	provider.currentIndex = gesture.view.tag;

	RAAppSliderProviderView *view = [[RAAppSliderProviderView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height / 2)]; // TODO: fix frame
	view.swipeProvider = provider;
	view.isSwipeable = YES;

	[[RAReachabilityManager sharedInstance] showAppWithSliderProvider:view];
}
@end

%ctor
{
	static id _widget = [[RARecentAppsWidget alloc] init];
	[RAWidgetSectionManager.sharedInstance registerSection:_widget];
}