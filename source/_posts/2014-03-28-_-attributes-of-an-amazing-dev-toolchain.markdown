---
layout: post
title: "_ attributes of an amazing dev toolchain"
date: 2014-03-28 20:30
comments: true
categories: 
---

aka The Rules Of The Go Script

Every ThoughtWorks project I've been on has some sort of script in the root of the project repo, often named `./go` or `./go.sh`. This script often starts life as the script that the CI server launches to test the project. It soon it aquires extra capablities. It becomes the way that developers perform a pre-commit check before pushing their changes. It becomes the script to run when you first get started on the project to download all the various project dependencies. 

Often the ./go script becomes the main interface into the dev tooling for the project, where it becomes a very powerful productivity aid. Whenever a team is tempted to put some process or workaround into a README or a wiki page they can instead automate it and put it into the ./go script. Things I've seen added to a ./go script are:

- download software dependencies needed for dev tooling, or at least detect that a required dependency is missing and provide instructions on how to install it.
- set up or update an IntelliJ configuration for a JVM project.
- do the rvm/bundler dance for a ruby project.
- run a standard set of pre-commit tests

I've spent some time thinking about what makes a good ./go script good. Here's my protips for an awesome ./go script:

## don't make me think
Make your dev toolchain as idiot-proof as possible. Give me sensible defaults. Give me clear error messages when something goes wrong, including hints on how to fix it. If there are two operations that need to be performed one after the other give me a higher-level operation which does them both (for example, wrap `vagrant destroy -f && vagrant up` into `./go vagrant-nuke`).

## isolate, isolate, isolate!
Try as hard as possible to isolate your toolchain so that it's maintained within the project. Strive to avoid system dependencies - software that need to be installed on the workstation itself. On a Scala project, run your own isolated version of sbt rather than the system sbt. On a ruby project use bundler's --path option to vendorize your gems and avoid the need for rvm gemsets. For python projects use virtualenv. Check in binary tools like chromedriver or phantomjs. This is absolutely the best way to ensure consistency across machines, and avoid "it (works|borked) on my machine" issues. Because toolchain dependencies are managed within the project repo this also makes it trivial to upgrade your tooling. No need to coordinate everyone switching versions of a tool.

## do on your workstation as you do in CI
Push as much of your CI/CD scripting as possible underneath your ./go script. This keeps everything centralized and under source control. It also makes it easy to debug CI/CD problems on a local dev workstation and makes it easier to maintain and extend those scripts.

You get the most benefit here if you've agressively followed the advice to isolate your dev dependencies. You need your local tooling to be the same as that which is running on your CI/CD agents.

This tooling consistency is such a valuable aspect of a good dev toolchain that it's worth *pushing your entire toolchain into a virtual machine*. Couple Vagrant or Docker with something like Chef or Ansible and you have a strong guarentee of a uniform toolchain across all dev/QA workstations and CI/CD agents. It gives you a very simple way to make sure your toolchain hasn't drifted from the project norms - just nuke your VM and rebuild from scratch. It might take a while but it'll probably be quicker than debugging the cause of the problem and correcting it.

Running your build in a VM on your workstation may sound extreme, but the amount of time you'll save not debugging irritating tooling issues is a fine tradeoff for the inefficiency of running on a virtual machine or LXC container.

## uniform interface
Everything goes through ./go. Everything. 

Don't make me remember whether it's `rake test`, `rspec`, or `./scripts/test`. Just put everything inside of ./go, even if ./go just immediately shells out to another tool. This is an extension to the "Don't make me think" rule. It also makes it a lot easier to isolate your tooling. Importantly it also give a level of indirection which means you can switch and modify your underlying tooling without having to re-educate every member of the team. Finally, this gives you a place to always do custom pre-flight checks for required dependencies. 

## One step to a running environment. One.
A new member on the team should need to do two things to get a running dev instance. The setup steps in your project README should be:

    git checkout yourProject
    cd yourProject
    ./go
    
In the worst case where you absoulely **cannot** automate some aspect of project setup then the ./go script should detect that the manual setup is required and provide clear and detailed instructions on how to perform it.
