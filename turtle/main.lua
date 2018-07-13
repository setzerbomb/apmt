local root = "turtle/"

dofile(root .. "programs/MainApp.lua")

local turnOn = true

for k,v in pairs(redstone.getSides()) do
  if redstone.getInput(v) then
    turnOn = false
    break
  end
end

if turnOn then
	if os.getComputerLabel() == nil then
		os.setComputerLabel("PC"..os.getComputerID())
	end
	local mainApp = MainApp(root)
	mainApp.main()
end
