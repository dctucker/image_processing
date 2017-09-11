import cv2
from img import *
from gui import *
from program import HEIGHT, dc

class ImageOp(ImgData):   # we'll put all image operations as a subclass of ImageOp
	def __init__(self, img):
		self.imgWidth=None
		self.imgHeight=None
		self.imgChannels=None
		self.imgMax=None
		self.imgData=[]
		self.imgPalette=[]
		self.imgScale=1.0
		self.pimg=None
		self.title = "";						# default title to be drawn above panel
		self.updateme = True;			# do I really need to be redrawn?
		self.posLeft = 0;							# default left position for the panel
		self.posTop = 150;			 # how far from the bottom do we draw the panel's top?
		self.posWidth = 100; # how wide should each panel be?
		self.input = None				 # reference to our input image
		self.chBypass = [] # this keeps track of what channels should be affected by the op
		self.visible = None
		self.selected = None
		self.controls = []
		self.pimg = None

		ImgData.__init__(self, img)
		self.input = img
		self.chBypass = [False for ch in range(self.imgChannels)]
		self.updateme = True
		self.visible = False
		self.title = "Default Op"
	
	def __str__(self):
		return self.title

	def printOut(self):
		self.loadPImage(zoom)
		for ch in range(self.imgChannels):
			print "channel", ch
			for y in range(self.imgHeight):
				for x in range(self.imgWidth):
					print self.imgData[x][y][ch] + "\t",
				print
			print

	def printPal(self):
		self.loadPImage(zoom)
		for ch in range(self.imgChannels):
			for k in range(self.imgMax):
				print hex(self.imgPalette[k][ch], 6) + "\t",
			print

	def setBypass(self, b):					# set the bypass states for all channels
		chBypass = b
	
	def setBypass(self, ch, b):		# set the bypass for a given channel
		chBypass[ch] = b
	
	
	def toggleBypass(self, ch):				 # flip the bypass for a given channel
		self.chBypass[ch] = not self.chBypass[ch]
		return self.chBypass[ch]
	
	
	def getBypass(self, ch):						# should we touch this channel?
		return self.chBypass[ch]
	


	def computeScale(self):								# scale the image after operating
		for ch in range(imgChannels):
			imgLocalMin = self.imgMax
			imgLocalMax = 0
			for x in range(imgWidth):				 # find minimum and maximum values
				for y in range(imgHeight):
					#for ch in range(imgChannels):
					v = imgData[x][y][ch]
					if(v < imgLocalMin):
						imgLocalMin = v
					if(v > imgLocalMax):
						imgLocalMax = v
					#


		if(imgLocalMin < 0 or imgLocalMax > imgMax) : # only scale if we've exceeded bounds
			imgLocalScale = imgMax / (float)(imgLocalMax - imgLocalMin)
			# now we want to apply the scale
			for x in range(imgWidth):
				for y in range(imgHeight):
					#for(ch=0; ch < imgChannels; ch++):
					v = self.imgData[x][y][ch]
					self.imgData[x][y][ch] = int((v - imgLocalMin) * imgLocalScale)
					#
				
			
		
	
	
	
	def compute(self): # this one can be overridden if necessary
		for x in range(imgWidth):				 # find minimum and maximum values
			for y in range(imgHeight):
				for ch in range(imgChannels):
					if not chBypass[ch]:
						self.imgData[x][y][ch] = calc(x,y,ch)

		self.updateme = False
		return self
	
	def drawBox(self): # draw the box for the panel
		font = cv2.FONT_HERSHEY_SIMPLEX
		if self.selected:
			fill = (0x66, 0x55, 0x44)
		else:
			fill = (0x33, 0x33, 0x33)
		
		stroke = (0x00, 0xcc, 0xcc)
		cv2.rectangle(dc, (self.posLeft, HEIGHT-self.posTop), (self.posWidth - 2, self.posTop), fill, -1 )
		cv2.rectangle(dc, (self.posLeft, HEIGHT-self.posTop), (self.posWidth - 2, self.posTop), stroke, 1 )
		textAlign = 'CENTER'
		fill = (0x00, 0xcc, 0xcc)
		cv2.rectangle(dc, (self.posLeft, HEIGHT-self.posTop), (self.posWidth - 2, 9), fill, -1)
		fill = (0, 0, 0)
		cv2.putText(dc, self.title, ((self.posLeft + self.posLeft + self.posWidth) / 2, HEIGHT - self.posTop + 9), font, 1, fill, cv2.LINE_AA )
	
	def loadPImage(self, zoom=None):								 # loads the image for onscreen display
		self.pimg = ImgData.loadPImage(self, zoom)
		updateme = False
		return self.pimg
	

	def drawOperator(self, operation):
		textSize(24)
		fill('#666633')
		for i in range(3):
			for j in range(3):
				text( operation, i + self.posLeft + posWidth / 2, j + HEIGHT - posTop + posTop / 2)
			
		
		fill('#dddddd')
		text( operation, 1 + self.posLeft + posWidth / 2,
										 1 + HEIGHT - posTop + posTop / 2)
	
	def drawOperator(self, op):
		drawOperator(op.charAt(0))
	


	# METHODS TO BE OVERRIDDEN BY CHILD CLASS:		
	def calc(x, y, ch):			# main calculation for each pixel
		return self.input.imgData[x][y][ch]
	
	def display(self):
		self.drawBox(); 				 # draw the control panel
	def update(self):
		return self.updateme;  # update self
	def setPos(self,l):
		self.posLeft = l; 	# reposition panel controls


