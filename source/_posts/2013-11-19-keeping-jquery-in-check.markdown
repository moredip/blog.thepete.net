---
layout: post
title: "Keeping jQuery in check"
date: 2013-11-19 22:18
comments: true
categories: 
---

The way we use JavaScript today has evolved radically from its humble beginnings. For a long time it was consider a simple UI language for basic enhancement of HTML content. Today it is used as a full-fledged first-class language used to build large applications. 

We should be building these modern JavaScript applications with the same professional care and rigor that we apply when building applications in other technologies. In this post I won't be talking too much about the general aspects of how we might use JavaScript properly - my [class-less JavaScript post](http://blog.thepete.net/2012/02/class-less-javascript.html) touches on some of that from a language point of view. Instead I'll be focusing on how to leverage the wonderful expressive power of jQuery to build a modern client-side JavaScript application in a maintainable, extensible, and testable way.

## jQuery is awesome.
jQuery is a wonderful library for working with the DOM. It provides a great API which raises the level of abstraction significantly while also smoothing over tedious cross-browser compatibility issues. It allows us to focus on the [essential complexity](http://97things.oreilly.com/wiki/index.php/Simplify_essential_complexity;_diminish_accidental_complexity) of the user experience we are creating, rather than the accidental complexity of manipulating HTML in a browser.

## jQuery-centric codebases aren't always awesome.
That said, jQuery isn't perfect. In the absence of developer discipline jQuery code will tend to evolve into a unstructured mess. There are a lot of "jQuery soup" codebases out there where AJAX calls, app logic, and UI logic are intermingled pretty much at random. 

In this post I'll refer to "jQuery soup" code quite a bit. This is a shorthand for the type of code where calls to jQuery are made from arbitrary places. A codebase where there is little distinction between 'UI code' and 'app code'.  This kind of unstructured JavaScript code is very similar to an unstructured PHP app where SQL statements sit side-by-side with business rules and a bit of HTML string concatenation (why not!). I'd be showing my age if I said that jQuery soup is also quite reminiscent of desktop apps from about a decade ago where button click handlers would hit the database, make a few service calls, and then update some other part of the UI.

## We need to start taking JavaScript seriously

These aspects of jQuery have been much less of an issue in the past, when JavaScript codebases tended to be extremely small (a few hundred lines of code maybe) with almost all non-presentation logic handled by some server-side component. The JavaScript part of the app was basically just responsible for presentation logic, so calls to jQuery from anywhere in the JavaScript code made perfect sense - the whole JavaScript codebase was just presentation-layer glue. 

However we know that this isn't the case for more and more JavaScript codebases today. In a modern web application you can expect to have significant application logic (not just presentation logic) implemented on the client in JavaScript. In extreme examples we now have single-page JavaScript applications which are able to run in a fully offline mode. That implies an application where *all* functionality implemented in JavaScript, at least some of the time. More sophisticated applications call for more sophistication in the way we structure our JavaScript.

# Testing with the DOM is no fun

It's interesting that jQuery soup tends to be a frustrating thing to unit test. I believe that <abbr title="Test-Driven Development">TDD</abbr> plays a significant role in providing feedback on the design of your code - a focused, loosely coupled design tends to lend itself to testing. So I don't find it particularly surprising that jQuery soup - which is hard to unit test - tends to corrolate to a poorly structured codebase which is hard to maintain and evolve. 

The `$` global variable (the Almighty Dollar) which jQuery introduces makes it very easy for jQuery calls to permeate your codebase. `$` is always within arms reach, and so convenient to use. This means it's *very* easy to create code which updates the UI or makes a network call as a non-obvious side-effect of doing its work. 

It's hard to test code which reaches out to implicit dependencies such as global variables. It's also hard to test UI code. jQuery soup code uses implicit dependencies to modify UI. This double-whammy leads to code which very tricky to test. Most developers when confronted with the task of writing automated tests for a jQuery soup codebase will quite rightly feel a lot of pain.

## jQuery can make it too easy to do the wrong thing

In part this is an outcome of the problem domain which jQuery is built to solve. jQuery's goal is to make it super-simple to work with DOM elements and CSS classes. The problem is that jQuery makes it *so easy* to just reach out and manipulate the DOM that if you are not careful these types of low-level interactions permeate your codebase. Those kind of interactions are hard to the kind of stuff which is tough to test in an isolated way. If they permeate your codebase (jQuery soup) then you're left with a codebase which is tough to test in an isolated way (we'll get back to what I mean by 'isolated' in a moment).

I'll illustrate what I mean with a concrete example. Imagine you have an app which does basic validation of a phone number. The easiest way to get that working was to use `$` to wire up some DOM events to some validation functions (or a jQuery plugin) which in turn use `$` to update the UI if there are validation issues. 

An initial pass at testing that validation logic might be to give your app some input and then see whether it passes validation based on how your app updates the UI. You might take a [mockist approach](http://martinfowler.com/articles/mocksArentStubs.html#ClassicalAndMockistTesting) to this and stub out `$`. Alternatively you might take a *state-based* approach and test how your app has behaved based on how it has used `$` to change the DOM. Either way, if we're testing our app logic by inspecting how our app drives jQuery (and thus the UI) then by necessity we have coupled testing of our app logic to our UI. This means that our tests are brittle - changes in our UI might break our app logic tests for no good reason. It also means our tests are going to run slowly - we probably need to run them in a browser or at the very least we need some sort of DOM available. Finally - and most importantly - our tests are not **focussed**. It's hard to see what a test is really verifying when you have UI concerns muddying the waters. And again, when that test breaks it's not immediately clear whether it broke because of a UI change or because some application logic is no longer working correctly. This is what we mean when we talk about isolated tests. Are they testing an isolated chunk of our app such that when the test breaks we know exactly which small chunk of our app is no loger working as expected.

# Separated Presentation

Wouldn't you know it, but this isn't the first time our industry has come up against this problem. In fact, there are well established patterns which can guide us towards a solution, such as [Separated Presentation](http://martinfowler.com/eaaDev/SeparatedPresentation.html). As Martin Fowler succinctly puts it this pattern helps *"Ensure that any code that manipulates presentation only manipulates presentation, pushing all domain and data source logic into clearly separated areas of the program"*. Sounds pretty appropriate to our jQuery soup problem I'd say.

## Seperating jQuery code

The question is how can we apply this approach to a JavaScript codebase. We start by aggressively segregating our low-level presentation code into a small area of your application which exposes a clear API to the rest of your application. This API goes two ways. It allows your app to update your UI, and it allows your app to respond to events in your UI. 

With this presentation separation in place we can now ban all use of `$` from anywhere else in our code. We can only use jQuery to interact with the DOM from within that skinny presentation layer.

Once you have this clear seperation you can now test both sides of the presentation-layer API in an optimal way. You can test your presentation code by loading it into a browser, poking it with tests, and seeing how it responds. You can test your non-presentation code by mocking out the presentation API with test doubles, and using those test doubles both to simulate UI events and to verify how your app manipulates the UI.

And guess what. the **only** place you should need a reference to JQuery is inside this thin presentation layer. In fact, the only place you need access to a browser DOM is inside the presentation layer. This means that you can run the large majority of your unit tests in a very fast and stable JavaScript environment using something like node.js or rhino, and leave the more fragile and expensive in-browser testing to a much smaller number of presentation-layer tests. This allows shockingly fast unit tests (I worked on a large javascript SPA where we just ran the entire unit test suite whenever a file was saved), plus focused DOM-based tests where they are helpful for UI-centric functionality.


## Sidebar - integration tests
Note I'm talking about unit tests here. You could (and probably should) write integration tests which drive your web application in a web browser, and test that for given inputs the web app behaves a certain way. You could do this inside the app's context using something like [JsTestDriver](http://code.google.com/p/js-test-driver/), or out of the app's context using something like [WebDriver](http://seleniumhq.org/). These types of test are definitely useful, but they are also fragile and slow. They also don't help drive out the *design* of your code. In other words, they are a *supplement* to unit tests, not a *substitute* for them.

