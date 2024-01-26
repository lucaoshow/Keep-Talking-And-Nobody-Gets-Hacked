extends Node

class_name Commands


const commandDict : Dictionary = {"cd <dir>" : "Navigates to the specified directory.", "clear" : "Clears the terminal's text.",
 "help" : "Shows the list containing all commands.",}

var currentDir : String = "C"
var previousDirs : Array[String]


# PUBLIC METHODS

func executeCommand(command : String, terminal : Terminal):
	command = command.strip_edges()
	terminal.setWindowText(terminal.getWindowText() + terminal.TERMINAL_PATH + command + "\n")
	if (command in self.commandDict.keys() and command != "cd <dir>"):
		call("_" + command, terminal)
		return
	if (command.begins_with("cd ")):
		self._cdCommand(command, terminal)


# PRIVATE METHODS

func _getformattedHelpText():
	var text : String = ""
	var spaces : String = "                 "
	var index = 0
	for key in self.commandDict:
		var slicingIndex : int = len(spaces) - len(key)
		text += key + spaces.substr(0, slicingIndex) + self.commandDict[key]
		if index != len(self.commandDict) - 1:
			text += "\n"
		index += 1

	return text


# COMMAND FUNCTIONS

func _help(terminal : Terminal):
	terminal.writeAnimatedText(self._getformattedHelpText() + "\n")
	for i in range(len(self.commandDict)):
		terminal.adjustYPos(terminal.getEnterYOffset())


func _clear(terminal : Terminal):
	terminal.windowTextToOriginalSize()
	terminal.returnToOriginalPos()


func _cdCommand(command : String, terminal : Terminal):
	if (len(command) < 4):
		return

	var dir = command.get_slice(" ", 1)

	if (dir not in Directories.directories.keys()):
		return

	if (dir in Directories.directories[self.currentDir]):
		self.previousDirs.append(self.currentDir)
		self.currentDir = dir
		return

	if (dir == ".." and self.previousDirs.size()):
		self.currentDir = self.previousDirs.pop_back()
		return

	return # Error: invalid command or command usage. Message: Please specify a valid directory.
