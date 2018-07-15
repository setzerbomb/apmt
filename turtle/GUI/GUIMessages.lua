function GUIMessages()

  local self = {}

  local function showMsgInColor(msg,color)
    if (term.isColor()) then
      term.setTextColor(color)
      print(msg)
      term.setTextColor(colors.white)
    else
      print(msg)
    end
  end

  function self.showErrorMsg(msg)
    showMsgInColor(msg,colors.red)
    print("")
  end

  function self.showSuccessMsg(msg)
    showMsgInColor(msg,colors.lime)
  end

  function self.showWarningMsg(msg)
    showMsgInColor(msg,colors.yellow)
  end

  function self.showInfoMsg(msg)
    showMsgInColor(msg,colors.lightBlue)
  end

  function self.showHeader(msg)
    showMsgInColor(msg,colors.blue)
  end

  function self.debug(msg)
    local p = LoadPeripherals()
    p.openWirelessModem(p.getTypes())
    showMsgInColor(msg,colors.orange)
    rednet.broadcast(msg,"debug")
  end

  return self

end
