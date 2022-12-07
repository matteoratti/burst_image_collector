require 'watir'
require 'json'

#https://burst.shopify.com

file = File.read('./data.json')
data = JSON.parse(file)

pagination = 1

pagination.times do |n|

  page = n+1
  category = "university"
  url = "https://burst.shopify.com/photos/search?page=#{page}&q=#{category}"

  puts "START!!!"
  puts "page number #{page}"

  browser = Watir::Browser.new :firefox, headless: true
  #browser = Watir::Browser.new :firefox
  browser.goto(url)
  
  images = browser.div(class:"js-masonry-grid").elements(class: ["grid__item" , "grid__item--desktop-up-third"])
  images_count = images.size

  puts "FOUND #{images_count} IMAGES !!!"

  downloaded_images = 0
  
  images.each do |image|

    if browser.div(class: "modal").present?
      puts "FOUND A MODAL!!!"
      browser.div(class: "modal").div(class: "modal__header").div(class: "modal__controls").button(class:"modal__close").click
    end

    if browser.div(class: "sticky-popover__toggle-full").present?
      puts "FOUND A sticky-popover!!!"
      browser.div(class: "sticky-popover__toggle-full").click  
    end

    image_name = image.div(:class => 'photo-card').div(:class=>"photo-tile").link(class: "photo-tile__image-wrapper").div(class: "ratio-box").img.attribute_value("data-photo-title")

    if data["scraped_images"].include? image_name
      next
    end

    data["scraped_images"] << image_name

    image.div(:class => 'photo-card').div(:class=>"photo-tile").button(name: "button").click
  
    downloaded_images += 1
  
    puts "#{downloaded_images}/#{images_count}"
  end
  
  browser.close

  File.write('./data.json', JSON.dump(data))
  
  puts "I HAVE FINISHED!!!"
end