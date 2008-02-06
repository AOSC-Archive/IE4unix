import wx

_width = 376
_height = 400

# wxPython GUI implementation
class GUI:

	def __init__(self):
		self.checkboxes = []
		self.comboboxes = []
		self.textfields = []
		
	def doInstaller(self, model):
		self.model = model
		self.app = wx.App()
		
		# Create Window
		self.window = wx.Frame(None, title=model.title, size=(_width, _height), style=wx.DEFAULT_FRAME_STYLE & ~ (wx.MINIMIZE_BOX | wx.RESIZE_BOX | wx.MAXIMIZE_BOX |wx.RESIZE_BORDER))
		window_box = wx.BoxSizer(wx.VERTICAL)
		self.window.SetSizer(window_box)
		
		# Add logo
		logoBitmap = wx.Image(model.logo, wx.BITMAP_TYPE_PNG).ConvertToBitmap()
		logo = wx.StaticBitmap(self.window, -1, logoBitmap)
		window_box.Add(logo, 0, wx.CENTER, border=5)
	
		# Notebook
		notebook = wx.Notebook(self.window)
		window_box.Add(notebook, 10, wx.EXPAND)

		# Create tabs
		for tab in model.tabs:
			t = wx.Panel(notebook)
			notebook.AddPage(t, tab.label)
			self._do_tab(t, tab)
	
		#Add buttons
		but_box = wx.BoxSizer(wx.HORIZONTAL)
		window_box.Add(but_box, 1, wx.EXPAND)
		for button in model.buttons:
			but = wx.Button(self.window, label=button.label)
			but.pmodel = button
			but.Bind(wx.EVT_BUTTON, self.callback_button)
			but_box.Add(but, 1, wx.EXPAND)
	
		# Show everything
		self.window.Centre()
		self.window.Show()
		self.app.MainLoop()

	# Configure one tab
	def _do_tab(self, container, tab):
		# Create box
		box = wx.BoxSizer(wx.VERTICAL)
		container.SetSizer(box)

		# Add text
		if hasattr(tab, 'text'):
			txt = wx.StaticText(container, -1, tab.text)
			box.Add(txt, 0)

		# Add groups
		for group in tab.groups:
			# the panel for the group
			panel = wx.Panel(container)
			box.Add(panel, 0, wx.EXPAND)
		
			# the group and the sizer
			g = wx.StaticBox(panel, -1, group.label)
			vbox = wx.StaticBoxSizer(g, wx.VERTICAL)

			# checkboxes orientation
			if group.orientation == 'horizontal':
				cb_box = wx.BoxSizer(wx.HORIZONTAL)
			else:
				cb_box = wx.BoxSizer(wx.VERTICAL)
			vbox.Add(cb_box)
		
			# add checkboxes
			for checkbox in group.checkboxes:
				cb = wx.CheckBox(panel, -1, checkbox.label)
				cb.SetValue(checkbox.checked)
				cb_box.Add(cb)
			
				cb.pmodel = checkbox
				self.checkboxes.append(cb)

			# Add comboboxes
			for combo in group.comboboxes:
				l = wx.StaticText(panel, -1, combo.label)
				c = wx.ComboBox(panel, -1, value=combo.selected, choices=combo.options, style=wx.CB_READONLY)
			
				cbox = wx.BoxSizer(wx.HORIZONTAL)
				vbox.Add(cbox)
				cbox.Add(l, 0, wx.RIGHT | wx.ALIGN_CENTER_VERTICAL, 4)
				cbox.Add(c, 1)
			
				c.pmodel = combo
				self.comboboxes.append(c)

			# Add TextFields
			# TODO make expandable and dynamic textfields
			textfield_width = 70
			for textfield in group.textfields:
				l = wx.StaticText(panel, -1, textfield.label, size=(textfield_width,25))
				t = wx.TextCtrl(panel, -1, textfield.value, size=(_width-textfield_width-20, 25))

				cbox = wx.BoxSizer(wx.HORIZONTAL)
				vbox.Add(cbox)
				cbox.Add(l, 0, wx.RIGHT | wx.ALIGN_CENTER_VERTICAL, 2)
				cbox.Add(t, 1, wx.EXPAND)
			
				t.pmodel = textfield
				self.textfields.append(t)

			# extra config
			panel.SetAutoLayout(True)
			panel.SetSizer(vbox)
			vbox.Fit(panel)
			vbox.SetSizeHints(panel)
		#/doGroups		

	# Response functions
	def callback_button(self, event):
		self.update_model()
		button = event.GetEventObject()
		button.pmodel.callback()

	# Iterate over components and update model	
	def update_model(self):
		for c in self.checkboxes:
			c.pmodel.checked = c.GetValue()
		for c in self.comboboxes:
			c.pmodel.selected = c.GetValue()
		for t in self.textfields:
			t.pmodel.value = t.GetValue()

	def quit(self):
		#TODO this
		print 'TODO wx quit'
		
	## EXECUTOR
	def doExecutor(self, e):
		self.window.Hide()
		
		# Create Window
		self.window = wx.Frame(None, title=e.title, size=(400, 450))
		window_box = wx.BoxSizer(wx.VERTICAL)
		self.window.SetSizer(window_box)
		
		# Add logo
		logoBitmap = wx.Image(e.logo, wx.BITMAP_TYPE_PNG).ConvertToBitmap()
		logo = wx.StaticBitmap(self.window, -1, logoBitmap)
		window_box.Add(logo, 0, wx.CENTER, border=5)

		# Console control variables
		self.remove_next_line = False
		self.last_line_position = -1

		# Add console
		self.console = wx.TextCtrl(self.window, -1, size=(self.window.GetSize()[0] -4, 100) , style=wx.TE_MULTILINE|wx.TE_READONLY| wx.HSCROLL |wx.TE_PROCESS_ENTER | wx.TE_RICH2)
		window_box.Add(self.console, 12, wx.CENTER, border=5)

		#Add buttons
		but_box = wx.BoxSizer(wx.HORIZONTAL)
		window_box.Add(but_box, 1, wx.EXPAND)
		for button in e.buttons:
			but = wx.Button(self.window, label=button.label)
			but.pmodel = button
			but.Bind(wx.EVT_BUTTON, self.callback_button)
			but_box.Add(but, 1, wx.EXPAND)
	
		# Show everything
		self.window.Centre()
		self.window.Show()

	def write_command_line(self, line):
		wx.CallAfter(self.wx_write_command_line, line)
		
	def wx_write_command_line(self, line):
	
		# Delete last line if it is \r
		if self.remove_next_line and line != '\n':
			self.console.Remove(self.last_line_position, self.console.GetLastPosition())
			self.remove_next_line = False

		# Double spaces
		if line[0:2] == '  ': line = "  " + line
		elif line[0:1] == ' ': line = " " + line
	
		# Detect styles
		style = self.console.GetDefaultStyle()
		bold = style.GetFont()
		bold.SetWeight(wx.FONTWEIGHT_BOLD)
		if line[0:2] == '# ':
			style = wx.TextAttr("BLACK", wx.NullColour, bold)
			line = line[2:]
		elif line == "[ OK ]\n":
			style = wx.TextAttr("BLUE", wx.NullColour, bold)
		elif line[0:3] == '!! ':
			style = wx.TextAttr("RED", wx.NullColour, bold)
			line = line[2:]
	
		# Save last position, write, apply style
		self.last_line_position = self.console.GetLastPosition()
		self.console.AppendText(line)
		self.console.SetStyle(self.last_line_position, self.console.GetLastPosition(), style)
				
		if line[-1] == '\r': 
			self.remove_next_line = True

