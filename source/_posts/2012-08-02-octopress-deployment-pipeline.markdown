---
layout: post
title: "Octopress deployment pipeline"
date: 2012-08-02 08:15
comments: true
categories: 
---

I spent a fun evening recently setting up a deployment pipeline for this blog. The motivation was that I wanted some way to publish 'draft' blog entries for other people to review, but I didn't want these drafts to show up on my public site. 

I played with Octopress's `published: false` option, but it really didn't give me what I needed. Then I saw someone commenting that the ideal would be to have a preview version of the site available somewhere. A pre-production environment, essentially. Hmm, I thought. Every web project I work on has one of these. It's used to showcase the version of the system which is going to be released to production. Why don't I just set that up.

##Delivery pipelines

It's important that what's eventually deployed to prod is the same thing that was showcased on pre-prod. A delivery pipeline helps ensure that. Every time code is committed it is compiled, unit tested, and then packaged into a build artifact. That build artifact (or just 'build') then moves through a pipeline which potentially ends in production. The build is often initially deployed to a dev/integration environment. Assuming it passes muster it may then be 'promoted' again to a QA environment, and perhaps then promoted again to pre-prod. Finally if that build may go through some sort of manual sign-off process in pre-prod and then be promoted to production. The key principle here is that it's the same build artifact which is moving through these different environments. Jez Humble talks about this pipeline as a sort of obstacle course, where you gain confidence in the quality of the build artifact as it moves through your pipeline, passing more and more quality hurdles at each stage. This delivery pipeline is a core part of a Continous Delivery system.

## CD for a blog?! Srsly?
Now clearly what I've just described is a little bit over the top for this lowly blog. I realize that. But it's still a fun and useful project to set up some sort of lightweight pipeline. So far I actually have found it useful.

## Pre-production environment

This blog is powered by Octopress, and it's published as a set of static files which I host on Amazon's S3 service. Creating a 'pre-prod environment' was as simple as creating a new S3 bucket and wiring it up to a subdomain.

## The approach

I didn't want to go *too* overboard, so rather than tracking a physical build artifact I opted to instead pass around git commits as my 'artifact'. Now this is actually a **bad** idea to do in a real CD system. You have to build and package your code at each stage in the pipeline, and you risk differences in how that build process occurs during at those different stages. That said, for my purposes just tracking commits in version control will work.

My goal was to be able to deploy from any git commit to my pre-prod environment using a simple script. I'd then be able to 'showcase' my changes - in this case by checking them myself by pointing my browser at my pre-prod subdomain. Assuming everything passes muster I can then run another script which 'promotes' whatever is in pre-prod to prod. Note that there is **no way** for me to deploy an arbitrary (and thus un-verified) commit to production. The commit has to move through my pre-prod environment first. 

## Tracking what's where

I track what is in pre-prod and prod using git marker branches. After successfully deploying a commit to an environment the corresponding marker branch is updated to point to that commit. That way I can always know which commit is deployed to each environment just by checking with git.

For more details on how I do the git branch manipulation you can take a look at the [push_preprod](https://github.com/moredip/blog.thepete.net/blob/fea96051bf4dbaaf46b1d5ef203353edbf7ef36b/scripts/push_preprod) and [promote_preprod_to_prod](https://github.com/moredip/blog.thepete.net/blob/fea96051bf4dbaaf46b1d5ef203353edbf7ef36b/scripts/promote_preprod_to_prod) scripts themselves.

## Deploying a commit
The steps I use to deploy an arbitrary commit of an octopress blog to S3 are:

- extract a snapshot of that commit to a temporary directory using `git archive`
- run the rake task which compiles the Octopress source into the static site files
- push the static files up to an S3 bucket using `s3cmd`

I encapsulated this in a Deployer class which is bundled with my blog's source [here](https://github.com/moredip/blog.thepete.net/blob/fea96051bf4dbaaf46b1d5ef203353edbf7ef36b/scripts/deployer.rb). **TODO**

## 
