# D. Casey Tucker

from op import *
import cv2
import numpy as np

HEIGHT = 700
WIDTH  = 1000

dc = None
img = None
img2 = None						 # our source PGM image
add = None
sub = None
mul = None
div = None		# for assignment 3
chain = []								 # structure to link image operations together
chainLeft=0					 # left pixel location of our first image op panel
chainPalette=0				# draw this ImageOp's palette on screen
dispimg = None							 # the main displayed image
dispWidth = None
dispHeight = None # width/height of the image display area
cmdHeight = 30
posHeight = 550
font = None
zoom = 8
extraWidth = 0
selChain = 0
cmd = ""


assignment = 5

def image(img,left=0,top=0):
	global dc
	dc[ top:top+img.shape[0], left:left+img.shape[1] ] = img
	cv2.imshow('main', dc)


def getChainID(ch):
	for c in chain:
		if c == ch:
			return i
	return -1

def printChain():
	global chain
	i=0
	for c in chain:
		pid = getChainID(c.input)
		parent = ""
		if pid != -1:
			parent = " " + pid + ": " + c.input
		print str(i) +": "+ c + parent
		i += 1

def drawConnectors(i, pid):
	kw = 6
	kh = 3

	if pid == -1:
		return

	x1 = chain[i].posLeft + kw
	x2 = chain[pid].posLeft + chain[pid].posWidth - (kh * (i - pid)) - kw
	x3 = x1
	y = HEIGHT - chain[0].posTop - (kh * (i - pid))
	y1 = HEIGHT - chain[0].posTop - kh
	
	while get(x2, y) == '#ffff00':
		y -= kh

	while get(x1, y1) == '#ffff00':
		x1 += kw

	#x1 = x3
	
	stroke('#000000')
	
	line(x1-1, y, x1-1, HEIGHT - chain[0].posTop)
	line(x1+1, y, x1+1, HEIGHT - chain[0].posTop)
	line(x2-1, y, x2-1, HEIGHT - chain[0].posTop)
	line(x2+1, y, x2+1, HEIGHT - chain[0].posTop)
	line(x1, y-1, x2, y-1)
	line(x1, y+1, x2, y+1)
	
	stroke('#ffff00')
	line(x1, y, x2, y)
	line(x1, y, x1, HEIGHT - chain[0].posTop)
	line(x2, y, x2, HEIGHT - chain[0].posTop)
	
	"""
	stroke('#ff00ff')
	fill('#ff00ff')
	point(x1,y1);#, 2, 2)
	"""

def drawChain():
	form = []
	kw = 6
	kh = 3

	cv2.rectangle(dc, (0, HEIGHT - chain[0].posTop - cmdHeight), ( WIDTH, cmdHeight), (0,0,0), -1)
	formula = ""

	cv2.rectangle(dc, (200, 0), (WIDTH - 200, HEIGHT - chain[0].posTop), (0,0,0), -1)
	textSize=10
	
	for i in range(len(chain)):
		curF0 = str(chain[i])
		
		formula += chr(ord('a') + i) + " = "
		if i == 0:
			formula += curF0
		elif isinstance(chain[i], ImgOpArith):
			pid1 = getChainID(chain[i].input1)
			pid2 = getChainID(chain[i].input2)
			"""
			if(pid2 < pid1):
				pid3 = pid1
				pid1 = pid2
				pid2 = pid3
			
			"""
			drawConnectors(i, pid1)
			drawConnectors(i, pid2)

			curOp = chain[i].operation
			curF1 = form[pid1]
			curF2 = form[pid2]
			curF1 = "" + (char)('a' + pid1); #((ImgOpArith)chain[i]).input1.toString()
			curF2 = "" + (char)('a' + pid2); #((ImgOpArith)chain[i]).input2.toString()

			formula += "( " + curF1 + " " +curOp + " "+ curF2 + " )"
		
		else:
			pid = getChainID(chain[i].input)
			drawConnectors(i, pid)

			curF1 = form[pid]
			curF1 = "" + (char)('a' + pid)
			formula += curF0 + "( " + curF1 + " )"

		
		#formula += ";"

		font=cv2.FONT_HERSHEY_SIMPLEX
		cv2.putText(dc, formula, (WIDTH - 200, 20 + i * 12), font, 1, (255,255,255), cv2.LINE_AA)
		#print(formula)
		form += [formula]
		formula = ""
	


