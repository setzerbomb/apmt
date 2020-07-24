function Configuration(miningTurtle)
  local dc = miningTurtle.getData()
  local commonF = miningTurtle.getCommonF()
  local limit = 15
  local continue = true
  local objects = dc.getObjects()
  local guiKP = GUIKeepData(commonF)

  local dataCase =
    commonF.switch {
    [1] = function(x)
      local localTable = guiKP.setPositionData(false)
      objects.position.setX(localTable.x)
      objects.position.setY(localTable.y)
      objects.position.setZ(localTable.z)
      objects.position.setF(localTable.f)
      guiKP.showSuccessMsg("Done")
    end,
    [2] = function(x)
      local localTable = guiKP.homeManualSet()
      objects.home.setX(localTable.x)
      objects.home.setY(localTable.y)
      objects.home.setZ(localTable.z)
      objects.home.setHome()
      guiKP.showSuccessMsg("Done")
    end,
    [3] = function(x)
      objects.execution.setExecuting("")
      objects.execution.setStep(0)
      objects.execution.setSpecificData(nil)
      objects.execution.setTerminate(false)
      objects.storedExecution.setExecuting("")
      objects.storedExecution.setStep(0)
      objects.storedExecution.setSpecificData(nil)
      objects.storedExecution.setTerminate(false)
      objects.previousPosition.setX(objects.position.getX())
      objects.previousPosition.setY(objects.position.getY())
      objects.previousPosition.setZ(objects.position.getZ())
      objects.previousPosition.setF(objects.position.getF())
      objects.task.reset()
      guiKP.showSuccessMsg("Done")
    end,
    [4] = function(x)
      local localTable = nil
      while (localTable == nil) do
        localTable = guiKP.setLightData(false)
        if (localTable.slot == objects.storages.getSlotIn() or localTable.slot == objects.storages.getSlotOut()) then
          guiKP.showErrorMsg(
            "Configuration conflict! Values must be different than EnderChest In/Out Slots: [" ..
              objects.storages.getSlotIn() .. "," .. objects.storages.getSlotOut() .. "]"
          )
          localTable = nil
        end
      end
      objects.light.setStep(localTable.step)
      objects.light.setSlot(localTable.slot)
      objects.light.setEnabled(localTable.enabled)
      guiKP.showSuccessMsg("Done")
    end,
    [5] = function(x)
      local localTable = guiKP.setTurtleInfo()
      objects.turtleInfo.setWorld(localTable.world)
      if (localTable.isSlave) then
        objects.turtleInfo.activateSlaveBehavior()
      else
        objects.turtleInfo.deactivateSlaveBehavior()
      end
      guiKP.showSuccessMsg("Done")
    end,
    [6] = function(x)
      local localTable = nil
      while (localTable == nil) do
        localTable = guiKP.setStorages(false)
        if (localTable.slotIn == objects.light.getSlot() or localTable.slotOut == objects.light.getSlot()) then
          guiKP.showErrorMsg(
            "Configuration conflict! Values must be different than Torch Light Slot: [" ..
              objects.light.getSlot() .. "]"
          )
          localTable = nil
        end
      end
      objects.storages.setSlotIn(localTable.slotIn)
      objects.storages.setSlotOut(localTable.slotOut)
      if (localTable.enabled) then
        objects.storages.enableEnder()
      else
        objects.storages.disableEnder()
      end
      guiKP.showSuccessMsg("Done")
    end,
    [7] = function(x)
      dc.saveData()
      continue = false
      guiKP.showSuccessMsg("Saved")
      if objects.turtleInfo.isSlave() then
        os.reboot()
      end
    end,
    [8] = function(x)
      continue = false
    end,
    default = function(x)
      guiKP.showErrorMsg("Invalid option")
    end
  }

  while continue do
    dataCase:case(tonumber(guiKP.menu()))
  end
end
