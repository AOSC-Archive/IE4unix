from installer import _Button as _Button

# Defines a program executor
class ExecutorDefinition:

	def __init__(self):
		self.buttons = []
		self.args = []

	def set_program(self, program):
		self.program = program
		self._do_command()
		return self
	
	def set_initial_command(self, command, args):
		self.command = command
		for arg in args: self.args.append(arg)
	
		self._do_command()
		return self
	
	def _do_command(self):	
		if not hasattr(self, 'program'): return
		
		for c in self.program.checkboxes():
			if c.checked:
				self.args.append(c.command)

		for c in self.program.comboboxes():
			self.args.append(c.command)
			self.args.append(c.selected)

		for t in self.program.textfields():
			self.args.append(t.command)
			self.args.append(t.value)

	def title(self, title):
		self.title = title
		return self
		
	def subtitle(self, subtitle):
		self.subtitle = subtitle
		return self

	def logo(self, logo):
		#TODO validates file existence
		self.logo = logo
		return self
	
	def button(self, label, img, callback):
		button = _Button(label, img, callback)
		self.buttons.append(button)
		return self

