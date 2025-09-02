function run_ocean_jelly_task_v5

% Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com
% Date: 7th May 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

% Presents gated tactile stimuli to left and right tactors simultaneously.
% Each stimulus is presented at different intencities, which translate to
% different intensities. These intensities start far apart and east to
% discriminate and become closer together as participant answers correctly.

% Important!! In this version of the tactors scripts the tactors audio
% comes directly from the mac and must be plugged into the audio jack.
% This is because the audio is not constant but instead controlled by the
% audio output.

% v5 runs with eye tracking
% v4 implements a fixation/trial structure
% v3 first stable version

fprintf(1,'<strong>SENSOR | Tactile Discrimination | Eye Tracking | starting up...</strong>\n')


%% Set paths
root = '/Users/SENSOR/Desktop/MATLAB';                      % Set root folder
addpath(genpath(root))                                      % Load all scripts in root folder
out_path = fullfile(root, 'data', 'tactdiscrim');           % Set path to save data
root = fullfile(root, 'stimEEG', 'tasks', 'tactdiscrim');   % Reset root to be more specific
stim_dir = fullfile(root, 'stim');                          % Stimuli directory
IOPort('CloseAll');                                         % Make sure serial port connections are closed
PsychPortAudio('Close');                                    % Make sure audio connections are closed


%% User settings
% These settings can be safely changed by the user without bugs, all
% settings will be recorded at the end so that any analysis can know what
% happened.

% General
num_trials = 30;
use_EEG = false;
use_ET = true;
run_training = false;
run_filler = true;
trials_between_reward = 2;                  % Number of trials between audio reward
trials_between_prompt = 3;                  % Number of trials between audio prompts

% Visual
show_preview = true;                        % Show preview screen
bg_video_name = 'ocean_vid.mp4';            % Background video filename
reward_video_name = 'star_animation.mp4';   % Reward movie
bg_opacity = 0.6;                           % Set background opacity
reward_video_duration = 15;                 % Sets the duration of reward videos in seconds

% Jellyfish
transparent_stimuli = true;                 % If using pngs with transparency
visual_buzz = 10;                           % Amount in pixels that the jellyfish buzz per frame while tactors are buzzing
offset = 500;                               % Number of pixels between jellyfish

% Audio
main_audio_device = 'SB Omni Surround';     % Device name for the main audio on the screen
bg_audio_name = 'bicycle.wav';              % Background audio filename (must be in stim folder)

% Tactor
num_tactors = 2;
tactor_audio_device = 'External Headphones';% Device name for the tactor audio
buzz_duration = 1;                          % seconds
stim_hz = 220;                              % instensity of stimulus (you would also need to move the correct stimulus into the folder from the alt tones folder)
intensity_range = 0.5:0.1:3;                % Used to dictate range of volumes to choose from
baseline_intensity = 0.5;                   % Baseline volume used
trial_pause = true;                         % Whether you would like a pause before jellyfish buzz for each trial
trial_pause_duration = 1;                   % Duration of pause in seconds


%% Participant ID
% Loop until a valid Participant ID is entered
if ~use_ET
    [participant_ID] = get_participant_id;
end

%% Key settings
KbName('UnifyKeyNames');


%% Play capping movie while setting up
if run_filler
    
    %% Prep screen
    [centrePos, cx, cy, imgH, imgW, jellyLeftTex, jellyRightTex, leftPos, ...
        pcx, pcy, p_imgH, p_imgW,  preview_centrePos, preview_divisor, preview_jellyLeftTex, ...
        preview_jellyRightTex, preview_leftPos, preview_offset, preview_rightPos, ...
        preview_text_base_font_size, preview_text_y_offset, preview_starfishTex, ...
        preview_win, preview_rect, reward_video_path, ps_imgH, ps_imgW, rightPos, ...
        s_imgH, s_imgW, screen_rect, starfishTex, stim_dir, text, ...
        text_base_font_size, text_colour, text_y_offset, video_path, win,  winRect, x_screen_prop] = ...
        setup_jellyfish_visuals(bg_video_name, offset, reward_video_name, root, show_preview, transparent_stimuli);
    
    movie_num = 1;
    [win, preview_win] = play_filler_movie(win, preview_win, movie_num);
end


