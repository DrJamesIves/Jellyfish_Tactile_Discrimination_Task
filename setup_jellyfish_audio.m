function [attention_sounds, attention_sound_fieldnames, audio_device_index, bg_handle, master_handle, ...
    prompt_handle, prompt_sounds, prompt_sound_fieldnames, reward_sounds, reward_sound_fieldnames] = ...
    setup_jellyfish_audio(bg_audio_name, main_audio_device, root, stim_dir)

% Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com
% Date: 29th July 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

%% Prep attention sounds
% Set the path, find the files, set up the holding structures
attention_path = fullfile(root, 'stim', 'attention');
attention_files = dir(attention_path);
attention_sounds = struct;

% Fill the attention sound struct
for a = 1:length(attention_files)
    
    % Skip mac hidden files
    if startsWith(attention_files(a).name, '.')
        continue
    end
    
    % Load attention audio sounds and store them
    attention_sounds.(attention_files(a).name(1:end-4)) = ...
        audioread(fullfile(attention_path, attention_files(a).name));
end

% Grab the filenames from the attention sounds fieldnames
attention_sound_fieldnames = fieldnames(attention_sounds);

%% Prep prompt audio
% Set the path, find the files, set up the holding structures
prompt_path = fullfile(root, 'stim', 'prompt_audio');
prompt_files = dir(prompt_path);
prompt_sounds = struct;

% Fill the prompt sound struct
for a = 1:length(prompt_files)
    
    % Skip mac hidden files
    if startsWith(prompt_files(a).name, '.')
        continue
    end
    
    % Load prompt audio sounds and store them
    prompt_sounds.(prompt_files(a).name(1:end-4)) = ...
        audioread(fullfile(prompt_path, prompt_files(a).name));
end

% Grab the filenames from the prompt sounds fieldnames
prompt_sound_fieldnames = fieldnames(prompt_sounds);

%% Prep reward audio
% Set the path, find the files, set up the holding structures
reward_path = fullfile(root, 'stim', 'reward_audio');
reward_files = dir(reward_path);
reward_sounds = struct;

% Fill the reward sound struct
for a = 1:length(reward_files)
    
    % Skip mac hidden files
    if startsWith(reward_files(a).name, '.')
        continue
    end
    
    % Load reward audio sounds and store them
    reward_sounds.(reward_files(a).name(1:end-4)) = ...
        audioread(fullfile(reward_path, reward_files(a).name));

end

% Grab the filenames from the reward sounds fieldnames
reward_sound_fieldnames = fieldnames(reward_sounds);

%% Prep main audio
InitializePsychSound(1);        % Low-latency mode

% Get the device index for the sound card
devices = PsychPortAudio('GetDevices');
match_index = find(contains({devices.DeviceName}, main_audio_device));

% If not plugged in put into a loop to ensure that it does get plugged in
while isempty(match_index)
    text_in = input(sprintf('Main audio not found, ensure soundcard is connected.\nType h for help or enter to continue:'), 's');
    devices = PsychPortAudio('GetDevices');
    match_index = find(contains({devices.DeviceName}, main_audio_device));
    
    if strcmp(text_in, 'h')
        fprintf(sprintf('\n\nDevice help:\nThe audio device that is being searched for is the first instance of %s\nthis is usually the soundcard. It does not matter which device index this is assigned.\n\nTo search for sound indexes call "InitializePsychSound(1)" then "devices = PsychPortAudio("GetDevices");"\n\nAdjust the main_audio_device by renaming it above.\n\nCurrent devices connected:\n', main_audio_device))
        d_names = {devices.DeviceName}; for a = 1:length(d_names); fprintf(sprintf('%s\n', d_names{a})); end
    elseif strcmp(text_in, 'x')
        Screen('CloseAll')
        PsychPortAudio('CloseAll')
        error('Unable to resolve tactor audio')
    end
end

audio_device_index = devices(match_index(1)).DeviceIndex;

% Prep the backing track
[bg_audio_data, bg_fs] = audioread(fullfile(stim_dir, bg_audio_name));

% Open master handle to cover background music and prompts
master_handle = PsychPortAudio('Open', audio_device_index, 1+8, 1, bg_fs, size(bg_audio_data,2));
PsychPortAudio('Start', master_handle, 0, 0, 1);

% Open background music handle
bg_handle = PsychPortAudio('OpenSlave', master_handle);
PsychPortAudio('FillBuffer', bg_handle, bg_audio_data');

% Prep the prompt/reward handle
prompt_handle = PsychPortAudio('OpenSlave', master_handle);

end