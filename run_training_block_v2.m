function [code] = run_training_block_v2(win, preview_win, tact_hist, jellyLeftTex, jellyRightTex, ...
    preview_jellyLeftTex, preview_jellyRightTex, audio_device_index, ...
    bg_opacity, centrePos, preview_centrePos, prompt_handle, ...
    preview_starfishTex, prompt_sounds, prompt_sound_fieldnames, starfishTex, ...
    bg_movie, reward_movie, visual_buzz, stim_dir, stim, ...
    screen_rect, preview_rect, leftPos, rightPos, preview_leftPos, preview_rightPos, ...
    x_screen_prop, cx, cy, offset, pcx, pcy, preview_offset, imgW, imgH, p_imgW, p_imgH, ...
    dur_buzz, pahandle, pahandleMaster)

% Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com
% Date: 29th July 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

%% Setup
% Return code, 0 for exit, 1 for skip training, 2 for cintinue as usual
code = 2;

% Set up training audio
[instructions_1, i_fs] = audioread(fullfile(stim_dir, 'instructions_1.mp3'));
[instructions_2, ~] = audioread(fullfile(stim_dir, 'instructions_2.mp3'));
[instructions_3_0, ~] = audioread(fullfile(stim_dir, 'instructions_3_0.mp3'));
[instructions_3, ~] = audioread(fullfile(stim_dir, 'instructions_3.mp3'));
[instructions_4, ~] = audioread(fullfile(stim_dir, 'instructions_4.mp3'));
[instructions_5, ~] = audioread(fullfile(stim_dir, 'instructions_5.mp3'));
[reward_1, ~] = audioread(fullfile(stim_dir, 'reward_1.mp3'));

instructions_handle = PsychPortAudio('Open', audio_device_index, [], 0, i_fs, 2);


% The jellyfish order on screen was altered so the instruction order was
% altered too.
PsychPortAudio('FillBuffer', instructions_handle, instructions_1');

tact_hist.training.current_phase = 1;

% Researcher instructions
fprintf(1,'<strong>Responses:\nLeft and right arrow to move to next training section\nTAB to skip training\nESC to return and quit.</strong>\n')


%% ===========================
%  Phase 1: Introduction Red
%  ===========================

% Reset setup variables
selected = '';
init = 0;

% Loop the video and start the training phase
while true
    % Removed ocean video from the training phases 1/2
    % Grab frame from video
    % tex = Screen('GetMovieImage', win, bg_movie);
    % if tex <= 0
    %     Screen('SetMovieTimeIndex', bg_movie, 0); % Rewind
    %     continue;
    % end
    %
    % % Draw video frame
    % Screen('DrawTexture', win, tex, [], screen_rect);
    % Screen('DrawTexture', preview_win, tex, [], preview_rect);
    
    if tact_hist.training.currently_buzzing
        % Main screen
        jitterX = randi([-visual_buzz, visual_buzz]);
        jitterY = randi([-visual_buzz, visual_buzz]);
        jittered_rect_left = CenterRectOnPointd([0 0 imgW imgH], cx + jitterX - offset, cy + jitterY);
        
        % Preview screen
        preview_jitterX = jitterX * x_screen_prop;
        preview_jitterY = jitterY * x_screen_prop;
        preview_jittered_rect_left = CenterRectOnPointd([0 0 p_imgW p_imgH], pcx + preview_jitterX - preview_offset, pcy + preview_jitterY);
        
        Screen('DrawTexture', win, jellyLeftTex, [], jittered_rect_left);
        % Screen('DrawTexture', win, jellyRightTex, [], rightPos);
        
        Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_jittered_rect_left);
        % Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_rightPos);
    else
        Screen('DrawTexture', win, jellyLeftTex, [], leftPos);
        % Screen('DrawTexture', win, jellyRightTex, [], rightPos);
        
        Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_leftPos);
        % Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_rightPos);
    end
    
    Screen('Flip', win);
    Screen('Flip', preview_win);
    % Screen('Close', tex);
    
    % If the first trial then start the audio
    if init == 0
        % Training phase has been initialised
        init = 1;
        
        % Start the instructions audio
        PsychPortAudio('Start', instructions_handle, 1, 0, 1);
        
        % Play buzzing
        tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
        tact_hist.training.currently_buzzing = true;
        startTime = GetSecs();
        
        % If not currently buzzing and waitTime is longer than 2 seconds
    elseif ~tact_hist.training.currently_buzzing && GetSecs() - waitTime > 2
        
        % Play buzzing
        tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
        tact_hist.training.currently_buzzing = true;
        startTime = GetSecs();
        
        % If all trials have been run and a selection has been made
    elseif ~isempty(selected) && audio_finished
        %         PsychPortAudio('Stop', instructions_handle);
        break
    end
    
    % Check audio status
    status = PsychPortAudio('GetStatus', instructions_handle);
    audio_finished = ~status.Active;
    
    if audio_finished
        % Key input check
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('LeftArrow'))
                selected = 'Left';
            elseif keyCode(KbName('RightArrow'))
                selected = 'Right';
            elseif keyCode(KbName('TAB'))
                code = 1;
                break
            elseif keyCode(KbName('ESCAPE'))
                code = 0;
                break;
            end
        end
    end
    
    % Ensure that there is at least 1 second before the response is
    % selected
    if GetSecs() - startTime < dur_buzz
        continue
    end
    
    % Get start time for the waiting time
    if tact_hist.training.currently_buzzing
        waitTime = GetSecs();
    end
    
    % Reset the buzzer tracker
    tact_hist.training.currently_buzzing = false;
    