class ImgOpPalette(ImageOp):
	def __init__(self, img, fn=None):
		ImageOp.__init__(self, img)
		self.setupScrollbars()
		self.updateme = True
		self.title = "Palette"
		self.hsr1 = None
		self.hsg1 = None
		self.hsb1 = None
		self.r=0.0
		self.g=0.0
		self.b=0.0
		if fn is not None:
			#this.in = img
			self.copyFrom(img)
			self.title = fn
			#compute()
	
	def display(self):
		ImageOp.display(self)
		
		# draw the palette scrollbars
		if self.hsr1:
			self.hsr1.display()
			self.hsg1.display()
			self.hsb1.display()

	def setPos(self,l):
		super.setPos(l)
		if self.hsr1:
			hsr1.setPos(l+5)
			hsg1.setPos(l+5)
			hsb1.setPos(l+5)
	
	def update(self):
		r1 = self.r
		g1 = self.g
		b1 = self.b
		if self.hsr1:
			self.hsr1.update()
			self.hsg1.update()
			self.hsb1.update()
			self.r = hsr1.getVal()
			self.g = hsg1.getVal()
			self.b = hsb1.getVal()
		
		if self.r != r1 or self.g != g1 or self.b != b1:
			self.doPalette()
			return True
		
		return False
	
	def doPalette(self):		 # deal with the palette scrollbars and redraw if needed
		setPalette(r,g,b)
		self.pimg = self.loadPImage(zoom); 
		#drawPalette((width - img.imgMax)/2, HEIGHT -190)
	

	def setupScrollbars(self):
		global HEIGHT
		self.hsr1 = HScrollbar(5 + self.posLeft, HEIGHT - self.posTop + 35, "Red")
		self.hsg1 = HScrollbar(5 + self.posLeft, HEIGHT - self.posTop + 60, "Green")
		self.hsb1 = HScrollbar(5 + self.posLeft, HEIGHT - self.posTop + 85, "Blue")
		self.hsr1.setColor((128,32,32))
		self.hsg1.setColor((32,96,32))
		self.hsb1.setColor((32,32,128))
		self.hsr1.setVal(1.0)
		self.hsg1.setVal(1.0)
		self.hsb1.setVal(1.0)
	



