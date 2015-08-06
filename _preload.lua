--
-- Name:        nacl/_preload.lua
-- Purpose:     Define the NaCl API's.
-- Author:      Manu Evans
-- Copyright:   (c) 2013-2015 Manu Evans and the Premake project
--

	local p = premake
	local api = p.api

--
-- Register the NaCl extension
--

	p.NACL = "nacl"
	p.PPAPI = "ppapi"

	api.addAllowed("system", { p.NACL, p.PPAPI })
	api.addAllowed("architecture", { "pnacl" })


--
-- Register Android properties
--

	api.register {
		name = "naclsdkroot",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	-- select glibc or newlib toolchain: <ToolchainName>glibc</ToolchainName>
--	api.register {
--		name = "toolchain",
--		scope = "config",
--		kind = "string",
--		tokens = true,
--	}

	api.register {
		name = "manifestpath",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "indexhtml",
		scope = "config",
		kind = "string",
		tokens = true,
	}

	api.register {
		name = "webserverport",
		scope = "config",
		kind = "integer",
	}

	api.register {
		name = "translatenexe",
		scope = "config",
		kind  = "list:string",
		allowed = {
			"none",
			"all",
			"x86",
			"x86_64",
			"arm"
		},
	}


--
-- Set global environment for the default NaCl platforms.
--

	configuration { "NaCl32 or NaCl64 or NaClARM" }
		system "nacl"
		toolset "gcc"

	configuration { "PNaCl" }
		system "nacl"
		architecture "pnacl"
		toolset "clang"

	configuration { "PPAPI" }
		system "ppapi"


--
-- Decide when the full module should be loaded.
--

	return function(cfg)
		return cfg.system == "nacl" or cfg.system == "ppapi"
	end
