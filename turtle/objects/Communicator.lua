function Communicator(commonF)

  local self = {}

  local loadPeripherals = nil
  local hasModem = false

  local function createTask()
    local task = {}
	task.execution = ""
	task.params = {}
	return task
  end

  local function executeNTimes(f,params)
    local data = nil
    for i = 1,10 do
	  data = f(params)
      if data ~= nil then
	    return data,true
      end
	end
	return nil,false
  end

  local function generateProcotol()
    local server = rednet.lookup("apmtSlaveConnection")
    if hasModem and server ~= nil then
	  local data,status = executeNTimes(
	    function ()
		  rednet.send(server,os.getComputerID(),"apmtSlaveConnection")
		  local s,m,p = rednet.receive(server .. os.getComputerID(),0.5)
          if (s ~= nil) then
		    return {s,m,p}
          end
          return nil
		end
	  )
	  if status then
	    local number = commonF.randomness(100,999)
	    data[3] = data[1] .. os.getComputerID()
		data[4] = number
	    data,status = executeNTimes(
	      function (params)
		    local s,m,p = rednet.receive(params[3],0.5)
		    if (s ~= nil) then
		      return {s,m,p}
            end
		    return nil
		  end,
		  data
	    )
		data[4] = number
		if status then
		  executeNTimes(
		    function (params)
		      rednet.send(params[1],params[4],params[3])
		  	  sleep(0.2)
		    end,
		    data
		  )
		end
		if status then
		  return {data[3] .. (data[2] * number),server,true}
		end
      end
	end
	return {nil,false}
  end

  local function main()
    lp = LoadPeripherals()
	hasModem = lp.openWirelessModem(lp.getTypes())
  end

  self.protocolGenerator = function ()
    return generateProcotol()
  end

  self.waitForTask = function(protocol)
    local task = createTask()
	local data,status executeNTimes(
	  function(params)
	    local s,m,p = rednet.receive(params[1],1)
		if (s ~= nil) then
		  local unserializedData = textutils.unserialize(m)
		  if unserializedData ~=nil then
		    params[2].execution = unserializedData.execution
			params[2].params = unserializedData.params
			params[2].complete = unserializedData.complete
			params[2].sent = true
		    return true
		  end
        end
		return nil
	  end,
	  {protocol,task}
	)
    return task
  end

  self.finishTask = function(task,status,server,protocol)
    task.complete = true
	task.status = status
	executeNTimes(
	   function (params)
	     --GUIMessages().debug(params[1] .. textutils.serialize(params[2]) .. params[3])
	     rednet.send(params[1],textutils.serialize(params[2]),params[3])
	     sleep(0.5)
		   return nil
	   end,
	   {server,task,protocol}
	)
  end

  main()

  return self
end