end

% Note that this section has been completed
tact_hist.training.phases_complete(tact_hist.training.current_phase) = 1;

% If quit has been signalled then return
if code == 0 || code == 1
    return
end

%% ===========================
%  Phase 2: Introduction Blue
%  ===========================


% Reset setup variables
selected = '';
init = 0;
tact_hist.training.first_buzz = false;

% Fill the buffer with the next set of instructons
PsychPortAudio('FillBuffer', instructions_handle, instructions_2');

% Set training phase to 2
tact_hist.training.current_phase = 2;

% Loop the video and start the training phase
while true
    % % Grab frame from video
    % tex = Screen('GetMovieImage', win, bg_movie);
    % if tex <= 0
    %     Screen('SetMovieTimeIndex', bg_movie, 0); % Rewind
    %     continue;
    % end
    %
    % % Draw video frame
    % Screen('DrawTexture', win, tex, [], screen_rect);
    % Screen('DrawTexture', preview_win, tex, [], preview_rect);
    
    if tact_hist.training.currently_buzzing
        % Main screen
        jitterX = randi([-visual_buzz, visual_buzz]);
        jitterY = randi([-visual_buzz, visual_buzz]);
        jittered_rect_right = CenterRectOnPointd([0 0 imgW imgH], cx - jitterX + offset, cy - jitterY);
        
        % Preview screen
        preview_jitterX = jitterX * x_screen_prop;
        preview_jitterY = jitterY * x_screen_prop;
        preview_jittered_rect_right = CenterRectOnPointd([0 0 p_imgW p_imgH], pcx - preview_jitterX + preview_offset, pcy - preview_jitterY);
        
        % Screen('DrawTexture', win, jellyLeftTex, [], leftPos);
        Screen('DrawTexture', win, jellyRightTex, [], jittered_rect_right);
        
        % Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_leftPos);
        Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_jittered_rect_right);
    else
        % Screen('DrawTexture', win, jellyLeftTex, [], leftPos);
        Screen('DrawTexture', win, jellyRightTex, [], rightPos);
        
        % Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_leftPos);
        Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_rightPos);
    end
    
    Screen('Flip', win);
    Screen('Flip', preview_win);
    % Screen('Close', tex);
    
    % If the first trial then play a tactor
    if init == 0
        % Training phase has been initialised
        init = 1;
        
        % Start the instructions audio
        PsychPortAudio('Start', instructions_handle, 1, 0, 1);
        
        % Play buzzing
        tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
        tact_hist.training.currently_buzzing = true;
        startTime = GetSecs();
        
        % If all trials have been run and a selection has been made
    elseif ~isempty(selected)
        %         PsychPortAudio('Stop', instructions_handle);
        break
        
        % If not currently buzzing and waitTime is longer than 2 seconds
    elseif ~tact_hist.training.currently_buzzing & GetSecs() - waitTime > 2
        
        % Play buzzing
        tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
        tact_hist.training.currently_buzzing = true;
        startTime = GetSecs();
    end
    
    % Check audio status
    status = PsychPortAudio('GetStatus', instructions_handle);
    audio_finished = ~status.Active;
    
    if audio_finished
        % Key input check
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('LeftArrow'))
                selected = 'Left';
            elseif keyCode(KbName('RightArrow'))
                selected = 'Right';
            elseif keyCode(KbName('TAB'))
                code = 1;
                break
            elseif keyCode(KbName('ESCAPE'))
                code = 0;
                break;
            end
        end
    end
    
    % Ensure that there is at least 1 second before the response is
    % selected
    if GetSecs() - startTime < dur_buzz
        continue
    end
    
    % Get start time for the waiting time
    if tact_hist.training.currently_buzzing
        waitTime = GetSecs();
    end
    
    % Reset the buzzer tracker
    tact_hist.training.currently_buzzing = false;
    
    % % Key input check
    % [keyIsDown, ~, keyCode] = KbCheck;
    % if keyIsDown
    %     if keyCode(KbName('LeftArrow'))
    %         selected = 'Left';
    %     elseif keyCode(KbName('RightArrow'))
    %         selected = 'Right';
    %     elseif keyCode(KbName('ESCAPE'))
    %         selected = 'Escape';
    %         break;
    %     end
    % end
