---
layout: post
title: "Running Frank as part of iOS CI"
date: 2012-07-22 09:44
comments: true
published: false
categories: 
---

[Frank](http://testingwithfrank.com) is a tool that allows you to run automated acceptance tests against your native iOS application. A major reason for creating *automated* acceptance tests is so that you can run them as part of your [Continuous Integration](http://martinfowler.com/articles/continuousIntegration.html) (CI) process. Doing this enables a rapid feedback loop where a developer checking in code is informed very quickly if that change caused a defect in your app. 

In this post I'll show how to configure a basic CI setup using [Jenkins](http://jenkinsci.org) which will build your app and run Frank tests against it every time you check in code. CI for iOS projects don't seem to be a common practice. This is a shame because the CI can bring just as many benefits for iOS applications as for other technologies. I suspect part of the reason CI is less popular is that Apple doesn't make it particularly easy to automate things like building your application and running unit tests. Things are moving in the right direction though, with both Apple and open-source developers making it easier to integrate a dev toolchain into a CI setup.

##Our plan of attack

I needed a simple app to demonstrate a CI setup. I'll be using the same [open source '2012 Olympics' app](https://github.com/Frahaan/2012-Olympics-iOS--iPad-and-iPhone--source-code) that I've used as a pedagogical example in previous posts. To keep the CI setup distinct from the application I created a master repo which contains just the CI setup for the Olympics app, along with including the app source code via a git submodule. I've also had to [fork the Olympics app](https://github.com/moredip/2012-Olympics-iOS--iPad-and-iPhone--source-code) because I needed to set it up for Frank testing, as well as make small changes to the app's project settings which allow CI to be easily set up. When setting up your own app for CI you'd likely already have these changes in place.

So, let's walk through what's involved in getting a basic CI set up for our iOS application. Our overall strategy will be:

- set up a build script which can build our app from the command line
- set up CI so that we can run that build whenever we check in code
- add Frank testing to our build script
- set up CI to enable Frank tests 

Let's get started by creating a build script.

## Scripting the build

Before we start setting up CI itself we need to automate the build process. This will involve stepping outside the safe environs of XCode and entering the powerful and intimidating world of the command line. Have no fear, it's not as scary as it sounds.

We're going to use a ruby tool called **Rake** to create our build script. Rake is similar to tools like Make and Ant - it makes it easy for us to succinctly express the different tasks we want our build script to perform, and allows us to chain those tasks together. We'll also be using a ruby gem called **xcodebuild-rb** from Luke Redpath (one of the most industrious open-source developers I know of). This gem makes it trivially easy to drive xcodebuild (the command line interface for XCode) from inside a Rake file.

Before we get started on the build script itself we need to create a **Gemfile** which declares our ruby dependencies. This file can be used by another tool called [Bundler](http://gembundler.com/) to ensure that developer machines and CI systems have everything they need. 

``` ruby Gemfile
source "https://rubygems.org"

gem "rake"
gem "xcodebuild-rb", "~> 0.3.0"
```

Those are all the dependencies we have for now. If you run `bundle install` bundler should now set up those gems. Next we'll create our initial Rakefile - the file which defines our app's build tasks:

``` ruby Rakefile
require 'rubygems'
require 'xcodebuild'

namespace :xcode do
  XcodeBuild::Tasks::BuildTask.new :debug_simulator do |t|
    t.invoke_from_within = './app'
    t.configuration = "Debug"
    t.sdk = "iphonesimulator"
    t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
  end
end

task :default => ["xcode:debug_simulator:cleanbuild"]
```

This Rakefile does a few things. First it loads the libraries we need. Then it defines an `xcode` namespace (a namespace is just a way of logically grouping a set of tasks). Inside that xcode namespace it uses an xcodebuild-rb helper to create a set of Rake tasks for automating a debug iphone simulator build of the project contained inside the `app` directory. Finally a `default` task is defined. This task doesn't do anything itself, but declares a dependency on the `xcode:debug_simulator:cleanbuild` task. That means that whenever the default task is run it will run that dependent task, causing a clean build of the debug simulator version of the app to be generated.

If you were to try that out now by running `rake` from the command line you should see xcodebuild creating a clean build of the app. You could also run `rake -T` to get a list of all interesting rake tasks. If you did so you'd notice that xcodebuild-rb has created a few different Rake tasks, not just for building the app but also tasks for cleaning build output and archiving the build. For the purposes of this blog post we'll just be using the cleanbuild task.

At this point we have an automated way to generate a clean build of the application. Now we want to make sure that our build script leaves that built application in a common 'artifact' directory so that our CI system can archive it. There's no point building the app if you don't save it for use later on. I'll follow a convention of putting everything which I want my CI system to save inside a 'ci_artifact' directory. I add the following to my Rakefile:

``` ruby Rakefile additions

namespace :ci do
  def move_into_artifacts( src )
    FileUtils.mkdir_p( 'ci_artifacts' )
    FileUtils.mv( src, "ci_artifacts/" )
  end

  task :clear_artifacts do
    FileUtils.rm_rf( 'ci_artifacts' )
  end

  task :build => ["xcode:debug_simulator:cleanbuild"] do
    move_into_artifacts( Dir.glob("app/build/Debug-iphonesimulator/*.app") )
  end
end

task :ci => ["ci:clear_artifacts","ci:build"]
```

Here I've created a `ci` namespace. Inside that I've added a `clear_artifacts` task and a `build` task. In addition I've also created a `ci` *task* in the root namespace. That task depends on the `clear_artifacts` and `build` tasks, meaning that whenever I run `rake ci` Rake will run `ci:clear_artifacts` and then `ci:build`. 

`ci:clear_artifacts` simply deletes any existing ci_artifact directory. `ci:build` depends on the existing xcode build task to actually create a build of the app, and then it copies the built app into the ci_artifacts directory, creating the directory if necessary. I didn't want to hard-code the app name into my Rakefile so I cheated a bit and used a glob to select any directory with a .app extension.

If I now run `rake ci` I should end up with a freshly-built copy of the application in a ci_artifacts directory.

## Setting up Jenkins

Now we have an automated build script we need to get our CI system set up. I'm going to use Jenkins in this post because it's probably the most commonly used CI server. Pretty much the exact same approach would be used for other tools such as [TeamCity](http://www.jetbrains.com/teamcity/) or [Go](http://www.thoughtworks-studios.com/go-agile-release-management).

I installed a sandbox copy of Jenkins on my laptop with a simple `brew install jenkins`, courtesy of [homebrew](http://mxcl.github.com/homebrew/). If you're a developer using a mac then I highly recommend homebrew. I followed the instructions provided with the homebrew recipe to launch the Jenkins server and then went to [http://localhost:8080/](http://localhost:8080/).

In the Jenkins UI I created a new 'free-style' job and configured it to point to my main git repo. Next I needed to tell Jenkins how to build our app. A good practice is to keep as much of your configuration as possible inside version control. As part of that I usually create a simple CI script inside the root directory of my app, and then have the CI system call that script. In this example that script is called `go.sh` and lives in the root of my main repo, under source control like everything else. The only thing I need to configure in Jenkins itself is a single line 'Execute Shell' build step which calls go.sh. Another nice benefit of this approach is that you can test tweaks you're making to your CI setup by calling `./go.sh` directly on your dev box, rather than having to kick off a new CI build. 

Here's what my initial go.sh looks like:

```sh go.sh
#!/bin/sh
bundle install --deployment
bundle exec rake ci
```

Pretty simple. It uses bundler to make sure all my ruby dependencies are installed and then runs the `ci` rake task.

The last thing I need to do is tell Jenkins to archive all the artifacts it finds inside the ci_artifacts directory by checking the 'Archive the artifacts' checkbox and then specifying `ci_artifacts/**/*` as the files to archive.

That's it, we're done with our Jenkins set up. If all has been done correctly when you kick off that Jenkins job it should build the app and save the resulting `2012 Olympics.app` inside Jenkin's *Build Artifacts* for that build.

## Setting up Frank tests

We now have a very basic CI setup for our iOS app. Next I'll describe how to integrate Frank into this CI system. I'm going to assume that your app itself has already been set up for Frank. If not, check out [a previous post of mine](/blog/2012/06/24/writing-your-first-frank-test/) for all the details. It's a painless process.

First we need to declare our dependency on the frank-cucumber gem which we'll use to actually run our Frank tests. We do that by updating our Gemfile:
``` ruby Gemfile
source "https://rubygems.org"

gem "rake"
gem "xcodebuild-rb", "~> 0.3.0"

gem "frank-cucumber", "~> 0.9.4"
```

The next step is to create a Rake task which will generate a Frankified build of your app. I'll add that to the ci namespace in my Rakefile as follows:

```ruby Rakefile additions
namespace :ci do

  # ... existing ci tasks don't change 

  task :frank_build do
    sh '(cd app && frank build)'
    move_into_artifacts( "app/Frank/frankified_build/Frankified.app" )
  end
end
```

This task shells out to the `frank build` command, and then copies the app bundle that it builds into our ci_artifacts directory.

Now that we have a Frankified build we want to run frank tests against it. Our Frank tests have been written using [Cucumber](http://cukes.info), which happily comes with great Rake integration. We just need to use that to create a rake task which runs our cucumber features against our Frankified build:

```ruby Rakefile additions
# ... near the top of our Rakefile
require 'cucumber/rake/task'

HERE = File.expand_path( '..',__FILE__ )
ENV['APP_BUNDLE_PATH'] = File.join( HERE, 'ci_artifacts/Frankified.app' )

# ... existing Rakefile code still here

namespace :ci do

  # ... existing ci namespace code here

  Cucumber::Rake::Task.new(:frank_test, 'Run Frank acceptance tests, generating HTML report as a CI artifact') do |t|
    t.cucumber_opts = "app/Frank/features --format pretty --format html --out ci_artifacts/frank_results.html"
  end
end

# ... redefine our ci task here
task :ci => ["ci:clear_artifacts","ci:build","ci:frank_build","ci:frank_test"]

```
There are a few things going on here. We require in Cucumber's rake helper code. Next we set the `APP_BUNDLE_PATH` environment variable to point to the location of the Frankified build inside our ci_artifacts directory. Frank uses that environment variable to know which app to launch in the simulator at the start of your Frank tests. We then use a Cucumber helper to generate a rake task called `ci:frank_test`. We configure that task to run the Cucumber tests inside `app/Frank/features`. We also ask Cucumber to generate a nice HTML test report for each test run, saving it into the ci_artifacts directory so that it can be accessed by the CI system. Finally we extend our main `ci` task to depend on those new tasks. 

This means that when you run the `rake ci` command rake will now generate a Frankified build and then run tests against it, in addition to generating the debug simulator build as it did previously.  So if you ran `./go.sh` at this point to simulate a full CI run you would see a debug build of your app generated, followed by a frankified build, and finally a Frank test run would run. You'd also see the Frankified app plus a nice HTML test run report in the ci_artifacts directory. We're almost done!

## Launching apps in the Simulator from a CI build

However, there's one final hurdle. If you now kicked off a Jenkins run you'd likely see the Frank tests fail to launch your app, even though Jenkins is using the exact same go.sh script we just ran successfully by hand. Not good.

The reason for this is a bit subtle. Apple doesn't provide an offical way to automate launching an app in the simulator, so Frank uses an open source tool called SimLauncher which reverse-engineers the way XCode launches apps. However this approach appears to only work if the process launching the app is attached to the OS X windowing system. In the case of Jenkins the process running a CI build is not always attached to the windowing system. To work around this fact SimLauncher has a client-server mode. You launch a SimLauncher server on your CI build box by hand so that it is attached to the windowing system. You then tell Frank to use SimLauncher in client-server mode when running CI. Frank will now ask that SimLauncher server to launch the app, rather than trying to launch it directly. Because the SimLauncher server process is attached to the windowing system it is able to launch the simulator even though the CI process itself isn't attached.

That was a rather complex sidebar, but fortunately the actual setup is straight forward. First open a new terminal window and run the `simlauncher` command. That will start up a simlauncher server in your terminal. 

Next, update your go.sh script to look like this:

```sh go.sh
#!/bin/sh
export USE_SIM_LAUNCHER_SERVER=YES
bundle install --deployment
bundle exec rake ci
```
The only change we made was exporting that `USE_SIMLAUNCHER_SERVER` environment variable. This tells Frank to launch the Frankified app using SimLauncher in client-server mode rather than trying to launch it directly. 

Next, test out your change by running `go.sh`. You should see the same CI run as before (including a successful Frank test run), but you should also notice that the terminal window running the SimLauncher contains some output showing that the server was responding to launch requests from Frank during the test run. At this point you should also be able to perform a complete CI run via Jenkins (as long as you have the SimLauncher server running of course).

Starting the `simlauncher` server by hand in a terminal is a bit of a hassle, but in practice it turns out to not be a big deal. You have to do it once every time you reboot your build box, which with OS X is a fairly infrequent event.


## Next steps

We now have a working CI setup. However this basic configuration should only be the start of the journey. Because of the value they provide CI systems tend to grow over time. I'll briefly describe some directions in which you might grow this system. 

The first thing I'd want to add is an **automated unit testing** run (before the Frank run). After that one could start adding **internal quality metrics** (code duplication, unit- and acceptance test coverage, cyclometric complexity reports, etc.). You might want builds which have passed your acceptance test suite to be **automatically deployed** to QA devices via [HockeyApp](http://hockeyapp.net) or [TestFlight](http://testflightapp.com). At that point you're starting to move towards a [Continuous Delivery](http://martinfowler.com/delivery.html) system where features and bug fixes move through one or more **delivery pipelines** from checkin through automated testing to QA deployment and eventual production deployment. As you add more functionality your builds will start to take longer to run, which means slower feedback and more time waiting for a build to pass initial quality checks. At that point you'll probably want to look at **parallelizing your build**, most likely by standing up multiple build agents.  
