---
layout: post
title: "Deploying to Heroku from CI - the gory details"
date: 2013-01-22 17:14
comments: true
categories: 
---

In my [previous post](/blog/2013/01/21/deploying-to-heroku-from-ci) I discussed why you might want to deploy to Heroku as part of a CI build. I demonstrated how my `heroku-headless` gem makes it very easy to script such a deployment. In this post I'll go into the details on how that gem does its work. I'll talk about what the Heroku deployment tooling expects to be available, why that's not necessarily going to be there in the context of a CI build environment, and how the gem helps resolve that.


## Heroku's deployment model 

Heroku's deployment model centers around pushing git commits to a special heroku git repo. When you want to deploy a new version of your application you push the git commit corresponding to that build up to the special heroku repo. As a side effect of updating the remote repo heroku will deploy a copy of the application as of that commit.  

Of course Heroku won't let anyone deploy a new version of your application. It only allows a registered collaborator to push to an app's repo. You can manage which heroku users are collaborators of the app via the Heroku [web interface](https://dashboard.heroku.com/apps), or via the `heroku sharing` set of commands. 

But how does Heroku know which user is trying to push to an app's heroku repo? It looks at the ssh key that git is using when it makes the push. Unless the ssh key is registered to a listed collaborator of the app then Heroku will reject the push.

A Heroku user usually registers their ssh key with Heroku using the `heroku keys:add` command. The average Heroku user only has to perform this procedure when they're setting up a new dev machine. Once it's done Heroku deploys are very low-friction since your registered ssh key is automatically used by git whenever you push. `git push heroku` is all you need to do. It's easy to forget that you registered your ssh key with Heroku at one point.

## What's different for a headless CI deploy

Things can be a bit different when deploying from a CI agent. The CI agent's user may not even have an ssh key generated, and if it does it is probably not associated with a Heroku user that has collaborator access to the Heroku app you want to deploy to.

One way to solve this would be to ensure that the CI agent user has a ssh key generated and to manually register that key for a Heroku user who has collaborator rights to the target app. This works, but it's not ideal. The manual setup is tedious and error prone, and you have to do it for every agent in your CI system. You also have to make sure that the Heroku user which the CI agent is acting as is registered as a collaborator for every Heroku app that it might be deploying to. If you're using a cloud-like CI system such as [Travis](http://travis-ci.org) then you might not even have access to the CI agent in order to generate and register an ssh key, and even if you did you have no control over which agent will be running your next build. With some systems you will be given an agent with a totally pristine environment for each build. In other words, you can't always rely on manually pre-configuring an agent's environment.

All of this means that it's better to avoid the need for manual setup of pre-existing ssh keys. A better approach is to generate a *disposable ssh key*, register it with a Heroku user, do a git push using that key, and then remove the disposable key. 

As luck would have it Heroku exposes API for adding and removing ssh keys for a user. When you use the Heroku API you pass a secret API key which Heroku uses to both authenticate you and also to figure out which user you are acting as. That allows the API to know which user's keys you are managing.

This *disposable key* approach is more secure and has no requirements on a CI agent having a previously configured environment. You could take a totally pristine box and use it to run a deploy without any other setup. Transversely, you can test a deploy script on a full-configured developer workstation without your local environment affecting the deploy script and without the deploy affecting your environment.

Note that the disposable key approach still requires that you have previously set up a Heroku user who has collaborator access to the app you are deploying to. It also requires that your build scripts have access to that user's secret Heroku API key. You need to be careful here - if that key gets into the wrong hands it could be used to run up a very large bill with Heroku. As I said in [my previous post](/blog/2013/01/21/deploying-to-heroku-from-ci), you'll want to use a feature in your CI system along the lines of Travis's [secure environment variables](http://about.travis-ci.org/docs/user/build-configuration/#Secure-environment-variables) to protect access to that key. Most CI/CD systems provide similar functionality.

## The steps for a headless deploy using disposable keys

So we have our basic approach laid out. Whenever we want to deploy our app we need our script to:

- generate a new disposable ssh key
- register that key with Heroku
- use the key to deploy the app via a git push
- unregister the key with Heroku
- delete the key locally

## Implementation details

I'll now briefly describe how the **heroku-headless** gem does all that. If you want more details I encourage you to study the [gem's implementation](https://github.com/moredip/heroku-headless). It's really pretty simple - a handful of classes, about 200 lines of code in total.

### Creating a local scratch directory

We use ruby's [tmpdir module](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/tmpdir/rdoc/Dir.html) to generate a temporary working directory which will contain our disposable ssh keys and some configuration files. After we're done with the deploy we'll delete this directory.

### Generating a disposable ssh key
Next we'll generate our disposable public/private key pair inside our new scratch directory. We use the `ssh-keygen` command which is available on pretty much any unix box: `ssh-keygen -t rsa -N "" -C #{ssh_key_name} -f #{ssh_key_path}`

### Registering the key with Heroku
The `heroku-api` gem is our friend here. We create an instance of the Heroku API with `heroku = Heroku::API.new()`. If you don't explicitly pass in an API key the gem will use the value of the `HEROKU_API_KEY` environment variable, so you need to make sure that that environment variable is set correctly by your CI system just prior to running your deploy script. Alternatively you can explicitly pass in an API key to the constructor, but again you need to be careful you **don't expose this key**. 

Given all of that, we can register our disposable ssh key with that API key's Heroku user by doing something like:

``` ruby register-disposable-key
heroku = Heroku::API.new()
public_ssh_key = File.read(path_to_public_ssh_key)
heroku.post_key(public_ssh_key)
```

Note that we're sending the *public* key to Heroku. Private ssh keys are never exposed.

### Pushing to the heroku git remote using our disposable key
This is the fiddly bit. We need to have git push to heroku using that newly generated ssh key, but we don't want to mess with any system ssh configuration which might be in place. Luckily git allows you to override the path to the underlying ssh executable it uses when connecting to a remote repo, via a `GIT_SSH` environment variable. We'll use that to point git to a little wrapper script. This script calls through to the system's standard ssh executable but adds a few command line arguments along the way. Those command line arguments will tell ssh to identify itself using our disposable key (as opposed to whatever may be setup in `~/.ssh/`). We also add a few arguments which tell ssh to not ask for confirmation the first time we connect to the heroku host, and also to prevent ssh from recording the heroku host as a known host. 

The wrapper script looks like this:

``` bash git_ssh_wrapper.sh
#!/bin/sh
exec ssh -o StrictHostKeychecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -i /path/to/disposable_ssh_key -- "$@"
```

All credit to [this Stack Overflow question](http://stackoverflow.com/questions/3496037/how-to-specify-which-ssh-key-to-use-within-git-for-git-push-in-order-to-have-git) which that wrapper script is based on.

Once we've generated that script and placed it in our scratch directory we can ask git to push to our app's heroku repo using that custom ssh wrapper like so:

``` ruby push-to-heroku
system( {'GIT_SSH'=>custom_git_ssh_path}, "git push git@heroku.com:#{app_name}.git HEAD:master" )
```

Note that in this example we're pushing whatever HEAD currently points to, but we could push any arbitrary commit up to Heroku using this same command.


### Deregistering the disposable ssh key
This one is easy: `heroku.delete_key(ssh_key_name)`. The ssh_key_name we pass in should be the same key name we passed to ssh-keygen via the -C flag.


### Cleanup
Lastly, we clean up after ourselves by deleting the local scratch directory.

## Fin

That's it. It did take a fair amount of Internet research to figure all that out, but I should be clear that almost all of what I've described was lifted from other blog posts, Stack Overflow answers, etc. Hopefully by collating that info here I'll help someone else travelling down a similar path. And again, if you don't really care about the details and just want to get your app deployed via CI then just use the heroku-headless gem and move on!
