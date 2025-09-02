function [f1, f2, tact_hist] = next_weighted_tactor_intensity(tact_hist)

% Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com
% Date: 7th May 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

% Uses a weighted 2 up 1 down staircase to calculate the next set of intensities
% to be differentiated. Starts with a high instensity difference. Tracks trial tact_hist 
% and whether the response is correct. Adjusts the intensityuencies accordingly, bringing 
% them closer (harder) after correct trials, and farther apart (easier) after incorrect ones.
% Uses weighted steps, meaning two corrects are needed to go down (harder), and one 
% incorrect bumps it back up (easier), with asymmetric step sizes if needed.

%% First trial exception
% If the first trial then use the default settings so no calc needed
if tact_hist.current_trial.trial_num == 1 
    intensities = tact_hist.current_trial.unrounded_intensities;
    f1 = 0.5; %intensities(1);
    f2 = intensities(2);
    return
end

%% Settings
% min_sep = 1;                                % Minimum instensity separation
% max_sep = tact_hist.settings.intensity_range(end) - ...
%     0.5; %tact_hist.settings.intensity_range(1);  % Max intensity separation
% mid_point = ...                         
%     tact_hist.settings.mean_intensity;      % The mid point where intensities will converge
max_intensity = tact_hist.settings.intensity_range(end);
up_step = tact_hist.settings.up_step;       % Step up multiplier (easier)
down_step = tact_hist.settings.down_step;   % Step down multiplier (harder)
correct_to_step_down = ...
    tact_hist.settings.correct_to_step_down;% How many in a row for difficulty to increase
intensity_range = ...
    tact_hist.settings.intensity_range;     % The allowed range and steps of intensity

intensities = tact_hist.current_trial.unrounded_intensities;
f2 = intensities(2);

% Current trial
% current_intensities = ...                   % Current intensities without rounding
%     tact_hist.current_trial.unrounded_intensities;
% current_sep = abs(current_intensities(1) - current_intensities(2));


% Note: intensities without rounding to the nearest intensity step are used
% to prevent intensities getting stuck at higher difficulty levels. E.g.
% with a separation of 2 or less and a step up (easier) of 1.2 the
% intensity separation would be multiplied and found to be 2.4.
% If rounded the separation would not change preventing the participant
% from reaching an easier level.


%% Determine separation step
if ~tact_hist.current_trial.correct_resp
    % If an incorrect choice is made then make the task easier by 
    % increasing the intensity separation
    f2 = f2 * up_step;
elseif tact_hist.current_trial.correct_resp && tact_hist.current_trial.correct_in_a_row == correct_to_step_down
    % If correct choice the correct number of times in a row then make the
    % task harder by decreasin the intensity separation
    f2 = f2 * down_step;
    tact_hist.current_trial.correct_in_a_row = 0;  % Reset streak after change
% else
%     % Keep same separation
%     new_sep = current_sep;
end

% Ensure the new separation is above the minimum separation allowed
% new_sep = max(min_sep, min(new_sep, max_sep));
f1 = tact_hist.settings.baseline_intensity;
f2 = min(f2, max_intensity);

% Centre around mid point (mean)
% f1 = mid_point - new_sep/2;
% f2 = mid_point + new_sep/2;

% Update tact_hist with new intensities
tact_hist.current_trial.unrounded_intensities = [f1, f2];
tact_hist.tracker.unrounded_intensity_hist(...
    tact_hist.current_trial.trial_num, :) = [f1, f2];

% Snap to nearest available intensity steps
[~, i1] = min(abs(intensity_range - f1));
[~, i2] = min(abs(intensity_range - f2));
f1 = intensity_range(i1);
f2 = intensity_range(i2);

% Update tact_hist with new intensities
tact_hist.current_trial.current_intensities = [f1, f2];



% Use this to visualise the difficulty progression if the number of steps
% up and down are the same. You want to use this to make sure that the min
% seperation is possible and to tweak the difficulty/easiness.
% results = [];
% val = max_sep;
% % Simulates the number of steps given the increased difficulty to get
% % harder and the number of trials available
% for i = 1:round(tact_hist.num_trials * (2 / (1 + correct_to_step_down)))
%     val = val * down_step;
%     results = [results; val];
%     val = val * up_step;
%     results = [results; val];
% end
% figure; plot(results)

end
