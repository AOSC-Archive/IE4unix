import sys, os
from model import installer, executor, process
from gui import guiwx as gui
#from gui import guigtk as gui

# Platform detection
MAC = LINUX = False
if sys.platform == 'darwin': MAC = True
else: LINUX=True

# Platform dependent configs
if LINUX:
	title = "IEs 4 Linux"
	subtitle = "Installs MS IE 7, 6, 5.5, 5, 2, 1.5, 1 on Linux"
	logo = "/home/sergio/workspace/ies4linux/trunk/lib/ies4linux.png"
if MAC:
	title = "IEs 4 Mac"
	subtitle = "Installs MS IE 7, 6, 5.5, 5, 2, 1.5, 1 on Mac OS X"
	logo = "/home/sergio/workspace/ies4linux/trunk/lib/ies4mac.png"

userhome = os.getenv("HOME")

# Define the GUI
def MakeTheGUI():
	return installer.InstallerDefinition()\
	.set_title(title)\
	.set_subtitle(subtitle)\
	.set_logo(logo)\
	.tab("Install options")\
		.group("Install Internet Explorers")\
			.checkbox("IE 6.0 SP1", "--install-ie6", True)\
			.checkbox("IE 5.5", "--install-ie55", False)\
			.checkbox("IE 5.01", "--install-ie5", False)\
			.combobox("Locale", "EN-US PT-BR", "--locale", "EN-US")\
			.done()\
		.group("Extra")\
			.checkbox("Adobe Flash 9", "--install-flash", True)\
			.checkbox("Core Fonts", "--install-corefonts", True)\
			.vertical()\
			.done()\
		.done()\
	.tab("Beta options")\
		.toptext("These options are still beta.")\
		.group("IE 7 engine")\
			.checkbox("Install IE7 Engine", "--install-ie7", False)\
			.done()\
		.done()\
	.tab("Advanced", LINUX)\
		.group("Shortcuts")\
			.checkbox("Create Desktop Icons", "--create-desktop-icons", True)\
			.checkbox("Create Menu Entries", "--create-menu", False)\
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
	.tab("Advanced", MAC)\
		.group("App Bundle")\
			.checkbox("Create Application Bundle on Desktop", "--create-app", True)\
			.done()\
		.group("Others")\
			.textfield("Curl flags", "", "--curl-flags")\
			.done()\
		.done()\
	.button("Install", "img.png", callback_install)\
	.button("Quit", "img.png", callback_quit)

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
_program = MakeTheGUI()
g = gui.GUI()
g.doInstaller(_program)
