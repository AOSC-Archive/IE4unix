import sys, os, threading, popen2

# Executes the program in another thread
class ProcessThread:

	stopthread = threading.Event()

	def __init__(self, executor, callback):
		self.executor = executor
		self.write_line_callback = callback		

	def start_program(self):
		threading.Thread(target=self._run_command).start()
		
	def _run_command(self):
		command = [self.executor.command]
		command.extend(self.executor.args)
	
		(stdout, stdin) = popen2.popen4(command)
		self.pid = int(os.popen("ps x | grep bash | grep ies4linux | head -n 1 | awk '{print $1}'").read())
		# print 'PID %s' % self.pid
		
		line = ''
		while not self.stopthread.isSet():
			char = stdout.read(1)
			line = line + char
				
			if char == '\n' or char == '\r':
				self.write_line_callback(line)
				line = ''
			
			if char == '': break
				
		self.write_line_callback(line + '\n')
		self.write_line_callback('END')

	def kill(self):
		self.stopthread.set()
		os.kill(self.pid, 9)