def appendChain(iop): 
	#System.out.print("Appended to chain: " + iop)
	#chainLeft += chain[chain.length-1].posWidth
	chainLeft = chain[chain.length - 1].posWidth + chain[chain.length - 1].posLeft
	iop.setPos(chainLeft)
	iop.update()

	chain += [ iop ]


def removeChain(ch):
	#chain = (ImageOp[]) subset(chain, ch, 1)
	chainLeft -= chain[ch].posWidth
	for i in range(ch, len(chain)-1):
		chain[i+1].posLeft -= chain[i].posWidth
		chain[i] = chain[i+1]
	
	del(chain[-1])
	fill('#000000')
	stroke('#000000')
	rect(0, chain[0].imgHeight, WIDTH, HEIGHT)



def updateChain():
	ret = False
	for op in range(len(chain)):
		if( chain[op].update() ): # if our panels have been tweaked, recompute.
			chain[op].compute()
			#print("updating " + op)
			if chain[op].visible:
				chain[op].loadPImage(zoom)
			ret = true
		
	
	return ret





def drawCmd():
	fill = (0,0,0)
	stroke = (0,0,0)
	#rect(0, dispimg.height, WIDTH, cmdHeight)
	fill = (0xcc, 0xcc, 0xcc)
	textAlign = 'LEFT'
	textSize = 12
	font = cv2.FONT_HERSHEY_SIMPLEX
	cv2.putText(dc, "> " + cmd, (5, HEIGHT - posHeight - 15), font, 1, stroke, 2, cv2.LINE_AA)


def dispChain(i):
	global dispimg, dispWidth, dispHeight
	fill = (0,0,0)
	cv2.rectangle(dc, (0,0), (dispWidth, dispHeight), fill, -1)

	if(i < chain.length):
		for ch in range(len(chain)):
			chain[ch].selected = False
		
		dispimg = chain[i].pimg
		chain[i].selected = true
		image(dispimg,0,0)
	


def mousePressed():
	loop()

def mouseReleased():
	draw()

cmd=""

smd = []
def hasElem(k, sk=None):
	if sk == None:
		if len(smd) > k:
			return smd[k]
		return ""
	else:
		if len(smd) > k:
			if(smd[k].equals(sk)):
				return true
		return False

def connectChain(iop):
	appendChain(iop)
	chain[chain.length-1].updateme = true
	chain[chain.length-1].visible = true
	#chain[chain.length-1].imgPalette = chain[chain.length - 2].imgPalette
	if chain[chain.length-1].imgChannels == chain[chain.length-1].input.imgChannels:
		#chain[chain.length -1].copyPalette(chain[chain.length - 2])
		chain[chain.length-1].copyPalette(chain[chain.length-1].input)


CWD = "/Users/casey/Development/image_processing/LoadPGM/data/"

def ls(path):
	#if(path.equals(""))
	f = File(path)
	d = f.listFiles()
	if d is not None:
		for i in range(len(d)):
			dn = d[i].getName()
			if(d[i].isDirectory()) :
				print (dn + "/")
			else :
				print (dn)
			
		
	





def LF():
	f = File(CWD+"proj/test")
	d = f.listFiles()
	if d is not None:
		dn = ""
		while True:
			i = int( random(0, d.length - 1) )
			dn = CWD + "proj/test/" + d[i].getName() 
			print ("" + i + ":" +dn)
			if d[i].isDirectory() and d[i].getName().startswith("."):
				break
		return dn

	return ""


class EyeDef :
	def __init__(s):
		k = s.split(" ")
		self.filename = k[0]
		self.lx = int( k[1] )
		self.ly = int( k[2] )
		self.rx = int( k[3] )
		self.ry = int( k[4] )

edef = []
eyei = 0

