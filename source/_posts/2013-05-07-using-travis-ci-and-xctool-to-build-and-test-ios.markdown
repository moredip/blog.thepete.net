---
layout: post
title: "Using Travis CI and xctool to build and test iOS apps"
date: 2013-05-07 22:40
comments: true
categories: 
---

[Travis CI](http://travis-ci.org) is a cloud-based Continuous Integration service which is free to use (but only on *public* github projects). They [recently](http://sauceio.com/index.php/2013/04/travis-ci-for-os-x-and-ios-powered-by-sauce/) [announced](http://about.travis-ci.org/blog/introducing-mac-ios-rubymotion-testing/) support for OS X agents, which means you can now use Travis to build and test iOS applications. In this post I'll show how I set up basic CI for an example iOS app using Travis, with the help of [xctool](https://github.com/facebook/xctool). xctool is the 'better xcodebuild' which Facebook recently open-sourced. It allows you to not only build your app on the command line but also run your app's unit tests from the command line with the same capabilities that XCode offers when you run the tests from the IDE proper.

To see a working example of the sort of thing we'll be setting up, take a look at the [github repo](https://github.com/moredip/run2bart-iOS) and the corresponding [Travis page](https://travis-ci.org/moredip/run2bart-iOS) for my Run2Bart example app.

## Getting started with Travis

### How Travis works

Travis is driven entirely through github integration. You configure Travis with information on how to build your app by adding a `.travis.yml` file to the root of your git repo. Then you log on to Travis using your github credentials and have it configure a github post-commit hook for the github repo. After doing that github will tell Travis every time you've pushed code to your repo. Travis will respond by dutifully downloading the commit which was pushed and will then do whatever build you've configured it to do in that `.travis.yml` file.

### an initial travis setup

I'm not going to cover linking your github repo to Travis; their own docs [explain this well](http://about.travis-ci.org/docs/user/getting-started/). Once you have linked your repo the next step would be to add a `.travis.yml` file to the root of the repo. Here's a basic setup similar to the one that I use to build my Run2Bart example app:
```yaml .travis.yml
---
  language: objective-c

  before_script: travis/before_script.sh
  script: travis/script.sh
```

First I'm telling Travis that this is an objective-c project. Next I tell Travis how I'd like it to do CI against this repo by giving it instructions on what scripts it should run in order to actually perform a build. I also give some extra instructions on what to do just prior to running a build. It's quite common to put all the build steps inline right in the `.travis.yml` file, but I prefer to actually create bash scripts in my repo inside a `travis` directory in my git repo and then just refer to those scripts from my `.travis.yml`. This keeps the .yml file nice and small, and also makes it easy for me to test the travis build scripts locally.

We gave Travis a before_script in the .yml file above. This is intended to be used by the Travis agent to download tools needed as part of the build. Here's what it looks like:
```bash travis/before_script.sh
#!/bin/sh
set -e

brew update
brew install xctool
```

Very simple. We just use homebrew to install xctool on the build agent. All travis build agents come with homebrew pre-installed, but sometimes the formula aren't up to date, so it's best to run a `brew update` before attempting a `brew install`.

That's all we need to do to prepare our agent for the build. Next let's look at the build script itself:
```bash travis/script.sh
#!/bin/sh
set -e

xctool -workspace MyWorkspace -scheme MyScheme build test
```

Again, this is really simple. We first do a basic sanity check by asking xctool to build our app, specifying a workspace and scheme. This just checks that we don't have any compilation errors. Assuming that succeeds xctool will then build and run the unit testing target for our app, launching the Simulator on the Travis agent if needed.

## It's that easy

And that's all there is to it for a basic build-and-test setup. At this point you're going to get very fast feedback from Travis as soon as anyone pushes code which either causes compilation errors or causes your unit tests to fail. From here you can easily build upon this basic CI set up. There are a lot of things you can do to expand this, some of which I've done in my example Run2Bart app. 

You can have xctool generate pretty output by specifying a different [reporter](https://github.com/facebook/xctool#reporters), and then archive that report as a build artifact using something like [travis-artifacts](http://about.travis-ci.org/blog/2012-12-18-travis-artifacts/).

You can add extra stages to your build such as [Frank acceptance tests](http://www.testingwithfrank.com). 

You could even have Travis distribute a build of your app to alpha users using something like [TestFlight](https://testflightapp.com/) or [HockeyApp](http://hockeyapp.net). That's definitely an advanced topic though - it would be very fiddly to achieve due to having to do code-signing of a device build on the Travis agent.

## You don't need to use Travis for this

And of course you can do all of the above on your own Jenkins (or TeamCity, or Go, or Bamboo) CI server rather than on Travis. In fact unless you're building an open-source app or you're a beta customer of [Travis Pro](http://travis-ci.com) then you'll likely want to use a different CI technology. Regardless, the basic approach remains the same.
