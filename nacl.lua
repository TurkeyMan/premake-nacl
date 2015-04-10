
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

		debugstartupcommands {
			'file ${cfg.targetdir}/%{cfg.targetprefix}%{prj.name}%{cfg.targetsuffix}%{cfg.targetextension}',
		}
		debugconnectcommands {
			'nacl-manifest %{cfg.manifestpath or (cfg.targetdir .. "/" .. prj.name .. ".nmf")}',
		}

	configuration { "PNaCl", "ConsoleApp or WindowedApp" }
		targetextension ".pexe"

		local nexe_loc = "%{cfg.targetprefix}%{prj.name}%{cfg.targetsuffix}-%{cfg.buildcfg}_remote.nexe"
		debugconnectcommands {
			'remote get nexe ' .. nexe_loc,
			'file ' .. nexe_loc,
		}

	configuration { "PNaCl or NaCl32 or NaCl64 or NaClARM", "ConsoleApp or WindowedApp" }

		-- TODO: **HAX** we need to find a reasonable way to get to a valid gdb exe; pnacl doesn't have one to use in it's folder
		debugtoolcommand "$(NACL_SDK_ROOT)/toolchain/win_x86_newlib/bin/x86_64-nacl-gdb.exe"

		debugremotehost "localhost"
		debugport(4014)

		local irt_loc = "nacl_irt.nexe"
		debugconnectcommands {
			'remote get irt ' .. irt_loc,
			'nacl-irt ' .. irt_loc,
		}

		-- we can configure the default nacl path mapping if NACL_SDK_ROOT is set
		local sdk_root = os.getenv("NACL_SDK_ROOT")
		if sdk_root ~= nil then
			local pepper = sdk_root:lower()
			local offset = string.find(pepper, "pepper")
			if offset ~= nil then
				pepper = pepper:sub(offset)
				local src = "/cygdrive/s/src/out/"..pepper.."/src"
				local target = sdk_root.."/src"
				debugpathmap { [src] = target }
			end
		end

		-- TODO: do we need to define search paths? (gdb needs paths to find source files)
--		debugsearchpaths {
--			'C:\path\to\symbols',
--		}

	configuration {}


	function nacl.isnacl(cfg)
		return cfg.system == premake.NACL or cfg.system == premake.PPAPI
	end


	-- TODO: extend 'clean' rules for remote .nexe and nacl_irt.nexe


	include("nacl_vstudio.lua")

	return nacl
