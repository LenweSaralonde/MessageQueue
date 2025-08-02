MessageQueue = {}

local queue = {}
local updaterFrame
local queueFrame
local pixelFrame
local flashTimer

local FlashClientIcon = function() FlashClientIcon() end -- C_Timer does not allow C functions so let's wrap this bad boy
local SendChatMessage = (C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage)

--- Main initialization
--
MessageQueue.Init = function()
	-- Create gray pixel frame at the top left corner for external key triggering
	pixelFrame = CreateFrame('Frame', 'MessageQueuePixelFrame')
	pixelFrame:SetSize(1, 1)
	pixelFrame:SetPoint('TOPLEFT')
	pixelFrame:Hide()
	pixelFrame.texture = pixelFrame:CreateTexture('MessageQueueFrameTexture', 'OVERLAY', nil, 7)
	pixelFrame.texture:SetColorTexture(0.2, 0.2, 0.2, 1) -- #333333
	pixelFrame.texture:SetAllPoints()

	-- Create queue frame to capture hardware events and proceed with the queue
	queueFrame = CreateFrame('Frame', 'MessageQueueFrame')
	queueFrame:SetPoint('TOPLEFT')
	queueFrame:SetPoint('BOTTOMRIGHT')
	queueFrame:Hide()

	-- Enable any possible hardware control
	queueFrame:EnableMouse(true)
	queueFrame:EnableMouseWheel(true)
	queueFrame:SetMouseMotionEnabled(true)
	queueFrame:EnableGamePadButton(true)
	queueFrame:EnableGamePadStick(true)
	queueFrame:EnableKeyboard(true)
	queueFrame:SetPropagateKeyboardInput(true)

	-- Capture any possible hardware event
	queueFrame:SetScript("OnMouseDown", MessageQueue.Run)
	queueFrame:SetScript("OnMouseUp", MessageQueue.Run)
	queueFrame:SetScript("OnMouseWheel", MessageQueue.Run)
	queueFrame:SetScript("OnGamePadButtonDown", MessageQueue.Run)
	queueFrame:SetScript("OnGamePadButtonUp", MessageQueue.Run)
	queueFrame:SetScript("OnGamePadStick", MessageQueue.Run)
	queueFrame:SetScript("OnKeyDown", MessageQueue.Run)
	queueFrame:SetScript("OnKeyUp", MessageQueue.Run)

	-- Create updater frame
	updaterFrame = CreateFrame('Frame')
	updaterFrame:SetScript('OnUpdate', function()
		if #queue > 0 then
			local frameLevel = UIParent:GetFrameLevel() + 1000
			queueFrame:SetFrameStrata('TOOLTIP')
			queueFrame:SetFrameLevel(frameLevel)
			queueFrame:Show()
			pixelFrame:SetFrameStrata('TOOLTIP')
			pixelFrame:SetFrameLevel(frameLevel)
			pixelFrame:Show()
		else
			queueFrame:Hide()
			pixelFrame:Hide()
		end
	end)

	-- Declare commands
	SlashCmdList["MESSAGEQUEUE"] = MessageQueue.Run
	SLASH_MESSAGEQUEUE1 = "/mq"
	SLASH_MESSAGEQUEUE2 = "/msgqueue"
	SLASH_MESSAGEQUEUE3 = "/messagequeue"
end

--- Enqueue a function
-- @param f (function)
MessageQueue.Enqueue = function(f)
	table.insert(queue, f)
	if flashTimer then
		flashTimer:Cancel()
	end
	flashTimer = C_Timer.NewTimer(.25, FlashClientIcon)
end

--- Enqueue a chat message.
-- Same parameters as the regular C_ChatInfo.SendChatMessage
-- Allows an optional callback that will run after the message has been sent.
-- The callback sould not contain any other hardware triggered function.
-- @param msg (string)
-- @param chatType (string)
-- @param [languageID (string)]
-- @param [channel (string)]
-- @param [callback (function)]
MessageQueue.SendChatMessage = function(msg, chatType, languageID, channel, callback)
	if chatType == 'CHANNEL' or chatType == 'SAY' or chatType == 'YELL' then
		MessageQueue.Enqueue(function()
			SendChatMessage(msg, chatType, languageID, channel)
			if callback then
				callback()
			end
		end)
	else
		SendChatMessage(msg, chatType, languageID, channel)
		if callback then
			callback()
		end
	end
end

--- Run the first item in the queue
-- Should be triggered by a hardware event
MessageQueue.Run = function()
	if flashTimer then
		flashTimer:Cancel()
	end
	while #queue > 0 do
		table.remove(queue, 1)()
	end
end

--- Returns the number of messages awaiting in queue
-- @return numPendingMessages (number)
MessageQueue.GetNumPendingMessages = function()
	return #queue
end

--- Clear the queue
--
MessageQueue.Clear = function()
	wipe(queue)
	if flashTimer then
		flashTimer:Cancel()
	end
end

-- Initialize on startup
MessageQueue.Init()
