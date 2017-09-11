mousePressed = False

def constrain(val, lo, hi):
	return min(hi, max(lo, val))

class HScrollbar:
	#int swidth, sheight;		# width and height of bar
	#int xpos, ypos;				 # x and y position of bar
	#float spos, newspos;		# x position of slider
	#int sposMin, sposMax;	 # max and min values of slider
	#int loose;							# how loose/heavy
	#boolean locked;				 # can we move?
	#color bgcolor;					# background color for the bar
	#float ratio
	#float loVal, hiVal;		 # the minimum and maximum computed values
	#int decimals;					 # number of significant digits after the decimal point
	#PFont font;						 # font to be used
	#float val;							# float value of scrollbar
	#String title;					 # scrollbar title to be drawn above
	#int lastKey;						# keypress processing variable

	def setup(self, xp, yp, sw, sh, l) :
		self.loVal = -1.0
		self.hiVal = 1.0
		self.decimals = 3
		#self.font = loadFont("CourierNew36.vlw")
		self.swidth = sw
		self.sheight = sh
		self.ratio = float(sw) / float(sw - sh)
		self.xpos = xp
		self.ypos = yp - self.sheight * 0.5
		self.spos = self.xpos + (self.swidth - self.sheight) * 0.5
		self.newspos = self.spos
		self.sposMin = self.xpos
		self.sposMax = self.xpos + self.swidth - self.sheight
		self.loose = l
		self.title = ""
	
	
	def __init__(self, xp, yp, title=None, lo=None, hi=None):
		self.setup(xp, yp, 90, 10, 1)
		if title:
			self.setTitle(title)
		if lo and hi:
			self.setScale(lo, hi)
	
	def __init__(self, xp, yp, title):
		self.setup(xp, yp, 90, 10, 1)
		self.setTitle(title)
	
	def setColor(self, bgc):
		self.bgcolor = bgc
	
	def setTitle(self, ti):
		self.title = ti
	
	# move the scrollbar to a new position
	def setPos(self, l):
		v = self.val
		self.xpos = l
		self.sposMin = self.xpos
		self.sposMax = self.xpos + self.swidth - self.sheight
		self.newspos = (self.sposMin + self.sposMax) / 2
		self.update()
		self.val = v
		self.display()
	
	# this is where the real work is done for computing its value
	def getReal(self):
		return 2.0 * (self.spos - self.xpos + (self.sheight * 0.5) - (self.swidth * 0.5)) / float(self.swidth-self.sheight)
	
	def setVal(self, r):
		if(self.loVal < self.hiVal) :
			self.val = constrain(r, self.loVal, self.hiVal)
		else :
			self.val = constrain(r, self.hiVal, self.loVal)
		
		r = 2.0 * ( self.val - self.loVal ) / ( self.hiVal - self.loVal ) - 1
		self.newspos = float(self.swidth-self.sheight) * 0.5 * r + self.xpos - (self.sheight / 2.0) + (self.swidth / 2.0)
		self.update()
	

	def getVal(self):
		#r = getReal()
		#return ((1 + r) / 2.0) * (hiVal-loVal) + loVal
		return self.val
	
	def setScale(self, lo, hi):
		self.loVal = lo
		self.hiVal = hi
		self.decimals = 3
	
	# integers don't have significant digits after the decimal point
	def setScale(self, lo, hi):
		self.loVal = lo
		self.hiVal = hi
		self.decimals = 0
	


	# let's update the scrollbar
	def update(self) :
		if mousePressed and self.over():
			self.locked = True
		
		if not mousePressed:
			self.locked = False
		
		if self.locked:
			self.newspos = constrain( (mouseX - sheight/2), self.sposMin, self.sposMax)
			r = getReal()
			val = ((1 + r) / 2.0) * (hiVal-loVal) + loVal
			#if(decimals == 0) val += (mouseY - ypos) * swidth / (float)(hiVal - loVal)
		
		if(abs(self.newspos - self.spos) > 1) :
			self.spos = self.spos + (self.newspos-self.spos) / self.loose
		
	
	# limit val to a value between and including minv and maxv
	#int constrain(int val, int minv, int maxv) :
	#	return min(max(val, minv), maxv)
	#

	# is the mouse currently over the scrollbar?
	def over(self):
		return mouseX > xpos and mouseX < xpos+swidth and mouseY > ypos and mouseY < ypos+sheight

	# draw the scrollbar to the display
	def display(self):
		fill(bgcolor)
		noStroke()
		rect(xpos, ypos, swidth, sheight)
		if self.over() or lself.ocked:
			fill(153, 102, 0)
			if not keyPressed:
				gv = getVal()
				if decimals == 0:
					sv = 1
				else:
					sv = 0.1
				if lastKey == RIGHT:
					self.setVal(gv + sv)
				elif lastKey == LEFT:
					self.setVal(gv - sv)
				
				lastKey = 0
			
				#update()
			#else :
			#	lastKey = keyCode
			#
			if(keyPressed):
				lastKey = keyCode
		else :
			fill = (102, 102, 102)
		
		rect(spos, ypos, sheight, sheight)
		
		#textFont(font, 12)
		fill = (0xcc, 0xcc, 0xcc)
		textAlign = 'CENTER'
		text(dc, title, ((sposMax + sposMin) / 2, ypos - 1), font, 1, (0,0,0), 2, cv2.LINE_AA )

		gv = self.getVal()
		if(self.getReal() < 0) :
			textAlign(LEFT)
			ofs = 10
		else :
			textAlign(RIGHT)
			ofs = 0
		
		
		fill = (255, 255, 255)
		gv *= pow(10, decimals)
		gvi = int(gv)
		gv = gvi / float(pow(10,decimals))
		text("" + gv, spos + ofs, ypos + 10)
	
	def display(self,c) :
		self.bgcolor = c
		self.display()
	

	def getPos(self):
		# Convert spos to be values between
		# 0 and the total width of the scrollbar
		return self.spos * self.ratio
	


