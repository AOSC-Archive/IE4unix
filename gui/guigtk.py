import gtk, pango, sys, os
gtk.gdk.threads_init()

# PyGTK GUI implementation
class GUI:

	def __init__(self):
		self.checkboxes = []
		self.comboboxes = []
		self.textfields = []

	def doInstaller(self, model):
		self.model = model
		
		# Create Window
		self.window = create_window(model.title)
		add_logo(self.window, model.logo)

		# Create notebook
		notebook = gtk.Notebook()
		append_component(self.window.main_vbox, notebook)
	
		# Create tabs
		for tab in model.tabs:
			box = gtk.VBox()
			notebook.append_page(box, gtk.Label(tab.label))
			self._do_tab(box, tab)

		# Create buttons
		but_box = gtk.HBox()
		append_component(self.window.main_vbox, but_box)
		for button in model.buttons:
			b = gtk.Button(label=button.label)
			b.connect("clicked", self.callback_button, None)
			b.pmodel = button
			but_box.pack_start(b)

		# Show everything
		self.window.show_all()
		gtk.main()
	
	# Configure one tab
	def _do_tab(self, container, tab):

		# Add text
		if hasattr(tab, 'text'):
			label = gtk.Label(tab.text)
			label.set_justify(gtk.JUSTIFY_LEFT)
			label.set_alignment(0, 0)
			label.set_line_wrap(True)
			label.set_size_request(-1, -1)
			append_component(container, label)

		# Add groups
		for group in tab.groups:
			frame = gtk.Frame(group.label)
			append_component(container, frame)
			self._do_group(frame, group)

	# Configure one group
	def _do_group(self, container, group):
		box = gtk.VBox()
		container.add(box)

		# Define orientation for checkboxes
		if group.orientation == 'horizontal':
			cb_box = gtk.HBox()
			box.pack_start(cb_box, False, False, 0)
			space = 5
		else:
			cb_box = box
			space = 0
	
		# Add Checkboxes
		for checkbox in group.checkboxes:
			cb = create_checkbox(checkbox)
			self.checkboxes.append(cb)
			append_component(cb_box, cb, space)

		# Add comboboxes
		for combo in group.comboboxes:
			label = gtk.Label(combo.label + ':')
			gcombo = create_combo(combo)
			self.comboboxes.append(gcombo)
		
			co_box = gtk.HBox()
			co_box.pack_start(label, False, False, 5)
			co_box.pack_end(gcombo)
			box.pack_start(co_box, False, False, 0)
		
		# Add TextFields
		for textfield in group.textfields:
			label = gtk.Label(textfield.label + ':')
			entry = gtk.Entry()
			entry.set_text(textfield.value)

			self.textfields.append(entry)
			entry.pmodel = textfield
		
			t_box = gtk.HBox()
			t_box.pack_start(label, False, False, 3)
			t_box.pack_end(entry)
			box.pack_start(t_box, False, False, 0)

	# Response functions
	def callback_button(self, button, data=None):
		self.update_model()
		button.pmodel.callback()

	# Iterate over components and update model	
	def update_model(self):
		for c in self.checkboxes:
			c.pmodel.checked = c.get_active()
		for c in self.comboboxes:
			c.pmodel.selected = _combo_get_selected(c)
		for t in self.textfields:
			t.pmodel.value = t.get_text()

	## EXECUTOR
	def doExecutor(self, e):
		# Quit old window
		self.window.hide()

		# Create window
		self.remove_next_line = False
		self.window = create_window(e.title)
		add_logo(self.window, e.logo)
		self.window.set_resizable(True)
		self.window.resize(376,450)

		# Terminal window
		sw = gtk.ScrolledWindow()
		sw.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		self.textview = gtk.TextView()
		self.textview.set_editable(False)
		self.textbuffer = self.textview.get_buffer()
		sw.add(self.textview)
		self.window.main_vbox.pack_start(sw, True, True, 0)
		
		# Tags
		self.normal_tag = self.textbuffer.create_tag(font="Monospace")
		self.section_tag = self.textbuffer.create_tag(weight=pango.WEIGHT_BOLD)
		self.ok_tag = self.textbuffer.create_tag(weight=pango.WEIGHT_BOLD, foreground='Blue')
		self.error_tag = self.textbuffer.create_tag(weight=pango.WEIGHT_BOLD, foreground='Red')

		# Create buttons
		but_box = gtk.HBox()
		append_component(self.window.main_vbox, but_box)
		self.buttons = []
		for button in e.buttons:
			b = gtk.Button(label=button.label)
			b.connect("clicked", self.callback_button, None)
			b.pmodel = button
			self.buttons.append(b)
			but_box.pack_start(b)

		# Show everything
		self.window.show_all()

	def write_command_line(self, line):
		# Finished installation, change button
		if line == "END":
			self.buttons[0].set_label("Close")
			return
	
		# What tag to use
		tag = self.normal_tag
		if line[0:2] == '# ':
			tag = self.section_tag
			line = line[2:]
		elif line == "[ OK ]\n":
			tag = self.ok_tag
		elif line[0:3] == '!! ':
			tag = self.error_tag
			line = line[2:]
		
		# Safe GTK thread
		gtk.gdk.threads_enter()
		
		# Delete last line if it is \r
		if self.remove_next_line and line != '\n':
			it = self.textbuffer.get_iter_at_line(self.textbuffer.get_line_count()-2)
			self.textbuffer.delete(it, self.textbuffer.get_end_iter())
			self.remove_next_line = False

		# Insert text and relocate scroll
		self.textbuffer.insert_with_tags(self.textbuffer.get_end_iter(), line, tag)
		self.textview.scroll_to_iter(self.textbuffer.get_end_iter(), 0)

		# Safe GTK Thread
		gtk.gdk.threads_leave()
		
		if line[-1] == '\r': self.remove_next_line = True

	# Quit
	def quit(self):
		gtk.main_quit()

# Auxiliary function
def create_window(title):
	window = gtk.Window(gtk.WINDOW_TOPLEVEL)
	window.connect("destroy", lambda w: sys.exit(1))
	window.set_position(gtk.WIN_POS_CENTER)
	window.set_title(title)
	window.set_border_width(0)
	window.set_resizable(False)
	mainBox = gtk.VBox()
	window.add(mainBox)
	window.main_vbox = mainBox	
	return window

def add_logo(window, logoFile):
	logoImg = gtk.gdk.pixbuf_new_from_file(logoFile)
	logo = gtk.Image()
	#logo.set_from_pixbuf(logoImg.scale_simple(100,100,gtk.gdk.INTERP_BILINEAR))
	logo.set_from_pixbuf(logoImg)
	#logo.set_size_request(100, 100)
	window.main_vbox.pack_start(logo, False, False, 5)

def create_checkbox(checkbox):
	checkButton = gtk.CheckButton(checkbox.label)
	checkButton.set_active(checkbox.checked)
	checkButton.set_alignment(0, 0)	
	checkButton.pmodel = checkbox
	return checkButton

def create_combo(combo):
	gcombo = gtk.combo_box_new_text()
	i = 0
	for option in combo.options:
		gcombo.append_text(option)
		if option == combo.selected:
			gcombo.set_active(i)
		i = i+1
	
	gcombo.pmodel = combo
	return gcombo

def append_component(where, what, space=5):
	where.pack_start(what, False, False, space)

def _combo_get_selected(combobox):
	model = combobox.get_model()
	active = combobox.get_active()
	if active < 0:
		return None
	return model[active][0]
	
