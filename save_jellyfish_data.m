function save_jellyfish_data(out_path, participant_ID, tact_hist)

% Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com
% Date: 29th July 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

if ~exist(out_path, 'dir'); mkdir(out_path); end
temp = fullfile(out_path, 'participant_data');
if ~exist(temp, 'dir'); mkdir(out_path); end
temp = fullfile(out_path, 'struct_backups');
if ~exist(temp, 'dir'); mkdir(out_path); end

%% Grab participant info
temp_ppt = split(participant_ID, '_');
ppt = temp_ppt{1};
wave = temp_ppt{2};
timestamp = strjoin(temp_ppt(3:end), '_');

%% Set up participant folders
ppt_folder = fullfile(out_path, 'participant_data', ppt);
wave_folder = fullfile(ppt_folder, wave);
date_folder = fullfile(wave_folder, timestamp);

folders = {ppt_folder, wave_folder, date_folder};

% Loop through folders and make them if they don't exist (likely all of
% them)
for folder = 1:length(folders)
    if ~exist(folders{folder}, 'dir')
        mkdir(folders{folder})
    end
end

%% Clean up and format
num_completed_trials = tact_hist.current_trial.trial_num;

% Clean up settings and grab other info for the participant info table
temp_info = tact_hist.settings;
temp_info.min_intensity = temp_info.intensity_range(1);
temp_info.max_intensity = temp_info.intensity_range(end);
temp_info.intensity_interval = temp_info.intensity_range(2) - temp_info.intensity_range(1);
temp_info.num_trials_completed = num_completed_trials;
temp_info.completed_training = tact_hist.training.training_complete;
temp_info.training_phases_completed = tact_hist.training.phases_complete;
temp_info.training_correct_responses = tact_hist.training.training_responses;
temp_info.total_training_correct_responses = sum(tact_hist.training.training_responses);
temp_info.total_trial_correct_responses = tact_hist.tracker.total_correct;
temp_info = rmfield(temp_info, {'intensity_range'});

% Grab an format the tracker info
temp_tracker = tact_hist.tracker;
temp_tracker = rmfield(temp_tracker, {'total_correct'});
tracker_fieldnames = fieldnames(temp_tracker);
for i = 1:length(tracker_fieldnames)
    temp_tracker.(tracker_fieldnames{i}) = temp_tracker.(tracker_fieldnames{i})(1:num_completed_trials, :);
end

%% Convert to a table
info = struct2table(temp_info);
tracker = struct2table(temp_tracker);

%% Save
% Save a redundant backup copy of the struct in case of issues
save(fullfile(out_path, 'struct_backups', [participant_ID, '.mat']), 'tact_hist');

% Save tables
save(fullfile(date_folder, ['ppt_info_', timestamp, '.mat']), 'info');
save(fullfile(date_folder, ['tracker_info_', timestamp, '.mat']), 'tracker');

end