# gamma operation
class ImgOpGamma(ImageOp):
	def __init__(img):
		super(ImgOpGamma, self).__init__(img)
		self.title = "Gamma"
		self.hGamma  = HScrollbar(self.posLeft + 5, HEIGHT - self.posTop + 100, "Gamma",   0.1, 4.0)
		self.hOffset = HScrollbar(self.posLeft + 5, HEIGHT - self.posTop + 120, "Offset", -0.5, 0.5)
		
		self.hGamma.setVal(1.0)
		self.hOffset.setVal(0.0)

		self.hGamma.setColor(color(32,32,32))
		self.hOffset.setColor(color(64,64,64))
		self.updateme = true
	
	def __init__(img, h, o):
		super(ImgOpGamma, self).__init__(img)
		self.title = "Gamma"
		#self.gamma = h
		#self.offset = o
		self.hGamma =	HScrollbar(self.posLeft + 5, HEIGHT - posTop + 100, "Gamma",	 0.1, 5.0)
		self.hOffset = HScrollbar(self.posLeft + 5, HEIGHT - posTop + 120, "Offset", -0.5, 0.5)
		self.hGamma.setVal(h)
		self.hOffset.setVal(o)
		self.hGamma.setColor(color(32,32,32))
		self.hOffset.setColor(color(64,64,64))
		self.updateme = true
	

	def setPos(l):
		super.setPos(l)
		hGamma.setPos(l + 5)
		hOffset.setPos(l + 5)
	
	def calc(x, y, ch):
		return (int)( pow(offset + self.input.imgData[x][y][ch], gamma) )
	

	def display():
		super.display(); #drawBox()
		#if(updateme) :
		drawGraph()
		hGamma.display()
		hOffset.display()
		#
	
	def drawGraph():	 # draws the gamma curve
		global HEIGHT, WIDTH
		stroke = (0x88, 0x88, 0x88)
		fill = (0,0,0)
		cv2.rectangle(dc, (15 + self.posLeft, HEIGHT - posTop + 10), ( 15 + self.posLeft + 64, HEIGHT - posTop + 10 + 64), fill, -1)
		cv2.rectangle(dc, (15 + self.posLeft, HEIGHT - posTop + 10), ( 15 + self.posLeft + 64, HEIGHT - posTop + 10 + 64), stroke, 1)
		stroke = (0x66, 0x22, 0x22)
		cv2.line(dc, (15 + self.posLeft, HEIGHT - posTop + 10 + 64), (15 + self.posLeft+64, HEIGHT-posTop + 10), stroke)
		stroke = (0xcc, 0xcc, 0xcc)
		for p in range(100):
			i = p * 0.01
			v = pow(offset + i, gamma)
			px = int(self.posLeft + 15 + 64*i)
			py = int(HEIGHT - posTop + 10 + 64 - constrain(64*v, 0,64))
			dc[py, px] = stroke
		
	
	def update():
		hGamma.update()
		hOffset.update()
		g = hGamma.getVal()
		o = hOffset.getVal()
		#updateme = False

		if(self.gamma != g):
			self.gamma = g
			self.updateme = true
		
		if(offset != o):
			offset = o
			self.updateme = true
		
		return self.updateme
	


class ImgOpInvLog(ImgOpGamma):
	hFactor = None #, hOffset;	 # scrollbars for gamma and epsilon
	factor = None #/ , offset;		 # parameters from scrollbars
	def __init__(img):
		super(img)
		self.title = "log??"
		self.gamma = 1.0
		self.offset = 0.0
		self.hFactor = HScrollbar(self.posLeft + 5, HEIGHT - posTop + 100, "Factor", 0.1, 5.0)
		#hOffset = HScrollbar(self.posLeft + 5, HEIGHT - posTop + 120, "Offset")
		
		self.hFactor.setVal(1.0)

		self.hFactor.setColor(color(32,32,32))
		#hOffset.setColor(color(64,64,64))
	
	def setPos(l):
		hGamma.setPos(l + 5)
		hOffset.setPos(l + 5)
		self.posLeft = l
	
	def calc(x, y, ch):
		v = self.input.imgData[x][y][ch] / float(imgMax)
		return (int)(constrain( imgMax * pow(offset + v, gamma), 0, 255) )
	
	def display():
		ImgOpGamma.display(self); #drawBox()
		#if(updateme) :
		self.drawGraph()
		self.hGamma.display()
		self.hOffset.display()
		#
	
	def drawGraph():	 # draws the gamma curve
		stroke = (0x88, 0x88, 0x88)
		fill = (0,0,0)
		cv2.rectangle(dc, (15 + self.posLeft, HEIGHT - posTop + 10), (15 + posLeft + 64, HEIGHT - posTop + 64), fill, -1)
		cv2.rectangle(dc, (15 + self.posLeft, HEIGHT - posTop + 10), (15 + posLeft + 64, HEIGHT - posTop + 64), stroke, 1)
		stroke = (0x66, 0x22, 0x22)
		cv2.line(dc, (15 + self.posLeft, HEIGHT - posTop + 10 + 64), (15 + self.posLeft+64, HEIGHT-posTop + 10), stroke, 1)
		stroke = (0xcc, 0xcc, 0xcc)
		for p in range(100):
			i = p * 0.01
			v = factor * exp(i)
			px = int(self.posLeft + 15 + 64*i)
			py = int(HEIGHT - posTop + 10 + 64 - constrain(64*v, 0,64))
			dc[py, px] = stroke;			
		
	
	def update():
		hFactor.update()
		f = hFactor.getVal()
		self.updateme = False

		if(factor != f):
			factor = f
			self.updateme = true
		
		return self.updateme
	

