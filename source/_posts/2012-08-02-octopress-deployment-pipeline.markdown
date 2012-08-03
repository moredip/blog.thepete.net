---
layout: post
title: "Octopress deployment pipeline"
date: 2012-08-02 08:15
comments: true
categories: 
---

I spent a fun evening recently setting up a deployment pipeline for this blog. I'd like to share some details on what I set up and why. 

The motivation was that I wanted some way to publish draft blog entries for other people to review, but I didn't want these drafts to show up on my public site.  I played with Octopress's `published: false` option, but it really didn't give me what I needed. Then I saw someone commenting that the ideal would be to have a preview version of the entire site available at a seperate url. A **pre-production environment**, essentially. Hmm, I thought. Every web project I work on has one of these. It's used to showcase the version of the system which is going to be released to production. That's what I need - why don't I just set that up for my blog?

##Delivery pipelines

When using a pre-prod environment to showcase it's important that what goes to prod is exactly what was showcased on pre-prod. A delivery pipeline helps ensure that. You could think of it as Continuous Integration on steroids. Every time code is committed it is built, unit tested, and then packaged into a **build artifact**. That build artifact (or just 'build') then moves through a **pipeline** which potentially ends in production. The build is often initially deployed to a dev/integration environment. Assuming it passes muster it may then be **promoted** to a QA environment, and perhaps then promoted again to pre-prod. Promoting a build means deploying it to the next environment in the pipeline. Finally that build may go through some sort of manual sign-off process in pre-prod and then finally be promoted to production. 

The key principle here is that of a well-defined build artifact which is moving through these different environments. Jez Humble talks about this pipeline as a sort of obstacle course, where you gain confidence in the quality of the build artifact as it moves through your pipeline, passing more and more quality hurdles at each stage. This delivery pipeline is a core part of a Continuous Delivery system.

## CD for a blog?! Srsly?
Now clearly what I've just described is a little bit over the top for this lowly blog. I realize that. But setting up a sort of lightweight pipeline was a fun and surprisingly useful project. It helped clarify some CD concepts for me (the best learning is by doing) and I do actually use the pipeline. In fact I made use of it while writing this very post!

## Pre-production environment

This blog is powered by [Octopress](http://octopress.org/), and it's published as a set of static files which are hosted by Amazon's S3 service. Happily this means that creating a 'pre-prod environment' was as simple as creating a new S3 bucket and wiring it up to a subdomain via a CNAME entry.

## The approach

I didn't want to go *too* overboard, so rather than tracking a physical build artifact I opted to instead pass around git commits as my 'artifact'. Now this is actually a **bad** idea to do in a real CD system. You have to repeatedly re-build and re-package your code at each stage in the pipeline, and you risk differences in how that build process occurs during at those different stages. That said, for my purposes just tracking commits in version control will work well enough.

My goal was to be able to deploy from any git commit to my pre-prod environment using a simple script. I'd then be able to 'showcase' my changes by pointing my browser at the pre-prod site. Assuming everything passes muster I could then run another script to promote whatever is in pre-prod to prod. Note that I allowed **no way** for me to deploy an arbitrary (and thus un-verified) commit to production. Anything I want to push to prod has to move through my pre-prod environment first. 

## Tracking what's where

I track what is in pre-prod and prod using git marker branches. After successfully deploying a commit to an environment the corresponding marker branch is updated to point to that commit. That way my scripts can always know which commit is deployed to each environment just by checking with git.

For more details on how I do the git branch manipulation you can take a look at the [push_preprod](https://github.com/moredip/blog.thepete.net/blob/fea96051bf4dbaaf46b1d5ef203353edbf7ef36b/scripts/push_preprod) and [promote_preprod_to_prod](https://github.com/moredip/blog.thepete.net/blob/fea96051bf4dbaaf46b1d5ef203353edbf7ef36b/scripts/promote_preprod_to_prod) scripts themselves.

## Deploying a commit
The steps I use to deploy an arbitrary commit of an octopress blog to S3 are:

- extract a snapshot of that commit to a temporary directory using `git archive`
- run the rake task which compiles the Octopress source into the static site files
- push the static files up to an S3 bucket using `s3cmd`

I encapsulated this in a Deployer class which is bundled with my blog's source [here](https://github.com/moredip/blog.thepete.net/blob/fea96051bf4dbaaf46b1d5ef203353edbf7ef36b/scripts/deployer.rb).

## Done

That's pretty much it. It's a simple lightweight system that give me just enough release management with very little overhead.

## TODO


Ideally I'd like to have my pre-prod environment use a slightly different Octopress configuration than my prod environment. For example I'd like to turn off disqus commenting in pre-prod since I don't want people to make comments on preview posts which may well be lost once I promote to prod. I'd also like to add a little banner so people know they'e viewing a preview copy of my blog.  

I'm not quite sure at the moment on the best way to approach this, so I'm leaving it be for now. 
