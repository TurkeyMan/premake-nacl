
--
-- Create a nacl namespace to isolate the additions
--
	premake.extensions.nacl = {}

	local nacl = premake.extensions.nacl
	local vstudio = premake.vstudio
	local project = premake.project
	local api = premake.api

	nacl.support_url = "https://bitbucket.org/premakeext/nacl/wiki/Home"

	nacl.printf = function( msg, ... )
		printf( "[nacl] " .. msg, ...)
	end

	nacl.printf( "Premake NaCl Extension (" .. nacl.support_url .. ")" )

	-- Extend the package path to include the directory containing this
	-- script so we can easily 'require' additional resources from
	-- subdirectories as necessary
	local this_dir = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]];
	package.path = this_dir .. "actions/?.lua;".. package.path


--
-- Register the Android extension
--

	-- TODO: should PNaCl be system = "pnacl" or system = "nacl" + architecture = "llvm"?
	premake.NACL = "nacl"
	premake.PPAPI = "ppapi"

	api.addAllowed("system", { premake.NACL, premake.PPAPI })
	api.addAllowed("architecture", { "x86", "x86_64", "arm", "llvm" })


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


--
-- Set global environment for some common NaCl platforms.
--

configuration { "NaCl32" }
	system "nacl"
	architecture "x86"

configuration { "NaCl64" }
	system "nacl"
	architecture "x86_64"

configuration { "NaClARM" }
	system "nacl"
	architecture "arm"

configuration { "PNaCl" }
	system "nacl"
	architecture "llvm"

configuration { "PPAPI" }
	system "ppapi"

configuration { "NaCl32 or NaCl64 or NaClARM", "ConsoleApp or WindowedApp" }
	targetextension ".nexe"

configuration { "PNaCl", "ConsoleApp or WindowedApp" }
	targetextension ".pexe"


--
-- 'require' the vs_addin code.
--

	require( "vstudio" )
	nacl.printf( "Loaded NaCl vs_addin support 'vstudio.lua'", v )
