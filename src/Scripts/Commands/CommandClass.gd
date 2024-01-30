extends Node

class_name Commands


const commandDict : Dictionary = {"cd <dir>" : "Navigates to the specified directory.", 
	"clear" : "Clears the terminal's text.", "help" : "Shows the list containing all commands.",
	"ls" : "Lists the directories and files in the current directory."}

var currentDir : String = "C"
var previousDirs : Array[String]


# PUBLIC METHODS

func executeCommand(command : String, terminal : Terminal):
	command = command.strip_edges()
	terminal.setWindowText(terminal.getWindowText() + terminal.TERMINAL_PATH + command + "\n")
	if (command in self.commandDict.keys() and command != "cd <dir>"):
		call("_" + command, terminal)
		return
	if (command.begins_with("cd")):
		self._cdCommand(command, terminal)


# PRIVATE METHODS

func _getFormattedHelpText():
	var text : String = "Command             Description\n-------------------------------\n"
	var spaces : String = "                         "
	var length : int = len(spaces)
	var index : int = 0
	for key in self.commandDict:
		var command : String= "- " + key + ":"
		var slicingIndex : int = length - len(command) + index *2
		text += command + spaces.substr(0, slicingIndex) + self.commandDict[key] + "\n"
		index += 1

	return text


func _getFormattedLsText():
	var text : String = "Directory Name\n-----------------\n"
	for dir in Directories.directories[self.currentDir]:
		var dirName : String = "- " + dir
		text += dirName + "\n"

	return text


# COMMAND FUNCTIONS

func _help(terminal : Terminal):
	terminal.writeAnimatedText(self._getFormattedHelpText())
	for i in range(len(self.commandDict) + 2):
		terminal.adjustYPos(terminal.getEnterYOffset())


func _clear(terminal : Terminal):
	terminal.windowTextToOriginalSize()
	terminal.returnToOriginalPos()


func _ls(terminal : Terminal):
	terminal.writeAnimatedText(self._getFormattedLsText())
	for i in range(len(Directories.directories[self.currentDir]) + 2):
		terminal.adjustYPos(terminal.getEnterYOffset())


func _cdCommand(command : String, terminal : Terminal):
	if (len(command) < 4):
		return

	var dir : String = command.get_slice(" ", 1)
	var isBack : bool = command.substr(2) == ".." or dir == ".."

	if (isBack and self.previousDirs.size()):
		self.currentDir = self.previousDirs.pop_back()
		terminal.goBackOneDir()
		return

	if (dir not in Directories.directories.keys()):
		return

	if (dir in Directories.directories[self.currentDir]):
		self.previousDirs.append(self.currentDir)
		self.currentDir = dir
		terminal.navigateToDir(dir)
		return

	return # Error: invalid command or command usage. Message: Please specify a valid directory.