%% Prep Eyetracking
if use_ET
    input(sprintf('\n\n<strong>Have you unplugged the tactors from the audio jack so calibration audio comes through?</strong>\n\n'), 's')
    Screen('CloseAll')
    PsychPortAudio('Close')
    [pres, log] = setup_jellyfish_eyetracking;
    participant_ID = sprintf('%s_%d_%s', pres.EyeTracker.Tracker.ParticipantID, pres.EyeTracker.Tracker.TimePoint, datestr(datetime, 'yyyy_mmm_dd_HH_MM_ss'));
    pres.WindowLimitEnabled = 0;
    
end

%% Prep screen
Screen('CloseAll')
[centrePos, cx, cy, imgH, imgW, jellyLeftTex, jellyRightTex, leftPos, ...
    pcx, pcy, p_imgH, p_imgW,  preview_centrePos, preview_divisor, preview_jellyLeftTex, ...
    preview_jellyRightTex, preview_leftPos, preview_offset, preview_rightPos, ...
    preview_text_base_font_size, preview_text_y_offset, preview_starfishTex, ...
    preview_win, preview_rect, reward_video_path, ps_imgH, ps_imgW, rightPos, ...
    s_imgH, s_imgW, screen_rect, starfishTex, stim_dir, text, ...
    text_base_font_size, text_colour, text_y_offset, video_path, win, winRect, x_screen_prop] = ...
    setup_jellyfish_visuals(bg_video_name, offset, reward_video_name, root, show_preview, transparent_stimuli);


%% Prep audio
PsychPortAudio('Close');
[attention_sounds, attention_sound_fieldnames, audio_device_index, bg_handle, master_handle, ...
    prompt_handle, prompt_sounds, prompt_sound_fieldnames, reward_sounds, reward_sound_fieldnames] = ...
    setup_jellyfish_audio(bg_audio_name, main_audio_device, root, stim_dir);


%% Prep tactors
if num_tactors > 0
    input(sprintf('\n\n<strong>Have you plugged the tactors into the audio jack?</strong>\n\n'), 's')
    [pahandle, pahandleMaster, stim, tactors] = setup_jellyfish_tactors(stim_dir, ...
        stim_hz, num_tactors, tactor_audio_device);
else
    stim = 0;
    pahandle = 0;
    pahandleMaster = 0;
end


%% Prep EEG
% Site-specific. Set some EEG details, and connect
if use_EEG
    setup_jellyfish_EEG;
end

%% Create tact_history struct to manage the tactor intencities
% Struct that will record the history and make the weighted changes
tact_hist = struct;                                             % Main struct

% Settings
tact_hist.settings.num_trials = num_trials;                     % Total number of trials
tact_hist.settings.num_tactors = num_tactors;                   % Number of tactors used in the trial
tact_hist.settings.use_EEG = use_EEG;                           % Whether or not the EEG is being used
tact_hist.settings.visual_buzz_intensity = visual_buzz;         % Amount that the jellyfish move when tactors buzz
tact_hist.settings.baseline_intensity = baseline_intensity;     % Baseline volume used.
tact_hist.settings.visual_offset = offset;                      % Offset from centre in pixels of jellyfish
tact_hist.settings.bg_opacity = bg_opacity;                     % Background opacity setting
tact_hist.settings.intensity_range = intensity_range;           % Volume intensity range
tact_hist.settings.stim_dur = buzz_duration;                         % Seconds
tact_hist.settings.up_step = 1.2;                               % Step up multiplier (easier)
tact_hist.settings.down_step = 0.8;                             % Step down multiplier (harder)
tact_hist.settings.correct_to_step_down = 2;                    % How many in a row for difficulty to increase
tact_hist.settings.trials_between_prompt = ...
    trials_between_prompt;                                      % Number of trials between prompts
tact_hist.settings.trials_between_reward = ...
    trials_between_reward;                                      % Number of trials between reward sounds
tact_hist.settings.trial_pause = trial_pause;                   % Sets a pause at the start of the trial before buzzing starts
tact_hist.settings.trial_pause_duration = trial_pause_duration; % Sets the duration of the start of trial pause
tact_hist.settings.reward_video_duration = ...
    reward_video_duration;                                      % Sets the duration of reward videos
tact_hist.settings.mean_intensity = mean(intensity_range);      % Mid point

% Info about the participant
tact_hist.participant.participant_ID = participant_ID;

