function [tact_hist] = play_tactor_stim(tact_hist, stim, pahandle, pahandleMaster)

% Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com
% Date: 13th May 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

% Fills the buffers for each of tactors with the appropriate intensity using
% f1 and f2.

% To check
% - Does pahandle need to be passed back?
% - Does this run non-concurrently?

% Grab some settings from tact_hist
tact_hist.current_trial.trial_num = tact_hist.current_trial.trial_num + 1;
trial_num = tact_hist.current_trial.trial_num;
num_tactors = tact_hist.settings.num_tactors;

% Generate the next set of intensities for the tactors and update tactor history struct
[f1, f2, tact_hist] = next_weighted_tactor_intensity(tact_hist);

%     PsychPortAudio('FillBuffer', pahandle, wave1);
%     PsychPortAudio('FillBuffer', pahandleMaster, wave1);
%     PsychPortAudio('Volume', pahandle, 1, [v1 v2]);
%     PsychPortAudio('Start', pahandle, 1, 0, 0);
%     PsychPortAudio('Start', pahandleMaster, 1, 0, 1);

if num_tactors > 0
    % Fill the buffer
    PsychPortAudio('FillBuffer', pahandle, stim);
    PsychPortAudio('FillBuffer', pahandleMaster, stim);
end

% Depending on the number of tactors play in mono or stero
if num_tactors == 1
    PsychPortAudio('Volume', pahandle, f1);
    PsychPortAudio('Start', pahandle, 1, 0, 0);
elseif num_tactors == 2
    % Randomise which tactor gets the more intense and record
    if rand() > 0.5
        % Set the volume
        PsychPortAudio('Volume', pahandle, [], [f1, f2]);
        
        if tact_hist.settings.use_EEG
        % Send an EEG event
        [status, err] = NetStation('Event', '200', GetSecs);
        if status ~= 0
            error('Error during NetStation event:\n\n\t%s', err)
        end
        end
        
        % Start the tactors
        PsychPortAudio('Start', pahandle, 1, 0, 0);
        PsychPortAudio('Start', pahandleMaster, 1, 0, 1);
        
        % Tracj the info
        tact_hist.tracker.instensity_hist(trial_num, :) = [f1 f2];
        tact_hist.tracker.correct_resp_hist(trial_num) = {'Right'};
        fprintf('Trial %d/%d — instensitys: L=%0.2f, R=%0.2f\n', ...
            trial_num, tact_hist.settings.num_trials, f1, f2);
    else
        % Set the volume
        PsychPortAudio('Volume', pahandle, [], [f2, f1]);
             
        if tact_hist.settings.use_EEG
        % Send an EEG event
        [status, err] = NetStation('Event', '200', GetSecs);
        if status ~= 0
            error('Error during NetStation event:\n\n\t%s', err)
        end
        end
        
        % Start the tactors
        PsychPortAudio('Start', pahandle, 1, 0, 0);
        PsychPortAudio('Start', pahandleMaster, 1, 0, 1);
        
        % Track the info
        tact_hist.tracker.instensity_hist(trial_num, :) = [f2 f1];
        tact_hist.tracker.correct_resp_hist(trial_num) = {'Left'};
        fprintf('Trial %d/%d — instensitys: L=%0.2f, R=%0.2f\n', ...
            trial_num, tact_hist.settings.num_trials, f2, f1);
    end
elseif num_tactors == 0
    % If no tactors still calc which would have been "right" and print that
    % Randomise which tactor gets the more intense and record
    if rand() > 0.5    
        if tact_hist.settings.use_EEG
        % Send an EEG event
        [status, err] = NetStation('Event', '200', GetSecs);
        if status ~= 0
            error('Error during NetStation event:\n\n\t%s', err)
        end
        end
        
        % Track the info
        tact_hist.tracker.instensity_hist(trial_num, :) = [f1 f2];
        tact_hist.tracker.correct_resp_hist(trial_num) = {'Right'};
        fprintf('Trial %d/%d — instensitys: L=%0.2f, R=%0.2f\n', ...
            trial_num, tact_hist.settings.num_trials, f1, f2);
    else
        if tact_hist.settings.use_EEG
        % Send an EEG event
        [status, err] = NetStation('Event', '200', GetSecs);
        if status ~= 0
            error('Error during NetStation event:\n\n\t%s', err)
        end
        end
        
        % Track the info
        tact_hist.tracker.instensity_hist(trial_num, :) = [f2 f1];
        tact_hist.tracker.correct_resp_hist(trial_num) = {'Left'};
        fprintf('Trial %d/%d — instensitys: L=%0.2f, R=%0.2f\n', ...
            trial_num, tact_hist.settings.num_trials, f2, f1);
    end
end

end