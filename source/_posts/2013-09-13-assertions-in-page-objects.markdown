---
layout: post
title: "Assertions in Page Objects"
date: 2013-09-13 16:19
comments: true
categories: 
---

Martin Fowler recently added a [bliki entry for the Page Object pattern](http://martinfowler.com/bliki/PageObject.html). It's a good writeup - if you haven't read it I recommend doing so now. [Go ahead](http://martinfowler.com/bliki/PageObject.html). I'll wait.

The entry sparked a discussion on an internal ThoughtWorks mailing list as to whether Page Objects should include assertions or not. In fact Martin mentions this difference of opinion in the bliki entry itself. I fell on the side of favoring page objects *with* assertions but couldn't come up with a compelling reason why until I was working on some Capybara-based page objects with a client QA today. 

## TL;DR

If you don't put assertions inside your page objects you are violating Tell Don't Ask, which in turn hinders the ability for your testing framework to do implicit spin asserts. 

In the following I'll explain all of that in more detail.

## Tell Don't Ask vs Single Responsibility Principle

Let's use a concrete example with Page Objects. I'm testing a web page which lists my bank accounts. In one of my tests I want to verify that the list of bank accounts includes a bank account with a balance of 100.25. 

If I didn't want assertions in my page object I would *Ask* my page object for a list of bank accounts, and then check for the balance myself:

``` ruby
accounts = bank_account_page.listed_accounts
accounts.find{ |account| account[:balance] == 100.25 }.should_not be_nil
```

On the other hand if I'm OK with assertions in my page object I would *Tell* my page object to check for a listed bank account with that balance:

``` ruby
bank_account_page.verify_has_listed_account_with_balance_of( 100.25 )
```

This second example conforms to "[Tell Don't Ask](http://martinfowler.com/bliki/TellDontAsk.html)", the idea that it's more object-oriented to tell an object what you want than to ask it questions and then do the work yourself. However you could argue that it also violates [Single Responsibility Principle](http://www.codinghorror.com/blog/2007/03/curlys-law-do-one-thing.html) - my page object is now responsible for both abstracting over the page being tested and also performing assertions on that page's state.

At this point we see there are valid arguments both for and against the inclusion of assertions in our page objects. This is a good example of how software design is rarely about right and wrong, but almost always about trade-offs between different design choices. However today I realized that there's a feature of Capybara (and other similar UI testing frameworks) which in my opinion pushes the decision further towards complying with Tell Don't Ask and including the assertions in the page object.

## Spin Asserts

[Spin Assert](http://sauceio.com/index.php/2011/04/how-to-lose-races-and-win-at-selenium/) is a very valuable UI automation pattern. It is used to avoid the fact that UI automation tests are often involved in *races* with the UI they are testing. 

Let's continue using our account listing example. Imagine I have a test in which I transfer some money from my checking account to my savings account, and then test that the balances are listed correctly:

``` ruby
def verify_funds( account_name, account_balance )
  accounts = bank_account_page.listed_accounts
  accounts.find{ |x| x[:name] == account_name && x[:balance] == account_balance }.should_not be_null
end

#...
#...

verify_funds( "Checking Account", 200.25 )
verify_funds( "Savings Account", 20.15 )

transfer_funds( 100, from: "Checking Account", to: "Savings Account" )

verify_funds( "Checking Account", 100.25 )
verify_funds( "Savings Account", 120.15 )
```

Looks good. But what if the account balances take a while to update in the UI after the funds are transfered? My test might check that the checking account has a balance of 100.25 before the UI has had a chance to update. The test would see a balance of 200.25 instead of the 100.25, and thus the test would fail before the UI has had a chance to update to the correct state. The test has raced ahead of the UI, leading to an invalid test failure. 

Spin Asserts deal with this by repeatedly checking for the expected state, rather than checking once and then instantly failing. Here's what a crude spin assert implementation might look like in a verify_funds implementation:

``` ruby
def verify_funds( account_name, account_balance )
  loop do 
    accounts = bank_account_page.listed_accounts
    break if accounts.find{ |x| x[:name] == account_name && x[:balance] == account_balance }
    sleep 0.1
  end
end
```

Here we just repeatedly search for an account with the expected name and balance, pausing briefly each time we loop. In a real spin assert implementation we would eventually time out and raise an exception to fail the test after spinning for a while.

## Implicit Spin Asserts

Spin Asserts are such a valuable technique that they is build into a lot of web automation tools. In fact a lot of web automation tools will do a spin assert even without you being aware of it. In Selenium/WebDriver this is referred to as ['implicit waits'](http://docs.seleniumhq.org/docs/04_webdriver_advanced.jsp), and Capybara does the same thing. 

When we tell Capybara "check that this node contains the text 'foo'" it will implicitly perform that check using a spin assert. It will repeatedly check the state of the UI until either the node in question contains the text 'foo' or the spin assert times out. Here's what that assertion might look like:

``` ruby
page.find(".container .blah").should have_content('foo')
```

However, what if we instead *ask* Capybara for the current content of an HTML node and then do further checks ourselves?
``` ruby
page.find(".container .blah").text.should include('foo')
```

This looks very similar, but now we're *asking* for `.text` instead of *telling* Capybara that we want the text to contain 'foo'. Capybara is required to return the full content of the node the instant we ask for `.text`, which robs it of the chance to do helpful implicit spin asserts it would do if we were telling it to check for 'foo'. By violating Tell Don't Ask we've forced Capybara to expose state and prevented it from enhancing that state with value-add behavior.

## Page Objects should include Assertions

Hopefully you can see where I'm heading by now. If our example account listing page object includes its own assertions then we can *tell* the page object "verify that there is a checking account with a balance of 100.25". The page object is free to internally use spin asserts while verifying that assertion. If we don't allow page objects to include assertions then we are required to verify the page state ourselves, which would mean we'd need to do implement our own spin asserts, and often wouldn't be able to take advantage of the free implicit spin asserts provided by Capybara.

