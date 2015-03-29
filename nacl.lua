
--
-- Create a nacl namespace to isolate the additions
--
	premake.modules.nacl = {}

	local nacl = premake.modules.nacl


	include("_preload.lua")

--
-- Set global environment for some common NaCl platforms.
--

	configuration { "NaCl32" }
		system "nacl"
		architecture "x86"
		targetsuffix "32"

	configuration { "NaCl64" }
		system "nacl"
		architecture "x86_64"
		targetsuffix "64"

--		debugremotehost "localhost"
--		debugport (4014)
--		debugsearchpaths {
--			'C:\path\to\symbols',
--		}

--		debugstartupcommands {
--			'file C:\ud2Clean\udWebView\www\udWebView64.nexe',
--			'set substitute-path /cygdrive/s/src/out/pepper_39/src C:\nacl_sdk\pepper_39\src'
--		}

		-- it would be great to set these, but the chrome version pollutes the path! >_<
--		debugconnectcommands {
--			'nacl-manifest C:\ud2Clean\udWebView\www\udWebView.nmf',
--			'remote get irt "C:/Program Files (x86)/Google/Chrome/Application/39.0.2171.95/nacl_irt_x86_64.nexe"',
--			'nacl-irt "C:/Program Files (x86)/Google/Chrome/Application/39.0.2171.95/nacl_irt_x86_64.nexe"'
--		}

	configuration { "NaClARM" }
		system "nacl"
		architecture "arm"
		targetsuffix "ARM"

	configuration { "PNaCl" }
		system "nacl"
		architecture "llvm"

	configuration { "PPAPI" }
		system "ppapi"

	configuration { "NaCl32 or NaCl64 or NaClARM", "ConsoleApp or WindowedApp" }
		targetextension ".nexe"

	configuration { "PNaCl", "ConsoleApp or WindowedApp" }
		targetextension ".pexe"


	include("nacl_vstudio.lua")

	return nacl
