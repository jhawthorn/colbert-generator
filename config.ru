require 'sinatra/base'
require 'net/http'
require 'json'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'colbert'

class ColbertGenerator < Sinatra::Base
  API_PUBLIC_KEY = 'Client-ID 9a635f414520be6'
  DESCRIPTION = "Generated by https://jhawthorn.github.io/colbert/\n\n"

  def imgur_upload(image_path, text)
    http = Net::HTTP.new('api.imgur.com', 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new('/3/image/')
    request.set_form_data(
      image: File.read(image_path),
      title: "You're On Notice!",
      description: DESCRIPTION + text.join("\n")
    )
    request.add_field('Authorization', API_PUBLIC_KEY)

    response = http.request(request)
    data = JSON.parse(response.body)

    data['data']['link']
  end

  def create_and_upload text
    file = Tempfile.new(%w[colbert .jpg])
    Colbert.new(text).write_to(file.path)

    imgur_upload(file.path, text)
  ensure
    file.close! if file
  end

  get '/' do
    redirect 'http://jhawthorn.github.io/colbert'
  end

  post '/generate' do
    text = params['text'] || []
    10.times do |i|
      text[i] = "grizzly bears" if !text[i] || text[i].empty?
    end

    link = create_and_upload(text)
    redirect link
  end
end

run ColbertGenerator
