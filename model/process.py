import sys, os, threading, popen2

# Executes the program in another thread
class ProcessThread:

	def __init__(self, executor, callback):
		self.executor = executor
		self.write_line_callback = callback		

	def start_program(self):
		threading.Thread(target=self._run_command).start()
		
	def _run_command(self):
		command = [self.executor.command]
		command.extend(self.executor.args)
	
		(stdout, stdin) = popen2.popen4(command)
		
		self.process_finished = False
		
		line = ''
		while not self.process_finished:
			char = stdout.read(1)
			line = line + char
				
			if char == '\n' or char == '\r':
				self.write_line_callback(line)
				line = ''
			
			if char == '':
				self.process_finished = True
				
		self.write_line_callback(line + '\n')

