function Maintenance(miningTurtle,guiCustomMessages)
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local gps = TurtlePositionLookup()
  local miningT = miningTurtle
  local commonF = miningT.getCommonF()
  local Data = miningT.getData()
  local gtp = GoToPosition(miningT,guiCustomMessages)
  local specificData = nil
  local objects = Data.getObjects()
  local storageGhosts = objects.ghosts.getStorageGhosts()
  local lightGhosts = objects.ghosts.getLightGhosts()
  local combustiveis = objects.fuels.getFuels()
  local guiMessages = guiCustomMessages or GUIMessages()
  local meta = {}
  local actionsCase = nil
  -- Private functions / Funções privadas

  local function talkWithMaster()
    objects.task.setStatus(false)
	objects.task.complete()
  end

  local imInHome = function(x,y,z)
    if ((objects.home.getX() == x) and (objects.home.getY() == y) and (objects.home.getZ() == z)) then
      return true
    end
    return false
  end

  local function finalize()
    Data.finalizeExecution()
  end

  local function newInternalData()
    local newData = {}
    newData.continue = true
    newData.searchForHelp = false
    newData.goBack = true
    newData.terminate = false
    specificData = newData
    return newData
  end

  local function main()
    if objects.execution.getExecuting() ~= "Maintenance" then
      objects.execution.setExecuting("Maintenance")
      objects.execution.setStep(0)
      objects.execution.setTerminate(false)
      objects.escape.setTryToEscape(true)
      objects.execution.setSpecificData(newInternalData())
    else
      specificData = objects.execution.getSpecificData()
    end
    miningT.saveAll()
  end

  local function restart()
    finalize()
    main()
    os.reboot()
  end

  local function searchChest()
    local isFull,j,item
    local upChestExists
    local sucess,data = turtle.inspectUp()
    if sucess then
      upChestExists = (storageGhosts[data.name] ~= nil)
    end
    for i = 1,4 do
      isFull = false
      j = 1
      sucess,data = turtle.inspect()
      if sucess then
        if storageGhosts[data.name] ~= nil then
          for j = 1,16 do
            turtle.select(j)
            if turtle.getItemCount() > 0 then
              local item = turtle.getItemDetail()
              if (j ~= objects.light.getSlot() or lightGhosts[item.name] == nil) and ((j ~= objects.storages.getSlotOut() and j ~= objects.storages.getSlotIn()) or storageGhosts[item.name] == nil) then
                if (lightGhosts[item.name] ~= nil or combustiveis[item.name] ~= 0 or storageGhosts[item.name] ~= nil) and upChestExists then
                  turtle.dropUp()
                else
                  if not turtle.drop() then
                    isFull = true
                  end
                end
              end
            end
          end
          if not isFull then
            return true
          else
            miningT.left()
          end
        else
          miningT.left()
        end
      else
        miningT.left()
      end
    end
    return false
  end

  local function callHelp()
    local p = LoadPeripherals()
    local errorFlag = false
    guiMessages.showInfoMsg("Press any key to sinalize that everything is ok")
    local resp = commonF.limitToWrite(2.5)
    if resp == 0 then
      if (p.openWirelessModem(p.getTypes())) then
        local position = gps.main()
        if (position ~= nil) then
          if (not imInHome(position.x,position.y,position.z)) then
            local guiKP = GUIKeepData()
            position.f = guiKP.getOrientation(gps,miningT)
            if (position.f >= 0) then
              guiMessages.showSuccessMsg(textutils.serialize(position))
              objects.position.setX(position.x)
              objects.position.setY(position.y)
              objects.position.setZ(position.z)
              objects.position.setF(position.f)
              Data.saveData()
            else
              errorFlag = true
            end
          end
        else
          errorFlag = true
        end
      end
      if errorFlag then
        return false
      end
    else
      restart()
    end
    return true
  end

  local function storeFuel(drop)
    local item
    for i = 1,16 do
      turtle.select(i)
      item = turtle.getItemDetail()
      if item ~= nil then
        if lightGhosts[item.name] == nil and storageGhosts[item.name] == nil then
          turtle.select(i)
          drop()
        end
      end
    end
  end

  local function organizeResources(drop)
    guiMessages.showInfoMsg("Organizing and Storing Resources")
    local function searchFreeSlot()
      tabela = {}
      cont=1
      for i = 1,16 do
        if turtle.getItemCount(i) == 0 then
          tabela[cont]=i
          cont = cont + 1
        end
      end
      return tabela
    end
    local function clearDefinedSlots(slot,fSlots)
      if turtle.getItemCount(slot) > 0 then
        local item = turtle.getItemDetail(slot)
        if lightGhosts[item.name] == nil and storageGhosts[item.name] == nil and item.name~= "EnderStorage:enderChest" then
          turtle.select(slot)
          if #fSlots > 0 then
            turtle.transferTo(fSlots[#fSlots])
            table.remove(fSlots,#fSlots)
          else
            turtle.drop()
          end
          return true
        end
      end
      return false
    end
    local function ordering(protectedGhost,slotR)
      if (protectedGhost ~= nil and slotR ~= nil) then
        for i = 1,16 do
          turtle.select(i)
          if turtle.getItemCount(slotR) < 64 then
            item = turtle.getItemDetail()
            if item ~= nil then
              if protectedGhost[item.name] ~= nil	then
                turtle.transferTo(slotR)
              end
            end
          else
            return
          end
        end
      end
    end
    local function storeLeavings()
      for i = 1,16 do
        turtle.select(i)
        if i ~= objects.light.getSlot() and i ~= objects.storages.getSlotIn()  and i ~= objects.storages.getSlotOut() then
          drop()
        end
      end
    end

    local freeSlots = searchFreeSlot()
    local stop = clearDefinedSlots(objects.light.getSlot(),freeSlots)	and  clearDefinedSlots(objects.storages.getSlotIn(),freeSlots) and clearDefinedSlots(objects.storages.getSlotOut(),freeSlots)
    if not stop then
      ordering(lightGhosts,objects.light.getSlot())
      ordering(storageGhosts,objects.storages.getSlotIn())
      ordering(storageGhosts,objects.storages.getSlotOut())
    end
    storeLeavings()
  end

  local function goHome()
    if miningT.getDistance(objects.home.getX(),objects.home.getY(),objects.home.getZ()) > 0 then
      gtp.backTo(objects.home.getX(),objects.home.getY(),objects.home.getZ())
    end
  end

  local localStorageActionsCase = commonF.switch{
    [0] = function(x)
      if not searchChest() then
        specificData.continue = false
        specificData.goBack = false
      end
    end,
    [1] = function(x)
      if not specificData.continue then
        print("I think that i'm lost...")
        specificData.terminate = true
        specificData.searchForHelp = true
      end
    end,
    [2] = function(x) turtle.select(1) end,
    [3] = function(x) while turtle.suckUp() do end end,
    [4] = function(x) turtle.select(1) end,
    [5] = function(x) miningT.forceRefuel() end,
    [6] = function(x) storeFuel(turtle.dropUp) end,
    [7] = function(x) organizeResources(turtle.dropUp) end,
    [8] = function(x)
      turtle.select(1)
      if (((miningT.getDistance(objects.previousPosition.getX(),objects.previousPosition.getY(),objects.previousPosition.getZ())*2) + 1) > turtle.getFuelLevel()) or objects.storedExecution.getExecuting() == "" then
        guiMessages.showWarningMsg("It's not worth going back to the previous operation")
        Data.previousPosIsHome()
        specificData.goBack = false
        specificData.terminate = true
        miningT.saveAll()
      end
    end,
    [9] = function(x) miningT.down() end,
    [10] = function(x) gtp.goTo(objects.previousPosition.getX(),objects.previousPosition.getY(),objects.previousPosition.getZ()) end,
    [11] = function(x)
      while objects.position.getF() ~= objects.previousPosition.getF() do
        miningT.left()
      end
    end,
    default = function (x) return 0 end
  }

  local enderStorageActionsCase = commonF.switch{
    [0] = function(x)
      local function verifyIfEnderStoragesAreSetUp(slot)
        if turtle.getItemCount(slot) > 0 then
          local item = turtle.getItemDetail(slot)
          if storageGhosts[item.name] ~= nil and item.name == "EnderStorage:enderChest" then
            return true
          end
        end
        return false
      end
      miningT.forward()
      miningT.back()
      if (not(verifyIfEnderStoragesAreSetUp(objects.storages.getSlotIn()) and verifyIfEnderStoragesAreSetUp(objects.storages.getSlotOut()))) then
        objects.storages.disableEnder()
        restart()
      end
    end,
    [1] = function(x)
      local slot = objects.storages.getSlotOut()
      miningT.select(slot)
      miningT.placeForward()
    end,
    [2] = function(x)
      for j = 1,16 do
        turtle.select(j)
        if turtle.getItemCount() > 0 then
          local item = turtle.getItemDetail()
          if (j ~= objects.light.getSlot() or lightGhosts[item.name] == nil) and ((j ~= objects.storages.getSlotOut() and j ~= objects.storages.getSlotIn()) or storageGhosts[item.name] == nil) then
            if not (lightGhosts[item.name] ~= nil or combustiveis[item.name] ~= 0 or storageGhosts[item.name] ~= nil) then
              if not turtle.drop() then
                restart()
              end
            end
          end
        end
      end
    end,
    [3] = function(x)
      local slot = objects.storages.getSlotOut()
      miningT.select(slot)
      miningT.digForward()
    end,
    [4] = function(x) turtle.select(1) end,
    [5] = function(x)
      local slot = objects.storages.getSlotIn()
      miningT.select(slot)
      miningT.placeForward()
    end,
    [6] = function(x) while turtle.suck() do end end,
    [7] = function(x) miningT.forceRefuel() end,
    [8] = function(x) storeFuel(turtle.drop) end,
    [9] = function(x) organizeResources(turtle.drop) end,
    [10] = function(x)
      local slot = objects.storages.getSlotIn()
      miningT.select(slot)
      miningT.digForward()
    end,
    [11] = function(x)
      local protectedGhost = storageGhosts
      local slot = objects.storages.getSlotIn()
      turtle.select(1)
      if (turtle.getItemCount(slot) > 0) then
        local item = turtle.getItemDetail(slot)
        if storageGhosts[item.name] ~= nil and item.name == "EnderStorage:enderChest" then
          return true
        else
          local foundEmptySlot = false
          local iterator = 1
          --print("teste")
          while (not foundEmptySlot and iterator <=16) do
            if (turtle.getItemCount(iterator) == 0 and (iterator ~= objects.light.getSlot() and iterator ~= objects.storages.getSlotOut() and iterator ~= objects.storages.getSlotIn())) then
              foundEmptySlot = true
              turtle.select(slot)
              turtle.transferTo(iterator)
            else
              iterator = iterator + 1
            end
          end
          if (foundEmptySlot) then
            if (protectedGhost ~= nil) then
              for i = 1,16 do
                turtle.select(i)
                if (turtle.getItemCount() > 0) then
                  local item = turtle.getItemDetail()
                  if ((protectedGhost[item.name] ~= nil and item.name == "EnderStorage:enderChest") and (i ~= objects.storages.getSlotOut())) then
                    turtle.transferTo(slot)
                  end
                end
              end
            end
          end
        end
      end
    end,
    default = function (x) return 0 end
  }


  local function patternAction()
    while objects.execution.getStep() <=11 and not specificData.terminate do
      actionsCase:case(objects.execution.getStep())
      objects.execution.addStep()
      miningT.saveAll()
    end
    objects.execution.setStep(0)
    miningT.saveAll()
  end

  -- Global functions of the object / Funções Globais do objeto

  function self.start()
    if (objects.storages.isEnabled()) then
      actionsCase = enderStorageActionsCase
    else
      actionsCase = localStorageActionsCase
      guiMessages.showInfoMsg("Well, let's get back to home")
      goHome()
    end
    patternAction()
    if specificData.searchForHelp then
      --print("Searching for help, trying to stabilich communication using procotol: Rescue")
      --guiMessages.showInfoMsg("Use helper.lua in another device that contains a wireless interface")
      if not callHelp() then
        guiMessages.showErrorMsg("Failed to get help")
        return false,false;
      else
        --objects.outsideCommunication.setNaoRepetirErro(false)
        finalize()
        main()
        if (not imInHome(objects.position.getX(),objects.position.getY(),objects.position.getZ())) then
          os.reboot()
        else
          guiMessages.showErrorMsg("Failed to get help")
        end
      end
    else
      finalize()
      Data.restoreStoredExecution()
      if not specificData.goBack then
	      talkWithMaster()
        finalize()
      end
      os.reboot()
    end
  end

  main()

  return self
end