end

tact_hist.training.phases_complete(tact_hist.training.current_phase) = 1;


%% ===========================
%  Phase 3: Reward
%  ===========================


% Reset setup variables
selected = '';
init = 0;

% Fill the buffer with the next set of instructons
PsychPortAudio('FillBuffer', instructions_handle, reward_1');

% Set training phase to 3
tact_hist.training.current_phase = 3;

% Loop the video and start the training phase
while true
    % Grab frame from video
    tex = Screen('GetMovieImage', win, reward_movie);
    if tex <= 0
        Screen('SetMovieTimeIndex', reward_movie, 0); % Rewind
        continue;
    end
    
    % Draw video frame
    Screen('DrawTexture', win, tex, [], screen_rect);
    Screen('DrawTexture', preview_win, tex, [], preview_rect);
    
    if tact_hist.training.currently_buzzing
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
        
        Screen('DrawTexture', win, jellyLeftTex, [], jittered_rect_left);
        Screen('DrawTexture', win, jellyRightTex, [], jittered_rect_right);
        
        Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_jittered_rect_left);
        Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_jittered_rect_right);
    else
        Screen('DrawTexture', win, jellyLeftTex, [], leftPos);
        Screen('DrawTexture', win, jellyRightTex, [], rightPos);
        
        Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_leftPos);
        Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_rightPos);
    end
    
    Screen('Flip', win);
    Screen('Flip', preview_win);
    Screen('Close', tex);
    
    % If the first trial then play a tactor
    if init == 0
        % Training phase has been initialised
        init = 1;
        
        % Start the instructions audio
        PsychPortAudio('Start', instructions_handle, 1, 0, 1);
        
        % Play buzzing
        %         tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
        %         tact_hist.training.currently_buzzing = true;
        %         startTime = GetSecs();
        
        % If all trials have been run and a selection has been made
    elseif ~isempty(selected)
        %         PsychPortAudio('Stop', instructions_handle);
        break
        
        % If not currently buzzing and waitTime is longer than 2 seconds
        %     elseif ~tact_hist.training.currently_buzzing & GetSecs() - waitTime > 2
        %
        %         % Play buzzing
        %         tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
        %         tact_hist.training.currently_buzzing = true;
        %         startTime = GetSecs();
    end
    
    % Check audio status
    status = PsychPortAudio('GetStatus', instructions_handle);
    audio_finished = ~status.Active;
    
    if audio_finished
        % Key input check
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('LeftArrow'))
                selected = 'Left';
            elseif keyCode(KbName('RightArrow'))
                selected = 'Right';
            elseif keyCode(KbName('TAB'))
                code = 1;
                break
            elseif keyCode(KbName('ESCAPE'))
                code = 0;
                break;
            end
        end
        
        pause_timer = GetSecs();
    end
    
    % Ensure that there's a pause after the audio has finished rather than
    % jumping on to the next part
    if exist('pause_timer', 'var') && GetSecs() - pause_timer < 5
        break
    end
    
    % Get start time for the waiting time
    %     if tact_hist.training.currently_buzzing
    %         waitTime = GetSecs();
    %     end
    
    % Reset the buzzer tracker
    %     tact_hist.training.currently_buzzing = false;
