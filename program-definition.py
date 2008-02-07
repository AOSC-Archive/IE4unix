import sys, os
from model import installer, executor, process
from gui import guiwx as gui
#from gui import guigtk as gui

# Platform detection
#MAC = LINUX = False
#if sys.platform == 'darwin': MAC = True
#else: LINUX=True

# Hack
# LINUX=False
# MAC=True

userhome = os.getenv("HOME")

# Define the GUI
def MakeTheGUI():
	return installer.InstallerDefinition()\
	.set_title("IEs 4 Mac", show=MAC)\
	.set_title("IEs 4 Linux", show=LINUX)\
	.set_logo("mac/logo.png", show=MAC)\
	.set_logo("linux/logo.png", show=LINUX)\
	.tab("Install options")\
		.group("Install Internet Explorers")\
			.checkbox("IE 6.0 SP1", "--install-ie6", True)\
			.checkbox("IE 5.5", "--install-ie55", False)\
			.checkbox("IE 5.01", "--install-ie5", False)\
			.combobox("Locale", "AR CN CS DA DE EL EN-US ES FI FR HE HU IT JA KO NL NO PL PT PT-BR RU SV TR TW", "--locale", "EN-US")\
			.done()\
		.group("Extra")\
			.checkbox("Adobe Flash 9", "--install-flash", True)\
			.checkbox("Core Fonts", "--install-corefonts", True, show=False)\
			.vertical()\
			.done()\
		.done()\
	.tab("Beta options")\
		.toptext("These options are still beta. Use carefully.")\
		.group("IE 7 engine")\
			.checkbox("Install IE7 Engine", "--install-ie7", False)\
			.done()\
		.done()\
	.tab("Advanced", LINUX)\
		.group("Shortcuts")\
			.checkbox("Create Desktop Icons", "--create-desktop-icons", True)\
			.checkbox("Create Menu Entries", "--create-menu", False, show=False)\
			.done()\
		.group("Folders")\
			.textfield("Base", userhome +"/.ies4linux", "--base-dir")\
			.textfield("Download", userhome + "/.ies4linux/downloads", "--download-dir")\
			.textfield("Bin", userhome + "/bin", "--bin-dir")\
			.done()\
		.group("Others")\
			.textfield("Wget flags", "-c", "--wget-flags")\
			.done()\
		.done()\
	.tab("Advanced Mac", False)\
		.group("App Bundle")\
			.checkbox("Create Application Bundle on Desktop", "--create-app", True)\
			.done()\
		.group("Others")\
			.textfield("Curl flags", "", "--curl-flags")\
			.done()\
		.done()\
	.button("Install", "none.png", callback_install)\
	.button("Quit", "none.png", callback_quit)

# Callbacks
def callback_install():
	# make gui
	e = MakeTheExecutor(_program)
	
	# show gui
	g.doExecutor(e)
	
	# execute process thread
	p = process.ProcessThread(e, g.write_command_line)
	g.process = p
	p.start_program()

def callback_quit():
	g.quit()
	sys.exit(0)

# Execution screen
def MakeTheExecutor(program):
	return  executor.ExecutorDefinition()\
			.title("Installing IEs")\
			.subtitle("You can stop it anytime")\
			.logo(program.logo)\
			.button("Cancel", "cncel.png", callback_cancel)\
			.set_initial_command("/home/sergio/workspace/ies4linux/trunk/ies4linux", ["--no-color"])\
			.set_program(program)
	
# Callbacks
def callback_cancel():
	g.process.kill()
	g.quit()
	sys.exit(0)

# MAIN
def program_main():
	_program = MakeTheGUI()
	g = gui.GUI()
	g.doInstaller(_program)
