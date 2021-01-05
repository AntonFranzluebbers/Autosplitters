state("loneecho") {}

startup {
settings.Add("Make sure to set the starting time to -8.16s");

	vars.internalLogFilePath = Directory.GetCurrentDirectory() + "\\autosplitter_loneecho.log";
	vars.log = (Action<string>)((string logLine) => {
		print(logLine);
		string time = System.DateTime.Now.ToString("dd/MM/yy hh:mm:ss:fff");
		System.IO.File.AppendAllText(vars.internalLogFilePath, time + ": " + logLine + "\r\n");
	});
	try {
		vars.log("Autosplitter loaded");
	} catch (System.IO.FileNotFoundException e) {
		System.IO.File.Create(vars.logFilePath);
		vars.log("Autosplitter loaded, log file created");
	}
	
	
	vars.splitnames = new string[] {
		//"Begin Thread",
		"Manual Dexterity Calibration",
		"Motor Functions Calibration",
		"Maneuvering Thrusters Calibration",
		"Communication Calibration",
		"Calibrations, interrupted",
		"Titan, we have a problem",
		"Open the Pod Bay Doors, Hera",
		"Miner Problems",
		"Transport Diagnostic Complete",
		"Container Field",
		"Processing Line",
		"Processing Line Operational",
		"Container Field",
		"Radioactive Container Jettisoned",
		"Primary Dig Site",
		"Primary Dig Site Active",
		"Kronos II Repairs Complete",
		"Depleted Dig Site",
		"Scanning the Anomaly",
		"Processing Line",
		"Station Emergency Boot-Up",
		"Damaged Satellite",
		"Damaged Satellite Online",
		"Fury Transport Stop At Ship\'s Hull",
		"Vicinity of Olivia\'s Fury Transport",
		"Repair Apollo\'s A.I. Processor",
		"Fury Transport to Olivia\"s Location",
		"Reunited with Olivia in the Life Support Room",
		"Reactor Room",
		"Reactor Room Activation Complete",
		"Returning to Activate the Life Support Systems",
		"Activating the Life Support Systems",
		"You Only Liv Once"
	};
	// for (int i = 0; i < vars.splitnames.Length; i++) {
	// 	settings.Add("split"+i, true, vars.splitnames[i]);
	// }
	vars.currentSplit = 0;

	vars.timerModel = new TimerModel { CurrentState = timer };

}

init {
	var page = modules.First();
	var gameDir = Path.GetDirectoryName(page.FileName);

	vars.logPathBase = gameDir.TrimEnd("\\bin\\win7".ToCharArray()) + "\\_local\\r14logs\\";

	vars.directory = new DirectoryInfo(vars.logPathBase);
	vars.logPath = vars.logPathBase + ((DirectoryInfo)vars.directory).GetFiles().OrderByDescending(f => f.LastWriteTime).First().ToString();
	vars.log("[Autosplitter] Using log path: '" + vars.logPath + "'");

	vars.reader = new StreamReader(new FileStream(vars.logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite));

	vars.reader.BaseStream.Seek(0, SeekOrigin.End);
}

exit {
	timer.IsGameTimePaused = true;
	vars.reader = null;
}


update {	
	string newLogPath = vars.logPathBase + ((DirectoryInfo)vars.directory).GetFiles().OrderByDescending(f => f.LastWriteTime).First().ToString();
	if (!string.Equals(newLogPath, vars.logPath)) {
		vars.logPath = newLogPath;
		vars.reader = new StreamReader(new FileStream(vars.logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite));
		vars.log("[Autosplitter] Using log path: '" + vars.logPath + "'");
	}
	vars.line = vars.reader.ReadLine();

	if (vars.line == null) {
		return false;
	}

	
}

reset {
	if (vars.line.Contains("[DIALOGUE] A bit odd, actually. Saying it out loud.")) {
		currentSplit = 0;
		return true;
	}
}


start {
	if (vars.line.Contains("[DIALOGUE] A bit odd, actually. Saying it out loud.")) {
		currentSplit = 0;
		return true;
	}
}

isLoading {
}

split {
	// try to split
	try {
		if (vars.line.Contains("[SAVING]")) {	// split on save
			vars.log(vars.line);
			var currentSplitLocal = vars.currentSplit;
			while (currentSplitLocal < vars.splitnames.Length) {
				if (vars.line.Contains(vars.splitnames[currentSplitLocal])) {
					try {
						for (int i = 0; i < (currentSplitLocal - vars.currentSplit); i++) {
							vars.log("Skip");
							vars.timerModel.SkipSplit();
						}
					} catch( Exception e) {
						vars.log(e.ToString());
					}
					vars.currentSplit = ++currentSplitLocal;
					vars.log("Split");
					return true;
				} else {
					currentSplitLocal++;
				}
			}
		} else if (vars.line.Contains("[DIALOGUE] Improvise.")) {	// Final split
			return true;
		}
	}
	catch (Exception e) {
		vars.log(e.ToString());
	}
}