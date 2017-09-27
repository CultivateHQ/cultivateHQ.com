xml.instruct!
xml.feed 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.title 'Cultivate'
  xml.subtitle 'Blog'
  xml.id 'http://cultivatehq.com/blog'
  xml.link 'href' => 'http://cultivatehq.com/blog'
  xml.link 'href' => 'http://blog.url.com/feed.xml', 'rel' => 'self'
  xml.updated blog.articles.first.date.to_time.iso8601
  xml.author { xml.name 'Cultivate' }

  blog.articles.each do |article|
    xml.entry do
      xml.title article.title
      xml.link 'rel' => 'alternate', 'href' => article.url
      xml.id article.url
      xml.published article.date.to_time.iso8601
      xml.updated article.date.to_time.iso8601
      xml.author { xml.name article.data.author }
      xml.summary article.summary, 'type' => 'html'
      xml.content article.body, 'type' => 'html'
    end
  end
end
