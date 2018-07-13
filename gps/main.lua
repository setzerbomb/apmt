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

--TableHandler: Load/Save data from/to the data file
local function TableHandler()
	-- Local variables of the object / Variáveis locais do objeto
	local self = {}

	-- Global functions of the object / Funções Globais do objeto

	-- Verify if the file called exists / Verifica se o arquivo chamado existe
	function self.fileExists(name)
		local f=fs.open(name,"r")
		if f==nil then
			return false
		else
			return true
		end
	end

	-- Save the data of the table in a file / Salva os dados da tabela em um arquivo
	function self.save(localTable,name)
		local file = fs.open(name,"w")
		file.write(textutils.serialize(localTable))
		file.close()
	end

	-- Read the data of a file and try to put into a table / Lê os dados de um arquivo e tenta coloca-lo em uma tabela
	function self.load(name)
		if self.fileExists(name) then
			local file = fs.open(name,"r")
			local data = file.readAll()
			file.close()
			return textutils.unserialize(data)
		else
			return nil
		end
	end

	return self
end

--Saved Position: A class that stores the position data of the computer/turtle

local function SavedPosition()
	-- Local variables of the object / Variáveis locais do objeto
	local self = {}
	local data

	-- Global functions of the object / Funções Globais do objeto

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

--LoadPeripherals: Tries to identify and get any peripherals next to the turtle

local function LoadPeripherals ()
	-- Local variables of the object / Variáveis locais do objeto
	local self = {}
	local wraped = {}
	local types = {}
	-- Global functions of the object / Funções Globais do objeto
	-- Return a specific peripheral / Retorna um periférico específico
	function self.getPeripheral(key)
		return wraped[key]
	end

	-- Return the table of types of peripherals / Retorna a tabela contendo os tipos de periféricos
	function self.getTypes()
		return types
	end

	-- Print the list of peripherals / Imprime na tela a lista de periféricos
	function self.showTypes()
		return textutils.serialize(types)
	end

	-- Local Functions / Funções Locais

	-- The start function / A função de inicialização
	local function start()
	  --os.loadAPI("ocs/apis/sensor")

	  for k,v in ipairs(peripheral.getNames())do
		wraped[k] = peripheral.wrap(v)
		types[k] = {}
		if peripheral.getType(v)=="sensor" then
			types[k][1] = wraped[k].getSensorName()
			types[k][2] = v
		else
			types[k][1] = peripheral.getType(v)
			types[k][2] = v
		end
	  end
	end
	start()

   return self
end

--GUIKeepData: A class showing a GUI that allows a manual configuration of the stored position on the computer/turtle

local function GUIKeepData(commonFunctions)
	-- Local variables of the object / Variáveis locais do objeto
	local self = {}
	local CommonF = commonFunctions

	function self.begin()
		print("Starting manual configuration")
	end

	function self.setPositionData()
		local Position = {}
		local errorFlag = true
		while errorFlag do
			errorFlag = false
			print("---------Device Postion---------")
			print("Type the X coordinate of the device")
			Position.X = tonumber(io.read())
			print("Type the Y coordinate of the device")
			Position.Y = tonumber(io.read())
			print("Type the Z coordinate of the device")
			Position.Z = tonumber(io.read())
			print("Type the F coordinate of the device")
			Position.F = tonumber(io.read())

			if Position.X == nil or Position.Y == nil or Position.Z == nil or Position.F == nil then
				print("Warning: X,Y,Z and F must be numbers")
				errorFlag = true
			else
				if Position.F ~= nil then
					if Position.F > 3 or Position.F < 0 then
						print("Warning: F must be a number between 0 and 3")
						errorFlag = true
					end
				end
			end
		end

		return Position
	end

	return self

end

