function [pres, log] = setup_jellyfish_eyetracking

% This function sets up the eyetracking for the jellyfish tactile discrimination task.
% This code is almost entirely based off of the task engine coding by Luke Mason (KCL)
% https://github.com/luke-cbcd

addpath(genpath('/Users/SENSOR/Desktop/MATLAB'));
pres=ECKPresenter;
pres.DebugMode=true;
pres.MonitorNumber = 1;  
pres.SetFullscreen; 
pres.EyeTracker = ECKEyeTracker_tobiiPro;
pres.WindowWidthLimitCm=34.5;
pres.WindowHeightLimitCm=25.9;
pres.WindowLimitEnabled=true;
pres.ETGetEyesMovie = 'ben_holly_et.mov';
pres.InitialiseDisplay          
pres.BackColour=[0 0 0];    
pres.AutoMakeImageTextures
pres.EyeTracker.ServerName='TX300-010101132315';
pres.EyeTracker.FrameRate=300;
pres.EyeTracker.ClearAoIs;
pres.EyeTracker.Connect;
% enabled eyetracker preview window
pres.PreviewEnabled = true;
% create a data tracker
track=ECKTracker('SENSOR');
track.DataRoot=pres.Paths.thirtysixmonthsET;
pres.EyeTracker.Tracker=track;
% create a log file
log=ECKLog;
% get eyes and calibrate
fprintf('Press %s to get eyes, and calibrate...\n',pres.KB_MOVEON)
KbWait(-1);
    pres.ETHandleCalibration;
    fprintf('<strong>Press any key to begin tasks.</strong>\n')  
    KbWait(-1);  
% begin logging session time
track.StartSession;
% tasks.AllowJog = true;
pres.EyeTracker.StartTracking;

end