def LE():
	img = null
	if(edef == null):
		#String[] s = loadStrings(CWD+"proj/training/training.txt")
		s = loadStrings(CWD+"proj/test/test.txt")
		edef = []
		for i in range(len(s)):
			edef[i] = EyeDef(s[i])
		eyei=-1

	eyei += 1
	eyei %= edef.length
	#setupChain( "proj/training/" + edef[eyei].filename )
	setupChain( "proj/test/" + edef[eyei].filename )
	connectChain( ImgOpGamma    ( chain[ 0 ], 1.4, 0.0 ) )
	connectChain( ImgOpScale    ( chain[ 1 ] ) )
	connectChain( ImgOpSobel    ( chain[ 0+2 ] ) )
	connectChain( ImgOp5x5      ( chain[ 1+2 ] ) )
	connectChain( ImgOpGamma    ( chain[ 2+2 ], 1.4, 0.0 ) )
	connectChain( ImgOpScale    ( chain[ 3+2 ] ) )
	connectChain( ImgEyeCrop    ( chain[ 4+2 ] ) )
	connectChain( ImgOpRowSum   ( chain[ 5+2 ] ) )
	connectChain( ImgOpHistEq   ( chain[ 6+2 ] ) )
	connectChain( ImgEyeCrop2   ( chain[ 7+2 ], chain[ 7 ] ) )
	connectChain( ImgOpSumXY    ( chain[ 8+2 ] ) )
	connectChain( ImgEyeFinder2 ( chain[ 9+2 ] ) )

	return eyei

	"""
		#connectChain( ImgOpBitPlane	 ( chain[ 0 ], 7 )	)
		#connectChain( ImgOpBitPlane	 ( chain[ 0 ], 6 )	)

		#connectChain( ImgOpRowSum		 ( chain[ 5+2 ] )	)
		#connectChain( ImgOpHalfRowSum ( chain[ 5+2 ] )	)
		#connectChain( ImgOpColSum		 ( chain[ 5+2 ] )	)
		#
		#connectChain(ImgOpScale(chain[2] ))
		#connectChain(ImgOpHistEq(chain[3] ))
		#
		#connectChain(ImgEyeMask( chain[2], edef[eyei].lx, edef[eyei].ly ) )
		#connectChain(ImgOpScale( chain[2] ) )
		#setupChain( LF() )
	"""

