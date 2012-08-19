---
layout: post
title: "marker branches in git"
date: 2012-08-09 21:40
comments: true
categories: 
---

In my [last post](/blog/2012/08/02/octopress-deployment-pipeline/) I talked about setting up a basic deployment pipeline using marker branches in git to keep track of what was where. 

In this post I want to go into a little more detail describing how these marker branches work. To do that I'll walk through a simple example showing the state of a git repo as code moves through being committed, being pushed to master, deployed to pre-prod, and finally promoted to prod.

## A sample git branch progression
In these diagrams the rounded boxes are git commits, the rectangles are git branches. The 'WD' rounded box represents uncommitted local changes in the current working directory. 

Many thanks to Scott Chacon, git teacher extrodinaire, who very generously [shares an omnigraffle file](https://github.com/schacon/git-presentations/) containing all the really nice git diagrams he uses in his books and presentations. I've shamelessly used that as the basis of these diagrams.


<figure class="diagram">
  {% img /images/post_images/octopress_cd/0.png %}
  <figcaption>
    starting state
  </figcaption>
</figure>

At the start of this scenario we have our master branch pointing at the *C5* commit. We also have a couple of **marker branches**, *pre-prod* and *prod*. We'll talk more about these guys momentarily. Finally we have some local code changes inside our working directory. These are the changes which we are going to be following as the travel their **path to production**.



<figure class="diagram">
  {% img /images/post_images/octopress_cd/1.png %}
  <figcaption>
  changes checked in
  </figcaption>
</figure>

In this next diagram you can see I've now checked in the local changes I had in my working directory to my *master* branch as *C6*. *master* is now pointing to the newly created *C6* commit but nothing else has changed.

## A release candidate is born

At this point I run some acceptance tests, and decide that what I currently have in master is a viable **release candidate**. I want to push it to *pre-prod* to start more exhaustive testing of this candidate.

To do that I run a deployment script which pushes the code revision which *master* is currently pointing to into the pre-prod environment. If the deployment succeeds the script will also update the *pre-prod* marker branch to point to the code revision which is now deployed to pre-prod. That's the essence of the marker branch concept. It's a way to indicate which revision of the codebase is in which environment.

<figure class="diagram">
  {% img /images/post_images/octopress_cd/2.png %}
  <figcaption>
    after deploying to pre-prod
  </figcaption>
</figure>

Here's what our git repo looks like after that deploy to pre-prod. The *pre-prod* branch has been updated to point to *C6*, since that's the commit which my script just successfully deployed to the pre-prod environment. *Master* also continues to point to *C6*, because there haven't been any other checkins to *master* since I decided to deploy to pre-prod.

## Pre-prod signoff

Now I will do some more exhaustive testing in my pre-prod environment. Probably some exploratory QA testing, and probably some sign-off with my product and design friends as well. Note that there's a very easy way to see exactly what is in pre-prod that has changed since our last release to prod. We have a *prod* marker branch which indicates which code revision is currently in production, and a *pre-prod* marker branch which shows what code revision the current pre-prod release candidate is from. If anyone needs to know exactly what changes are involved in this release candidate we can use standard git diffing and logging tools to find out.


## Release candidates don't stop other work

While we're verifying our release candidate other development work can continue to happen, with more commits to master.

<figure class="diagram">
  {% img /images/post_images/octopress_cd/3.png %}
  <figcaption>
  meanwhile, work continues...
  </figcaption>
</figure>

Here we see that the *master* branch has continued to move forward with new commits *C7* and *C8*. I included this in the scenario to highlight the benefits of the *pre-prod* marker branch. We don't have to stop forward development while we verify that a specific code revision is good for release. We also don't need to create a true branch in the repo. We simply use a marker branch to make a note of what revision is currently in pre-prod while allowing unrelated development to move forward.

## Promote to production

At this point our friends in QA and Product have given us a happy thumbs up and agreed that what's in pre-prod is ready for release to production. We'll now run a deployment script which takes the code revision pointed to by the *pre-prod* marker branch and **promotes** (i.e. re-deploys) that code revision to the production environment.

<figure class="diagram">
  {% img /images/post_images/octopress_cd/4.png %}
  <figcaption>
  released to production
  </figcaption>
</figure>

Here's the state of the git repo after a successful promotion from pre-prod to prod. After some smoke tests against the production environment have passed the script updates the *prod* marker branch to reflect the new reality - the current code in production is the code at commit 6 in the repo.

## Conclusion

I've shown how marker branches can act as a simple way to track which version of your application is live in which environment. I've also shown that you can use marker branches to enforce lightweight process constraints - for example you can't deploy an arbitrary code revision to prod, it has to be the code revision that's currently in pre-prod.

Marker branches are not a substitute for a real grown-up build pipeline with build artifacts and an associated artifact repository. However for a really simple system (e.g. deploying a blog) marker branches can make sense. 

The lightweight constraints can also potentially work as a way to manage how code changes enter CI when working in a large team of developers. For example you could only allow developers to check in code on top of a *passed--ci-smoke* marker branch. This would prevent a developer from accidentally checking in on top of code which has not yet gone through a CI smoke test.
