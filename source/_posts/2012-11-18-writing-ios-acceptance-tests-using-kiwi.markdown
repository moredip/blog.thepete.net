---
layout: post
title: "Writing iOS acceptance tests using Kiwi"
date: 2012-11-18 19:24
comments: true
categories: 
---

In this post I'll describe an experiment where rather than using [Frank](http://testingwithfrank.com) to write iOS acceptance tests I instead combined Kiwi with the low-level libraries that Frank uses internally. This allowed me to write acceptance tests in pure objective-C which run in the app process itself, very similarly to the way [KIF](http://github.com/square/kif) works.

## What?

Before I start, let me be clear that I personally wouldn't use this approach to writing acceptance tests. I much prefer using a higher-level language like ruby to write these kinds of tests. The test code is way less work and way more expressive, assuming you're comfortable in ruby. And that's why I wanted to try this experiment. I've spoken to quite a few iOS developers over time who are *not* comfortable writing tests in ruby. They are more comfortable in Objective-C than anything else, and would like to write their tests in the same language they use for their production code. Fair enough.

## Why not KIF?

I suspect that the ability to write your tests in Objective C is the main reason that some developers turn to KIF for their acceptance tests. 

I have two problems with KIF though. First, the tool conflates three distinct activities - test organization, view selection, and simulating interactions. I think these activities are better served when broken out into distinct responsibilities. In the case of test organization, tools like Cedar and Kiwi have had a lot of uptake and Kiwi in particular is becoming a very popular choice. Alternatively you can use one of the more established tools like OCUnit. These tools handle things like organizing test code into test cases and test suites, running those tests, asserting on values, and reporting the output in a useful way. Why re-invent that wheel in KIF, when it's the core competency of these other tools? When it comes to view selection and simulating interactions, because these two are intertwined in KIF you end up with really verbose code if you want to do something like find an element, check it's visible, tap it, then check it went away. 

The second concern I have with KIF is simply that it doesn't seem to be under active development. I have also heard from a few people that it's not really used much by teams within Square at this point.

## So what's the alternative?

I visited a couple of iOS development teams in Australia recently and this topic came up with both teams while chatting with them. It occurred to me that you could probably implement KIF-style tests pretty simply using the view selection and automation library which Frank uses, plus Kiwi for a test runner. I had a 15 hour flight back to San Francisco, and this seemed like a fun experiment to while away a couple of those hours.

