function LightController(miningT)

  local self = {}
  
  local objects = (miningT.getData()).getObjects()

  local function placeTorch(slot,where)
    miningT.select(slot)
      if where == "left" then
        miningT.left()
        miningT.placeForward()
        miningT.right()
      else
        if where == "right" then
        miningT.right()
        miningT.placeForward()
        miningT.left()
      else
        miningT.placeDown()
      end
    end
    miningT.select(1)
  end

  function self.enlighten(where,limit)
    if objects.light.getEnabled() then
      if objects.light.getStep()  >= limit then
        local itemDetail = turtle.getItemDetail(objects.light.getSlot())
        if itemDetail~=nil then
          if itemDetail.name == "minecraft:torch" and turtle.getItemCount(objects.light.getSlot()) > 1 then
            placeTorch(objects.light.getSlot(),where)
          end
        end
        objects.light.setStep(0)
      else
        objects.light.addStep()
      end
    end
  end

  return self
end
