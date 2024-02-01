extends Node

class_name Commands


const COMMAND_DICT : Dictionary = {"clear" : "Clears the terminal's text.",
	"config" : "Shows hardware specifications and system details.",
	"exiftool <file>" : "Analyzes the specified file.",
	"find <dir || file>" : "Returns the absolute path to the specified directory or file.",
	"frw <IP address>" : "Removes an user from the current network via firewall.",
	"ls" : "Lists the directories and files in the current directory.",
	"nmap <IP address>" : "Scans the users in the network specified by the IP adress.",
	"rm <dir || file>" : "Removes the specified directory or file.",
	"users-ls" : "Lists the users present in the system."}

const REMOVABLE_DIRS : Array[String] = ["pt-BR", "Temp", "Music", "Pictures", "Videos",
	"Favourite", "Downloads", "Contacts", "Documents", "Git", "My Games", "WinRAR",
	"WindowsXPInstallationAssistant", "AdvancedInstallers", "Clips", "LoL"]

const FRW_TEXT : Array[String] = ["Removing user from network...\n", "User successfully removed from network.\n",
	"Error: removed self from network. Reseting network configurations...\n", "Configurations successfully reset.\n"]


@onready var continueNmapTimer : Timer = Timer.new()
@onready var continueFrwTimer : Timer = Timer.new()
@onready var hackerOutTimer : Timer = Timer.new()
var pauses : int = 1
var ipAddress : String = "192.168.1." + str(randi_range(0, 1)) + "/" + str(randi_range(11, 28))
var hackerIp : String = "192.168.1." + str(randi_range(2, 9))
var randomIp : String = "192.168.1." + str(randi_range(10, 19))
var ipAddresses : Array[String] = [self.ipAddress.substr(0, 11), self.hackerIp, self.randomIp] 
var currentDir : String = "C"
var previousDirs : Array[String]
var pauseCommandTerminal : Terminal
var hackerFiles : Array[String] = ["c23e5so67hc9e.exe", "sys.shell", "temp.phpp"]
var configString : String = "" + self.ipAddress
var nmapText : Array[String] = ["Starting Nmap 7.80 ( https://nmap.org ) at 2024-01-18 12:00 UTC\n\n",
	"Nmap scan report for " + self.ipAddresses[0] +
	"""\nHost is up (0.001s latency).
	Not shown: 991 closed ports
	PORT   STATE SERVICE
	21/tcp open  ftp
	22/tcp open ssh
	106/tcp open macOS\n\n""",
	"Nmap scan report for " + self.ipAddresses[1] +
	"""\nHost is up (0.002s latency).
	Not shown: 997 closed ports
	PORT    STATE SERVICE
	22/tcp  open  ssh
	80/tcp  open  http
	139/tcp open dns
	443/tcp open  https\n\n""",
	"Nmap scan report for " + self.ipAddresses[2] +
	"""\nHost is up (0.003s latency).
	Not shown: 999 closed ports
	PORT  STATE SERVICE
	80/tcp  open  http
	106/tcp open macOS
	443/tcp open  https\n\n"""]


func _ready():
	self.continueNmapTimer.one_shot = true
	self.continueFrwTimer.one_shot = true
	self.hackerOutTimer.one_shot = true
	self.hackerOutTimer.wait_time = 50
	self.continueNmapTimer.connect("timeout", self.onContinueNmapTimeout)
	self.continueFrwTimer.connect("timeout", self.onContinueFrwTimeout)
	self.hackerOutTimer.connect("timeout", self.onHackerOutTimeout)
	self.add_child(self.continueNmapTimer)
	self.add_child(self.continueFrwTimer)
	self.add_child(self.hackerOutTimer)


# PUBLIC METHODS

func executeCommand(command : String, terminal : Terminal):
	command = command.strip_edges()
	terminal.setWindowText(terminal.getWindowText() + terminal.TERMINAL_PATH + command + "\n")
	if ((command in self.COMMAND_DICT.keys() and !command.contains("<") and !command.contains("-")) or command == "help"):
		call("_" + command, terminal)
		return
	if (command == "users-ls"):
		self._usersLs(command, terminal)
		return
	if (command.begins_with("cd")):
		self._cdCommand(command, terminal)
		return
	if (command.begins_with("exiftool ")):
		self._exiftool(command, terminal)
		return
	if (command.begins_with("rm ")):
		self._removeCommand(command, terminal)
		return
	if (command.begins_with("find ")):
		self._find(command, terminal)
		return
	if (command.begins_with("nmap ")):
		self._nmapCommand(command, terminal)
		return
	if (command.begins_with("frw ")):
		self._frwCommand(command, terminal)
		return

	self._displayErrorMessage(terminal, 'Command or file not found. Type "help" to see the list of available commands.')


