import numpy as np

def PImage(width, height, channels=3):
	return np.zeros((height,width,channels), np.uint8)

class ImgData:
	def __str__(self):
		return str(self.imgData) # ""; #"[" + imgWidth + "x" + imgHeight + "/" + imgChannels + "]"
	
	def ImgDataInit(self, input):
		if isinstance(input, ImgData):
			self.imgChannels = input.imgChannels
			self.imgWidth = input.imgWidth
			self.imgHeight = input.imgHeight
			self.imgMax = input.imgMax
			self.imgScale = input.imgScale
		else:
			self.imgChannels = input.shape[2] if len(input.shape) == 3 else 1
			self.imgWidth = input.shape[1]
			self.imgHeight = input.shape[0]
			self.imgMax = np.iinfo(input.dtype).max
			self.imgScale = 1.0

		#System.out.println("Instantiated "+imgWidth+"x"+imgHeight+"."+imgChannels)
	
	def __init__(self,input):
		self.ImgDataInit(input)
		
		self.imgData = np.zeros((self.imgHeight,self.imgWidth,self.imgChannels), np.uint8)
		zoom = 1
		self.pimg = PImage(self.imgWidth * zoom, self.imgHeight * zoom)
		self.imgPalette = np.zeros((self.imgMax+1, self.imgChannels, 3), np.uint8)
	
	# copy pixel and palette data from an existing image
	def copyFrom(self, input):
		print "copyfrom"
		self.copyPalette(input)
		for y in range(self.imgWidth):
			for x in range(self.imgHeight):
				for ch in range(self.imgChannels):
					self.imgData[x][y][ch] = input.imgData[x][y][ch]

	def copyPalette(self, input):
		self.imgPalette = np.zeros((self.imgMax+1, input.imgChannels, 3), np.uint8)
		for ch in range(input.imgChannels):
			for i in range(self.imgMax+1):
				self.imgPalette[i][ch] = input.imgPalette[i][ch]
	
	# draws the image to the display
	def draw(self):
		image(self.pimg, 0,0)
	
	# prepares the PImage for display
	def loadPImage(self, zoom=None):
		if self.pimg is None:
			self.pimg = PImage(self.imgWidth, self.imgHeight)

		if zoom:
			self.pimg = PImage(self.imgWidth * zoom, self.imgHeight * zoom)

		#self.pimg.loadPixels()
		zoom = False
		if zoom:
			if self.imgChannels == 1:
				for y in range(self.imgHeight):
					for x in range(self.imgWidth):
						col = imgData[x][y][0]
						col = constrain(col, 0, imgMax)
						for z2 in range(zoom):
							for z1 in range(zoom):
								loc = (self.imgWidth*zoom) * (y*zoom+z2) + (x*zoom) + z1
								self.pimg.pixels[ loc ] = imgPalette [ col ][0]
			elif self.imgChannels == 2: # complex data
				for y in range(imgHeight):
					for x in range(self.imgWidth):
						c1 = imgData[x][y][0]
						c2 = imgData[x][y][1]
						colorMode(HSB, 360)
						c = color( c2 + 180, constrain( 60 + c1, 0, 360 ), constrain( c1, 0, 360 ) )
						for z2 in range(zoom):
							for z1 in range(zoom):
								loc = (self.imgWidth*zoom) * (y*zoom+z2) + (x*zoom) + z1
								self.pimg.pixels[ loc ] = c
								#print(c)
				colorMode(RGB, 255)
			elif self.imgChannels >= 3:
				for y in range(self.imgHeight):
					for x in range(self.imgWidth):
						col = imgData[x][y][0]
						col = constrain(col, 0, imgMax)
						for z2 in range(zoom):
							for z1 in range(zoom):
								loc = (self.imgWidth*zoom) * (y*zoom+z2) + (x*zoom) + z1
								c = getBlend(x,y)
								self.pimg.pixels[ loc ] = c
								#print(c)
		else:
			pass
			#if self.imgChannels == 1:
			#	for i in range(pimg.pixels.length):
			#		x = i % self.imgWidth
			#		y = i / self.imgWidth
			#		self.pimg.pixels[i] = imgPalette[ imgData[x][y][0] ][ 0 ]
			#elif self.imgChannels >= 3:
			#	for i in range(self.pimg.pixels.length):
			#		x = i % self.imgWidth
			#		y = i / self.imgWidth
			#		c = getBlend(x,y)
			#		self.pimg.pixels[i] = c
			#		print(c)

		self.pimg = self.imgData
		#self.pimg.updatePixels()
		return self.pimg
	
	def getBlend(x, y):
		ch0 = constrain(imgData[x][y][0], 0, 255)
		ch1 = constrain(imgData[x][y][1], 0, 255)
		ch2 = constrain(imgData[x][y][2], 0, 255)
		c0 = imgPalette[ ch0 ][ 0 ]
		c1 = imgPalette[ ch1 ][ 1 ]
		c2 = imgPalette[ ch2 ][ 2 ]
		c3 = blendColor(c0, c1, ADD)
		c4 = blendColor(c2, c3, ADD)
		return c4
	
	# set the display palette for an image based on rgb ? [ -1.0 , 1.0 ]
	def setPalette(r, g, b) :
		for ch in range(self.imgChannels):
			setPalette(ch, r, g, b)
		
	
	# set the palette for one channel
	def setPalette(ch, r, g, b) :
		for i in range(imgMax+1):
			vr = getPalValue(i,r)
			vg = getPalValue(i,g)
			vb = getPalValue(i,b)
			imgPalette[i][ch] = color(vr,vg,vb)
	
	# calculates the correct value for a given index in the palette
	def getPalValue(index, val):
		if(val<0):
			fr = -val * imgScale * float(imgMax - index)
		else:
			fr =  val * imgScale * float(index)
		return int(fr)
	
	# draws the palette to the screen for the first channel
	def drawPalette(x, y):
		fill(0)
		noStroke()
		#rect(x, y, x+imgMax, y+20)
		for i in range(imgMax+1):
			c = imgPalette[imgMax - i][0]
			stroke(c)
			line(x+i, y, x+i, y+20)
		
		for i in range(imgMax+1):
			c = imgPalette[i][0]
			stroke(c)
			line(x+i, y+5, x+i, y+15)
		
	
	# prints the palette out to stdout
	def printPalette():
		for i in range(imgMax+1):
			c = imgPalette[i][0]
			print hex(c),
		print "\n\n"
	
	# getter methods
	def getHeight(): return self.imgHeight; 
	def getWidth() : return self.imgWidth; 
	def getPImage(): return self.pimg; 



