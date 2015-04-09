--
-- nacl/nacl_vstudio.lua
-- NaCl integration for vstudio.
-- Copyright (c) 2012 Manu Evans and the Premake project
--


	local p = premake
	local nacl = p.modules.nacl

	nacl.vs = {}

	local naclvs = nacl.vs
	local sln2005 = p.vstudio.sln2005
	local vc2010 = p.vstudio.vc2010
	local vstudio = p.vstudio
	local project = p.project
	local config = p.config


--
-- Add NaCl tools to vstudio actions.
--

	if vstudio.vs200x_architectures ~= nil then
		vstudio.vs200x_architectures.x86 = "x86"
		vstudio.vs200x_architectures.x86_64 = "x64"
	end

	premake.override(vstudio, "archFromConfig", function(oldfn, cfg, win32)
		if cfg.system == premake.PPAPI then
			return "PPAPI"
		elseif cfg.system == premake.NACL then
			local platformMap = { x86 = "NaCl32", x86_64 = "NaCl64", arm = "NaClARM", llvm = "PNaCl" }
			if cfg.architecture ~= nil then
				if platformMap[cfg.architecture] then
					return platformMap[cfg.architecture]
				end
				error("Unsupported NaCl architecture: " .. cfg.architecture, 2)
			end
			error("No architecture specified", 2)
		else
			return oldfn(cfg, win32)
		end
	end)

	premake.override(vstudio, "archFromPlatform", function(oldfn, platform)
		-- if platform is named the same as a nacl 'platform'
		local naclTargets = { "NaCl32", "NaCl64", "NaClARM", "PNaCl", "PPAPI" }
		if naclTargets[platform] then
			return platform
		end
		return oldfn(platform)
	end)


--
-- Extend configurationProperties.
--

	premake.override(vc2010.elements, "configurationProperties", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.kind ~= p.UTILITY then
			elements = table.join(elements, {
				naclvs.naclIndexHtml,
				naclvs.naclToolchainName,
				naclvs.naclSdkRoot,
			})
		end
		return elements
	end)

	function naclvs.naclIndexHtml(cfg)
		if cfg.system == premake.NACL or cfg.system == premake.PPAPI then
			if cfg.indexhtml ~= nil then
				_p(2,'<NaClIndexHTML>%s</NaClIndexHTML>', cfg.indexhtml)
			end
		end
	end

	function naclvs.naclToolchainName(cfg)
		if cfg.system == premake.NACL and cfg.architecture ~= "llvm" then
			-- TODO: do something about this?
--			_p(2,'<ToolchainName>glibc</ToolchainName>')
		end
	end

	function naclvs.naclSdkRoot(cfg)
		if cfg.system == premake.NACL or cfg.system == premake.PPAPI then
			if cfg.naclsdkroot ~= nil then
				_p(2,'<VSNaClSDKRoot>%s</VSNaClSDKRoot>', cfg.naclsdkroot)
			end
		end
	end


--
-- Extend outputProperties.
--

	premake.override(vc2010.elements, "outputProperties", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.kind ~= p.UTILITY then
			elements = table.join(elements, {
				naclvs.naclWebServerPort,
				naclvs.naclManifestPath,
				naclvs.naclAddinVersion,
			})
		end
		return elements
	end)

	function naclvs.naclWebServerPort(cfg)
		if cfg.system == premake.NACL or cfg.system == premake.PPAPI then
			if cfg.webserverport ~= nil then
				_p(2,'<NaClWebServerPort>%d</NaClWebServerPort>', cfg.webserverport)
			end
		end
	end

	function naclvs.naclManifestPath(cfg)
		if cfg.system == premake.NACL then
			if cfg.manifestpath ~= nil then
				_p(2,'<NaClManifestPath>%s</NaClManifestPath>', cfg.manifestpath)
			end
		end
	end

	function naclvs.naclAddinVersion(cfg)
		if cfg.system == premake.NACL then
			_p(2,'<NaClAddInVersion>1</NaClAddInVersion>')
		end
	end

	premake.override(vc2010, "targetExt", function(oldfn, cfg)
		if cfg.system == premake.NACL then
			local ext = cfg.buildtarget.extension
			if ext ~= "" then
				_x(2,'<TargetExt>%s</TargetExt>', ext)
			end
		else
			oldfn(cfg)
		end
	end)


