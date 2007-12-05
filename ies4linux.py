#!/usr/bin/env python

from Base.BaseGUI import *
import sys,os

"""On Mac, use pythonw"""
def reexec_with_pythonw():
	if sys.platform == 'darwin' and not sys.executable.endswith('MacOS/Python'):
		os.execvp('pythonw',['pythonw',__file__] + sys.argv[1:])
		
		
