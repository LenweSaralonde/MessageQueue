MessageQueue
============
Implements an alternative to `C_ChatInfo.SendChatMessage()` to securely send messages in chat channels in response to a hardware event such as a mouse click or a keypress.

How it works
------------
Use `MessageQueue.SendChatMessage()` in your add-ons and macros to send chat messages instead of `C_ChatInfo.SendChatMessage()`. MessageQueue will then wait for a hardware event to send the message. A callback that will be executed after the message has been sent can also be provided so you can write your code in an asynchronous way.

Any of the following hardware inputs allows the queue to run: mouse click, mouse wheel, keyboard, gamepad stick or button. Unlike keyboard inputs, mouse and gamepad inputs are consumed by an invisible frame that shows up at the topmost level so any click on an action may fail if MessageQueue needs to send a message at the same time.

Use with AutoHotKey
-------------------
MessageQueue can be used in conjunction with [AutoHotkey](https://www.autohotkey.com/) and the provided `PixelTrigger.v*.ahk` script to automatically send hardware events to the World of Warcraft window when needed.

* For **AutoHotKey v1.1**, use `PixelTrigger.v1.ahk`.
* For **AutoHotKey v2.0**, use `PixelTrigger.v2.ahk`.

The script monitors the color of the top left pixel of the WoW window and sends a keypress on the *PAUSE* key every time the pixel turns gray (*#333333*). The WoW window doesn't need to be active but the top left corner should remain visible on the screen and not be covered by another window for the script to work.

The AutoHotKey script only works on Windows. If you're running MessageQueue on Mac, you'll need to trigger your hardware event manually.

If you wish to use another hardware event than the *PAUSE* key, make a copy of the `PixelTrigger.v*.ahk` script and edit it accordingly (instructions are provided within the script comments). Make sure to keep your copy of the script out of the add-on folder since it could be automatically deleted if you use an add-on manager.

Please be aware that the use of AutoHotkey is not against Blizzard's ToS and you won't get banned for just using it along with WoW. It's commonly used by players with disabilities. Only obvious abuse such as spamming or automating complex actions can get you banned. Do not use any other script than the provided `PixelTrigger.v*.ahk` unless you know what you're doing. Anyway, the use of AutoHotKey and the provided script is not mandatory for MessageQueue to work, it just adds convenience.

API documentation
-----------------
### MessageQueue.SendChatMessage
`MessageQueue.SendChatMessage("msg" [,"chatType" [,languageID [,"target" [, "callback"]]]])`

Add a message to the queue if the target requires a hardware event (chatType is either "SAY", "YELL" or "CHANNEL"). For any other chatType, the message is sent instantly.

Arguments are the same as the regular [C_ChatInfo.SendChatMessage](https://warcraft.wiki.gg/wiki/API_C_ChatInfo.SendChatMessage) function.

The optional **callback** function will be executed when the message has been sent. The callback should not contain any other code requiring a hardware event.

### MessageQueue.Enqueue
`MessageQueue.Enqueue(func)`

Enqueue a function that requires a hardware event to run. The function may not perform more than one action requiring a hardware event.

Shares the same queue as **MessageQueue.SendChatMessage()**.

### MessageQueue.GetNumPendingMessages
`messageCount = MessageQueue.GetNumPendingMessages()`

Returns the number of messages awaiting in the queue.

### MessageQueue.Run
`MessageQueue.Run()`

Runs the first message awaiting in queue. Should only be called in response to a hardware event. If for some reason the message fails, it won't be possible to attempt it again.

### MessageQueue.Clear
`MessageQueue.Clear()`

Clears the entire queue.

Integration guide
-----------------
The integration of MessageQueue in your add-on is pretty straightforward.

First, add MessageQueue as a required dependency for your add-on by adding the following in the .toc file:
`## RequiredDeps: MessageQueue`

Then, just replace `C_ChatInfo.SendChatMessage()` calls by `MessageQueue.SendChatMessage()`.

However, keep in mind that the message will not be sent instantly (for example if the World of Warcraft window is not in focus). If the rest of your code requires the message to be actually sent, you should pause the execution of the current process then resume it in the callback.

Before
```lua
C_ChatInfo.SendChatMessage(text, 'SAY')
-- Do stuff
return
```

After
```lua
MessageQueue.SendChatMessage(text, 'SAY', nil, nil, function()
	-- Do stuff
	-- Resume process execution
end)
-- Pause process execution
return
```

The functions `MessageQueue.Enqueue` and `MessageQueue.Run` can be hooked using `hooksecurefunc()` by your add-on to perform actions when an element has been added or removed from the queue.
