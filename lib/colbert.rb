
require 'tempfile'

class Colbert
  TEXT_WIDTH = 350*4
  TEXT_HEIGHT = 50*4

  INPUT_COORDS = %W[ 0,0 #{TEXT_WIDTH},0 #{TEXT_WIDTH},#{TEXT_HEIGHT} 0,#{TEXT_HEIGHT} ]

  BACKGROUND = File.expand_path('../assets/images/colbert.jpg', __FILE__)
  FONT = File.expand_path('../assets/fonts/bebas/BEBAS___.ttf', __FILE__)

  DEST_COORDS = [
    "212,1 522,37 520,82 213,53",
    "213,65 520,95 520,139 214,116",
    "215,134 519,157 518,198 215,181",
    "215,198 519,214 518,256 215,245",
    "215,262 517,272 517,316 215,309",
    "221,326 523,329 522,372 221,374",
    "214,391 516,388 516,431 215,438",
    "215,455 515,447 514,487 214,501",
    "213,520 516,505 515,551 213,566",
    "220,585 520,561 521,602 220,630"
  ].map do |s|
    s.split(' ')
  end

  attr_reader :text
  def initialize text
    raise ArgumentError if text.length != 10
    @text = text.map(&:upcase)
  end

  def write_to file_path
    command = %W[convert #{BACKGROUND} -virtual-pixel transparent]

    text.each_with_index do |line, i|
      command.concat %W[
      (
      -background transparent
      -fill #CCCCCC -font #{FONT} -strokewidth 2 -stroke black -size #{TEXT_WIDTH}x#{TEXT_HEIGHT} -gravity center label:#{line.gsub(' ', '  ')}
      +distort Perspective #{perspective(i)}
      )
      ]
    end

    command.concat %W[-layers merge #{file_path}]

    p command
    system *command
  end

  private
  def perspective i
    INPUT_COORDS.zip(DEST_COORDS[i]).flatten.join(' ')
  end
end
