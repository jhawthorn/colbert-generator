require 'sinatra/base'
require 'imgur2'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'colbert'

class ColbertGenerator < Sinatra::Base
  def create_and_upload text
    file = Tempfile.new(%w[colbert .jpg])
    Colbert.new(text).write_to(file.path)

    client = Imgur2.new '65aea9a07b4f6110c90248ffa247d41a'
    response = client.upload(file)
    response['upload']['links']['original']
  ensure
    file.close! if file
  end

  get '/' do
    <<-EOS
    <form action="/generate" method="post">
    <input type="text" name="text[]" value="Black Hole at Center of Galaxy"><br/>
    <input type="text" name="text[]" value="Michael Adams"><br/>
    <input type="text" name="text[]" value="Grizzly Bears"><br/>
    <input type="text" name="text[]" value="Filliam H Muffman"><br/>
    <input type="text" name="text[]" value="The Toronto Raptors"><br/>
    <input type="text" name="text[]" value="The British Empire"><br/>
    <input type="text" name="text[]" value='"Business Casual"'><br/>
    <input type="text" name="text[]" value="Barbra Streisand"><br/>
    <input type="text" name="text[]" value="Distractions"><br/>
    <input type="text" name="text[]" value="You Know Who You Are"><br/>
    <input type="submit">
    </form>
    EOS
  end

  post '/generate' do
    text = params.fetch('text')
    10.times do |i|
      text[i] = "grizzly bears" if !text[i] || text[i].empty?
    end

    link = create_and_upload(text)
    redirect link
  end
end

run ColbertGenerator