--DataController: Responsible to fill the objects with the data gathered from the file on TableHandler class
local function DataController(commonFunctions)
	-- Local variables of the object / Variáveis locais do objeto
	local self = {}

	local TableH = TableHandler()
	local guiKP = GUIKeepData(commonFunctions)

	local values = nil
	local objects = {}
	objects.savedPosition = SavedPosition()
	-- Local functions of the object / Funções locais do objeto

	-- Copy the all content of a table: http://lua-users.org/wiki/CopyTable
	local function deepcopy(orig)
		local orig_type = type(orig)
		local copy
		if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in next, orig, nil do
				copy[deepcopy(orig_key)] = deepcopy(orig_value)
			end
			setmetatable(copy, deepcopy(getmetatable(orig)))
		else
			copy = orig
		end
		return copy
	end

	local function fillObjects()
		objects.savedPosition.start(values.SavedPosition)
	end

	-- Create a new set data if the data file is empty / Cria um novo conjunto de dados se o arquivo de dados está vazio
	local function newData()
		values = {}
		local gpsWorks = false
		guiKP.begin()
		values.SavedPosition = guiKP.setPositionData(true)
		fillObjects()
		self.saveData()
	end

	-- Global functions of the object / Funções Globais do objeto

	-- Verify if the values table that contains all data objets in empty, if is nil, creates a new set of data / Verifica se a tabela de valores contém todos os dados necessários, senão os cria novamente
	local function configureDataObjects()
		if values ~= nil and next(values) ~= nil then
			fillObjects()
		else
			newData()
		end
	end

	-- Retrieve the data from the config file / Puxa os dados do arquivo de configuração
	function self.load()
		if TableH.fileExists(os.getComputerLabel()) then
			values =  TableH.load(os.getComputerLabel())
		end
			configureDataObjects()
	end

	-- Save the data into the config file / Salva os dados no arquivo de configuração
	function self.saveData()
		TableH.save(values,os.getComputerLabel())
	end

	-- Getters

	function self.getObjects()
		return objects
	end

	return self
end

--Classe MainGUI
local function GUIMain(commonFunctions)
	-- Local variables of the object / Variáveis locais do objeto
	local self = {}
	local CommonF = commonFunctions

	-- Global functions of the object / Funções Globais do objeto

	function self.menu()
		print("------Main Menu------")
		print("1: Configure")
		print("2: Exit")
		return CommonF.limitToWrite(15)
	end
	return self
end

local openWirelessModem =  function(types)

	local locateModemSide = function(types)
		for k,v in ipairs(types) do
			if (v[1] == "modem") then
				return v[2]
			end
		end
		return nil
	end

	local side = locateModemSide(types)

	if (side ~= null) then
	    if (rednet.isOpen(side) == false) then
			rednet.open(side)
		end
		return true
	end
	return false
end

local location = function(x,y,z,f)
	if (x ~= 0 or y~=0 or z~=0 or f~=0) then
		local p = LoadPeripherals()
		if (openWirelessModem(p.getTypes())) then
			local protocol = "location"

			rednet.host(protocol,"locationServer" .. os.getComputerID())
			print("Open to receive requisitions")

			while true do

				local data = {os.pullEvent()}

				if (data[1] == "modem_message") then
					local senderId = data[4]
					local message = data[5].message
					local senderProtocol = data[5].sProtocol
					local distance = data[6]

					if (senderProtocol == protocol) then
						rednet.send(senderId,textutils.serialize({x,y,z,f,distance}),protocol)
					end
				end
			end
		end
	end
end

local main = function()
	local commonF = CommonFunctions()
	local dc = DataController(commonF)
	local guiMain = GUIMain(commonF)
	local guiKP = GUIKeepData(commonF)
	local savedPos = dc.getObjects().savedPosition

	if os.getComputerLabel() == nil then
		os.setComputerLabel("PC"..os.getComputerID())
	end

	dc.load()

	local mainCase = commonF.switch{
		[1] = function(x)
			local vectorData = guiKP.setPositionData(false)
			savedPos.setX(vectorData.X)
			savedPos.setY(vectorData.Y)
			savedPos.setZ(vectorData.Z)
			savedPos.setF(vectorData.F)
			dc.saveData()
		end,
		default = function (x) end
	}

	local r = 0;
	print ("Type anithing to access the main menu")
	r = commonF.limitToWrite(3)

	if r ~= 0 then
		mainCase:case(tonumber(guiMain.menu()))
	end

	location(savedPos.getX(),savedPos.getY(),savedPos.getZ(),savedPos.getF())

end

main()