% Info about the training phase
tact_hist.training.training_complete = 0;
tact_hist.training.current_phase = 0;
tact_hist.training.phases_complete = [0 0 0 0 0];
tact_hist.training.training_responses = [0 0 0 0 0];            % Tracks the responses made to training
tact_hist.training.correct_response = 0;                        % Used to track the correct response to check
tact_hist.training.first_buzz = false;                          % Tracks whether first buzz has happened, which we would like to be after the audio has finished
tact_hist.training.currently_buzzing = false;                   % Tracks whether the tactors are playing or not
tact_hist.training.responding = false;                          % Tracks whether a response has been selected so double.triple responses aren't selected

% Trackers for the current responses i.e. the actual data
tact_hist.current_trial.trial_num = 0;                          % Current trial count
tact_hist.current_trial.correct_resp = 0;                       % Current correct status to current trial
tact_hist.current_trial.correct_in_a_row = 0;                   % Number of current correct in a row
tact_hist.current_trial.current_intensities = ...               % Current intensities (always start as far apart as possible)
    [baseline_intensity intensity_range(end)];
tact_hist.current_trial.unrounded_intensities = ...             % Current unrounded intensities to stop ceiling floor effects
    [baseline_intensity intensity_range(end)];
tact_hist.current_trial.currently_buzzing = 0;                  % Tracks whether the tactors are playing or not
tact_hist.current_trial.starfish_rotation = 0;                  % Angle of starfish rotation
tact_hist.current_trial.trial_started = false;                  % Waits for user input to start the trial
tact_hist.current_trial.trial_ended = false;                    % Checks to see if the trial has ended
tact_hist.current_trial.fixation_init = false;                  % Checks whether fixation has been initiated
tact_hist.current_trial.trial_paused = true;                    % Whether the buzzing of the trial is paused
tact_hist.current_trial.trial_audio_start = false;              % Whether trial audio prompt has already played
tact_hist.current_trial.reward_audio_start = false;             % Whether reward audio prompt has been played
tact_hist.current_trial.add_question = false;                   % Whether the question mark should be added

% Trackers for the history of the data
tact_hist.tracker.total_correct = 0;                            % Total correct responses
tact_hist.tracker.correct_hist = zeros(num_trials, 1);          % History of whether trial was responded to correct
tact_hist.tracker.instensity_hist = zeros(num_trials, 2);       % History of instensityuency pairs per trial
tact_hist.tracker.correct_resp_hist = cell(num_trials, 1);      % History of which response is correct
tact_hist.tracker.unrounded_intensity_hist = ...
    zeros(num_trials, 2);                                       % History of unrounded intensities


%% Play capping movie while setting up
% fprintf(1,'\n\n<strong>Remember to plug the tactors into the audio jack</strong>\n\n')

if run_filler
    movie_num = 1;
    [win, preview_win] = play_filler_movie(win, preview_win, movie_num);
end

%% Run training block
% Close the capping video and play the jellyfish background movie
bg_movie = Screen('OpenMovie', win, video_path);
Screen('PlayMovie', bg_movie, 1); % Start playback

if run_training
    reward_movie = Screen('OpenMovie', win, reward_video_path);
    Screen('PlayMovie', reward_movie, 1); % Start playback
    
    code = run_training_block_v2(win, preview_win, tact_hist, jellyLeftTex, jellyRightTex, ...
        preview_jellyLeftTex, preview_jellyRightTex, audio_device_index, ...
        bg_opacity, centrePos, preview_centrePos, prompt_handle, ...
        preview_starfishTex, prompt_sounds, prompt_sound_fieldnames, starfishTex, ...
        bg_movie, reward_movie, visual_buzz, stim_dir, stim, ...
        screen_rect, preview_rect, leftPos, rightPos, preview_leftPos, preview_rightPos, ...
        x_screen_prop, cx, cy, offset, pcx, pcy, preview_offset, imgW, imgH, p_imgW, p_imgH, ...
        buzz_duration, pahandle, pahandleMaster);
    
    % If a quit has been requested during training then exit the script
    % immediately. At this point there is isn't anything to save.
    if code == 0
        fprintf(1,'\n\n<strong>Quit requested during training.</strong>\n\n')
        %% Cleanup
        if num_tactors > 0
            % Disable open tactors
            cmdStr = sprintf('T%d%s', 1, 'D');
            IOPort('Write', tactors, char(27));
            IOPort('Write', tactors, cmdStr);
            
            if num_tactors == 2
                cmdStr = sprintf('T%d%s', 2, 'D');
                IOPort('Write', tactors, char(27));
                IOPort('Write', tactors, cmdStr);
            end
            
            % Close the tactors
            IOPort('Close', tactors);
            
            % Close tactor audio handles
            PsychPortAudio('Close', pahandle);
            PsychPortAudio('Close', bg_handle);
            PsychPortAudio('Close', prompt_handle);
            
            if num_tactors == 2
                PsychPortAudio('Close', pahandleMaster);
                PsychPortAudio('Close', master_handle);
            end
        end
        
        if use_EEG
            [status, err] = NetStation('Disconnect');
            if status ~= 0
                error('Error during NetStation disconnect:\n\n\t%s', err)
            end
        end
        
        % Close windows on screens
        Screen('CloseAll');
        ShowCursor;
        
        return
    elseif code == 1
        fprintf(1,'\n\n<strong>Training skipped by user.</strong>\n\n')
    end
