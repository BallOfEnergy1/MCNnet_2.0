--Node (beta)
local netname="Internet" --change this: network name
local component=require("component")
local computer=require("computer")
local ser=require("serialization")
if not component.isAvailable("modem") then error("You gonna need a modem.") end
local modem=component.modem
local thread=require("thread")
local event=require("event")
local gpu=component.gpu
local mnp=require("mnp")
local session=require("session")
local ip=require("ipv2")
local dns=require("dns")

local function log(text,crit)
  local res="["..computer.uptime().."]"
  if crit==0 or not crit then
    print(res.."[NODE/INFO]"..text)
  elseif crit==1 then
    gpu.setForeground(0xFFFF33)
    print(res.."[NODE/WARN]"..text)
    gpu.setForeground(0xFFFFFF)
  elseif crit==2 then
    gpu.setForeground(0xFF3333)
    print(res.."[NODE/ERROR]"..text)
    gpu.setForeground(0xFFFFFF)
  elseif crit==3 then
    gpu.setForeground(0xFF3333)
    print(res.."[NODE/FATAL]"..text)
    gpu.setForeground(0xFFFFFF)
    local file=io.open("node_err.log","w")
    file:write(res..text)
    file:close()
    error("Fatal error occured in runtime,see log file")
  else end
end


--setup
os.sleep(0.1)
print("---------------------------")
log("Node Starting - Hello World!")
log("Checking modem")
if not modem.isWireless() then log("Modem is recommended to be wireless, bro") end
if modem.getStrength()<400 then log("Modem strength is recommended to be default 400",1) end
log("Setup ipv2...")
ip.setMode("NODE")
if not ip.set(ip.gnip()) then log("Could not set node IP",3) end
log("Setup DNS...")
dns.init()
log("Registering!")
local timeout=2
local attempts=5
log("Searching for nodes... Should take "..timeout*attempts.." seconds")
if not mnp.node_register(attempts,timeout) then log("Could not set register: check if ip is set?",3) end
log("Setup MNP")
if not mnp.openPorts() then log("Could not open ports",3) end
mnp.setNetworkName(netname)
log("Starting MNCP")
thread.create(mnp.mncpService):detach()
--main
log("Node Online!")