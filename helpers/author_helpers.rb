def find_author(author_slug)
  author_slug = author_slug.downcase
  result = data.authors.select {|author| author.keys.first == author_slug }
  raise ArgumentError unless result.any?
  result.first
end

def articles_by_author(author_name)
  sitemap.resources.select do |resource|
  resource.data.author == author_name
  end.sort_by { |resource| resource.date.date }
end