end

%% Initialise main trial
% Start the background audio
PsychPortAudio('Start', bg_handle, 0, 0, 1);

if use_EEG
    % Send syncing event
    [status, err] = NetStation('Event', '247', GetSecs);
    if status ~= 0
        error('Error during NetStation sync event sending:\n\n\t%s', err)
    end
end

%% Loop the video and start the trial
% Reset holders
selected = '';
video_requested = false;
aoi_init = false;
aoi_hit = false;

fprintf(1,'\n\n<strong>Controls:\nPress TAB at any time to request reward video, which will play after trial end.\nIf a video is requested it will play after the trial has ended.\n\nAll controls are based on eye movements. The script can be exited with ESC key.</strong>\n\n')
while true
    % Grab frame from video
    tex = Screen('GetMovieImage', win, bg_movie);
    if tex <= 0
        Screen('SetMovieTimeIndex', bg_movie, 0); % Rewind
        continue;
    end
    
    %% DRAW FRAME
    % Draw video frame
    Screen('DrawTexture', win, tex, [], screen_rect, [], [], bg_opacity);
    Screen('DrawTexture', preview_win, tex, [], preview_rect, [], [], bg_opacity);
    
    % First decide whether a fixation or trial is being played and draw
    % textures as appropriate

    % If trial hasn't started then play fixation screen
    if ~tact_hist.current_trial.trial_started
        % Draw the starfish
        Screen('DrawTexture', win, starfishTex, [], centrePos, ...
            tact_hist.current_trial.starfish_rotation);
        
        Screen('DrawTexture', preview_win, preview_starfishTex, [], preview_centrePos, ...
            tact_hist.current_trial.starfish_rotation);
        
        % Increment the rotation so that it spins
        tact_hist.current_trial.starfish_rotation = tact_hist.current_trial.starfish_rotation + 5;
        
        % Set up the area of interest (AOI) for the starfish when it is
        % first drawn
        if ~aoi_init
            
            % Converts pixel position to proportion for AoI
            centrePosProp = [centrePos(1) / screen_rect(3), ...
                centrePos(2) / screen_rect(4), ... % 0.1, ...%
                centrePos(3) / screen_rect(3), ...
                centrePos(4) / screen_rect(3)];
            
            % clear AoIs
            pres.EyeTracker.ClearAoIs;
            
            % Draw AOI
            pres.EyeTracker.AddAoI(centrePosProp, 'FIX');
            
            % send event noting start of fixation
            [fixOnsetLocal, fixOnsetRemote] = pres.EyeTracker.SendEvent('FIX_ONSET');
            
            % Set the flag so the AOI isn't continually redrawn
            aoi_init = true;
            aoi_hit = false;
            
        end
        
        % Play an attention sound when the fixation starfish first appears
        % on screen except when reward audio is playing
        % fixation_init is used to determine whether fixation has been initiated
        % reward_audio_start is used to determine whether reward audio is being played
        if ~tact_hist.current_trial.fixation_init && ~tact_hist.current_trial.reward_audio_start
            % Generate a random number for the prompt to be played
            r = randi(length(attention_sound_fieldnames), 1);
            
            % Play random audio sound
            attention_sound = [attention_sounds.(attention_sound_fieldnames{r})'; ...
                attention_sounds.(attention_sound_fieldnames{r})'];
            
            % Play attention sound
            PsychPortAudio('FillBuffer', prompt_handle, attention_sound);
            
            % Start the prompt audio
            PsychPortAudio('Start', prompt_handle, 1, 0, 1);
            
            % Set the fixation initiation to true
            tact_hist.current_trial.fixation_init = true;
        end
        
        % If an AoI hit hasn't yet been recorded then check for a hit
        if ~aoi_hit
            % Refresh the eyetracker
            pres.EyeTracker.Refresh;
            
            % check for hit on AOI
            aoi_hit_fix = pres.EyeTracker.LookupAoI('FIX');
            tact_hist.current_trial.trial_started = aoi_hit_fix.Hit;
            
            % Reset for the trial
            if tact_hist.current_trial.trial_started
                % send event noting end of fixation
                [fixOffsetLocal, fixOffsetRemote] = pres.EyeTracker.SendEvent('FIX_OFFSET');
                
                % Reset aoi_init flag for the trial
                aoi_init = false;
                clear aoi_hit_fix
                
                % If a pause is put before the jellyfish buzz then start a timer
                if tact_hist.settings.trial_pause
                    trial_pause_start = GetSecs();
                end
                
                % Note that there has been a hit
                aoi_hit = true;
            end
        end
    
    % if trial has started then play the jellyfish instead
    else
        
        % Check whether the jellyfish should be buzzing
        if tact_hist.current_trial.currently_buzzing

            % Set the amount of buzzing to be a random number within the visual buzz range
            % Then set the jitter offset by that much, this will be used for both jellyfish

            % Main screen
            jitterX = randi([-visual_buzz, visual_buzz]);
            jitterY = randi([-visual_buzz, visual_buzz]);
            jittered_rect_left = CenterRectOnPointd([0 0 imgW imgH], cx + jitterX - offset, cy + jitterY);
            jittered_rect_right = CenterRectOnPointd([0 0 imgW imgH], cx - jitterX + offset, cy - jitterY);
            
            % Preview screen
            preview_jitterX = jitterX * x_screen_prop;
            preview_jitterY = jitterY * x_screen_prop;
            preview_jittered_rect_left = CenterRectOnPointd([0 0 p_imgW p_imgH], pcx + preview_jitterX - preview_offset, pcy + preview_jitterY);
            preview_jittered_rect_right = CenterRectOnPointd([0 0 p_imgW p_imgH], pcx - preview_jitterX + preview_offset, pcy - preview_jitterY);
            
            % Draw the jellyfish to the screens
            Screen('DrawTexture', win, jellyLeftTex, [], jittered_rect_left);
            Screen('DrawTexture', win, jellyRightTex, [], jittered_rect_right);
            
            Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_jittered_rect_left);
            Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_jittered_rect_right);
        else

            % If not currently buzzing then just place the jellyfish on screen in their static places 
            Screen('DrawTexture', win, jellyLeftTex, [], leftPos);
            Screen('DrawTexture', win, jellyRightTex, [], rightPos);
            
            Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_leftPos);
            Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_rightPos);
        end
        
        % Set up the area of interest (AOI) for the starfish when it is
        % first drawn
        if ~aoi_init

            % Converts pixel position to proportion for AoI
            leftPosProp = [leftPos(1) / screen_rect(3), ...
                leftPos(2) / screen_rect(4), ...
                leftPos(3) / screen_rect(3), ...
                leftPos(4) / screen_rect(3)];

            % Converts picel position to proportion for AoI
            rightPosProp = [rightPos(1) / screen_rect(3), ...
                rightPos(2) / screen_rect(4), ...
                rightPos(3) / screen_rect(3), ...
                rightPos(4) / screen_rect(3)];
            
            % clear AoIs
            pres.EyeTracker.ClearAoIs;
            
            % Draw AOI
            pres.EyeTracker.AddAoI(leftPosProp, 'LEFT_JELLY');
            pres.EyeTracker.AddAoI(rightPosProp, 'RIGHT_JELLY');
            
            % send event noting start of trial
            [trialOnsetLocal, trialOnsetRemote] = pres.EyeTracker.SendEvent('TRIAL_ONSET');
            
            % Set the flag so the AOI isn't continually redrawn
            aoi_init = true;
            aoi_hit = false;
            
        end
        
        % After a fixed time, add a uestion mark to further prompt the participant
        % add_question is used to turn the question mark on or off
        if tact_hist.current_trial.add_question

            % Size of the question mark, based on the amount of time the question mark is on screen
            scale = sin(1.5 * 0.1 * pi * question_time);
            
            % Set the font text size
            text_font_size = round(text_base_font_size * scale);
            preview_font_size = round(preview_text_base_font_size * scale);
            
            % Apply to the screen
            Screen('TextSize', win, text_font_size);
            Screen('TextSize', preview_win, preview_font_size);
            
            % Set the bounds of the question mark on the screen
            bounds = Screen('TextBounds', win, text);
            preview_bounds = Screen('TextBounds', preview_win, text);
            
            % Set the position of the question mark on the screen
            xPos = cx - bounds(3)/2;
            preview_xPos = pcx - preview_bounds(3)/2;
            
            yPos = text_y_offset - bounds(4)/2;
            preview_yPos = preview_text_y_offset - bounds(4)/6;
            
            % Draw the text to the screens
            DrawFormattedText(win, text, xPos, yPos, text_colour);
            DrawFormattedText(preview_win, text, preview_xPos, preview_yPos, text_colour);
        end
    end
    
    % Draw the whole frame and textures to the screens
    Screen('Flip', win);
    Screen('Flip', preview_win);
    % Not sure why this doesn't work (as in v4) but this often causes crashing
    %     try
    % %     Screen('Close', tex);
    %     catch
    %     end
    
    %% RESPONSE AND AUDIO
    % If in fixation check for down arrow to start the trial
    if ~tact_hist.current_trial.trial_started
        
        % Key input for trial start
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('TAB'))
                if ~video_requested
                    fprintf('Reward video requested\n');
                end
                video_requested = true;
                
                %             elseif keyCode(KbName('DownArrow'))
                %                 selected = 'down';
                %
                %                 % Set the trial to start
                %                 tact_hist.current_trial.trial_started = true;
                %
                %                 % If a pause is put before the jellyfish buzz then start a timer
                %                 if tact_hist.settings.trial_pause
                %                     trial_pause_start = GetSecs();
                %                 end
                
            elseif keyCode(KbName('ESCAPE'))
                selected = 'Escape';
                break;
            end
        end
        
    % If in trial then perform logic to play tactors and audio at the
    % correct time.
    else

        % First trial
        % Checks to see if this is the first trial (which is treated as special)
        if tact_hist.current_trial.trial_num == 0
            
            % Checks to see if audio has finished and if not waits
            status = PsychPortAudio('GetStatus', prompt_handle);
            audio_finished = ~status.Active;
            if ~audio_finished
                continue
            end
            
            % Play a prompt sound if the correct trial number/interval
            if mod(tact_hist.current_trial.trial_num, tact_hist.settings.trials_between_prompt) == 0 && ...
                    ~tact_hist.current_trial.trial_audio_start
                
                % Generate a random number for the prompt to be played
                r = randi(length(fieldnames(prompt_sounds)), 1);
                
                % If prompt needed load random prompt and play
                PsychPortAudio('FillBuffer', prompt_handle, prompt_sounds.(prompt_sound_fieldnames{r})');
                
                % Start the prompt audio
                PsychPortAudio('Start', prompt_handle, 1, 0, 1);
                
                % Record whether trial audio prompt has already started
                tact_hist.current_trial.trial_audio_start = true;
                
            end
            
            % If there is a pause before the jellyfish buzz and that pause
            % is longer than the required duration then move on.
            if tact_hist.settings.trial_pause && ...
                    GetSecs() - trial_pause_start > tact_hist.settings.trial_pause_duration
                
                % Calc next set of intensities to play and play them
                tact_hist = play_tactor_stim(tact_hist, stim, pahandle, pahandleMaster);
                tact_hist.current_trial.currently_buzzing = 1;
                
                % Record the start time of the buzzing
                buzz_start_time = GetSecs();
                
                % Main task start
                main_task_start = true;
                
            elseif ~tact_hist.settings.trial_pause
                % If a selection has been made then choose the next set of stimuli
                selected = '';
                tact_hist = play_tactor_stim(tact_hist, stim, pahandle, pahandleMaster);
                tact_hist.current_trial.currently_buzzing = 1;
                buzz_start_time = GetSecs();
            end
            
            
        % End of the trials
        % If all trials have been run and a selection has been made
        elseif tact_hist.current_trial.trial_num == tact_hist.settings.num_trials && ~isempty(selected)
            
            % Stop the audio and break from the loop
            PsychPortAudio('Stop', bg_handle);
            break
           

        % Main trials - check if a selection has been made 
        elseif ~isempty(selected) && ~main_task_start
            
            % Checks to see if reward/prompt audio has finished and if not waits
            status = PsychPortAudio('GetStatus', prompt_handle);
            audio_finished = ~status.Active;
            if ~audio_finished
                continue
            end
            
            % If needed play the prompt sound depending on the
            % trialnumber/interval of prompts
            if mod(tact_hist.current_trial.trial_num, tact_hist.settings.trials_between_prompt) == 0 && ...
                    ~tact_hist.current_trial.trial_audio_start
                
                % Generate a random number for the prompt to be played
                r = randi(length(fieldnames(prompt_sounds)), 1);
                
                % If prompt needed load random prompt and play
                PsychPortAudio('FillBuffer', prompt_handle, prompt_sounds.(prompt_sound_fieldnames{r})');
                
                % Start the prompt audio
                PsychPortAudio('Start', prompt_handle, 1, 0, 1);
                
                % Record whether the trial audio has started
                tact_hist.current_trial.trial_audio_start = true;
                
            end
            
            % If there is a pause before the jellyfish buzz and that pause
            % is longer than the required duration then move on.
            if tact_hist.settings.trial_pause && ...
                    GetSecs() - trial_pause_start > tact_hist.settings.trial_pause_duration
                
                % If a selection has been made then choose the next set of stimuli
                selected = '';
                tact_hist = play_tactor_stim(tact_hist, stim, pahandle, pahandleMaster);
                tact_hist.current_trial.currently_buzzing = 1;
                buzz_start_time = GetSecs();
                
            elseif ~tact_hist.settings.trial_pause
                % If a selection has been made then choose the next set of stimuli
                selected = '';
                tact_hist = play_tactor_stim(tact_hist, stim, pahandle, pahandleMaster);
                tact_hist.current_trial.currently_buzzing = 1;
                buzz_start_time = GetSecs();
            end
        end

        %% Pause checks
        % To ensure the smooth flow of the logic, pauses have been built in to make sure that
        % certain things have stopped (e.g. audio playing, tactor buzzing etc) so that there
        % is order and not things overlapping all over the place.]
        
        % Checks to see if audio has finished and if not waits
        status = PsychPortAudio('GetStatus', prompt_handle);
        audio_finished = ~status.Active;
        if ~audio_finished
            continue
        end
        
        % Record that the reward audio has finished
        tact_hist.current_trial.reward_audio_start = false;
        
        % Ensure that the buzzing has finished before moving on
        if ~exist("buzz_start_time", "var") || GetSecs() - buzz_start_time < buzz_duration
            continue
        end
        
        % Reset the buzzer tracker
        tact_hist.current_trial.currently_buzzing = 0;
        
        % Set question time
        question_time = GetSecs() - (buzz_start_time + 2);
        if question_time > 0
            tact_hist.current_trial.add_question = true;
        end
        
        % If no AoI hit has been recorded check for a hit
        if ~aoi_hit
            % Refresh the eyetracker
            pres.EyeTracker.Refresh;
            
            % check for hit on AOI
            aoi_hit_left = pres.EyeTracker.LookupAoI('LEFT_JELLY');
            aoi_hit_right = pres.EyeTracker.LookupAoI('RIGHT_JELLY');

            % If a hit is recorded then we want to reset to the fixation screen
            if aoi_hit_left.Hit || aoi_hit_right.Hit
                tact_hist.current_trial.trial_started = false;
            end
            
            % Reset for the trial
            if ~tact_hist.current_trial.trial_started
                % Send event noting end of fixation
                [trialOffsetLocal, trialOffsetRemote] = pres.EyeTracker.SendEvent('TRIAL_OFFSET');
                
                % Reset aoi_init flag for the trial
                aoi_init = false;
                aoi_hit = true;
                
                % Update selected with the jellyfish selected
                if aoi_hit_left.Hit
                    selected = 'Left';
                    disp('Left selected')
                elseif aoi_hit_right.Hit
                    selected = 'Right';
                    disp('Right selected')
                end  
            end
        end
        
        %% Researcher input
        % Key input, if there is a selection then resets to fixation starfish
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('Return'))
                if ~video_requested
                    fprintf('Reward video requested\n');
                end
                video_requested = true;
                %             elseif keyCode(KbName('LeftArrow'))
                %                 selected = 'Left';
                %             elseif keyCode(KbName('RightArrow'))
                %                 selected = 'Right';
            elseif keyCode(KbName('ESCAPE'))
                selected = 'Escape';
                break;
            end
        end
        
        if strcmp(selected, 'Left') || strcmp(selected, 'Right')

            % Updates the responses and the tact_hist tracker
            main_task_start = false;
            tact_hist = is_tact_resp_correct(tact_hist, selected);
            tact_hist.current_trial.trial_started = false;
            tact_hist.current_trial.fixation_init = false;
            tact_hist.current_trial.trial_audio_start = false;
            tact_hist.current_trial.add_question = false;
            clear buzz_start_time
            
            % If video requested by researcher then play video and
            % reset flag
            if video_requested
                video_requested = false;
                
                % Stop the background audio and restart it after the
                % reward movie
                PsychPortAudio('Stop', bg_handle, 1);
                
                [win, preview_win] = play_filler_short_animation(win, preview_win, 0, 1, tact_hist.settings.reward_video_duration);
                
                PsychPortAudio('Start', bg_handle, 0, 0, 1);
                
            % Play a prompt sound if the correct trial number/interval
            elseif mod(tact_hist.current_trial.trial_num, tact_hist.settings.trials_between_reward) == 0
                
                % Generate a random number for the prompt to be played
                r = randi(length(reward_sound_fieldnames), 1);
                
                % If prompt needed load random prompt and play
                PsychPortAudio('FillBuffer', prompt_handle, reward_sounds.(reward_sound_fieldnames{r})');
                
                % Start the prompt audio
                PsychPortAudio('Start', prompt_handle, 1, 0, 1);
                
                % Record whether trial audio prompt has already started
                tact_hist.current_trial.reward_audio_start = true;
                
            end
        end
    end
end

%% Clean up jellyfish content
PsychPortAudio('Close', bg_handle);
PsychPortAudio('Close', prompt_handle);
PsychPortAudio('Close', master_handle);
Screen('PlayMovie', bg_movie, 0);
Screen('CloseMovie', bg_movie);

if use_EEG
    % Close connection to NetStation
    [status, err] = NetStation('Event', '249', GetSecs);
    if status ~= 0
        error('Error during NetStation end event sending:\n\n\t%s', err)
    end
    
    [status, err] = NetStation('StopRecording');
    if status ~= 0
        error('Error during NetStation stop recording:\n\n\t%s', err)
    end
end

%% Filler
% Play another movie to entertain the infants while equipment is changed
input(sprintf('\n\n<strong>Have you unplugged the tactors from the audio jack?</strong>\n\n'), 's')

if run_filler
    movie_num = 2;
    [win, preview_win] = play_filler_movie(win, preview_win, movie_num);
end

%% Cleanup
if num_tactors > 0
    % Disable open tactors
    cmdStr = sprintf('T%d%s', 1, 'D');
    IOPort('Write', tactors, char(27));
    IOPort('Write', tactors, cmdStr);
    
    if num_tactors == 2
        cmdStr = sprintf('T%d%s', 2, 'D');
        IOPort('Write', tactors, char(27));
        IOPort('Write', tactors, cmdStr);
    end
    
    % Close the tactors
    IOPort('Close', tactors);
    
    % Close tactor audio handles
    PsychPortAudio('Close', pahandle);
    if num_tactors == 2
        PsychPortAudio('Close', pahandleMaster);
    end
end

if use_EEG
    [status, err] = NetStation('Disconnect');
    if status ~= 0
        error('Error during NetStation disconnect:\n\n\t%s', err)
    end
end

% Close windows on screens
Screen('CloseAll');
ShowCursor;

% Clean up eye tracker data
pres.EyeTracker.StopTracking;
pres.EyeTracker.Disconnect;
% track.EndSession;
% log.SaveLogs(track.DataPath);
pres.EyeTracker.SaveData(pres.Paths.gap_data);

clear pres

% Save data
save_jellyfish_data(out_path, participant_ID, tact_hist)
% save(fullfile(out_path, participant_ID), "tact_hist");
fprintf('✅ Finished all trials.\n');
end