end

tact_hist.training.phases_complete(tact_hist.training.current_phase) = 1;

% If quit has been signalled then return
if code == 0 || code == 1
    return
end

%% ===========================
%  Phase 4: Practice block
%  ===========================

tact_hist.training.practice_block_complete = 0;

while ~tact_hist.training.practice_block_complete
    %% Reset setup variables
    init = 0;
    selected = '';
    tact_hist.training.practice_trial = 1;
    tact_hist.training.training_responses = [0 0 0 0 0];
    tact_hist.training.correct_response = 'Neither';
    tact_hist.training.currently_buzzing = false;
    tact_hist.training.responding = false;
    tact_hist.current_trial.trial_started = true;
    tact_hist.current_trial.trial_audio_start = false;
    
    % Set training phase to 3
    tact_hist.training.current_phase = 3;
    
    % Loop the video and start the training phase
    while tact_hist.training.practice_trial < 6
        
        %% DRAW FRAME
        % Grab frame from video
        tex = Screen('GetMovieImage', win, bg_movie);
        if tex <= 0
            Screen('SetMovieTimeIndex', bg_movie, 0); % Rewind
            continue;
        end
        
        % Draw video frame
        Screen('DrawTexture', win, tex, [], screen_rect, [], [], bg_opacity);
        Screen('DrawTexture', preview_win, tex, [], preview_rect, [], [], bg_opacity);
        
        % First decide whether a fixation or trial is being played and draw
        % textures as appropriate
        if ~tact_hist.current_trial.trial_started
            % Draw the starfish
            Screen('DrawTexture', win, starfishTex, [], centrePos, ...
                tact_hist.current_trial.starfish_rotation);
            
            Screen('DrawTexture', preview_win, preview_starfishTex, [], preview_centrePos, ...
                tact_hist.current_trial.starfish_rotation);
            
            % Increment the rotation so that it spins
            tact_hist.current_trial.starfish_rotation = tact_hist.current_trial.starfish_rotation + 5;
            
