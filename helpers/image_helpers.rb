# Helpers for getting the image in a page for og and twitter meta tags
module ImageHelpers
  def self.featured_image(page, host)
    "#{host}/#{(page.data.image || default_image)}"
  end

  def self.default_image
    'images/default.jpg'
  end
end
