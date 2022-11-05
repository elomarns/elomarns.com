---
layout: single
title: "Book Review: The Ruby on Rails Tutorial (7th edition)"
permalink: "book-review-the-ruby-on-rails-tutorial-7th-edition/"
---
When I was learning [Rails](https://rubyonrails.org/), I read a couple of introductory books. One of them was [RailsSpace](https://www.amazon.com/RailsSpace-Building-Networking-Addison-Wesley-Professional/dp/0321480791), written by [Michael Hartl](https://www.michaelhartl.com/). It teaches Rails by building a complete web application, step by step. It wasn't an innovative approach, [Agile Web Development with Rails](https://pragprog.com/titles/rails7/agile-web-development-with-rails-7/) did it first, but I liked the book anyway.

Many years later, I heard about a new book called [The Ruby on Rails Tutorial](https://www.railstutorial.org/), written by the same Michael Hartl. It was getting a lot of praise, and it seemed to have the same approach as RailsSpace. But at the time I was already working with Rails, so an introductory book didn't spark any interest in me.

As time went by, new editions were released, each one covering a new version of Rails. The 7th edition covers Rails 7, which it's the latest version of Rails. I wasn't a big fan of [Webpack](https://webpack.js.org/), and since Rails 7 ditches Webpack and introduces many changes for front-end development, it got me seriously interested. So I decided to finally give a chance to The Ruby on Rails Tutorial, hoping it has an in-depth coverage of the changes in Rails 7.

<figure>
  <img src="/assets/img/book-review-the-ruby-on-rails-tutorial-7th-edition/the-ruby-on-rails-tutorial-7th-edition.png" class="w-60">

  <figcaption>Why is there a sword piercing through the ruby?</figcaption>
</figure>

## Overview

As I said before, the book teaches Rails by building applications throughout the chapters. At first, it builds two small applications, just to cover the basics, and then it focuses on [the main application](https://github.com/learnenough/rails_tutorial_sample_app_7th_ed) for the rest of the book. The main application is a Twitter clone, and with each new chapter it gets new features, while the book explains how Rails works. In its final version, the application has user management, microposts, user feeds, and the ability to follow and unfollow other users.

The book doesn't rush any concept, explaining with great detail most pieces of code. It even has a short introduction to Ruby, for those who haven't written a single line of Ruby code before. There are also a few short exercises after most sections. However, the book doesn't include the answers, which can be confusing for beginners.

Something that might scare some people is the book's length. It has 972 pages in PDF format. But don't be afraid, the font is bigger than usual, and the book has many pages with nothing but images. So I wouldn't say it's a long book. At least not longer than most programming books.

## From zero to deploy

One of the most interesting things this book does is cover deployment right from the beginning. You deploy to [Heroku](https://www.heroku.com/) all the 3 applications you develop while reading the book. And the book really holds your hand here, so most people will be able to publish their applications without any significant setbacks. It also helps you to set up an account on [SendGrid](https://sendgrid.com/) and an [AWS S3](https://aws.amazon.com/s3) bucket, so you can send emails and store your file uploads in production.

Most introductory books don't teach this important aspect of web development. In fact, I don't remember any other introductory book that teaches how to deploy an application. But this is a very important topic because it closes the development cycle. It's also much more exciting to learn a new framework if you can publish the results for the whole world to see.

However, it's important to highlight that this aspect of the book is going to disappear in a few weeks. [Starting November 28, Heroku won't offer free applications anymore](https://blog.heroku.com/next-chapter). This means that unless the book is updated until there, it will lose one of its most appealing features.

## Topics covered

Rails is a framework made of several smaller components, and most of them are shown in the book. For example, it teaches you to save and query data with Active Record, route requests to controllers, write dynamic HTML views, send emails with Action Mailer, and upload files with Active Storage. But it doesn't go super deep into most of these topics. For example, it doesn't cover polymorphic associations or scopes when it teaches you about Active Record. There are also some important pieces of Rails left out, such as Active Job and Action Cable. And it doesn't include some less relevant components too, like Action Mailbox and Action Text.

## Tests everywhere!

The book made a great choice by employing a test-heavy approach. It guides you on how to write tests from the beginning. You write tests for models, controllers, helpers, mailers, and even integration tests. The only important kind of test missing is system tests. The book also discusses when it's a good idea to use [TDD](https://en.wikipedia.org/wiki/Test-driven_development), and it shows you how to use it.

The only thing people can dislike about how the book approaches tests is its library choice. It uses [MiniTest](https://github.com/minitest/minitest) instead of [RSpec](https://rspec.info/), but I believe it was the right decision. RSpec is the most popular option, but MiniTest is the one that comes with Rails. And for beginners, it really doesn't make much of a difference, as long as they learn the importance of writing tests.

## Rails 7

Rails 7 was the reason why I decided to read this book. I wanted to learn more about topics like [import maps](https://github.com/rails/importmap-rails), [Turbo](https://turbo.hotwired.dev/), and [Stimulus](https://stimulus.hotwired.dev/). Since the book covers Rails 7, it was reasonable to think it would teach most of these subjects. But it doesn't. It briefly presents import maps, it has two examples using Turbo Streams, and that's it. Considering the importance of these new features, I think it'd be nice if the book had a more in-depth discussion of them.

## Final thoughts

This is a really well-written book, and it does a great job introducing Rails. If you don't know anything about Ruby or Rails, this is probably the best book for you. I believe it can be useful even if you don't know anything besides HTML and CSS. But if you're an experienced Ruby developer who wants to learn about Rails 7, you should probably look elsewhere. The same can be said for those who already know Rails but want to learn more advanced topics.
