---
layout: single
title: "Comparing Heroku Alternatives"
permalink: "comparing-heroku-alternatives/"
---
As soon as I knew about [Heroku](https://www.heroku.com/) I was excited. It was love at first sight, but maybe not for the reason you're thinking. When Heroku first came out, its value proposition was a little bit different from what it is today. In the beginning, it was more than just a hosting platform. You could use Heroku to write your application's code, and then easily deploy it. Think about [AWS Cloud9](https://aws.amazon.com/cloud9/), but many years earlier and only for [Rails](https://rubyonrails.org/) applications.

<figure>
  <a href="/assets/img/comparing-heroku-alternatives/heroku-in-2008.png" alt="Heroku in 2008">
    <img src="/assets/img/comparing-heroku-alternatives/heroku-in-2008.png" alt="Heroku in 2008">
  </a>

  <figcaption>This was Heroku in 2008</figcaption>
</figure>

At the time, I really liked the idea of having a platform that could support all the major steps of the development of web applications. But it became obvious that even though the built-in [IDE](https://en.wikipedia.org/wiki/Integrated_development_environment) was a fun and novel idea, it wasn't actually good. However, there was value in providing an easy way to deploy applications, so Heroku focused on that, and it achieved huge success doing so.

Because of its ease of use, Heroku became my favorite hosting platform. Any new project was a `git push` away from gaining life in the real world. That was especially huge if you think about how hard it was to deploy Rails applications at the time. But then Heroku made it trivial. And it even allowed free applications with limited resources. It was hard not to love Heroku.

But we can't live in the past, and Heroku has not been looking good in the last few years. It stopped evolving, and [it doesn't offer free dynos anymore](https://blog.heroku.com/next-chapter).  More than ever it makes sense to search for a new home for my projects. But I don't want to lose all the convenience Heroku got me used to. I want something as painless as Heroku, but well-maintained and with a clear path ahead. After searching for a while I've found two worthy contenders: [Render](https://render.com/) and [Fly](https://www.fly.io/).

## The sample application

Now that we have two suitable candidates, it's time to evaluate them. Since I'm looking for a replacement for a hosting provider with great developer experience, it makes sense to do it by deploying a sample application to both of them. That way I can compare how easy the process is with them, and also compare with how easy it would be with Heroku.

Despite the fact Heroku supports many languages and frameworks now, I'm using Rails for the sample application since most of my future projects will be built with it. And to make things easier, I'm building a very simple application. It's basically a user scaffold. But despite its simplicity, it's enough to use as a basis for comparison, as it fully manages a database-backed resource.

You have two options in case you want to follow along. You can clone [the application's repository on GitHub](https://github.com/elomarns/comparing_heroku_alternatives), or you can follow the steps below. In both cases however you're going to need Ruby and Rails to run the application locally. Now let's build this application!

**1\. Create a Rails application**

Let's start by creating the sample application. To do that, execute the following commands on your terminal:

```shell
rails new comparing_heroku_alternatives -d postgresql
cd comparing_heroku_alternatives
```

**2\. Add the user scaffold**

Now we're going to create the files that will allow us to list, create, update, show, and delete users:

```shell
bin/rails g scaffold user name email bio
bin/rails db:create db:migrate
```

The commands above will also create the database and the `users` table. PostgreSQL needs to have a user with the same name as the currently logged-in user on your operating system, and it must not require a password for that user. If you want to use another user or require a password, you need to change your `config/database.yml` file to reflect that.

**3\. Set the root route**

Replace the content of the file `config/routes.rb` with the following:

```ruby
Rails.application.routes.draw do
  resources :users

  root "users#index"
end
```

**4\. Check if everything it's working**

To make sure your application is running as it should, you need to start the Rails server:

```shell
bin/rails s
```

Then visit [http://localhost:3000](http://localhost:3000) and interact with the application.

## Deploying to Render

Now it's time to deploy the sample application to Render. You're going to need an account on Render, so you must create it to proceed if you don't have it already. The steps below are based on [Render documentation for Rails applications](https://render.com/docs/deploy-rails):

**1\. Update the database configuration**

On `config/database.yml`, replace the production configuration with this:

```yaml
production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

The code above loads the database configuration from the environment variable `DATABASE_URL` on Render. We'll set that variable a few steps ahead.

**2\. Enable the public file server on production**

On `config/environments/production.rb`, replace the following line:

```ruby
config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
```

With this:

```ruby
config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present? || ENV['RENDER'].present?
```

**3\. Create a build script**

Render requires a script containing the necessary commands to build your application. So create the file `bin/render-build.sh` inside your application with the following content:

```shell
#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate
```

This is the script that will be executed every time you push to your repository. It installs the required gems, compiles the assets, and runs any new migrations. But you need to make sure the script is executable:

```shell
chmod a+x bin/render-build.sh
```

**4\. Declare your application's services**

Applications on Render have several services to cover all their needs. For example, a service for the application server, another for the database, and so on. There are two ways to tell Render about the services your application needs: declare them in a special file, or manually set up these services using [Render's dashboard](https://dashboard.render.com/). I'm using the first approach, so create a file called `render.yaml` at the root of your application with the following content:

```yaml
databases:
  - name: comparing_heroku_alternatives_production
    databaseName: comparing_heroku_alternatives_production
    user: comparing_heroku_alternatives

services:
  - type: web
    name: comparing_heroku_alternatives
    env: ruby
    buildCommand: "./bin/render-build.sh"
    startCommand: "bundle exec puma -C config/puma.rb"
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: comparing_heroku_alternatives_production
          property: connectionString
      - key: RAILS_MASTER_KEY
        sync: false
```

The YAML code above states that our application will have a database, and that the database's connection string should be stored in the environment variable `DATABASE_URL`. This is the environment variable we're using on `config/database.yml`. We're also setting the build script and the start command for the application.

Just a warning: you can't use the same name for your application as me. That name will be used on the URL generated by Render, and since I'm already using it, Render will ask you to use another name. So when you see `comparing_heroku_alternatives` above, replace it with something like `comparing_heroku_alternatives_YOUR_USERNAME_HERE`.

**5\. Create a repository on GitHub**

Render will deploy the application every time the main branch is updated, but for that to happen we need to create a repository on GitHub or GitLab. I'm choosing GitHub here, but before creating your repository there, you need to commit your changes:

```shell
git add .
git commit -m "First commit."
```

Now you can create your repository on GitHub:

<figure>
  <a href="/assets/img/comparing-heroku-alternatives/new-repository-on-github.png">
    <img src="/assets/img/comparing-heroku-alternatives/new-repository-on-github.png" alt="Creating a new repository on GitHub">
  </a>

  <figcaption>In case you're not feeling creative, you can fill the fields with the same content as me</figcaption>
</figure>

After creating the repository on GitHub, we need to push our code:

```shell
git remote add origin git@github.com:YOUR_USERNAME_HERE/comparing_heroku_alternatives.git
git push -u origin main
```

**6\. Create a blueprint**

Render's blueprint specify your application's infrastructure as code. We did just that two steps above using `render.yaml`. So to create a blueprint we just need to connect Render to a Git repository containing a `render.yaml` file. To do that, on Render's dashboard, go to the [new blueprint page](https://dashboard.render.com/select-repo?type=blueprint) and connect your GitHub account:

<figure>
  <a href="/assets/img/comparing-heroku-alternatives/connecting-github-account-on-render.png">
    <img src="/assets/img/comparing-heroku-alternatives/connecting-github-account-on-render.png" alt="New blueprint page on Render">
  </a>

  <figcaption>Click on the button shown above to connect your GitHub account to Render</figcaption>
</figure>

It's probably a good idea to select only the repository you're going to use:

<figure>
  <a href="/assets/img/comparing-heroku-alternatives/installing-render-on-github.png">
    <img src="/assets/img/comparing-heroku-alternatives/installing-render-on-github.png" alt="Connecting the repository to Render">
  </a>

  <figcaption>Connecting the repository to Render</figcaption>
</figure>

Then the new blueprint page will reload, showing the repository you've just linked to your Render account. Click on the button to connect that repository and start creating the blueprint:

<figure>
  <a href="/assets/img/comparing-heroku-alternatives/starting-creating-the-render-blueprint.png">
    <img src="/assets/img/comparing-heroku-alternatives/starting-creating-the-render-blueprint.png" alt="New blueprint page on Render with repository alread connected">
  </a>

  <figcaption>Click on the button above to start creating your blueprint</figcaption>
</figure>

On the following page, you'll need to provide a service group name, and also the Rails master key. You can find that key on `config/master.key`. After filling in these two fields, click on the button to start the deployment:

<figure>
  <a href="/assets/img/comparing-heroku-alternatives/finishing-creating-the-render-blueprint.png">
    <img src="/assets/img/comparing-heroku-alternatives/finishing-creating-the-render-blueprint.png" alt="Page that finishes blueprint creation on Render">
  </a>

  <figcaption>Finish creating your blueprint and start your first deployment on Render</figcaption>
</figure>

 Render will read your `render.yaml` file, and then create and deploy all the services. And... that's it. You've just deployed your application to Render. Return to the Dashboard's home, select your newly created service (`comparing_heroku_alternatives` in my case), and then you'll see the full URL for your application. In my case it's [https://comparing-heroku-alternatives.onrender.com/](https://comparing-heroku-alternatives.onrender.com/).

And since your Git repository is linked to your blueprint, every time you update your main branch it will trigger a new deployment. Just like Heroku.

## Deploying to Fly

The process with Render went pretty smoothly, now it's time to see how things go with Fly.

**1\. Install flyctl**

The first step is to [install flyctl](https://www.fly.io/docs/hands-on/install-flyctl/), which is the command line tool to interact with Fly. If you're using Linux or macOS you can install it with this:

```shell
curl -L https://fly.io/install.sh | sh
```

And this is the command for For Windows users:

```shell
iwr https://fly.io/install.ps1 -useb | iex
```

**2\. Sign in with flyctl**

`flyctl` is installed, now it needs to know who you are so it can interact with your apps:

```shell
flyctl auth login
```

The command above will open a browser window allowing you to sign in and connect `flyctl` to your account. I'm supposing you already have an account on Fly but if you don't you can create one at the [sign up page](https://fly.io/app/sign-up), or using `flyctl` itself:

```shell
flyctl auth signup
```

**3\. Create and configure the application on Fly**

Run `flyctl launch` on your terminal to create your application. It's going to ask you a few questions. Here are my answers as reference:


```shell
flyctl launch
Creating app in /home/elomarns/Dropbox/Projects/comparing_heroku_alternatives
Scanning source code
Detected a Rails app
? Choose an app name (leave blank to generate one): comparing-heroku-alternatices
automatically selected personal organization: Elomar Nascimento dos Santos
? Choose a region for deployment: São Paulo (gru)
Created app comparing-heroku-alternatices in organization personal
Set secrets on comparing-heroku-alternatices: RAILS_MASTER_KEY
Wrote config file fly.toml
? Would you like to set up a Postgresql database now? Yes
? Select configuration: Development - Single node, 1x shared CPU, 256MB RAM, 1GB disk
...
? Would you like to set up an Upstash Redis database now? No
...
Your Rails app is prepared for deployment.
...
Now: run 'fly deploy' to deploy your Rails app.
```

At the end of the process it will create the following files:

```
.dockerignore
Dockerfile
fly.toml
lib/tasks/fly.rake
```

These files declare the Docker image Fly is going to use to deploy your application, and also the services your application will use.

**4\. Deploy your application**

Now that your application already exists on Fly, you can deploy it:

```shell
flyctl deploy
```

**5\. Launch your application**

Your application is live! Run `flyctl open` and it'll open on your browser. For me, it opens in the URL [https://comparing-heroku-alternatices.fly.dev/](https://comparing-heroku-alternatices.fly.dev/)

## It's comparison time!

Finally, it's time to compare both platforms to decide which will be my next hosting platform.

### Developer experience

Render doesn't require us to install any additional software, but we had to manually create two new files: `bin/render-build.sh` and `render.yaml`. On the other hand, Fly requires us to install their CLI tool, but we didn't have to manually create any new files, although some files were created for us when we ran flyctl launch.

The first deployment is equally easy with the two of them, and the same can be said about any subsequent deployment. With Render with just need to update the main branch, and with Fly we need to run `flyctl deploy`.

I'd say they're practically tied here since both have a very straightforward approach. But because I like CLI tools, I like Fly's approach better. Their CLI tool is quite capable, and it seems you can fully manage your application with it.

### Dashboard

Render has a really nice dashboard. It shows all your services, and it allows you to interact with them in several ways. It shows logs and metrics (CPU, memory, and bandwidth usage), and you can even access your application through a shell interface directly in the dashboard. This means you can run `rails c` on your application from anywhere.

I had some problems with [Fly's dashboard](https://fly.io/dashboard). Most of the time, it just didn't work for me. It simply refused to show my applications. I've tried for a few days, but it didn't show any data. It seemed it was loading the data, but it couldn't finish. Google Chrome's console showed a failed web socket connection, but I have no idea why. I've also tried the same with Firefox, but it made no difference. Then I found the command `flyctl dashboard`, which opens your browser window directly on your application's dashboard page. After this, the dashboard's home also worked. It seems the dashboard requires you to first run `flyctl dashboard` to work. I really can't find any other explanation.

When it works, Fly's dashboard is quite useful. It shows logs and metrics, allows you to manage certificates and volumes, and lets you scale your application, among other features. But even though Fly has a very capable dashboard, considering the strange experience I had with it, I have no other option other than giving Render an advantage here.

### Features

Render and Fly offer standard features such as autoscaling, secrets management, custom domains, Docker-based deploys (optional on Render), asynchronous workers, and HTTP/2 support, among many others. By the way, HTTP/2 support is very important for Rails applications using Rails 7, as otherwise, [they can't take advantage of import maps](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b). This is something that Heroku doesn't have yet.

At first, it seems their capabilities are quite similar, but there are a few differences. With Fly, everything is an app running on [Firecracker microVMs](https://github.com/firecracker-microvm/firecracker). They are lightweight virtual machines that safely isolate your application. This means that everything you host on Fly is treated as a regular application, including databases. So it doesn't have traditionally managed databases, as Heroku and Render do. This may or may not be a problem, depending on how comfortable you're with managing databases yourself.

However, Fly has an interesting advantage compared with Render: it allows you to deploy your application in 26 regions, while Render only offers 4 regions. This enables you to have your application closer to your intended audience, which can be an essential feature for real-time applications. With Fly you can also host your applications on multiple regions at the same time, which doesn't seem to be possible with Render.

Since they both have compelling features, it's hard to choose one of them to win this category. So I won't. The truth is their feature sets are equally great, so it all comes down to specific application needs.

### Docs

No matter how easy a hosting platform is, we still need documentation to learn our way around it. Fortunately, Render and Fly deliver on this front. Their docs are well-written and comprehensive. They have specific guides for the most popular languages and frameworks, they cover the platform's features, and they even include a guide that teaches how to migrate your application from Heroku. Without any prior knowledge about them, I was able to quickly deploy a simple application. That in itself is proof that their documentations are top-notch.

So there's no winner in this category either. If there's any significant advantage for one of them, it's something I'd notice only after using the platform for an extended period.

### Pricing

Pricing is one of the most sensitive attributes for a hosting provider. Platforms that hide the complicated stuff for you have the habit of being expensive. Heroku is a prime example. It abstracts almost everything, but it's one of the most expensive options out there. Render and Fly are also on the more abstract side of the fence, but they're not as expensive as Heroku.

To make this more concrete, I'm comparing their pricing using two scenarios. The first scenario is a Rails application with just the application server and a PostgreSQL database, and only using free resources. But before starting the actual comparison, it's important to mention that Render's pricing is about to change. [On January 1, 2023, Render will have a new pricing strategy](https://render.com/pricing-jan-1-2023). So to prevent this post from becoming outdated in less than a month, I'm considering the new pricing.

Render's pricing is based on what you're hosting. You can host static sites, services, PostgreSQL databases, Redis instances, and cron jobs. Using only free resources, we can have an application server with 512 MB RAM and a shared CPU. Render also offers PostgreSQL with 256 MB RAM and 1 GB of storage. But there are limitations. The application server will be shut down after 15 minutes of inactivity, similar to Heroku's old behavior. You also can't have more than 750 hours of running time across all free web services in your account. This means you can only have one free application running on Render. It also sets 100 GB as the maximum bandwidth usage before charging you. The database has even harsher restrictions. After 90 days, it will expire and you'll no longer be able to reach it. You'll need to create another database, losing all your data. This makes Render's free offer restricted to learning purposes or applications that don't require a database.

Fly offers for free 3 VMs with shared CPUs and 256 MB RAM for you to use however you want to. For this first scenario, you won't need more than 2 VMs, one for the application server and the other for the database. But it can be difficult to run your application with only 256 MB RAM. And you have only 3 GB of storage, so you can't have a big database. But I believe it's usable for really simple applications. For example, the sample application I'm using on this post is using around 228 MB. But anything slightly more intensive than that won't fit the free offering.

Both platforms offer very limited free solutions, but because Render is not really usable for a real web application with a database, I think Fly's free offer is better, but far from being great.

Now for the second scenario, let's consider a more demanding application. It can't be shut down if it's inactive, it needs an application server with 512 MB RAM, and it also needs a background worker. This is the cost on Render:

Application server: $7/month<br>
Database server: $7/month<br>
Worker: $7/month<br>
Total: $21/month

And here we have the cost using Fly:

Application server: $3.19/mo<br>
Database server: $3.19/mo<br>
Worker: $3.19/mo<br>
Total: $9.57.month<br>

For this second application, Fly is so much cheaper than Render that I can't avoid thinking I'm misunderstanding their pricing.  But If I'm not mistaken and the numbers are right, Fly definitely gets the nod here as the least expensive option by a considerable margin.

So as Fly won in both scenarios, it wins the pricing battle.

## Final thoughts

It's safe to say that both platforms have a bright future ahead of them. They're easy to use, the pricing is not bad, they offer a lot of features, and their documentations are great. But which one I'm going to use for my future projects? I'm going to give you the most hateful answer of all: it depends. I know that's not the answer you were looking for, but there's no better answer here. They're both very good alternatives to Heroku, so the choice depends on the application you want to host.

If you're looking for a real-time application, Fly is most likely the better choice. It can run your application in many regions, thus decreasing the latency. It's also the option I'd choose if my application needs a lot of small services, as their pricing is better. But if your application is not that fancy, and you value convenience above everything else, Render might be your best choice. It has managed databases, and it seems to handle more of the low-level stuff for you than Fly.

Whatever your choice might be, I believe you won't regret it. I can't think of a better alternative to Heroku than one of them.
