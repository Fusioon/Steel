using System;
using System.Diagnostics;
using System.IO;

namespace SteelEngine.Resources
{
	public static class Tools
	{
		static String _toolsPath ~ delete _;

		static this()
		{
			_toolsPath = new String();
			let toolsPath = scope String();
			Environment.GetExecutableFilePath(toolsPath);
			if(Path.GetDirectoryPath(toolsPath, _toolsPath) case .Err)
			{
				Log.Error("Failed to get tools directory!");
			}
		}

		public static Result<int> Execute(StringView executable, StringView cmdLine, String stdOutBuffer,  String stdErrBuffer, int maxWaitTimeMS = -1)
		{
			String exePath = scope $"{_toolsPath}/{executable}";

			ProcessStartInfo processStartInfo = scope .();
			processStartInfo.SetFileName(exePath);
			processStartInfo.SetArguments(cmdLine);
			processStartInfo.RedirectStandardOutput = true;
			processStartInfo.RedirectStandardError = true;
			processStartInfo.UseShellExecute = false;

			FileStream stdOut = scope .();
			StreamReader stdOutReader = scope .(stdOut);
			FileStream stdErr = scope .();
			StreamReader stdErrReader = scope .(stdErr);

			SpawnedProcess process = scope .();
			if(process.Start(processStartInfo) case .Err)
			{
				Log.Error($"Couldn't start process! Executable: {executable}");
				return .Err;
			}
			process.AttachStandardOutput(stdOut);
			process.AttachStandardOutput(stdErr);
			stdOutReader.ReadToEnd(stdOutBuffer).IgnoreError();
			stdErrReader.ReadToEnd(stdErrBuffer).IgnoreError();

			if(!process.WaitFor(maxWaitTimeMS))
			{
				return .Err;
			}

			return process.ExitCode;
		}
	}
}