# PRIVATE METHODS

func _getHelpText():
	return """- clear :                           %s
	- config :                         %s
	- exiftool <file> :      %s
	- find <dir || file> :       %s
	- frw <user> :                  %s
	- ls :                                   %s
	- nmap <IP adress> :     %s
	- rm <dir || file> :         %s
	- users-ls :                     %s\n"""


func _getFormattedLsText():
	var text : String = ""
	for dir in Directories.directories[self.currentDir]:
		var dirName : String = "- " + dir
		text += dirName + "\n"

	return text


func _getFileAnalysisText():
	return """File Name                                                :   %s
	Directory                                               :   %s
	File Size                                                :   %s
	File Modification Date/Time       :   %s
	File Permissions                               :   %s
	File Type                                               :   %s
	File Type Extensions                       :   %s
	Author                                                     :   %s\n"""


func _getPathToFile(fileName : String, previousDir : String):
	if (previousDir.begins_with("C\\")):
		return "C:\\" + previousDir.substr(2)
	for key in Directories.directories.keys():
		if fileName in Directories.directories[key]:
			return self._getPathToFile(key, key + "\\" + previousDir)

	return ""


func _writeToTerminal(terminal : Terminal, msg : String):
	terminal.writeAnimatedText(msg)
	for i in range(msg.count("\n")):
		terminal.adjustYPos(terminal.getEnterYOffset())


func _displayErrorMessage(terminal : Terminal, message : String):
	self._writeToTerminal(terminal, "Error:  " + message + "\n")
	# TODO: Penalize player


func _analyzeFile(terminal : Terminal, fileName : String):
	var slicingIndex : int = fileName.rfind(".")
	var file : FileResource = load("res://Resources/File/" + fileName.substr(0, slicingIndex) + ".tres")
	var properties : Array[String] = [file.fname, file.directory, file.size, file.modification,
		file.permissions, file.type, file.extension, file.author]

	self._writeToTerminal(terminal, self._getFileAnalysisText() % properties)


func _removeFromNmapText(ip : String):
	for t in range(1, len(self.nmapText)):
		if (self.nmapText[t].contains(ip)):
			self.nmapText.remove_at(t)


func _isCommandEmpty(command : String, minLength : int):
	if (len(command) < minLength):
		return true
	return false


# COMMAND FUNCTIONS

func _help(terminal : Terminal):
	self._writeToTerminal(terminal, self._getHelpText() % self.COMMAND_DICT.values())


func _clear(terminal : Terminal):
	terminal.windowTextToOriginalSize()
	terminal.returnToOriginalPos()

func _config(terminal : Terminal):
	self._writeToTerminal(terminal, self.configString + "\n")


func _ls(terminal : Terminal):
	if (!Directories.directories[self.currentDir].size()):
		self._writeToTerminal(terminal, "You don't have permission to access that information.")
		return

	self._writeToTerminal(terminal, self._getFormattedLsText())


func _cdCommand(command : String, terminal : Terminal):
	var errorMsg : String = 'Directory not found. Type "ls" to see the list of available directories.'

	if (self._isCommandEmpty(command, 4)):
		self._displayErrorMessage(terminal, errorMsg)
		return

	var dir : String = command.get_slice(" ", 1)
	var isBack : bool = command.substr(2) == ".." or dir == ".."

	if (isBack and self.previousDirs.size()):
		self.currentDir = self.previousDirs.pop_back()
		terminal.goBackOneDir()
		return

	if (dir not in Directories.directories.keys()):
		self._displayErrorMessage(terminal, errorMsg)
		return

	if (dir in Directories.directories[self.currentDir]):
		self.previousDirs.append(self.currentDir)
		self.currentDir = dir
		terminal.navigateToDir(dir)
		return

	self._displayErrorMessage(terminal, errorMsg)


func _exiftool(command : String, terminal : Terminal):
	var errorMsg : String = 'File not found in current directory. Type "ls" to see the list of available files.'
	
	if (self._isCommandEmpty(command, 10)):
		self._displayErrorMessage(terminal, errorMsg)
		return 

	var fileName : String = command.get_slice(" ", 1)

	if (fileName in Directories.directories[self.currentDir]):
		self._analyzeFile(terminal, fileName)
		return

	self._displayErrorMessage(terminal, errorMsg)


