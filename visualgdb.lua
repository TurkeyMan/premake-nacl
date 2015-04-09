--
-- nacl/visualgdb.lua
-- VisualGDB integration for vstudio.
-- Copyright (c) 2012 Manu Evans and the Premake project
--


	local p = premake

	premake.modules.visualgdb = {}

	local visualgdb = premake.modules.visualgdb

	local vs2010 = p.vstudio.vs2010
	local vc2010 = p.vstudio.vc2010
	local project = p.project
	local config = p.config


--
-- Add VisualGDB support for vs201x.
--

	premake.override(vs2010, "generateProject", function(oldfn, prj)
		oldfn(prj)

--		p.eol("\r\n")
		p.indent("  ")
--		p.escaper(vs2010.esc)

		for cfg in project.eachconfig(prj) do
			if cfg.debugger == "VisualGDB" then
				visualgdb.generate(prj, "." .. cfg.buildcfg .. ".vgdbsettings", visualgdb.generateVGDBSettings, cfg)
			end
		end
	end)

	function visualgdb.generate(obj, ext, callback, arg)
		local fn = premake.filename(obj, ext)
		printf("Generating %s...", path.getrelative(os.getcwd(), fn))

		local f, err = io.open(fn, "wb")
		if (not f) then
			error(err, 0)
		end

		io.output(f)
		_indentLevel = 0
		callback(arg or obj)
		f:close()
		_indentLevel = 0
	end

	function visualgdb.generateVGDBSettings(cfg)
		_p(0, "<?xml version=\"1.0\"?>")
		_p(0, "<VisualGDBProjectSettings2 xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">")

			_p(1, "<ConfigurationName>%s</ConfigurationName>", cfg.buildcfg)

			_p(1, "<Project xsi:type=\"com.visualgdb.project.windows\">")
				_p(2, "<CustomSourceDirectories>")

					if #cfg.debugpathmap then
						_p(3, "<Directories>")
							for _, mappings in ipairs(cfg.debugpathmap) do
								for src, target in pairs(mappings) do
									_p(4, "<SourceDirMappingEntry>")
										_x(5, "<RemoteDir>%s</RemoteDir>", src)
										_x(5, "<LocalDir>%s</LocalDir>", target)
									_p(4, "</SourceDirMappingEntry>")
								end
							end
						_p(3, "</Directories>")
					else
						_p(3, "<Directories />")
					end

					_p(3, "<PathStyle>CygwinUnixSlash</PathStyle>")
					_p(3, "<LocalDirForAbsolutePaths />")
					_p(3, "<LocalDirForRelativePaths />")
				_p(2, "</CustomSourceDirectories>")
				_p(2, "<MainSourceDirectory>$(ProjectDir)</MainSourceDirectory>")
			_p(1, "</Project>")
			_p(1, "<Build xsi:type=\"com.visualgdb.build.custom\">")
				_p(2, "<BuildCommand>")
					_p(3, "<SkipWhenRunningCommandList>false</SkipWhenRunningCommandList>")
				_p(2, "</BuildCommand>")
				_p(2, "<CleanCommand>")
					_p(3, "<SkipWhenRunningCommandList>false</SkipWhenRunningCommandList>")
				_p(2, "</CleanCommand>")
				_p(2, "<MainBuildDirectory>$(SourceDir)</MainBuildDirectory>")
				_p(2, "<AbsoluteTargetPath>$(TargetPath)</AbsoluteTargetPath>")
				_p(2, "<AutoUpdateMakefiles>false</AutoUpdateMakefiles>")
			_p(1, "</Build>")
			_p(1, "<Debug xsi:type=\"com.visualgdb.debug.remote\">")
				_p(2, "<AdditionalStartupCommands>")
					_p(3, "<GDBPreStartupCommands>")
						for _, command in ipairs(cfg.debugstartupcommands) do
							_x(4, "<string>interpreter-exec mi \"%s\"</string>", command)
						end
						if cfg.system == premake.NACL then
							-- we need to manually connect
							_x(4, "<string>interpreter-exec mi \"target remote %s:%s\"</string>", cfg.debugremotehost or "localhost", (""..cfg.debugport) or "4014")

							-- and now we'll execute the post-connect commands here
							for _, command in ipairs(cfg.debugconnectcommands) do
								_x(4, "<string>interpreter-exec mi \"%s\"</string>", command)
							end
						end
					_p(3, "</GDBPreStartupCommands>")
					_p(3, "<GDBStartupCommands />")
				_p(2, "</AdditionalStartupCommands>")
				_p(2, "<AdditionalGDBSettings>")
					_p(3, "<FilterSpuriousStoppedNotifications>false</FilterSpuriousStoppedNotifications>")
					_p(3, "<ForceSingleThreadedMode>false</ForceSingleThreadedMode>")
					_p(3, "<PendingBreakpointsSupported>true</PendingBreakpointsSupported>")
					_p(3, "<DisableChildRanges>false</DisableChildRanges>")
					_p(3, "<UseAppleExtensions>false</UseAppleExtensions>")
					_p(3, "<CanAcceptCommandsWhileRunning>false</CanAcceptCommandsWhileRunning>")
					_p(3, "<MakeLogFile>false</MakeLogFile>")
					_p(3, "<IgnoreModuleEventsWhileStepping>true</IgnoreModuleEventsWhileStepping>")
					_p(3, "<UseRelativePathsOnly>false</UseRelativePathsOnly>")
					_p(3, "<ExitAction>None</ExitAction>")
					_p(3, "<Features>")
						_p(4, "<DisableAutoDetection>false</DisableAutoDetection>")
						_p(4, "<UseFrameParameter>false</UseFrameParameter>")
						_p(4, "<SimpleValuesFlagSupported>false</SimpleValuesFlagSupported>")
						_p(4, "<ListLocalsSupported>false</ListLocalsSupported>")
						_p(4, "<ByteLevelMemoryCommandsAvailable>false</ByteLevelMemoryCommandsAvailable>")
						_p(4, "<ThreadInfoSupported>false</ThreadInfoSupported>")
						_p(4, "<PendingBreakpointsSupported>false</PendingBreakpointsSupported>")
						_p(4, "<SupportTargetCommand>false</SupportTargetCommand>")
					_p(3, "</Features>")
					_p(3, "<DisableDisassembly>false</DisableDisassembly>")
					_p(3, "<ExamineMemoryWithXCommand>false</ExamineMemoryWithXCommand>")
					_p(3, "<StepIntoNewInstanceEntry />")
					_p(3, "<ExamineRegistersInRawFormat>true</ExamineRegistersInRawFormat>")
					_p(3, "<EnableSmartStepping>false</EnableSmartStepping>")
					_p(3, "<DisableSignals>false</DisableSignals>")
					_p(3, "<EnableAsyncExecutionMode>false</EnableAsyncExecutionMode>")
					_p(3, "<EnableNonStopMode>false</EnableNonStopMode>")
				_p(2, "</AdditionalGDBSettings>")
				_p(2, "<LaunchGDBSettings xsi:type=\"GDBLaunchParametersCustom\">")

--					_p(3, "<GDBExe>C:\dev\nacl_sdk\pepper_41\toolchain\win_x86_newlib\bin\x86_64-nacl-gdb.exe</GDBExe>")

					_p(3, "<GDBEnvironment>")
						if #cfg.debugenvs > 0 then
							_p(4, "<Records>")
								for _, env in ipairs(cfg.debugenvs) do
									local eq = string.find(env, "=")
									local var = env
									local val = ""
									if eq ~= nil then
										var = env:sub(1, eq-1)
										val = env:sub(eq+1)
									end
									_p(5, "<Record>")
										-- TODO: split 'env' around '=' into 'var' and 'val'
										_x(6, "<VariableName>%s</VariableName>", var)
										_x(6, "<Value>%s</Value>", val)
									_p(5, "</Record>")
								end
							_p(4, "</Records>")
						else
							_p(4, "<Records />")
						end
					_p(3, "</GDBEnvironment>")

					_p(3, "<GDBArguments>--interpreter mi</GDBArguments>") -- TODO: should this always be set?
					_p(3, "<GDBDirectory>%s</GDBDirectory>", cfg.debugdir or "")
					_p(3, "<SessionStartMode>UsingContinue</SessionStartMode>")
					_p(3, "<TargetSelectionCommand />")
					_p(3, "<AttachPID>0</AttachPID>")
				_p(2, "</LaunchGDBSettings>")
				_p(2, "<GenerateCtrlBreakInsteadOfCtrlC>false</GenerateCtrlBreakInsteadOfCtrlC>")
				_p(2, "<DeploymentTargetPath />")
				_p(2, "<X11WindowMode>Local</X11WindowMode>")
				_p(2, "<KeepConsoleAfterExit>true</KeepConsoleAfterExit>")
				_p(2, "<RunGDBUnderSudo>false</RunGDBUnderSudo>")
				_p(2, "<DeploymentMode>Auto</DeploymentMode>")
				_p(2, "<LdLibraryPath />")
				_p(2, "<DeployWhenLaunchedWithoutDebugging>true</DeployWhenLaunchedWithoutDebugging>")
			_p(1, "</Debug>")
			_p(1, "<CustomBuild>")
				_p(2, "<PreBuildActions />")
				_p(2, "<PostBuildActions />")
				_p(2, "<PreCleanActions />")
				_p(2, "<PostCleanActions />")
			_p(1, "</CustomBuild>")
			_p(1, "<CustomDebug>")
				_p(2, "<PreDebugActions />")
				_p(2, "<PostDebugActions />")
				_p(2, "<BreakMode>CtrlC</BreakMode>")
			_p(1, "</CustomDebug>")
			_p(1, "<DeviceTerminalSettings>")

				-- for tcp connections...
				_p(2, "<Connection xsi:type=\"com.sysprogs.terminal.connection.tcp\">")
					_x(3, "<Host>%s</Host>", cfg.debugremotehost or "localhost")
					_p(3, "<Port>%s</Port>", (""..cfg.debugport) or "2159")
				_p(2, "</Connection>")

				_p(2, "<EchoTypedCharacters>false</EchoTypedCharacters>")
				_p(2, "<DisplayMode>ASCII</DisplayMode>")
				_p(2, "<Colors>")
					_p(3, "<Background>")
						_p(4, "<Alpha>255</Alpha>")
						_p(4, "<Red>0</Red>")
						_p(4, "<Green>0</Green>")
						_p(4, "<Blue>0</Blue>")
					_p(3, "</Background>")
					_p(3, "<Disconnected>")
						_p(4, "<Alpha>255</Alpha>")
						_p(4, "<Red>169</Red>")
						_p(4, "<Green>169</Green>")
						_p(4, "<Blue>169</Blue>")
					_p(3, "</Disconnected>")
					_p(3, "<Text>")
						_p(4, "<Alpha>255</Alpha>")
						_p(4, "<Red>211</Red>")
						_p(4, "<Green>211</Green>")
						_p(4, "<Blue>211</Blue>")
					_p(3, "</Text>")
					_p(3, "<Echo>")
						_p(4, "<Alpha>255</Alpha>")
						_p(4, "<Red>144</Red>")
						_p(4, "<Green>238</Green>")
						_p(4, "<Blue>144</Blue>")
					_p(3, "</Echo>")
				_p(2, "</Colors>")
				_p(2, "<HexSettings>")
					_p(3, "<MaximumBytesPerLine>16</MaximumBytesPerLine>")
					_p(3, "<ShowTextView>true</ShowTextView>")
					_p(3, "<BreaksAroundEcho>true</BreaksAroundEcho>")
					_p(3, "<AutoSend>true</AutoSend>")
					_p(3, "<SendAsHex>true</SendAsHex>")
					_p(3, "<TimeoutForAutoBreak>0</TimeoutForAutoBreak>")
				_p(2, "</HexSettings>")
				_p(2, "<LineEnding>LF</LineEnding>")
				_p(2, "<TreatLFAsCRLF>false</TreatLFAsCRLF>")
			_p(1, "</DeviceTerminalSettings>")
			_p(1, "<CustomShortcuts>")
				_p(2, "<Shortcuts />")
				_p(2, "<ShowMessageAfterExecuting>true</ShowMessageAfterExecuting>")
			_p(1, "</CustomShortcuts>")
			_p(1, "<UserDefinedVariables />")
		_p(0, "</VisualGDBProjectSettings2>")
	end


--
-- Extend outputProperties.
--

	premake.override(vc2010.elements, "outputProperties", function(oldfn, cfg)
		local elements = oldfn(cfg)
		if cfg.kind ~= p.UTILITY then
			elements = table.join(elements, {
				visualgdb.debugger,
			})
		end
		return elements
	end)

	function visualgdb.debugger(cfg)
		if cfg.debugger == "VisualGDB" then
			local settingsFile = p.filename(cfg.project, "." .. cfg.buildcfg .. ".vgdbsettings")
			_x(2,'<NMakeOutput>$(ProjectDir)%s</NMakeOutput>', project.getrelative(cfg.project, settingsFile))
		end
	end
