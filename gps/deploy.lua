--[[
The MIT License (MIT)

Copyright (c) 2018 Setzerbomb

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

This code was based on GPS Deploy by neonerZ [https://pastebin.com/qLthLak5]
]]--

--CommonFunctions: Class that aggregates all the common functions used in the program

local function CommonFunctions()

	local self = {}

	-- Switch Function [http://lua-users.org/wiki/SwitchStatement]
	function self.switch(t)
		t.case = function (self,x)
			local f=self[x] or self.default
			if f then
				if type(f)=="function" then
					f(x,self)
				else
					error("Case "..tostring(x).." is not a function")
					end
				end
			end
			return t
		end

		-- Try Function [https://www.lua.org/wshop06/Belmonte.pdf]
		function self.try(f, catch_f)
			local status, exception = pcall(f)
			if not status then
				catch_f(exception)
			end
		end

		function self.limitToWrite(limit)
			local timer = os.startTimer(limit)
			while true do
				local event, result = os.pullEvent()
				if event=="timer" and timer==result then
					return 0
				else
					if event=="key" then
						return io.read()
					end
				end
			end
		end
		return self
	end

	--Position: Store the turtle postion data and modify it's variables with add and sub functions

	local function Position()

		-- Local variables of the object / Variáveis locais do objeto
		local self = {}
		local data

		-- Global functions of the object / Funções Globais do objeto

		function self.addF()
			if data.F <3 then
				data.F = data.F + 1
			else
				data.F = 0
			end
		end

		function self.subF()
			if data.F > 0 then
				data.F = data.F - 1
			else
				data.F = 3
			end
		end

		function self.addY()
			data.Y = data.Y + 1
		end

		function self.subY()
			data.Y = data.Y - 1
		end

		function self.addZ()
			data.Z = data.Z + 1
		end

		function self.subZ()
			data.Z = data.Z - 1
		end

		function self.addX()
			data.X = data.X + 1
		end

		function self.subX()
			data.X = data.X - 1
		end

		function self.getF()
			return data.F
		end

		function self.setF(f)
			data.F = f
		end

		function self.getY()
			return data.Y
		end

		function self.setY(y)
			data.Y = y
		end

		function self.getX()
			return data.X
		end

		function self.setX(x)
			data.X = x
		end

		function self.getZ()
			return data.Z
		end

		function self.setZ(z)
			data.Z = z
		end

		function self.start(vectorData)
			data = vectorData
		end

		return self
	end

	--Turtle Moviments: Modify the turtle moviments behavior to a smarter one

	local TurtleMoviments = function(position)

		local self = {}
		local CommonF = CommonFunctions()

		function self.left()
			if turtle.turnLeft() then
				position.subF()
			end
		end

		function self.up()
			if turtle.up() then
				position.addY()
				return true
			else
				if not turtle.digUp() then
					turtle.attackUp()
				end
				return self.up()
			end
			return false
		end

		function self.down()
			if turtle.down() then
				position.subY()
				return true
			else
				if not turtle.digDown() then
					turtle.attackDown()
				end
				return self.down()
			end
			return false
		end

		function self.forward()
			if turtle.forward() then
				self.adjustGPSWhenGoForward()
				return true
			else
				if not turtle.dig() then
					turtle.attack()
				end
				return self.forward()
			end
			return false
		end

		function self.back()
			if turtle.back() then
				self.adjustGPSWhenGoBack()
				return true
			end
			return false
		end

		function self.select(slot)
			turtle.select(slot)
		end

		function self.place()
			return turtle.place()
		end

		function self.placeUp()
			return turtle.placeUp()
		end

		function self.placeDown()
			return turtle.placeDown()
		end

		function self.adjustGPSWhenGoForward()
			local gpsCase = CommonF.switch{
				[0] =function (x) position.addZ() end,
				[1] =function (x) position.subX() end,
				[2] =function (x) position.subZ() end,
				[3] =function (x) position.addX() end,
				default = function (x) return false end
			}
			gpsCase:case(position.getF())
		end

		function self.adjustGPSWhenGoBack()
			local gpsCase = CommonF.switch{
				[0] =function (x) position.subZ() end,
				[1] =function (x) position.addX() end,
				[2] =function (x) position.addZ() end,
				[3] =function (x) position.subX() end,
				default = function (x) return false end
			}
			gpsCase:case(position.getF())
		end

		return self

	end

	-- Main Code: The neonerZ GPS code with some modifications

	local tArgs = { ... }

	local refuel = function(height)
		if type(turtle.getFuelLevel()) == "string" then
			print("No-fuel mode")
		else
			if turtle.getFuelLevel() < ((height*2)+70) then
				if (turtle.getFuelLevel() < (height*2)+70) then
					turtle.select(1)
					local realcoal=(((height*2)+70))/80
					turtle.refuel(realcoal)
				end
			end
		end
	end

	local verifyRequiredItems = function()

		local monitor=true
		local modem=true
		local diskdrive=true
		local disk=true

		turtle.select(2)
		if turtle.getItemCount() < 4 then
			print("Please place at least 4 computers into slot two")
			monitor=false
		end
		turtle.select(3)
		if turtle.getItemCount() < 4 then
			print("Please place at least 4 modems into slot three")
			modem=false
		end
		turtle.select(4)
		if turtle.getItemCount() < 1 then
			print("Please place 1 disk drive into slot four if a -mining turtle-")
			print("Please place 4 disk drives into slot four if a -standard turtle-")
			diskdrive=false
		end
		turtle.select(5)
		if turtle.getItemCount() < 1 then
			print("Please place 1 disk into slot five")
			disk=false
		end

		if not monitor or not modem or not diskdrive or not disk then
			print("Please fix above issues to continue")
			return false
		end

		return monitor and modem and diskdrive and disk
	end

	local install = function(pos)
		return [[
		local fileExists = function(name)
			local f=fs.open(name,"r")
			if f==nil then
				return false
			else
				return true
			end
		end

		local function save(localTable,name)
			local file = fs.open(name,"w")
			file.write(textutils.serialize(localTable))
			file.close()
		end

		if os.getComputerLabel() == nil then
			os.setComputerLabel("PC"..os.getComputerID())
		end

		if (not fileExists("main.lua")) then
			fs.copy("disk/main.lua","main.lua")
		end
		if (not fileExists("start.lua")) then
			fs.copy("disk/start.lua","startup")
		end

		local values = {}

		values.SavedPosition = ]] .. textutils.serialize(pos) .. [[

		values.SavedPosition.Y = values.SavedPosition.Y + 1

		if (values.SavedPosition.F == 0) then
			values.SavedPosition.Z = values.SavedPosition.Z + 1
		else
			if (values.SavedPosition.F == 2) then
				values.SavedPosition.Z = values.SavedPosition.Z - 1
			else
				if (values.SavedPosition.F == 1) then
					values.SavedPosition.X = values.SavedPosition.X - 1
				else
					if (values.SavedPosition.F == 3) then
						values.SavedPosition.X = values.SavedPosition.X + 1
					end
				end
			end
		end

		save(values,os.getComputerLabel())

		os.reboot()
		]]
	end

	local deploy = function(movT,pos)

		local fileExists = function(name)
			local f=fs.open(name,"r")
			if f==nil then
				return false
			else
				return true
			end
		end

		local putDriverAndDisk = function()
			movT.down()
			movT.forward()
			turtle.select(4)
			turtle.place()
			turtle.select(5)
			turtle.drop()
		end

		local putModem = function()
			movT.back()
			turtle.select(3)
			turtle.place()
		end

		local putComputer = function()
			turtle.select(2)
			turtle.place()
		end

		local updateInstaller = function(pos)
			fs.delete("disk/install.lua")
			local file = fs.open("disk/install.lua","w")
			file.write(
			install(pos)
		)
		file.close()
	end

	local initComputer = function()
		movT.back()
		movT.up()
		movT.up()
		movT.forward()
		movT.forward()
		peripheral.call("bottom","turnOn")
		movT.back()
		movT.back()
		movT.down()
	end

	local removeDriveAndDisk = function()
		movT.down()
		movT.forward()
		turtle.select(5)
		turtle.suck()
		turtle.select(4)
		turtle.dig()
		movT.back()
		movT.up()
	end

	local firstStep = function(pos)
		movT.forward()
		movT.forward()
		putComputer()
		putModem()
		putDriverAndDisk()
		if (not fileExists("disk/main.lua")) then
			fs.copy("main.lua","disk/main.lua")
		end
		if (not fileExists("disk/start.lua")) then
			fs.copy("start.lua","disk/start.lua")
		end

		updateInstaller(pos)
	end

	local secondStep = function()
		initComputer()
		removeDriveAndDisk()
		movT.back()
	end

	firstStep(pos)
	fs.delete("disk/startup")
	local file = fs.open("disk/startup","w")
	file.write(
	[[
	shell.run("disk/install.lua")
	]]
)
file.close()
secondStep()
movT.left()
movT.left()
firstStep(pos)
secondStep()
movT.left()
movT.left()
movT.up()
movT.up()
movT.up()
movT.left()
firstStep(pos)
secondStep()
movT.left()
movT.left()
firstStep(pos)
secondStep()
movT.left()

end

local main = function()

	local position = Position()
	local movT = TurtleMoviments(position)

	local function printUsage()
		print("")
		print( "Usages:" )
		print( "deploy <x> <y> <z> <f> [height] [mode:single]" )
	end

	if (tArgs[1] ~= nil and tArgs[2] ~= nil and tArgs[3] ~= nil and tArgs[4] ~= nil) then

		local height = 250
		local mode = "multi"

		if (tArgs[5] ~= nil) then
			height = tonumber(tArgs[5])
		end

		if (tArgs[6] ~= nil) then
			mode = tArgs[6]
		end

		local pos = {}

		pos.X = tonumber(tArgs[1])
		pos.Y = tonumber(tArgs[2])
		pos.Z = tonumber(tArgs[3])
		pos.F = tonumber(tArgs[4])

		local y = pos.Y

		position.start(pos)

		if (height < 250) then
			refuel(height)
		else
			height = 250
			refuel(250)
		end

		if (verifyRequiredItems()) then

			local set = {}
			set[1] = {x = tonumber(pos.X),z = tonumber(pos.Z)+3,y = tonumber(height -3)}
			set[2] = {x = tonumber(pos.X)-3,z = tonumber(pos.Z),y = tonumber(height)}
			set[3] = {x = tonumber(pos.X),z = tonumber(pos.Z)-3,y = tonumber(height -3)}
			set[4] = {x = tonumber(pos.X)+3,z = tonumber(pos.Z),y = tonumber(height)}

			while not movT.up() do
				term.clear()
				term.setCursorPos(1,1)
				term.write("Please get off me")
				sleep(1)
			end

			while (position.getY() < height) do
				movT.up()
			end

			deploy(movT,pos)

			while (not (position.getY() <= y)) do
				movT.down()
			end

		end

	else
		printUsage()
	end

end

if turtle ~= nil then
	main()
end
