---
layout: post
title: "Running Frank as part of iOS CI"
date: 2012-07-22 09:44
comments: true
categories: 
---

[Frank](http://testingwithfrank.com) is a tool that allows you to run automated acceptance tests against your native iOS application. A major reason for creating *automated* acceptance tests is so that you can run them as part of your [Continuous Integration](http://martinfowler.com/articles/continuousIntegration.html) process. Doing this enables a rapid feedback loop where a developer checking in code is informed very quickly if that change caused a defect in your app. 

In this post I'll show how to configure a basic CI setup using [Jenkins](http://jenkinsci.org) which will build your app and run Frank tests against it every time you check in code. Continuous Integration (CI) setups for iOS projects don't seem to be particularly common. This is a shame because the value of CI applies just as much for iOS as for other technologies. I suspect part of the reason CI is less popular is that Apple doesn't make it particularly easy to automate things like building your application and running unit tests. Things are moving in the right direction though, with both Apple and open-source developers making it easier to integrate a dev toolchain into a CI setup.

##Our plan of attack

I needed a simple app to demonstrate a CI setup. I'll be using the same [open source '2012 Olympics' app](https://github.com/Frahaan/2012-Olympics-iOS--iPad-and-iPhone--source-code) that I've used as a pedagogical example in previous posts. In this case I've had to fork the app because I needed to make small changes to the app's project to allow CI to be easily set up.  My forked version of the app is available on github [here](https://github.com/moredip/2012-Olympics-iOS--iPad-and-iPhone--source-code). I also setup a master repo that contains the CI setup for the project, along with the app itself as a submodule.

Our overall strategy will be:

- setup a build script that will build our app
- setup CI to run that build whenever we check in code
- add Frank testing to our build script
- setup CI to enable Frank tests 

Let's get started by creating a build script.

# Scripting the build

Before we start setting up CI itself we need to automate the build process. This will involve stepping outside the safe environs of XCode and entering the powerful and intimidating world of the command line. Have no fear, it's not as scary as it first appears.

We're going to use a ruby tool called **Rake** to create a build script. Rake makes it easy for us to succinctly express the different tasks we want our build script to perform, and allows us to chain those tasks together. We'll also be using a ruby gem called **xcodebuild-rb** from Luke Redpath (one of the most industrious open-source developers I know of). This gem makes it trivially easy to drive xcodebuild (the command line interface for XCode) from inside a Rake file.

First off we'll create a Gemfile. This is used by a ruby tool called [Bundler](http://gembundler.com/) to manage ruby dependencies.

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

This Rakefile does a few things. First it loads the libraries we need. Then it defines an `xcode` namespace (a namespace is just a way of logically grouping a set of tasks). Inside that xcode namespace it uses an xcodebuild-rb helper to create a set of Rake tasks for automating a debug iphone simulator build of the project contained inside the `app` directory. Finally a `default` task is defined. This task doesn't do anything itself, but declares a dependency on the `xcode:debug_simulator:cleanbuild` task. That means that whenever the default task is run it will run the dependent task, causing a debug simulator version of the app to be cleaned and then built. 

If you were to try that out now by running `rake` from the command line you should see xcodebuild creating a clean build of the app. You could also run `rake -T` to get a list of all interesting rake tasks.

At this point we have an automated way to generate a clean build of the application. Now we want to move the built application to a common 'artifact' directory so that our CI system can save it. There's no point building the app if you don't save it for use later on. I'll follow a convention of putting everything that I want my CI system to save inside a 'ci_artifact' directory. Here's what I'll add to my Rakefile:

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

I've created a `ci` namespace. Inside that I've added a `clear_artifacts` task and a `build` task. I've also created a `ci` *task* in the root namespace. That task depends on the `clear_artifacts` and `build` tasks, meaning that whenever I run `rake ci` Rake will run `ci:clear_artifacts` and then `ci:build`. 

`ci:clear_artifacts` simply deletes any existing ci_artifact directory. `ci:build` depends on the existing xcode build task to actually create a build of the app, and then it copies the built app into the ci_artifacts directory. I didn't want to hard-code the app name into my Rakefile so I cheated a bit and used a glob to select any directory with a .app extension.

If I now run `rake ci` I should end up with a freshly-built copy of the application in a ci_artifacts directory.

## Setting up Jenkins

Now we have an automated build script we need to get our CI system set up. I'm going to use Jenkins in this post because it's probably the most commonly used CI server, but the same approach applies just as well to tools like [TeamCity](http://www.jetbrains.com/teamcity/) or [Go](http://www.thoughtworks-studios.com/go-agile-release-management).

I installed a sandbox copy of Jenkins on my laptop with a simple `brew install jenkins`, courtesy of [homebrew](http://mxcl.github.com/homebrew/). If you're a developer using a mac then I highly recommend homebrew. I followed the instructions provided with the homebrew recipe to launch the Jenkins server and then went to [http://localhost:8080/](http://localhost:8080/).

I created a new 'free-style' job and configured it to point to my main git repo. Next we need to tell Jenkins how to build our app. A good practice is to keep as much of your configuration as possible inside version control. As part of that I usually create a simple CI script inside the root directory of my app, and then have the CI system call that script. In this example that script is called `go.sh` and lives in the root directory of my app. That script lives in source control like everything else. The only thing I need to configure in Jenkins itself is a single line 'Execute Shell' build step which calls go.sh. Another nice benefit of this approach is that you can test tweaks you're making to your CI setup by calling `./go.sh` directly on your dev box, rather than having to kick off a new CI build. Here's what my initial go.sh looks like:

```sh go.sh
#!/bin/sh
bundle install --deployment
bundle exec rake ci
```

This simply uses bundler to make sure all my ruby dependencies are installed and then runs the `ci` rake task.

The last thing I need to do is tell Jenkins to archive all the artifacts it finds inside the ci_artifacts directory by checking the 'Archive the artifacts' checkbox and then specifying `ci_artifacts/**/*` as the files to archive.

That's it, we're done with our Jenkins setup. If all has been done correctly when you now kick off your job from the Jenkins UI it should build the app and save the resulting `2012 Olympics.app` to Jenkin's Build Artifacts for that build.

## Setting up Frank tests

We now have a very basic CI setup for our iOS app. Now I'll describe how to integrate Frank into this CI system. 

I'm going to assume that your app itself has already been set up for Frank. If not, check out [my previous post](/blog/2012/06/24/writing-your-first-frank-test/) for all the details. It's a painless process.

I AM HERE

## Next steps

- Setting up build agents using mac minis
- Unit testing
- Deploying to hockey-app
- Pipelining
