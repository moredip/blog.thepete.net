---
layout: post
title: "the 5 rules of an awesome dev toolchain"
date: 2014-03-28 20:30
comments: true
categories: 
---

{% pullquote %}
Every [ThoughtWorks](http://www.thoughtworks.com) project I've ever been on has a script in the root of the project repo, often named `./go` or `./go.sh` (or `./go.bat` if you're very unlucky). This script often starts life as the script that the CI server runs to test the project. It soon it acquires extra capabilities. It becomes the way that developers perform a pre-commit check before pushing their changes. It becomes the script to run when you first get started on the project to download all the various project dependencies. 

{" Eventually the `./go` script can become the main interface into the dev tooling for the project. "}
At that point it becomes a very powerful productivity aid. Whenever a team is tempted to put some process or workaround into a README or a wiki page they can instead automate it and put it into the `./go` script. Tribal knowledge on how to perform certain tasks is automated, readily available, and under source control. 
{% endpullquote %}

Things I've seen added to a `./go` script are:

- download software dependencies needed for dev tooling, or at least detect that a required dependency is missing and provide instructions on how to install it.
- set up or update an IntelliJ configuration for a JVM project.
- do the rvm/bundler dance for a ruby project.
- run a standard set of pre-commit tests

# What makes a ./go script great?

I've spent some time thinking about what makes a good `./go` script good. Here are my rules for an awesome `./go` script, and thus a low-friction dev toolchain.

## 1. don't make me think
Make your dev toolchain as idiot-proof as possible. Give me sensible defaults. Give me clear error messages when something goes wrong, including hints on how to fix it. If there are two operations that need to be performed one after the other give me a higher-level operation which does them both (for example, wrap `vagrant destroy -f && vagrant up` into `./go vagrant-nuke`). Give me a list of all operations available to me. 

The git cli is a good example of what you should be striving for.

## 2. isolate, isolate, isolate!
Try as hard as humanly possible to isolate your toolchain so that it's maintained within the project. Strive to avoid system dependencies - software that need to be installed on the workstation itself. 

On a Scala project, run your own isolated version of sbt rather than the system sbt. On a ruby project use bundler's --path option to vendorize your gems and avoid the need for rvm gemsets. For python projects use virtualenv. Check in binary tools like chromedriver or phantomjs. 

This is absolutely the best way to ensure consistency across machines, and avoid "it's only (working|borked) on my machine" issues. Because toolchain dependencies are managed within the project repo this also makes it trivial to upgrade your tooling. No need to coordinate everyone switching versions of a tool.

## 3. do on your workstation as you do in CI
Push as much of your CI/CD scripting as possible underneath your `./go` script. This keeps everything centralized and under source control. It also makes it easy to debug CI/CD problems on a local dev workstation and makes it easier to maintain and extend those scripts.

{% pullquote %}
You get the most benefit here if you've agressively followed the advice to isolate your dev dependencies. You need your local tooling to be the same as that which is running on your CI/CD agents.

{" This tooling consistency is such a valuable aspect of a good dev toolchain that it's worth pushing your entire toolchain into a virtual machine "}. Couple Vagrant or Docker with something like Chef or Ansible and you have a strong guarantee of a uniform toolchain across all dev/QA workstations, and also all CI/CD agents. It gives you a very simple way to make sure your toolchain hasn't drifted from the project norms - just nuke your VM and rebuild from scratch. That might take a while but it'll probably be quicker than debugging the cause of the problem and correcting it.

Running your build in a VM on your workstation may sound extreme, but the amount of time you'll save not debugging irritating tooling issues is a fine tradeoff for the inefficiency of building within a virtual machine or LXC container.
{% endpullquote %}

## 4. uniform interface
Everything is done via `./go`. Everything. 

Don't make me remember whether it's `rake test`, `rspec`, or `./scripts/test`. Just put everything inside of `./go`, even if `./go` just immediately shells out to another tool. This is an extension to the "Don't make me think" rule. It also makes it a lot easier to isolate your tooling. Importantly it adds a level of indirection which is under your project's direct control. That means that you can modify or even switch your underlying tooling without having to re-educate every member of the team. You can add custom pre-flight checks for required dependencies before performing an operation. You can wrap every operation with benchmarking or instrumentation.


## 5. one step to a running local dev environment. One.
A new member on the team should be able to run one command to get to a running dev instance on their workstation. The setup steps in your project README should be:

    git checkout yourProject
    cd yourProject
    ./go
    
In the worst case where you absolutely **cannot** automate some aspect of project setup then the `./go` script should detect that the manual setup is required and provide clear and detailed instructions on how to perform it.