def execCmd():
	global cmd
	smd = cmd.split(" ")

	if cmd == "q":
		sys.exit()
	elif( hasElem(0, "l") ):
		#img = null
		#setupChain(hasElem(1))
		fn = hasElem(1)
		loadimg = PGMImage(fn); 
		appendChain( ImgOpPalette(loadimg, fn) )
	elif( hasElem(0, "L") ):
		img = null
		setupChain(hasElem(1))
	elif( hasElem(0, "LF") ):
		img = null
		setupChain( LF() )
		nextChain()
	elif( hasElem(0, "LE") ):
		LE();		
	elif( hasElem(0, "LEA") ):
		r = 0
		while True:
			r = LE()
			ef = chain[chain.length-1]
			filename = chain[0].title
			updateChain()
			print ( filename + "\t" + ef.eyelx + "\t" + ef.eyely + "\t" + ef.eyerx + "\t" + ef.eyery )

			if r != edef.length -1:
				break
	elif( hasElem(0, "d") ):
		i = int(hasElem(1))
		dispChain(i)
	elif( hasElem(0, "a") ):
		p1 = int(hasElem(3)); 
		ch = int(hasElem(1))
		op = hasElem(2)
		if( ch == 0 ) :
			op = hasElem(1)
			ch = selChain
			p1 = int(hasElem(2))
		
		
		if op == "hist":
			appendChain(ImgOpHist(chain[ch]))
			chain[chain.length - 1].updateme=true
		elif op == "nhist":
			appendChain(ImgNoiseHist(chain[ch]))
			chain[chain.length - 1].updateme=true
		elif op in ('+','-','*','/'):
			ch1 = ch
			ch2 = int(hasElem(3))
			if ch2 == 0:
				ch2 = int(hasElem(2))
			connectChain(ImgOpArith(chain[ch1], chain[ch2], op.charAt(0) ))
		elif(op == "neg"):
			connectChain(ImgOpNegate(chain[ch]))
		elif(op == "gamma"):
			pf1 = float(hasElem(2))
			pf2 = float(hasElem(3))
			connectChain(ImgOpGamma(chain[ch], pf1, pf2))
		elif(op == "thresh"):
			connectChain(ImgOpThreshold ( chain[ch], p1 ) )
		elif op == "equal":
			connectChain(ImgOpHistEq(chain[ch]))
		elif(op == "filter"):
			connectChain(ImgOpFilter(chain[ch]))
		elif(op == "sharp"):
			connectChain(ImgOpSharp(chain[ch]))
		elif(op == "median"):
			connectChain(ImgOpMedian(chain[ch]))
		elif(op == "laplace"):
			filt = int(hasElem(2))
			connectChain(ImgOpLaplacian(chain[ch], filt))
		elif(op == "sobel"):
			connectChain(ImgOpSobel(chain[ch]))
		elif(op == "prewitt"):
			connectChain(ImgOpPrewitt(chain[ch]))
		elif(op == "5x5"):
			connectChain(ImgOp5x5(chain[ch]))
		elif(op == "gauss"):
			pf2 = float(hasElem(3))
			if(p1 == 0):
				connectChain(ImgOpGaussian(chain[ch]))
			else:
				connectChain(ImgOpGaussian(chain[ch], p1, pf2))
			
		elif(op == "scale"):
			connectChain(ImgOpScale(chain[ch]))
		elif(op == "clip"):
			connectChain(ImgOpClip(chain[ch]))
		elif(op == "ch"):
			connectChain(ImgOpChannel(chain[ch], p1))
		elif(op == "hsi"):
			connectChain(ImgOpRGBtoHSI(chain[ch]))
		elif(op == "rgb"):
			connectChain(ImgOpHSItoRGB(chain[ch]))
		elif(op == "dft"):
			connectChain(ImgOpDFT4(chain[ch]))
		elif(op == "edgelocal"):
			connectChain(ImgOpEdgeLocal(chain[ch]))
		elif(op == "hgap"):
			connectChain(ImgOpHGap(chain[ch]))
		elif(op == "vgap"):
			connectChain(ImgOpVGap(chain[ch]))
		elif(op == "athresh"):
			p2 = int(hasElem(3))
			connectChain(ImgOpAThresh(chain[ch], p1, p2))
		elif(op == "gthresh"):
			connectChain(ImgSegGThresh(chain[ch]))
		elif(op == "gmean"):
			connectChain(ImgOpGMean(chain[ch]))
		elif(op == "amean"):
			connectChain(ImgOpAMean(chain[ch]))
		elif(op == "eye"):
			connectChain(ImgEyeFinder2(chain[ch]))
		elif(op == "rowsum"):
			connectChain(ImgOpRowSum(chain[ch]))
		elif(op == "colsum"):
			connectChain(ImgOpColSum(chain[ch]))
		elif(op == "eyecrop"):
			connectChain(ImgEyeCrop(chain[ch]))
		elif(op == "sumxy"):
			connectChain(ImgOpSumXY(chain[ch]))

	elif( hasElem(0, "r") ):
		i = int(hasElem(1))
		if i == 0:
			i = selChain
		removeChain(i)
		selChain -= 1
		dispChain(selChain)
	elif( hasElem(0, "E") ):
		connectChain(ImgOpSubst( chain[int(hasElem(2))], chain[selChain], int(hasElem(1)) ))
	elif( hasElem(0, "e") ):
		connectChain(ImgOpChannel(chain[selChain], int(hasElem(1)) ) )
	elif( hasElem(0, "b") ):
		if(hasElem(1, "x")):
			im = chain[selChain].imgMax
			np = int( log(im) / log(2) )
			for plane in range(np, 0, -1):
				connectChain(ImgOpBitPlane( chain[selChain], plane ) )
			
		else:
			connectChain(ImgOpBitPlane( chain[selChain], int(hasElem(1)) ) )
		
	elif( hasElem(0, "B") ):
		connectChain(ImgOpBitSubst( chain[int(hasElem(2))], chain[selChain], int(hasElem(1)) ) )
	elif( hasElem(0, "c") ):
		chain[selChain].compute()
		chain[selChain].loadPImage(zoom)
	elif( hasElem(0, "z" ) ):
		zoom = constrain( int(hasElem(1)), 1, 8 )
	elif( hasElem(0, "ls") ):
		ls(CWD + hasElem(1))
	elif( hasElem(0, "p" ) ):
		chain[selChain].printOut()
	elif( hasElem(0, "pp" ) ):
		chain[selChain].printPal()
	elif( hasElem(0, "macro") or hasElem(0, "M") ):
		macro = ""
		param = int( hasElem(1) )
		if param == 1:
			macro = "a laplace 2;];a + 0;[;a sobel;]]];a 5x5;];a * 2;];a + 0;];a scale;];a gamma 0.4 -0.1"
		elif param == 2:
			macro = "a bitplane 7;];a gamma 0.4 0.0;];a + 0;];a sobel;];a * 3;];a / 0;];a scale;];a gamma 0.4 0.0"
		elif param == 3:
			macro = "a bitplane 7;a bitplane 6;a bitplane 5;a bitplane 4;a bitplane 3;a bitplane 2;a bitplane 1;a bitplane 0"
		elif param == 4:
			macro = "a bitplane 7;a bitplane 6;]];a gamma 1.0 -0.5;];a + 1;];[[[[;a - 4;]]]]];a clip;[[[[[;a - 6;a * 7;]]]]]]]];a scale;]"
		elif param == 5:
			macro = "a hist;a gamma 0.4 0.0;]];a hist;[[;a equal;]]]];a hist"
		elif param == 23:
			macro = "L truck_rear.pgm;];a edgelocal;];a athresh 70 30;];e 0;e 1;];a hgap;];a vgap;]];a + 5"
		elif param == 24:
			macro = "L fingerprint.pgm;];a hist;a gthresh"
		elif param == 25:
			macro = "L noise.pgm;];a nhist"
		elif param == 26:
			macro = "L noisy.pgm;];a gmean;a amean"
		else:
			macro = ""
		
		execMacro(macro)
	
	
	elif( cmd.startswith("assignment ") ):
		assignment = Integer.parseInt(smd[1])
		img = null
		setup()
	
	
	elif( cmd.startswith("[") ):
		for i in range(len(cmd), 0, -1):
			prevChain()
		
	elif( cmd.startswith("]") ):
		for i in range(len(cmd), 0, -1):
			nextChain()
		
	
	