func _removeCommand(command : String, terminal : Terminal):
	var errorMsg : String = 'Directory or file not found in current directory. Type "ls" to see the list of available files.'

	if (self._isCommandEmpty(command, 4)):
		self._displayErrorMessage(terminal, errorMsg)
		return

	var fileOrDir : String = command.get_slice(" ", 1)

	if (fileOrDir not in Directories.directories[self.currentDir]):
		self._displayErrorMessage(terminal, errorMsg)
		return

	if (fileOrDir.contains(".")):
		if (fileOrDir == "system.dll"):
			return #TODO: LOSE
		Directories.directories[self.currentDir].erase(fileOrDir)
		return

	if (fileOrDir in self.REMOVABLE_DIRS):
		Directories.directories.erase(fileOrDir)
		Directories.directories[self.currentDir].erase(fileOrDir)
		return


func _usersLs(_command : String, terminal : Terminal):
	self._writeToTerminal(terminal, "Users:\n- " + "\n- ".join(Directories.directories["Users"]) + "\n")


func _find(command : String, terminal : Terminal):
	var errorMsg : String = "Directory or file could not be found."
	
	if (self._isCommandEmpty(command, 6)):
		self._displayErrorMessage(terminal, errorMsg)
		return

	var fileName : String = command.get_slice(" ", 1)

	var path : String = self._getPathToFile(fileName, fileName)
	if (len(path)):
		self._writeToTerminal(terminal, "Absolute path to file:\n" + path + "\n")
		return

	self._displayErrorMessage(terminal, errorMsg)


func _nmapCommand(command : String, terminal : Terminal):
	var errorMsg : String = 'Unknown IP address. Type "config" to see the IP address of the current network'
	
	if (self._isCommandEmpty(command, 6)):
		self._displayErrorMessage(terminal, errorMsg)
		return

	var ip : String = command.get_slice(" ", 1)

	if (ip != self.ipAddress):
		self._displayErrorMessage(terminal, errorMsg)
		return

	self.pauses = 1
	self.continueNmapTimer.wait_time = 6
	terminal.togglePause()
	self.pauseCommandTerminal = terminal
	self._writeToTerminal(self.pauseCommandTerminal, self.nmapText[0])
	self.continueNmapTimer.start()


func _frwCommand(command : String, terminal : Terminal):
	var errorMsg : String = 'IP address could not be found in current network.'
	
	if (self._isCommandEmpty(command, 6)):
		self._displayErrorMessage(terminal, errorMsg)
		return

	var ip : String = command.get_slice(" ", 1)
	var ipIsValid : bool = ip in self.ipAddresses

	if (!ipIsValid):
		self._displayErrorMessage(terminal, errorMsg)
		return

	if (ip == self.hackerIp):
		self._removeFromNmapText(self.hackerIp)
		self.ipAddresses.erase(self.hackerIp)
		self.hackerOutTimer.start()
		return

	if (ip == self.randomIp):
		self._removeFromNmapText(self.randomIp)
		self.ipAddresses.erase(self.randomIp)

	self.pauses = 0
	if (ip == self.ipAddresses[0]):
		self.pauses = 1
		return

	self.continueFrwTimer.wait_time = 15
	terminal.togglePause()
	self.pauseCommandTerminal = terminal
	self._writeToTerminal(self.pauseCommandTerminal, self.FRW_TEXT[pauses])
	self.continueFrwTimer.start()


# EVENT LISTENERS

func onContinueNmapTimeout():
	self.continueNmapTimer.wait_time = 13
	if (self.pauses <= self.nmapText.size() - 2):
		self._writeToTerminal(self.pauseCommandTerminal, self.nmapText[self.pauses])
		self.continueNmapTimer.start()
		self.pauses += 1
		return
	self._writeToTerminal(self.pauseCommandTerminal, self.nmapText[self.pauses])
	self.pauseCommandTerminal.togglePause()


func onContinueFrwTimeout():
	self.pauses += 1

	self._writeToTerminal(self.pauseCommandTerminal, self.FRW_TEXT[self.pauses])

	if (self.pauses == 1 or self.pauses == 3):
		self.pauseCommandTerminal.togglePause()
		return

	self.continueFrwTimer.wait_time = 20
	self.continueFrwTimer.start()


func onHackerOutTimeout():
	self.hackerIp = "192.168.1." + str(randi_range(2, 9))
	self.nmapText.append("Nmap scan report for " + self.hackerIp +
	"""\nHost is up (0.004s latency).
	Not shown: 999 closed ports
	PORT    STATE SERVICE
	22/tcp  open  ssh
	80/tcp  open  http
	139/tcp open NetBios
	443/tcp open  ftp\n\n""",)