The idea is simple really. Wire up Kiwi just like you would for [Application Unit Tests](http://developer.apple.com/library/ios/#documentation/DeveloperTools/Conceptual/UnitTesting/02-Setting_Up_Unit_Tests_in_a_Project/setting_up.html#//apple_ref/doc/uid/TP40002143-CH3-SW6), but rather than doing white-box testing on individual classes inside your app you instead drive your app's UI by selecting views programmatically using Shelley (Frank's view selection engine) and then simulate interacting with those views using PublicAutomation (the lightweight wrapper over Apple's private UIAutomation framework that Frank also uses). Alternatively after selecting views using Shelley you might then just programatically inspect the state of the views to confirm that the UI has responded appropriately to previous steps in your test.

## How does it work?

To prove this concept out I wrote a really simple User Journey test which was exercising the same 2012 Olympics app I've used as an example in [previous](/blog/2012/06/24/writing-your-first-frank-test) [posts](/blog/2012/07/22/running-frank-as-part-of-ios-ci). Here's what it looks like:

``` obj-c BasicUserJourney_Spec.m
#import "AcceptanceSpecHelper.h"
#import "EventsScreen.h"

SPEC_BEGIN(BasicUserJourney)

describe(@"User Journey", ^{
    
    beforeAll(^{
        sleepFor(0.5);
    });
    it(@"visits the event screen and views details on a couple of events", ^{
        EventsScreen *eventsScreen = [EventsScreen screen];
        [[theValue([eventsScreen currentlyOnCorrectTab]) should] beTrue];
        
        [eventsScreen selectEvent:@"beach volleyball"];
        [[theValue([eventsScreen currentlyViewingEventDetailsFor:@"Beach Volleyball"]) should] beTrue];
        
        [eventsScreen goBackToOverview];
        
        [eventsScreen selectEvent:@"canoe sprint"];
        [[theValue([eventsScreen currentlyViewingEventDetailsFor:@"Canoe Sprint"]) should] beTrue];

    });
});


SPEC_END
```

I'm using the Page Object pattern to encapsulate the details of how each screen is automated. In this case the `EventsScreen` class is playing that Page Object role. 

The aim here is that you can read the high-level flow test above and quite easily get the gist of what it's testing. Now let's dive into the details and see how the magic happens inside `EventsScreen`:

``` obj-c EventsScreen.m
#import "EventsScreen.h"

@interface EventsScreen()
- (NSArray *)viewsViaSelector:(NSString *)selector;
- (UIView *)viewViaSelector:(NSString *)selector;
- (void) tapViewViaSelector:(NSString *)selector;
@end

@implementation EventsScreen

+ (EventsScreen *) screen{
    EventsScreen *screen = [[[EventsScreen alloc] init] autorelease];
    [screen visit];
    return screen;
}

- (void) visit{
    [self tapViewViaSelector:@"view:'UITabBarButton' marked:'Events'"];
}

- (BOOL) currentlyOnCorrectTab{
    return [self viewViaSelector:@"view:'UITabBarButton' marked:'Events' view:'UITabBarSelectionIndicatorView'"] != nil;
}

- (void) selectEvent:(NSString *)eventName{
    NSString *viewSelector = [NSString stringWithFormat:@"view:'UIScrollView' button marked:'%@'",eventName];
    [self tapViewViaSelector:viewSelector];
}

- (void) goBackToOverview{
    [self tapViewViaSelector:@"view:'UINavigationButton' marked:'Back'"];
}

- (BOOL) currentlyViewingEventDetails{
    return [self viewViaSelector:@"label marked:'Key Facts'"] && [self viewViaSelector:@"label marked:'The basics'"];
}

- (BOOL) currentlyViewingEventDetailsFor:(NSString *)eventName{
    return [self currentlyViewingEventDetails] && [self viewViaSelector:[NSString stringWithFormat:@"label marked:'%@'",eventName]];
}


#pragma mark internals


- (NSArray *)viewsViaSelector:(NSString *)selector{
    return [[Shelley withSelectorString:selector] selectFrom:[[UIApplication sharedApplication] keyWindow]];
}

- (UIView *)viewViaSelector:(NSString *)selector{
    NSArray *views = [self viewsViaSelector:selector];
    if( [views count] == 0 )
        return nil;
    else
        return [views objectAtIndex:0];
}

- (void) tapViewViaSelector:(NSString *)viewSelector{
    [UIAutomationBridge tapView:[self viewViaSelector:viewSelector]];
    sleepFor(0.1); //ugh
}

@end
```

As you can see, most of `EventsScreen` methods are only a line or two long. They generally either tap on a view or check that a view exists in the heirarchy. They use Shelley view selectors, which is a big part of keeping the code declarative and concise. There are also a few internal helper methods inside `EventsScreen` which would probably get moved out into a shared location pretty soon, maybe a `BaseScreen` class from which concrete Page Object classes could be derived.

## Proof of Concept satisfied

And that's pretty much all that was needed. There was the usual tedious XCode plumbing to get Kiwi and everything else working together, plus a few other bits and pieces, but really there wasn't much to it.

## What else would you need?

For any large test suite you'd want a lot more helpers. Based on my experience writing acceptance tests with Frank you usually need things like:

- wait for something to happen, with timeout
- scroll things into view so you can interact with them
- support for higher-level generic questions (is this view currently visible, is anything animating, etc).

Eventually you'd probably also evolve a little internal DSL that lets you implement your Page Object classes in a more expressive way.

## What do you think?

I'm very interested to see if this approach is appealing to people. If you're interested, or even better if you take this and run with it then please let me know.