def execMacro(macro):
	cmds = split(macro, ";")
	for i in range(len(cmds)):
		cmd = cmds[i]
		execCmd()
	


def nextChain():
	if(selChain < chain.length - 1):
		selChain += 1
	dispChain(selChain)

def prevChain():
	if(selChain > 0):
		selChain -= 1
	dispChain(selChain)


def keyPressed(keyCode):
	global cmd
	if keyCode == "\0":
		return
	if keyCode == "\b":
		if len(cmd) > 0:
			cmd = cmd[0:-1]
	elif keyCode in ("\n","\r"):
		execCmd()
	elif keyCode == '[':
		prevChain()
	elif keyCode == ']':
		nextChain()
	else:
		cmd += keyCode
		drawCmd()
	print cmd

def keyReleased():
	draw()

def draw():
	global dispimg, chain
	updChain = updateChain()

	if assignment == 2:
		drawAssignment2()
	elif assignment == 3:
		drawAssignment3()
	elif assignment == 4:
		drawAssignment4()
	else:
		image(dispimg,0,0) # display the final image
	
	#if(updChain) :
	#	chain[chainPalette] . drawPalette( 20, img.imgHeight + 4)

	drawChain()
	for op in range(len(chain)): # draw each op's control panel
		chain[op].display()
	
	drawCmd()

def setupChain(filename):
	global img, chain
	#size(extraWidth + constrain(zoom * img.getWidth(), 400, 1024)	, 
	#		 zoom * img.getHeight() + 220 )
	chain = [None] # a nop to begin with

	if img is None:
		img = ImgData(cv2.imread('LoadPGM/data/'+filename))
		chain[0] = ImgOpPalette(img, filename)

	zoom = 1
	while chain[0].imgHeight * zoom < HEIGHT / zoom:
		#print (""+ (chain[0].imgHeight * zoom) +" < "+ (HEIGHT / zoom))
		zoom += 1
	
	zoom -= 1
	#print ("Zoom set to " + zoom ) 


def setup() :
	global dc, chain, dispimg
	cv2.namedWindow('main')
	dc = np.zeros((700,1100,3), np.uint8)

	#font = createFont("Lucida Sans Unicode", 11)
	#textFont(font, 12)
	
	if assignment == 1:
		setupAssignment1()
	elif assignment == 2:
		setupAssignment2()
	elif assignment == 3:
		setupAssignment3()
	elif assignment == 4:
		setupAssignment4()
	else:
		setupChain("truck_rear.pgm")
	

	posHeight = chain[0].posTop
	dispWidth = WIDTH
	dispHeight = HEIGHT - posHeight - cmdHeight

	print str(dispWidth) + "x" + str(dispHeight)
	for op in range(1,len(chain)): # compute each op
		chain[op].compute()
		chain[op].loadPImage(zoom)
	

	dispimg = chain[0].loadPImage(zoom)

	#printChain()
	draw()

if __name__ == '__main__':
	setup()
	draw()

	while True:
		key = cv2.waitKey(1) & 0xff
		if key == ord('q'):
			break
		elif key <= 127:
			keyPressed(chr(key))
		draw()

	cv2.destroyAllWindows()