%             % Play an attention sound when the fixation starfish first appears
%             % on screen except when reward audio is playing
%             if ~tact_hist.current_trial.fixation_init && ~tact_hist.current_trial.reward_audio_start
%                 % Generate a random number for the prompt to be played
%                 r = randi(length(attention_sound_fieldnames), 1);
%                 
%                 attention_sound = [attention_sounds.(attention_sound_fieldnames{r})'; ...
%                     attention_sounds.(attention_sound_fieldnames{r})'];
%                 
%                 % Play attention sound
%                 PsychPortAudio('FillBuffer', prompt_handle, attention_sound);
%                 
%                 % Start the prompt audio
%                 PsychPortAudio('Start', prompt_handle, 1, 0, 1);
%                 
%                 tact_hist.current_trial.fixation_init = true;
%             end
            
        else
            if tact_hist.training.currently_buzzing
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
                
                Screen('DrawTexture', win, jellyLeftTex, [], jittered_rect_left);
                Screen('DrawTexture', win, jellyRightTex, [], jittered_rect_right);
                
                Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_jittered_rect_left);
                Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_jittered_rect_right);
            else
                Screen('DrawTexture', win, jellyLeftTex, [], leftPos);
                Screen('DrawTexture', win, jellyRightTex, [], rightPos);
                
                Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_leftPos);
                Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_rightPos);
            end
        end
        
        Screen('Flip', win);
        Screen('Flip', preview_win);
        Screen('Close', tex);
        
        %% RESPONSE AND AUDIO
        % If in fixation check for down arrow to start the trial
        if ~tact_hist.current_trial.trial_started
            
            % Key input for trial start
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(KbName('DownArrow'))
                    selected = 'down';
                    
                    % Set the trial to start
                    tact_hist.current_trial.trial_started = true;
                    
                    % If a pause is put before the jellyfish buzz then start a timer
                    if tact_hist.settings.trial_pause
                        trial_pause_start = GetSecs();
                    end
                    
                elseif keyCode(KbName('TAB'))
                    code = 1;
                    break
                elseif keyCode(KbName('ESCAPE'))
                    selected = 'Escape';
                    code = 0;
                    break;
                end
            end
            
            % If in trial then perform logic to play tactors and audio at the
            % correct time.
        else
            % If the first trial then play a tactor
            if init == 0
                % If a pause is put before the jellyfish buzz then start a timer
                if tact_hist.settings.trial_pause
                    trial_pause_start = GetSecs();
                end
                
                % Training phase has been initialised
                init = 3;
                
                % Fill the buffer with the next set of instructons
                PsychPortAudio('FillBuffer', instructions_handle, instructions_3_0');
                
                % Start the instructions audio
                PsychPortAudio('Start', instructions_handle, 1, 0, 1);
                
                % Play buzzing
                tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
                tact_hist.training.currently_buzzing = true;
                tact_hist.training.responding = false;
                buzz_start_time = GetSecs();
                
            elseif ~tact_hist.training.currently_buzzing && init == 2
                
                init = 1;
                
                % Now move on with the training that they have to discriminate
                tact_hist.training.current_phase = 4;
                
                % Fill the buffer with the next set of instructons
                PsychPortAudio('FillBuffer', instructions_handle, instructions_3');
                
                % Start the instructions audio
                PsychPortAudio('Start', instructions_handle, 1, 0, 1);
                
                % Play buzzing
                tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
                tact_hist.training.currently_buzzing = true;
                tact_hist.training.responding = false;
                buzz_start_time = GetSecs();
                
                % If not currently buzzing and waitTime is longer than 2 seconds then
                % buzz again
            elseif ~tact_hist.training.currently_buzzing && GetSecs() - waitTime > 2
                
                % Play a prompt sound if the correct trial number/interval
                if ~tact_hist.current_trial.trial_audio_start && tact_hist.training.practice_trial ~= 1

                    % Hard code in the prompts that directly ask which is
                    % wiggling the most so it is super obvious during
                    % training.
                    if tact_hist.training.practice_trial == 2
                        r = 14;
                    elseif tact_hist.training.practice_trial == 3
                        r = 16;
                    elseif tact_hist.training.practice_trial == 4
                        r = 15;
                    else
                        r = 17;
                    end
                    
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
                    tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
                    tact_hist.training.currently_buzzing = true;
                    tact_hist.training.responding = false;
                    
                    % Record the start time of the buzzing
                    buzz_start_time = GetSecs();
                    
                elseif ~tact_hist.settings.trial_pause
                    % If a selection has been made then choose the next set of stimuli
                    tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
                    tact_hist.training.currently_buzzing = true;
                    tact_hist.training.responding = false;
                    buzz_start_time = GetSecs();
                end
                
                %                 % Play buzzing
                %                 tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
                %                 tact_hist.training.currently_buzzing = true;
                %                 tact_hist.training.responding = false;
                %                 startTime = GetSecs();
            end
            
            % Ensure that there is at least 1 second before the response is
            % selected
            if GetSecs() - buzz_start_time < dur_buzz
                continue
            end
            
            % Record that the reward audio has finished
            tact_hist.current_trial.reward_audio_start = false;
            
            % Once buzzing has finished we start a wait timer so buzzing
            % doesn't start too soon and set currently_buzzing to false.
            
            % Get start time for the waiting time
            if tact_hist.training.currently_buzzing
                waitTime = GetSecs();
            end
            
            % Reset the buzzer tracker
            tact_hist.training.currently_buzzing = false;
            
            % Audio status running or not
            status = PsychPortAudio('GetStatus', instructions_handle);
            
            % Key input check
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && ~status.Active && ~tact_hist.training.responding
                if keyCode(KbName('LeftArrow'))
                    
                    % If left is the correct response then record that in
                    % training responses
                    if strcmp(tact_hist.training.correct_response, 'Left')
                        tact_hist.training.training_responses(...
                            tact_hist.training.practice_trial) = 1;
                    end
                    
                    % Increment the practice trial number
                    tact_hist.training.practice_trial = tact_hist.training.practice_trial + 1;
                    
                    % Mark that a response is being recorded and clear key info
                    % so no double responses are recorded
                    tact_hist.training.responding = true;
                    clear keyIsDown keyCode
                    
                    % Set the trial to stop for fixation
                    tact_hist.current_trial.trial_started = false;
                    tact_hist.current_trial.trial_audio_start = false;
                    
                elseif keyCode(KbName('RightArrow'))
                    
                    % If left is the correct response then record that in
                    % training responses
                    if strcmp(tact_hist.training.correct_response, 'Right')
                        tact_hist.training.training_responses(...
                            tact_hist.training.practice_trial) = 1;
                    end
                    
                    % Increment the practice trial number
                    tact_hist.training.practice_trial = tact_hist.training.practice_trial + 1;
                    
                    % Mark that a response is being recorded and clear key info
                    % so no double responses are recorded
                    tact_hist.training.responding = true;
                    clear keyIsDown keyCode
                    
                    % Set the trial to stop for fixation
                    tact_hist.current_trial.trial_started = false;
                    tact_hist.current_trial.trial_audio_start = false;
                    
                    % If eithr TAB or ESC recorded then escape from training
                elseif KeyCode(KbName('TAB'))
                    break;
                elseif keyCode(KbName('ESCAPE'))
                    break;
                end
                
                % Provide user feedback in case key press is during buzzing and
                % not recorded
                fprintf('Key press recorded\n')
            end
            
            if init == 3 && ~status.Active
                % Switch init to play the second audio clip (only once and only after the first)
                init = 2;
            end
            
            % disp(tact_hist.training.practice_trial)
        end
    end
    
    init = 0;
    
    correct_responses = sum(tact_hist.training.training_responses);
    fprintf(1,sprintf('<strong>Has the participant completed practice?\n%d/%d correct responses recorded.</strong>\ny to move on\nn to repeat practice\n', correct_responses, length(tact_hist.training.training_responses)))
    
    % Confer with the researcher to see if it needs to be redone. During
    % this time only play the background movie
    while true
        % Grab frame from video
        tex = Screen('GetMovieImage', win, bg_movie);
        if tex <= 0
            Screen('SetMovieTimeIndex', bg_movie, 0); % Rewind
            continue;
        end
        
        % Draw video frame
        Screen('DrawTexture', win, tex, [], screen_rect, [], [], bg_opacity);
        Screen('DrawTexture', preview_win, tex, [], preview_rect, [], [], bg_opacity);
        
        Screen('DrawTexture', win, jellyLeftTex, [], leftPos);
        Screen('DrawTexture', win, jellyRightTex, [], rightPos);
        
        Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_leftPos);
        Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_rightPos);
        
        Screen('Flip', win);
        Screen('Flip', preview_win);
        Screen('Close', tex);
        
        
        if init == 0
            % Training phase has been initialised
            init = 1;
            
            % Fill the buffer with the next set of instructons
            PsychPortAudio('FillBuffer', instructions_handle, reward_1');
            
            % Start the instructions audio
            PsychPortAudio('Start', instructions_handle, 1, 0, 1);
        end
        
        % % Check audio status
        % status = PsychPortAudio('GetStatus', instructions_handle);
        % audio_finished = ~status.Active;
        %
        % if audio_finished
        
        % Key input check
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('y'))
                selected = 'Complete';
                break
            elseif keyCode(KbName('n'))
                selected = 'Retry';
                break
            elseif keyCode(KbName('TAB'))
                selected = 'Escape';
                code = 1;
                break
            elseif keyCode(KbName('ESCAPE'))
                selected = 'Escape';
                code = 0;
                break;
            end
        end
        % end
    end
    
    switch selected
        case 'Complete'
            tact_hist.training.practice_block_complete = 1;
        case 'Retry'
            continue
        case 'Escape'
            break
    end
    
