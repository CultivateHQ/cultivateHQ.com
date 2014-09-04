---
title:  "The future of Ruby"
author: Paul Wilson
archive: https://web.archive.org/web/20130314012109/http://www.neo.com/2012/05/21/the-future-of-ruby
description: I am not a very old-school Rubyist. My involvement dates from 2005 when I, along with many of my Extreme Programming (XP) colleagues, joined the Great Rails Bandwagon. It is telling that so many of the people who became involved around that time were from the Agile/XP community. We were sick of the mountains of glue code and XML configuration that stood in the way of us getting things done in Enterprise Java.
---

> originally published with [.net magazine](http://www.netmagazine.com/opinions/future-ruby)

I am not a very old-school Rubyist. My involvement dates from 2005 when I, along with many of my Extreme Programming (XP) colleagues, joined the Great Rails Bandwagon. It is telling that so many of the people who became involved around that time were from the Agile/XP community. We were sick of the mountains of glue code and XML configuration that stood in the way of us getting things done in Enterprise Java.

Those were heady days. The Metaprogrammability dynamic typing, and introduction of patterns such as Convention Over Configuration that was provided by the combination of Ruby and Rails gave us speedy, concise code. The test-driven discipline that was built into the language, framework, and the community gave us disciplined and verified code. Behaviour Driven Development, which had been struggling to survive in Java (JBehave anyone?) emerged and thrived in Ruby: Rspec was an early hit followed by Cucumber. To this day, the best Ruby Shops are also Agile/XP shops, while the others aspire to be so.

Fast forward to 2012 and the revolution is over. Ruby development has grown up and entered the mainstream, or at least the mainstream has shifted. While penetration of traditional enterprises such as banks is not great, Ruby startups such as LivingSocial and Groupon have grown into large corporations. The key moment that showed that Ruby had become mainstream was when Salesforce.com acquired Heroku in December 2010, and the message was reinforced the following July, when Ruby's designer, Matz (Yukihiro Matsumoto) was hired as Heroku's chief architect, Ruby.

Anecdotally, Rails has become the de-facto web technology for web startups. This growing success has not changed the community a great deal: it is still one that cares about craftsmanship, loves trying different languages such as Clojure and Erlang, and is grass-roots driven with a wide number of regional conferences.

Most Ruby development these days is still Rails, but we are entering an era of Rails backlash. The simple opinionated Model View Controller architecture that was so attractive in 2005, is now criticised for its lack of a layered architecture with proper separation of concerns. [Yehuda Katz](https://twitter.com/wycats), the driving force behind Rails 3, quipped on Twitter:

<div>
  <blockquote class="twitter-tweet" lang="en"><p>The problem with Rails today is that 1/2 the people are afraid Rails is turning into Java and the other 1/2 are trying to turn it into Java</p>&mdash; Yehuda Katz (@wycats) <a href="https://twitter.com/wycats/statuses/193629465375547392">April 21, 2012</a></blockquote>
  <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
</div>

My hope and belief is that the Ruby on Rails community is mature and reflective enough to introduce just the right amount of architecture back into web development, without reinventing Enterprise Java Beans. The signs for this are good with the upcoming Hexagonal Rails talk at the Scottish Ruby Conference; Avdi Grimm's [Objects on Rails](http://objectsonrails.com/) and Steven Baker's [Solid Rails](https://leanpub.com/solidrailsbook).

* [YARV](http://www.atdot.net/yarv/) is now the official Ruby interpreter for current Ruby 1.9.x, with significant performance benefits over Matz's original interpreter.

* [JRuby](http://jruby.org/) is the most mature and widely adopted alternative to YARV, developed by a team with a track record of consistent delivery. It brings to Ruby all the advantages of the Java Virtual Machine, just-in-time compilation, access to the rich set of Java libraries, interoperability with legacy Java code and true, native, multi-threading. The last is becoming more pertinent as the ability to take advantage of multi-core servers becomes more relevant to scaling: using threads is far more memory efficient than spinning up new processes.

* [Iron Ruby](http://www.ironruby.net/), the Ruby implementation for the .Net Framework, is still making progress despite withdrawal of direct support form Microsoft.

* [Rubinius](http://rubini.us/) is Ruby (as far as possible) written in Ruby. Despite some early stumbles and a big rewrite, Rubinius is now on a firm footing. It is on track to implement full multi-threading for version 2, with the removal of the Global Interpreter Lock.

* [Maglev](http://maglev.github.com/) is built on top of the VMWare's GemStone/S 3.1 Virtual Machine, allowing distributed and persistent Ruby Objects. Its perception in the community suffered from too early exposure: it made a huge splash when first demoed at RailsConf in 2008, followed by a few years of silence.

* [MacRuby](http://macruby.org/), the successor to RubyCocoa, is a 1.9 implementation built directly on top of the core OS X technologies. Probably the biggest obstacle to Ruby on OS X was inability to also use that code on iOS (iPhone / iPad), which is why the recent launch of Ruby in Motion, built on MacRuby but entirely iOS App Store compliant is such an exciting development.

* [MRuby](https://github.com/mruby/mruby) is worth a mention for two reasons: it is Matz's own project and it is being funded by the Japanese Government. It is a lightweight implementation of Ruby designed to be in the same space as Lua. The Japanese connection may be key to adaption, raising the possibility of seeing Ruby becoming embedded in electronics.

Seventeen years since its first appearance, and eight years from the Rails revolution, the Ruby community is still an exciting place to be. With all the current activity, and innovations coming to fruition, I don't see that changing any time soon.
