function [pahandle, pahandleMaster, stim, tactors] = ...
    setup_jellyfish_tactors(stim_dir, stim_hz, num_tactors, tactor_audio_device)

% Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com
% Date: 29th July 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

% Open audio device: 2 channels output
devices = PsychPortAudio('GetDevices');
match_index = find(contains({devices.DeviceName}, tactor_audio_device));
fs = 44100;

% If not plugged in put into a loop to ensure that it does get plugged in
while isempty(match_index)
    text_in = input(sprintf('\nTactor audio not found, ensure tactors are plugged into the headphone jack.\nIf the audiojack isnt listed under help after plugging it in you must restart.\nType h for help, x to exit with an error or enter to continue:'), 's');
    devices = PsychPortAudio('GetDevices');
    match_index = find(contains({devices.DeviceName}, tactor_audio_device));
    
    if strcmp(text_in, 'h')
        fprintf(sprintf('\n\nDevice help:\nThe audio device that is being searched for is the first instance of %s\nthis is the 3.5mm audio jack on the side of the mac. It does not matter which device index this is assigned.\n\nTo search for sound indexes call "InitializePsychSound(1)" then "devices = PsychPortAudio("GetDevices");"\n\nAdjust the tactor_audio_device by renaming it above.\n\nCurrent devices connected:\n', tactor_audio_device))
        d_names = {devices.DeviceName}; for a = 1:length(d_names); fprintf(sprintf('%s\n', d_names{a})); end
    elseif strcmp(text_in, 'x')
        Screen('CloseAll')
        PsychPortAudio('CloseAll')
        error('Unable to resolve tactor audio')
    end
end

% Get the tactor device index
tactor_device_index = devices(match_index(1)).DeviceIndex;

% Setup the tactors with either 1 or 2 tactors
if num_tactors == 1
    pahandle = PsychPortAudio('Open', tactor_device_index, 1, 1, fs, 1);
    pahandleMaster = 0;
elseif num_tactors == 2
    pahandleMaster = PsychPortAudio('Open', tactor_device_index, 1+8, 1, fs, 2, [], [], [], 1);
    
    if isempty(pahandleMaster)
        error('Master tactor channel not opened successfully.')
    end
    
    pahandle = PsychPortAudio('OpenSlave', pahandleMaster, 1, 2);
else
    error('Too many tactors selected.')
end

% Load the stim being used and stack into a stereo system
stim = load(sprintf('%s/tone_%dHz.mat', stim_dir, stim_hz));
stim = stim.tone; stim = [stim; stim];


%% Set up tactors variables
% tactors = teTactors(pres.Tracker.TactorPort);
[tactors, ~] = IOPort('OpenSerialPort', '/dev/cu.usbserial-FTD4RB4J',...
    'BaudRate=57600 DataBits=8 StopBits=1');

% Enable tactor 1
cmdStr = sprintf('T%d%s', 1, 'E');
IOPort('Write', tactors, char(27));
IOPort('Write', tactors, cmdStr);

% Enable the tactors
if num_tactors == 2
    %     tactors.Enable(2)
    cmdStr = sprintf('T%d%s', 2, 'E');
    IOPort('Write', tactors, char(27));
    IOPort('Write', tactors, cmdStr);
end
    
end