end

tact_hist.training.phases_complete(tact_hist.training.current_phase) = 1;

% Reset ready for the main trials
tact_hist.current_trial.trial_started = false;
tact_hist.current_trial.trial_audio_start = false;
tact_hist.current_trial.fixation_init = false;
tact_hist.current_trial.starfish_rotation = 0;

% If quit has been signalled then return
if code == 0 || code == 1
    return
end

%% =====================================
%  Phase 5: Final reward and transition
%  =====================================


% Reset setup variables
selected = '';
init = 0;

% Fill the buffer with the next set of instructons
PsychPortAudio('FillBuffer', instructions_handle, instructions_5');

% Set training phase to 3
tact_hist.training.current_phase = 5;

% Loop the video and start the training phase
while true
    % Grab frame from video
    tex = Screen('GetMovieImage', win, reward_movie);
    if tex <= 0
        Screen('SetMovieTimeIndex', reward_movie, 0); % Rewind
        continue;
    end
    
    % Draw video frame
    Screen('DrawTexture', win, tex, [], screen_rect);
    Screen('DrawTexture', preview_win, tex, [], preview_rect);
    
    if tact_hist.training.currently_buzzing
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
        
        Screen('DrawTexture', win, jellyLeftTex, [], jittered_rect_left);
        Screen('DrawTexture', win, jellyRightTex, [], jittered_rect_right);
        
        Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_jittered_rect_left);
        Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_jittered_rect_right);
    else
        Screen('DrawTexture', win, jellyLeftTex, [], leftPos);
        Screen('DrawTexture', win, jellyRightTex, [], rightPos);
        
        Screen('DrawTexture', preview_win, preview_jellyLeftTex, [], preview_leftPos);
        Screen('DrawTexture', preview_win, preview_jellyRightTex, [], preview_rightPos);
    end
    
    Screen('Flip', win);
    Screen('Flip', preview_win);
    Screen('Close', tex);
    
    % If the first trial then play a tactor
    if init == 0
        % Training phase has been initialised
        init = 1;
        
        % Start the instructions audio
        PsychPortAudio('Start', instructions_handle, 1, 0, 1);
        
        % Play buzzing
        tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
        tact_hist.training.currently_buzzing = true;
        startTime = GetSecs();
        
        % If all trials have been run and a selection has been made
    elseif ~isempty(selected)
        %         PsychPortAudio('Stop', instructions_handle);
        break
        
        % If not currently buzzing and waitTime is longer than 2 seconds
    elseif ~tact_hist.training.currently_buzzing & GetSecs() - waitTime > 2
        
        % Play buzzing
        tact_hist = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster);
        tact_hist.training.currently_buzzing = true;
        startTime = GetSecs();
    end
    
    % Check audio status
    status = PsychPortAudio('GetStatus', instructions_handle);
    audio_finished = ~status.Active;
    
    if audio_finished
        % Key input check
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('LeftArrow'))
                selected = 'Left';
            elseif keyCode(KbName('RightArrow'))
                selected = 'Right';
            elseif keyCode(KbName('TAB'))
                code = 1;
                break
            elseif keyCode(KbName('ESCAPE'))
                code = 0;
                break;
            end
        end
    end
    
    % Ensure that there is at least 1 second before the response is
    % selected
    if GetSecs() - startTime < dur_buzz
        continue
    end
    
    % Get start time for the waiting time
    if tact_hist.training.currently_buzzing
        waitTime = GetSecs();
    end
    
    % Reset the buzzer tracker
    tact_hist.training.currently_buzzing = false;
    
    % % Key input check
    % [keyIsDown, ~, keyCode] = KbCheck;
    % if keyIsDown
    %     if keyCode(KbName('LeftArrow'))
    %         selected = 'Left';
    %     elseif keyCode(KbName('RightArrow'))
    %         selected = 'Right';
    %     elseif keyCode(KbName('ESCAPE'))
    %         selected = 'Escape';
    %         break;
    %     end
    % end
end

tact_hist.training.phases_complete(tact_hist.training.current_phase) = 1;

tact_hist.training.training_complete = 1;

end

