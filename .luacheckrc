max_line_length = false

exclude_files = {
}

ignore = {
	-- Ignore global writes/accesses/mutations on anything prefixed with the add-on name.
	-- This is the standard prefix for all of our global frame names and mixins.
	"11./^MessageQueue",

	-- Ignore unused self. This would popup for Mixins and Objects
	"212/self",
}

globals = {
	-- Globals
	"SLASH_MESSAGEQUEUE1",
	"SLASH_MESSAGEQUEUE2",
	"SLASH_MESSAGEQUEUE3",

	-- AddOn Overrides
}

read_globals = {
	-- Libraries

	-- 3rd party add-ons
}

std = "lua51+wow"

stds.wow = {
	-- Globals that we mutate.
	globals = {
		"SlashCmdList"
	},

	-- Globals that we access.
	read_globals = {
		-- Lua function aliases and extensions
		"date",
		"floor",
		"ceil",
		"format",
		"sort",
		"strconcat",
		"strjoin",
		"strlen",
		"strlenutf8",
		"strsplit",
		"strtrim",
		"strupper",
		"strlower",
		"tAppendAll",
		"tContains",
		"tFilter",
		"time",
		"tinsert",
		"tInvert",
		"tremove",
		"wipe",
		"max",
		"min",
		"abs",
		"random",
		"Lerp",
		"sin",
		"cos",

		-- Global Functions
		"CreateFrame",
		"FlashClientIcon",
		"SendChatMessage",

		C_ChatInfo = {
			fields = {
				"SendChatMessage"
			},
		},

		-- Global Mixins and UI Objects
		UIParent = {
			fields = {
				"GetFrameLevel"
			}
		},
		C_Timer = {
			fields = {
				"NewTimer"
			}
		}

		-- Global Constants
	},
}