--
-- Extend clCompile.
--

	premake.override(vc2010.elements, "clCompile", function(oldfn, cfg)
		return table.join(oldfn(cfg), {
			naclvs.debugInformation,
--			naclvs.positionIndependentCode,
		})
	end)

	function naclvs.debugInformation(cfg)
		if cfg.system == premake.NACL then
			if cfg.flags.Symbols then
				_p(3,'<GenerateDebugInformation>true</GenerateDebugInformation>')
			end
		end
	end

	premake.override(vc2010, "warningLevel", function(oldfn, cfg)
		if cfg.system == premake.NACL then
			local map = { Off = "DisableAllWarnings", Extra = "AllWarnings" }
			if map[cfg.warnings] ~= nil then
				_p(3,'<Warnings>%s</Warnings>', map[cfg.warnings])
			end
		else
			oldfn(cfg)
		end
	end)

	premake.override(vc2010, "treatWarningAsError", function(oldfn, cfg)
		if cfg.system == premake.NACL then
			if cfg.flags.FatalCompileWarnings and cfg.warnings ~= "Off" then
				_p(3,'<WarningsAsErrors>true</WarningsAsErrors>')
			end
		else
			oldfn(cfg)
		end
	end)

	premake.override(vc2010, "optimization", function(oldfn, cfg, condition)
		if cfg.system == premake.NACL then
			local map = { Off="O0", On="O2", Debug="O0", Full="O3", Size="Os", Speed="O3" }
			local value = map[cfg.optimize]
			if value or not condition then
				vc2010.element('OptimizationLevel', condition, value or "O0")
			end
		else
			oldfn(cfg, condition)
		end
	end)

	premake.override(vc2010, "exceptionHandling", function(oldfn, cfg)
		if cfg.system == premake.NACL then
			if cfg.flags.NoExceptions then
				_p(3,'<GccExceptionHandling>false</GccExceptionHandling>')
			end
		else
			oldfn(cfg)
		end
	end)


--
-- Extend Link.
--

	premake.override(vc2010.elements, "link", function(oldfn, cfg, explicit)
		local elements = oldfn(cfg, explicit)
		if cfg.kind ~= p.STATICLIB then
			elements = table.join(elements, {
				naclvs.translateNexe,
			})
		end
		return elements
	end)

	function naclvs.translateNexe(cfg)
		-- Note: Only relevant to PNaCl
		if cfg.system == premake.NACL and cfg.architecture == "llvm" then
			_x(3, '<TranslateX86>%s</TranslateX86>', iif(cfg.translatenexe.all or cfg.translatenexe.x86, 'true', 'false'))
			_x(3, '<TranslateX64>%s</TranslateX64>', iif(cfg.translatenexe.all or cfg.translatenexe.x86_64, 'true', 'false'))
			_x(3, '<TranslateArm>%s</TranslateArm>', iif(cfg.translatenexe.all or cfg.translatenexe.arm, 'true', 'false'))
		end
	end

	premake.override(vc2010, "generateDebugInformation", function(oldfn, cfg)
		-- Note: NaCl specifies the debug info in the clCompile section
		if cfg.system ~= premake.NACL then
			oldfn(cfg)
		end
	end)


	function naclvs.getlinks(cfg, systemonly)
		local result = {}

		if not systemonly then
			if cfg.flags.RelativeLinks then
				local libFiles = premake.config.getlinks(cfg, "siblings", "basename")
				for _, link in ipairs(libFiles) do
					if string.find(link, "lib") == 1 then
						link = link:sub(4)
					end
					table.insert(result, link)
				end
			else
				-- NaCl TODO: verify that this is okay for NaCl sibling links

				-- Don't use the -l form for sibling libraries, since they may have
				-- custom prefixes or extensions that will confuse the linker. Instead
				-- just list out the full relative path to the library.
				result = config.getlinks(cfg, "siblings", "fullpath")
			end
		end

		local links = config.getlinks(cfg, "system", "fullpath")
		for _, link in ipairs(links) do
			if path.isframework(link) then
				table.insert(result, "-framework " .. path.getbasename(link))
			elseif path.isobjectfile(link) then
				table.insert(result, link)
			else
				table.insert(result, path.getname(link))
			end
		end

		return result
	end

	premake.override(vc2010, "additionalDependencies", function(oldfn, cfg, explicit)
		if cfg.system == premake.NACL then
			local links = naclvs.getlinks(cfg, not explicit)
			if #links > 0 then
				links = path.translate(table.concat(links, ";"))
				p.x('<AdditionalDependencies>%s;%%(AdditionalDependencies)</AdditionalDependencies>', links)
			end
		else
			return oldfn(cfg, explicit)
		end
	end)

--
-- Add NaCl tools to vstudio actions.
--

	premake.override(vc2010, "additionalCompileOptions", function(oldfn, cfg, condition)
		if cfg.system == premake.NACL then
			naclvs.additionalOptions(cfg, condition)
		end
		return oldfn(cfg, condition)
	end)


--
-- Add options unsupported by NaCl vs_addin UI to <AdvancedOptions>.
--
	function naclvs.additionalOptions(cfg, condition)

		local function alreadyHas(t, key)
			for _, k in ipairs(t) do
				if string.find(k, key) then
					return true
				end
			end
			return false
		end

		-- Flags that are not supported by the NaCl vs_addin UI may be added manually here...

--		Eg: table.insert(cfg.buildoptions, "-option")

	end
