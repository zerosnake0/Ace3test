local AceGUI = assert(LibStub("AceGUI-3.0"))

local frame
function Ace3test:TestAceGUI()
	self:TestBegin("AceGUI")
	if not frame then
		frame = AceGUI:Create("Frame")
		frame:SetTitle("Example Frame")
		frame:SetStatusText("AceGUI-3.0 Example Container Frame")

		local editbox = AceGUI:Create("EditBox")
		editbox:SetLabel("Insert text:")
		editbox:SetWidth(400)
		frame:AddChild(editbox)

	elseif frame:IsShown() then
		frame:Hide()
	else
		frame:Show()
	end
end