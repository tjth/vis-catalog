require 'RMagick'
require 'v8'

def getBackgroundColor(filePath)
	canvasPixels = []
	ctx = V8::Context.new
	ctx.load("color-thief.js")

	img = Magick::ImageList.new(filePath)
	pixels = img.get_pixels(0, 0, img.columns, img.rows)

	(0..img.columns).each do |x|
	    (0..img.rows).each do |y|

	    pixel = img.pixel_color(x, y)
	    canvasPixels.push(pixel.red/257)
	    canvasPixels.push(pixel.green/257)
	    canvasPixels.push(pixel.blue/257)
	    canvasPixels.push(255 - pixel.opacity/257)

	    end
	end

	return "rgb(" + ctx[:ColorThiefGetColor].call(canvasPixels, img.columns * img.rows) + ")"
end


