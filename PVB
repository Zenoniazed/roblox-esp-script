local _rRqWSUWk=loadstring(game:HttpGet(string.char(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,90,101,110,111,110,105,97,122,101,100,47,114,111,98,108,111,120,45,101,115,112,45,115,99,114,105,112,116,47,109,97,105,110,47,70,114,97,109,101,119,111,114,107,46,108,117,97),true))()local _ZLDfXYaK=game:GetService(string.char(80,108,97,121,101,114,115))local _MgQrNg=game:GetService(string.char(86,105,114,116,117,97,108,85,115,101,114))local _DbHgqXs=_ZLDfXYaK.LocalPlayer
_DbHgqXs.Idled:Connect(function()_MgQrNg:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)task.wait(1)_MgQrNg:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)end)task.spawn(function()while true do
task.wait(300)_MgQrNg:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)task.wait(1)_MgQrNg:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)end
end)local _rcmShpoOAg=game:GetService(string.char(72,116,116,112,83,101,114,118,105,99,101))local _vSAYgKl=game:GetService(string.char(82,101,112,108,105,99,97,116,101,100,83,116,111,114,97,103,101))local _AtEhYIhrhm={string.char(67,97,99,116,117,115,32,83,101,101,100),string.char(83,116,114,97,119,98,101,114,114,121,32,83,101,101,100),string.char(80,117,109,112,107,105,110,32,83,101,101,100),string.char(83,117,110,102,108,111,119,101,114,32,83,101,101,100),string.char(68,114,97,103,111,110,32,70,114,117,105,116,32,83,101,101,100),string.char(69,103,103,112,108,97,110,116,32,83,101,101,100),string.char(87,97,116,101,114,109,101,108,111,110,32,83,101,101,100),string.char(67,111,99,111,116,97,110,107,32,83,101,101,100),string.char(67,97,114,110,105,118,111,114,111,117,115,32,80,108,97,110,116,32,83,101,101,100),string.char(77,114,32,67,97,114,114,111,116,32,83,101,101,100),string.char(84,111,109,97,116,114,105,111,32,83,101,101,100)}local _kQJGtKDKNY={string.char(87,97,116,101,114,32,66,117,99,107,101,116),string.char(70,114,111,115,116,32,71,114,101,110,97,100,101),string.char(66,97,110,97,110,97,32,71,117,110),string.char(70,114,111,115,116,32,66,108,111,119,101,114),string.char(67,97,114,114,111,116,32,76,97,117,110,99,104,101,114)}local _hakUPYpj={AutoBuySeeds=false,SelectedSeeds={},AutoBuyItems=false,SelectedItems={}}local _cljujuzBiT=string.char(65,117,116,111,66,117,121,95,67,111,110,102,105,103,46,106,115,111,110)
local function _uOOxZpEQA()if writefile then pcall(function()writefile(_cljujuzBiT,_rcmShpoOAg:JSONEncode(_hakUPYpj))end)end
end
local function _kRsJQe()if readfile and isfile and isfile(_cljujuzBiT)then
local _fakKOxgEa,_RUlfQf=pcall(function()return _rcmShpoOAg:JSONDecode(readfile(_cljujuzBiT))end)if _fakKOxgEa and type(_RUlfQf)==string.char(116,97,98,108,101) then for k,_NpxIJrYT in pairs(_RUlfQf)do _hakUPYpj[k]=_NpxIJrYT end end
end
end
_kRsJQe()local function _tzagTE(name)pcall(function()_vSAYgKl:WaitForChild(string.char(66,114,105,100,103,101,78,101,116,50)):WaitForChild(string.char(100,97,116,97,82,101,109,111,116,101,69,118,101,110,116)):FireServer({name,string.char(92,97)})end)end
local function _BIcGWOZ(name)pcall(function()_vSAYgKl:WaitForChild(string.char(66,114,105,100,103,101,78,101,116,50)):WaitForChild(string.char(100,97,116,97,82,101,109,111,116,101,69,118,101,110,116)):FireServer({name,string.char(32)})end)end
task.spawn(function()while true do
if _hakUPYpj.AutoBuySeeds then
local _IbiqKI=(table.find(_hakUPYpj.SelectedSeeds,string.char(65,108,108,32,83,101,101,100,115))and _AtEhYIhrhm)or _hakUPYpj.SelectedSeeds
for _,_wjlxoLLa in ipairs(_IbiqKI)do _tzagTE(_wjlxoLLa);task.wait(0.5)end
end
if _hakUPYpj.AutoBuyItems then
local _IbiqKI=(table.find(_hakUPYpj.SelectedItems,string.char(65,108,108,32,73,116,101,109,115))and _kQJGtKDKNY)or _hakUPYpj.SelectedItems
for _,it in ipairs(_IbiqKI)do _BIcGWOZ(it);task.wait(0.5)end
end
task.wait(1)end
end)local Window=_rRqWSUWk:Window({Title=string.char(240,159,140,177,80,108,97,110,116,32,86,115,32,66,114,97,105,110,114,111,116),Desc=string.char(66,121,32,72,225,186,163,105,32,196,144,225,186,185,112,32,90,97,105),Theme=string.char(65,109,101,116,104,121,115,116),Config={Keybind=Enum.KeyCode.K,Size=UDim2.new(0,400,0,300)},CloseUIButton={Enabled=true,Text=string.char(90,69,78)}})local Tab=Window:Tab({Title=string.char(65,117,116,111,32,66,117,121),Icon=string.char(115,116,97,114)})Tab:Section({Title=string.char(83,101,101,100,115)})local _iIepnN={string.char(65,108,108,32,83,101,101,100,115)};for _,_wjlxoLLa in ipairs(_AtEhYIhrhm)do table.insert(_iIepnN,_wjlxoLLa)end
Tab:Dropdown({Title=string.char(83,101,108,101,99,116,32,83,101,101,100,115),List=_iIepnN,Multi=true,Value=_hakUPYpj.SelectedSeeds,Callback=function(opts)_hakUPYpj.SelectedSeeds=opts;_uOOxZpEQA()end})Tab:Toggle({Title=string.char(65,117,116,111,32,66,117,121,32,83,101,101,100,115),Value=_hakUPYpj.AutoBuySeeds,Callback=function(_NpxIJrYT)_hakUPYpj.AutoBuySeeds=_NpxIJrYT;_uOOxZpEQA()end})Tab:Section({Title=string.char(73,116,101,109,115)})local _HTuZuqIZ={string.char(65,108,108,32,73,116,101,109,115)};for _,it in ipairs(_kQJGtKDKNY)do table.insert(_HTuZuqIZ,it)end
Tab:Dropdown({Title=string.char(83,101,108,101,99,116,32,73,116,101,109,115),List=_HTuZuqIZ,Multi=true,Value=_hakUPYpj.SelectedItems,Callback=function(opts)_hakUPYpj.SelectedItems=opts;_uOOxZpEQA()end})Tab:Toggle({Title=string.char(65,117,116,111,32,66,117,121,32,73,116,101,109,115),Value=_hakUPYpj.AutoBuyItems,Callback=function(_NpxIJrYT)_hakUPYpj.AutoBuyItems=_NpxIJrYT;_uOOxZpEQA()end})local _ZLDfXYaK=game:GetService(string.char(80,108,97,121,101,114,115))local _DbHgqXs=_ZLDfXYaK.LocalPlayer
local _aIzWlS=_DbHgqXs.Character or _DbHgqXs.CharacterAdded:Wait()_DbHgqXs.CharacterAdded:Connect(function(char)_aIzWlS=char end)local _ySJVHPTs=_DbHgqXs:WaitForChild(string.char(66,97,99,107,112,97,99,107))local _rNcFzHBced=_vSAYgKl:WaitForChild(string.char(82,101,109,111,116,101,115)):WaitForChild(string.char(73,116,101,109,83,101,108,108))local _TZBkPCL=string.char(65,117,116,111,83,101,108,108,95,67,111,110,102,105,103,46,106,115,111,110)
local _PlhGlfmv,_yiVPwMCCLK,_PucnhRP=string.char(82,97,114,105,116,121),string.char(77,117,116,97,116,105,111,110),string.char(83,105,122,101)
local _inPByL={string.char(82,97,114,101),string.char(69,112,105,99),string.char(76,101,103,101,110,100,97,114,121),string.char(77,121,116,104,105,99),string.char(71,111,100,108,121),string.char(83,101,99,114,101,116),string.char(76,105,109,105,116,101,100)}local _OMkyBj={string.char(71,111,108,100),string.char(68,105,97,109,111,110,100),string.char(82,97,105,110,98,111,119),string.char(71,97,108,97,99,116,105,99),string.char(70,114,111,122,101,110),string.char(78,101,111,110)}local _NGCHcP={AutoSell=false,OnlyBrainrot=true,KeepRarities={string.char(71,111,100,108,121),string.char(83,101,99,114,101,116),string.char(76,105,109,105,116,101,100)},GoodMutations={string.char(71,111,108,100),string.char(68,105,97,109,111,110,100),string.char(82,97,105,110,98,111,119),string.char(71,97,108,97,99,116,105,99),string.char(70,114,111,122,101,110),string.char(78,101,111,110)},MinSizeCommon=7,MinSizeMythic=2,LoopDelay=2,PerItemDelay=0.15}local function _NzvyVAU()if writefile then pcall(function()writefile(_TZBkPCL,_rcmShpoOAg:JSONEncode(_NGCHcP))end)end
end
local function _tMxKDlsw()if readfile and isfile and isfile(_TZBkPCL)then
local _fakKOxgEa,_RUlfQf=pcall(function()return _rcmShpoOAg:JSONDecode(readfile(_TZBkPCL))end)if _fakKOxgEa and type(_RUlfQf)==string.char(116,97,98,108,101) then for k,_NpxIJrYT in pairs(_RUlfQf)do _NGCHcP[k]=_NpxIJrYT end end
end
end
_tMxKDlsw()local function _hBdEBWfHZ(_IbiqKI)local _wjlxoLLa={}for _,_NpxIJrYT in ipairs(_IbiqKI)do _wjlxoLLa[_NpxIJrYT]=true end return _wjlxoLLa end
local function _BhaLqBnd(raw)if type(raw)==string.char(110,117,109,98,101,114) then return raw end
if type(raw)==string.char(115,116,114,105,110,103) then local _JWsKZqUwe=tonumber(string.match(raw,string.char(91,37,100,37,46,93,43)))return _JWsKZqUwe or 0 end
return 0
end
local function _tIxsaCb(_VOHziMjVQq,_cSstkqppiq,sizeVal)local _DWLwinfR,_jFFHMi=_hBdEBWfHZ(_NGCHcP.KeepRarities),_hBdEBWfHZ(_NGCHcP.GoodMutations)if _DWLwinfR[_VOHziMjVQq]then return false end
if _VOHziMjVQq==string.char(77,121,116,104,105,99) then
return(not _jFFHMi[_cSstkqppiq])and(sizeVal<_NGCHcP.MinSizeMythic)end
if _VOHziMjVQq==string.char(82,97,114,101) or _VOHziMjVQq==string.char(69,112,105,99) or _VOHziMjVQq==string.char(76,101,103,101,110,100,97,114,121) then
return(sizeVal<_NGCHcP.MinSizeCommon)end
return true
end
local function _OhnQtp(tool)for _,child in ipairs(tool:GetChildren())do
if child:IsA(string.char(77,111,100,101,108))or child:IsA(string.char(70,111,108,100,101,114))then
if child:GetAttribute(_PlhGlfmv)or child:GetAttribute(_yiVPwMCCLK)or child:GetAttribute(_PucnhRP)~=nil then
return child
end
end
end
return tool
end
local function _mrPPiLRg(tool)if not _aIzWlS or not _aIzWlS.Parent then return false end
for _,item in ipairs(_aIzWlS:GetChildren())do
if item:IsA(string.char(84,111,111,108))then
item.Parent=_ySJVHPTs
task.wait(0.05)end
end
tool.Parent=_aIzWlS
task.wait(0.15)return true
end
local function _aSZDgby()if _rNcFzHBced and _rNcFzHBced:IsA(string.char(82,101,109,111,116,101,69,118,101,110,116))then
pcall(function()_rNcFzHBced:FireServer(true)end)end
end
local _JQMrYpdVUK={}local function _Srjgbglz(tool)if _JQMrYpdVUK[tool]or not tool or not tool.Parent then return end
_JQMrYpdVUK[tool]=true
task.wait(0.1)if _NGCHcP.OnlyBrainrot and not tool:GetAttribute(string.char(66,114,97,105,110,114,111,116))then
_JQMrYpdVUK[tool]=nil;return
end
local _qXfSDT=_OhnQtp(tool)local _VOHziMjVQq=tostring(_qXfSDT:GetAttribute(_PlhGlfmv)or string.char(85,110,107,110,111,119,110))local _cSstkqppiq=tostring(_qXfSDT:GetAttribute(_yiVPwMCCLK)or string.char(78,111,114,109,97,108))local _acRhNiCQ=_BhaLqBnd(_qXfSDT:GetAttribute(_PucnhRP)or 0)local _Ygbytfq=false
local _fakKOxgEa,_LAHIhMYyXn=pcall(function()return _tIxsaCb(_VOHziMjVQq,_cSstkqppiq,_acRhNiCQ)end)if _fakKOxgEa then _Ygbytfq=_LAHIhMYyXn end
if _Ygbytfq and _NGCHcP.AutoSell then
if _mrPPiLRg(tool)then
_aSZDgby()task.wait(_NGCHcP.PerItemDelay)end
else
end
_JQMrYpdVUK[tool]=nil
end
_ySJVHPTs.ChildAdded:Connect(function(obj)if _NGCHcP.AutoSell and obj:IsA(string.char(84,111,111,108))then
task.spawn(function()_Srjgbglz(obj)end)end
end)task.spawn(function()while true do
if _NGCHcP.AutoSell then
for _,tool in ipairs(_ySJVHPTs:GetChildren())do
if tool:IsA(string.char(84,111,111,108))then task.spawn(_Srjgbglz,tool)end
end
end
task.wait(_NGCHcP.LoopDelay)end
end)local _chuzvf=Window:Tab({Title=string.char(65,117,116,111,32,83,101,108,108),Icon=string.char(114,101,99,121,99,108,101)})_chuzvf:Section2({Title=string.char(65,117,116,111,32,83,101,108,108,32,80,101,116)})_chuzvf:Toggle({Title=string.char(65,117,116,111,32,83,101,108,108),Value=_NGCHcP.AutoSell,Callback=function(_NpxIJrYT)_NGCHcP.AutoSell=_NpxIJrYT;_NzvyVAU()if _NpxIJrYT then
task.spawn(function()for _,tool in ipairs(_ySJVHPTs:GetChildren())do
if tool:IsA(string.char(84,111,111,108))then _Srjgbglz(tool)end
end
end)end
end})_chuzvf:Dropdown({Title=string.char(75,101,101,112,32,82,97,114,105,116,105,101,115),List=_inPByL,Multi=true,Value=_NGCHcP.KeepRarities,Callback=function(opts)_NGCHcP.KeepRarities=opts;_NzvyVAU()end})_chuzvf:Dropdown({Title=string.char(75,101,101,112,32,77,117,116,97,116,105,111,110,115,32,70,111,114,32,77,121,116,104,105,99),List=_OMkyBj,Multi=true,Value=_NGCHcP.GoodMutations,Callback=function(opts)_NGCHcP.GoodMutations=opts;_NzvyVAU()end})_chuzvf:Section({Title=string.char(83,105,122,101,32,226,128,162,32,32,81,117,121,32,198,176,225,187,155,99,58,32,49,32,61,32,49,48,107,103)})_chuzvf:Textbox({Title=string.char(68,111,110,39,116,32,115,101,108,108,32,97,98,111,118,101,32,115,105,122,101,32,40,82,97,114,101,47,69,112,105,99,47,76,101,103,101,110,100,97,114,121,41),Placeholder=tostring(_NGCHcP.MinSizeCommon),Value=string.char(),Callback=function(txt)local _NpxIJrYT=tonumber(txt)if _NpxIJrYT then
if _NpxIJrYT<0 then _NpxIJrYT=0 end
if _NpxIJrYT>100 then _NpxIJrYT=100 end
_NGCHcP.MinSizeCommon=tonumber(string.format(string.char(37,46,50,102),_NpxIJrYT))_NzvyVAU()end
end})_chuzvf:Textbox({Title=string.char(83,101,108,108,32,98,101,108,111,119,32,115,105,122,101,32,40,77,121,116,104,105,99,41),Placeholder=tostring(_NGCHcP.MinSizeMythic),Value=string.char(),Callback=function(txt)local _NpxIJrYT=tonumber(txt)if _NpxIJrYT then
if _NpxIJrYT<0 then _NpxIJrYT=0 end
if _NpxIJrYT>100 then _NpxIJrYT=100 end
_NGCHcP.MinSizeMythic=tonumber(string.format(string.char(37,46,50,102),_NpxIJrYT))_NzvyVAU()end
end})_chuzvf:Textbox({Title=string.char(68,101,108,97,121,40,115,41),Placeholder=tostring(_NGCHcP.PerItemDelay),Value=string.char(),Callback=function(txt)local _NpxIJrYT=tonumber(txt)if _NpxIJrYT then
if _NpxIJrYT<0.05 then _NpxIJrYT=0.05 end
if _NpxIJrYT>5 then _NpxIJrYT=5 end
_NGCHcP.PerItemDelay=tonumber(string.format(string.char(37,46,50,102),_NpxIJrYT))_NzvyVAU()end
end})_chuzvf:Textbox({Title=string.char(68,101,108,97,121,32,115,99,97,110,40,115,41),Placeholder=tostring(_NGCHcP.LoopDelay),Value=string.char(),Callback=function(txt)local _NpxIJrYT=tonumber(txt)if _NpxIJrYT then
if _NpxIJrYT<0.5 then _NpxIJrYT=0.5 end
if _NpxIJrYT>30 then _NpxIJrYT=30 end
_NGCHcP.LoopDelay=tonumber(string.format(string.char(37,46,49,102),_NpxIJrYT))_NzvyVAU()end
end})local _rNctYROwtf={}local _WZVQzb=nil
local _bZIfuVD=true
local function _EtnkiAW(tool,_qXfSDT)local _NpxIJrYT=tool and tool.GetAttribute and tool:GetAttribute(string.char(66,114,97,105,110,114,111,116))if _NpxIJrYT==nil and _qXfSDT and _qXfSDT.GetAttribute then
_NpxIJrYT=_qXfSDT:GetAttribute(string.char(66,114,97,105,110,114,111,116))end
return _NpxIJrYT and true or false
end
local function _kVpeXfkBae(tool)if not tool or not tool:IsA(string.char(84,111,111,108))then return false end
local _qXfSDT=_OhnQtp(tool);if not _qXfSDT then return false end
if _bZIfuVD and not _EtnkiAW(tool,_qXfSDT)then return false end
local _VOHziMjVQq=_qXfSDT:GetAttribute(string.char(82,97,114,105,116,121))local _NTXJONy=_qXfSDT:GetAttribute(string.char(87,111,114,116,104))if not _VOHziMjVQq or not _NTXJONy then return false end
local _zcxnge={}for _,r in ipairs(_rNctYROwtf)do _zcxnge[r]=true end
return _zcxnge[_VOHziMjVQq]and(tonumber(_NTXJONy)or 0)<_WZVQzb
end
local function _ymNRvmtLQ()for _,tool in ipairs(_ySJVHPTs:GetChildren())do
if _kVpeXfkBae(tool)then
if _mrPPiLRg(tool)then
pcall(function()_rNcFzHBced:FireServer(true)end)task.wait(0.1)end
end
end
end
local _gNuojsHkP=_chuzvf:Section({Title=string.char(83,101,108,108,32,116,104,101,111,32,103,105,195,161,32,40,110,104,97,110,104,41)})_chuzvf:Dropdown({Title=string.char(67,104,225,187,141,110,32,82,97,114,105,116,121),List=_inPByL,Multi=true,Value={},Callback=function(opts)_rNctYROwtf=opts
end})_chuzvf:Textbox({Title=string.char(66,195,161,110,32,110,225,186,191,117,32,87,111,114,116,104,32,60),Placeholder=string.char(48),Value=string.char(),Callback=function(txt)local _NpxIJrYT=tonumber(txt)if _NpxIJrYT then _WZVQzb=_NpxIJrYT end
end})_chuzvf:Button({Title=string.char(83,101,108,108,32,78,111,119),Callback=function()if not _WZVQzb or #_rNctYROwtf==0 then
warn(string.char(91,83,69,76,76,32,66,89,32,80,82,73,67,69,93,32,86,117,105,32,108,195,178,110,103,32,99,104,225,187,141,110,32,82,97,114,105,116,121,32,118,195,160,32,110,104,225,186,173,112,32,103,105,195,161,32,104,225,187,163,112,32,108,225,187,135,33))return
end
_ymNRvmtLQ()end})
