# READ ME: Jellyfish_Tactile_Discrimination_Task
This is a Matlab/Psychtoolbox task designed for the Birkbeck College (CBCD), SENSOR project. This task tests tactile discrimination in a fun jellyfish/underwater themed game. v4 runs with researcher inputting participant responses. v5 runs with eyetracking to control the responses.
## Background
Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com<br />
For: SENSOR Project
- [https://cbcd.bbk.ac.uk/research/sensor]
<!-- end of the list -->
Date: 2nd September 2025<br />
Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html<br />
Open to collaboration—feel free to contact me!<br />
## Versioning
v3 was the first stable version of the jellyfish task, this ran as a continuous session with no trials, encouragement or other input. v3 was researcher controlled only.
v4 is a stable version of the jellyfish task using a trial structure, training, reward and encouragement prompts. Participant responses are made and input by the researcher using keyboard keys.
v5 is a stable version of the jellyfish task that uses eye tracking for the participant response.
## Known issues and suggested improvements.
V5
### Updates to et setup
At the moment the system uses a hybrid of custom code (the jellyfish part) and task engine (used only to control the eye tracking). The reason for this is that task engine doesn’t allow the level of audiovisual control necessary for the tactors, but I didn’t have time to code in a bespoke eye tracking system. Extract custom code for connecting to eyetracker, calibration, eyetracker refresh, AoI logic etc, tracking and data saving. Put this within the custom code for the jellyfish task. This would remove the need to run the visuals set up twice (once before so that the filler movie is played) and once again after the eyetracking setup has run to reassert the controlable screen. This would also remove the confusing closing and reloading of screens.
### Customisable fixation duration
Currently the fixations in v5 are based on the last frame rather than a specific fixation duration, this is easy enough to add into the script. Add a variable for the duration requested and pass this through to LookUpAoI in the appropriate format.
### Generate AoI coordinates in setup
At the moment centrePosProp, leftPosProp and rightPosProp (used to set up AoI coordinates) are generated within the main trial loop, but as these don’t change this could be moved to setup_jellyfish_eyetracking or setup_jellyfish_visuals. This wasn’t done as there wasn’t enough time to implement and properly test.
### Reintroduce manual controls
It may be worth reintroducing the manual controls for the researcher if the participant is unresponsive it could move the task on (allowing the researcher to request an attention grabbing video etc). To do this uncomment the code related to the directional arrows (lines 539-548 and 743-746). This wasn’t done as there wasn’t enough time to implement and properly test.
### Refactor code relating to reward/prompt audio
The code relating to rewards or prompts is repeated and could be replaced with a function instead making the main script shorter and removing the potential for differences when editing this code.
### Update et save path
Currently on line 865 there is a call to save the data, this hasn’t been fully tested and also saves that data in the gap_data path. This needs to be updated to somewhere else.
This may need to be updated to save manually if it isn’t working well, there is a good example in gap_trial.
### Record timing of audio prompts and/or tactor buzzing in eyetracking log
If in the future analysis looking at response times is conducted then the variable onset time needs to be taken into account and it would be worthwhile recording (via eye tracking event) when the audio finishes. 
E.g. imagine two trials. First: trial starts, the tactors buzz for exactly one second (during which time a response cannot be made) and then the participant makes a look to the jellyfish (or looks to the jellyfish during the second of buzzing). Second: trial starts, prompt audio plays with a variable duration, the tactors then buzz for exactly one second. The participant then looks to one or has already looked at one or the other.
This presents the possibility for a range of exciting new analysis questions:<br />
  1.	Do participants look to the correct jellyfish during the buzzing?
    a.	If so, is there a temporal difference between groups?
  2.	Do participants change their fixation direction while the jellyfish are buzzing?<br />
    a.	This could be an issue if they look to the correct jellyfish and then look at the other for novelty. This could be recorded as an incorrect response.
  3.	Does having the audio prompt mean that participant fixation is not in the centre of the screen (which would have been drawn originally by the starfish)?
  4.	Do participants look to specific jellyfish during the audio prompts?<br />
    a.	I.e. if by chance a jellyfish has had more correct responses overall, or more recent correct responses do participants favour looking at that jellyfish?<br />
    b.	Are there any group differences in this respect?
<!-- end of the list -->
As a result, if we want to look at these, we need to send events at the start and end of the buzzing and the audio prompts. This wouldn’t be difficult, events are already sent to the eyetracking log, it would just mean adding in more events.
## To Test
-	**Eyetracking results** - Do the eye tracking results come out as expected?
-	**Eyetracking sensitivity** – Is the eye tracker sensitive enough to pick up directional responses?
-	**Eyetracking overlap** – Is there enough of a temporal gap between fixation hit to an AoI and the next part of the trial? I.e. a fixation to the fixation starfish isn’t then immediately leading to a fixation on the jellyfish causing the trial to move on too quickly?
<!-- end of the list -->
## User settings
The script allows you to adjust several settings before running the tactile discrimination task. Withing the “User settings” section any of the values can be safely modified depending on your experiment needs without needing changes to the subsequent code. All chosen settings are automatically recorded with the data for reference during analysis.
### General Settings
-	**num_trials** (number): Total number of trials in the session. Example: 30
-	**use_EEG** (true/false): Whether EEG recording is active. Example: false
-	**run_training** (true/false): Include the training block at the start. Example: true
-	**run_filler** (true/false): Play filler movies before/after task. Example: true
-	**trials_between_reward** (number): Number of trials between reward sounds. Example: 2
-	**trials_between_prompt** (number): Number of trials between audio prompts. Example: 3
    - Note: the number of trials between reward and prompt should be offset so that the reward and prompt audio aren’t always played together.
<!-- end of the list -->
### Visual Settings
-	**show_preview** (true/false): Display preview screen for the researcher trials. Example: true
-	**bg_video_name** (string): Filename of background video. Example: 'ocean_vid.mp4'
-	**reward_video_name** (string): Filename of reward animation. Example: 'star_animation.mp4'
    - This has only been used in the training steps.
-	**bg_opacity** (number, 0–1): Transparency of background video to help the jellyfish appear more visually salient and distinguishable. Example: 0.6
-	**reward_video_duration** (number): Duration of reward video in seconds. Example: 8
<!-- end of the list -->
### Jellyfish Stimuli Settings
-	**transparent_stimuli** (true/false): Use images with transparency. If set to false then there will be white boxes where images are transparent. Example: true
-	**visual_buzz** (number, pixels): Maximum jitter of jellyfish during stimulus. Example: 10
-	**offset** (number, pixels): Horizontal offset of jellyfish from centre. Example: 500
<!-- end of the list -->
### Audio Settings
-	**main_audio_device** (string): Name of the main audio output device. This is the audio devide that plays the background sounds, not the tactor audio device (see Tactor settings). Example: 'SB Omni Surround'
-	**bg_audio_name** (string): Background audio filename. Example: 'bicycle.wav'
    -	Other background sounds included are ‘Ending.mp3’ and ‘Poupis_Theme.mp3’. These may need to be converted to .wav.
<!-- end of the list -->
### Tactor Settings
-	**num_tactors** (number): Number of tactors active. Example: 2
    - If 1 tactor is chosen then the left tactor should play only. If 0 tactors is chosen then the system should play as normal just without the buzzing.
-	**tactor_audio_device** (string): Device name for tactor audio. Example: 'External Headphones'
-	**buzz_duration** (number, seconds): Duration of tactor stimulus. Example: 1
-	**stim_hz** (whole number, Hz): Frequency/intensity of stimulus. Example: 220
-	**intensity_range** (number array): Range of volume intensities. Example: 0.5:0.05:5
    - When changing the intensity range these should be tested to make sure that the intensities can be distinguished.
-	**baseline_intensity** (number): Used as the intensity for the baseline tactor. One tactor will always be this intensity and the difference between this and the other tactor is what is being tested. Example: 0.5
-	**trial_pause** (true/false): Insert pause before tactor buzz. Example: true
-	**trial_pause_duration** (number, seconds): Duration of pre-buzz pause. Example: 1
<!-- end of the list -->
## run_ocean_jelly_task_v4.m
### Purpose:
The script presents visual and tactile stimuli to participants, measuring their ability to discriminate between different stimulus intensities. It is designed for experiments with infants or children, incorporating adaptive difficulty, training blocks, attention prompts, and reward feedback. EEG recording can be integrated if required.
#### 1. Initial Setup
-	The script begins by setting up paths, loading all necessary scripts, and defining where experimental data will be saved.
-	Any previous serial port or audio connections are closed to ensure a clean start.
-	The participant is prompted to enter a valid ID (see get_participant_id function below), which is then used to track all subsequent data.
-	The script reads user-adjustable settings (see above guide).
<!-- end of the list -->
#### 2. Preparation of Visuals and Audio
Visuals and audio are prepared (see setup_jellyfish_visuals, setup_jellyfish_audio and setup_jellyfish_tactors functions below):
-	Jellyfish stimuli textures are loaded for both main and preview screens.
-	Background and reward videos are loaded.
-	Starfish fixation and attention markers are created.
-	Audio setup includes background sounds, prompts, and reward sounds.
-	If tactors are used, the system prepares the tactor devices and stimulus signals.
<!-- end of the list -->
#### 3. EEG Preparation (Optional)
If EEG recording is enabled, the script connects to the EEG system and prepares syncing events. This part is under tested but stable.
(see setup_jellyfish_EEG function below):
#### 4. Trial History and Tracking Initialization
A structure (tact_hist) is created to manage:
-	Participant info.
-	Trial settings.
-	Training phase tracking.
-	Trial-by-trial intensity, responses, and performance history.
<!-- end of the list -->
All settings are saved in tact_hist to keep a record of the user settings that were used as well as a record of the results.
#### 5. Pre-Experiment Filler / Attention Movie
Before trials begin, a capping movie or filler video is optionally played to keep participants engaged while equipment is checked. This is ended by the researcher pressing tab.
If the movie is prespecified then the prespecified movie will be played (by default Peppa Pig), but no movie needs to be specified and a choice will be shown on screen.
(see play_filler_movie function below)
#### 6. Training Block
If enabled, a training block is run (see run_training_block_v2 function below):
-	A background video and reward video are played.
-	Participants are guided through initial trials to familiarise themselves with the task. First introducing each jellyfish with a blank background, then the undersea concept, then the trial structure.
-	During the trial structure only, responses are monitored, and difficulty is adaptively adjusted based on performance. If the participant doesn’t do well enough then the training can be repeated with input from the researcher.
-	The system can terminate the training early if requested, cleaning up audio, tactor, and EEG resources.
<!-- end of the list -->
#### 7. Main Trial Loop
The main trials proceed as below. At any point the researcher can press tab to request a reward video or escape to end the trials and move onto a filler video.
  1.	Video Playback: Background video frames are drawn continuously on both main and preview screens. This is put first so if the rest of the logic is paused then the background video will continue playing.
  2.	Fixation / Starfish Phase:<br />
    a.	A rotating starfish appears while attention sounds prompt the participant.<br />
    b.	The trial begins when the researcher presses the down arrow key. If a trial start pause has been requested then a timer is started 
  3.	Trial Start:<br />
    a.	Jellyfish stimuli are displayed on screen moving (visual buzz) when tactors are buzzing.<br />
    b.	Tactor stimuli are played if available (see play_tactor_stim function below).<br />
    c.	Audio prompts or rewards are triggered based on the trial number.
  4.	Response Collection:<br />
    a.	The researcher responds with left or right arrow keys to indicate stimulus responses.<br />
    b.	Correctness is recorded, and stimulus difficulty is adapted accordingly with two correct responses needed for the difficulty to increase (see is_tact_resp_correct function below)<br />
    c.	Reward videos or sounds are played when appropriate.<br />
    d.	If a filler video/animation has been requested then plays a short animation. These are used to grab the participant’s attention (see play_filler_short_animation function below).
  5.	Adaptive Updates:<br />
    a.	Intensities of the tactile stimuli are adjusted based on previous trial performance to maintain task challenge.<br />
    b.	Trial tracking variables are updated.
<!-- end of the list -->
Researchers can request a reward video at any point using the TAB key. The system pauses the background audio, plays the reward, then resumes.
The trial loop continues until all trials are completed or the experiment is manually stopped.
#### 8. Post-Experiment Filler
After trials, a second filler video is optionally played while the experimenter changes equipment or disengages participants.
#### 9. Clean-up and Data Saving
All devices and connections are safely closed:
-	Tactors are disabled and closed.
-	Audio devices are closed.
-	EEG connections are disconnected.
-	All screen windows are closed, and the cursor is restored.
-	Data from the session, including trial history and settings, is saved to the designated output folder.
<!-- end of the list -->
#### 10. Completion
A final confirmation message is printed, indicating that all trials have successfully finished.
## run_ocean_jelly_task_v5.m
### Purpose:
The script presents visual and tactile stimuli to participants, measuring their ability to discriminate between different stimulus intensities. It is designed for experiments with infants or children, incorporating adaptive difficulty, training blocks, attention prompts, and reward feedback. EEG recording can be integrated if required.
### Experimental Flow
As well as setup steps 1-4, there is an additional eyetracking setup step is added (see setup_jellyfish_eyetracking below) and get_participant_id is not used. 
### Eyetracker setup
Visuals and audio are prepared (see setup_jellyfish_visuals, setup_jellyfish_audio and setup_jellyfish_tactors functions below):
-	Path Setup - Adds all necessary MATLAB paths for dependencies.
-	Presenter Setup – Uses taskengine to set up a presenter object with associated properties and methods.
-	Eye Tracker Setup – Uses tobii eyetracker method to connect to the eye tracker and set up relevant properties.
-	Data Tracking and Logging – Sets up tracking and logging.
-	Calibration – Runs calibration logic.
-	Session Start – Starts the eye tracking session.
<!-- end of the list -->
### Main Trial Loop Updates
During the main trial loop, rather than the researcher pressing the directional arrows to move the script along the responses are controlled by fixations (currently as soon as the object is viewed).
If areas of interest (AoIs) have not been set up then:
-	The position is calculated based on the position of the textures that have been generated.
-	AoIs are cleared using ClearAoIs method (just to be sure).
-	AoI is drawn to the screen and given a name.
-	An event is sent to the eye tracking tracker.
-	Data is requested through Refresh.
-	Hits are checked between eye tracking data and AoIs.
-	If the AoI has been hit then send an event and move the trial to fixation or fixation to trial.
<!-- end of the list -->
## Subfunctions
### get_participant_id.m
#### Purpose
Generates a validated and timestamped participant ID string by prompting the user for group and wave information. Ensures consistent formatting for downstream file naming or data tagging.
Note that this is not used for v5 as the task engine 
#### What it Does
-	Prompts the user for a Participant ID (P, S, or N followed by 3 digits).
-	Validates input using a regular expression.
-	Asks for a Wave number (1–3, corresponding to age groups).
-	Validates input against allowed values.
-	Appends a timestamp to create a unique ID string in the format:
    -	S001_2_2025_Jul_29_15_34_12.
<!-- end of the list --><br />
### setup_jellyfish_visuals.m
#### Purpose
Initialises all screen and visual stimulus elements for a jellyfish-themed experimental task. It sets up both the main display and an optional preview window, loads and prepares stimuli (images and videos), and computes all texture handles and screen positions for accurate rendering.
#### What it Does
-	**Screen Setup**:
    -	Opens a full-sized main window and (optionally) a smaller preview window, both with a white background [255, 255, 255]. Enables blending if using transparent images.
-	**Stimulus Pathing**:
    - Constructs file paths for background and reward videos, jellyfish images, and a starfish image from a specified root directory.
-	**Image Loading and Preparation**:
    -	Loads image files, applies alpha channels for transparency (if enabled), and resizes them for both main and preview windows.
    -	To change jellyfish or starfish images you would need to look in the “on screen settings and variables” section.
-	**Texture Creation**:
    -	Converts each image into a texture for display using Psychtoolbox’s Screen('MakeTexture').
-	**Positioning**:
    -	Calculates on-screen coordinates for placing jellyfish and starfish images on both windows, offsetting the jellyfish horizontally by a user-defined value, “offset”.
-	**Text Settings**:
    -	Prepares text display settings (font, style, colour, size, position) for both main and preview screens.
-	**Outputs**:
    -	Returns all relevant textures, image sizes, positions, screen handles, and paths needed for the main experiment to display visuals consistently.
<!-- end of the list --><br />
### setup_jellyfish_audio.m
#### Purpose
Initialises all auditory components for a jellyfish-themed experimental task, including loading audio files, preparing PsychPortAudio devices, and configuring playback handles for background, prompt, attention, and reward sounds.
#### What it Does
-	**Loads Audio Files**:
    -	Scans subdirectories (attention, prompt_audio, and reward_audio) inside the stimulus directory and loads all .wav (or similar) files into structs.
    -	Fieldnames of each struct correspond to the filenames (minus extension), allowing flexible reference to specific sounds without worrying which format they’re in.
    -	Files can be removed, replaced or added without breaking the set up.
-	**Initialises PsychPortAudio**:
    -	Activates low-latency audio mode and searches for the target audio device by name.
    -	If the device isn’t found, it prompts the user with troubleshooting options until the device is connected.
-	**Sets Up Audio Handles**:
    -	Opens a master audio handle that governs all audio playback for everything that isn’t tactor related.
    -	Opens a slave handle for background audio, loads and prepares the looping track specified by bg_audio_name.
    -	Opens another slave handle for prompt/reward audio, allowing sounds to be layered over background audio. This is also used for attention sounds.
-	**Returns**:
    -	All audio structs and their fieldnames.
    -	PsychPortAudio handles for background, master, and prompt/reward streams.
    -	The audio device index for reference or debugging.
<!-- end of the list --><br />
### setup_jellyfish_tactors.m
#### Purpose
Initialises the tactile feedback system (tactors) for the experiment. It opens the correct audio device, loads the stimulation waveform, and prepares serial communication with the physical tactor hardware to ensure they're ready for use.
#### What it Does
-	**Device Matching**:
    -	Searches available audio output devices for one matching tactor_audio_device specified by the user.
    -	Prompts the user to troubleshoot if the device isn’t found (e.g. unplugged or not recognised).
    -	Currently requires the program to be reset.
-	**Audio Handle Setup**:
    -	For 1 tactor, opens a simple mono output using PsychPortAudio.
    -	For 2 tactors, opens a master/slave stereo configuration, allowing control over both channels separately, which is important for volume/intensity control.
    -	Ensures the sample rate is set to 44.1 kHz for consistency with pre-generated tones.
-	**Stimulus Loading**:
    -	Loads a .mat file containing a sine wave tone at the specified frequency (stim_hz) from stim_dir.
    -	Duplicates the waveform across stereo channels to drive multiple tactors simultaneously.
-	**Serial Port Communication**:
    -	Opens a connection to the tactor control unit via the serial port (assumed /dev/cu.usbserial-FTD4RB4J).
    -	Sends enable commands to activate either one or both tactors, depending on num_tactors.
-	**Returns**:
    -	pahandle: the slave audio handle for sending stim tones
    -	pahandleMaster: the master handle (if using 2 tactors)
    -	stim: the loaded stereo waveform
    -	tactors: the serial communication object used to trigger and control physical tactor devices
<!-- end of the list --><br />
### setup_jellyfish_EEG.m
#### Purpose
This is an optional function (currently set to false and not fully tested). Establishes a connection between the experimental task and NetStation (EGI’s EEG acquisition software), ensuring EEG data recording is initialised and time-synchronised before stimuli presentation begins.
#### What it Does
-	**Defines Network Settings**:
      -	Sets the IP addresses and port numbers for both the host computer and EEG amplifier (ip_host, port_host, ip_amp).
-	**Attempts Connection to NetStation**:
      -	Repeatedly tries to connect to the NetStation server using NetStation('Connect', ...).
      -	Allows up to 50 attempts (numTries), with a 5-second pause between each (tryWait).
      -	If all attempts fail, the function throws an error and halts execution.
-	**Synchronisation and Recording**:
      -	Once connected:
          - Calls NetStation('Synchronize') to align the clocks of the stimulus computer and EEG system.
          - Starts EEG recording using NetStation('StartRecording').
-	**Error Handling**:
      -	Each major step checks the returned status and provides detailed error messages if synchronisation or recording fails, helping diagnose connection issues early.
-	**Returns**:
      -	This function does not return any output variables; it ensures that the EEG system is ready and synced for the task to proceed.#
<!-- end of the list --><br />
### setup_jellyfish_eyetracking.m
#### Purpose
Initialises the eyetracking setup for the jellyfish experimental task using an ECKPresenter display object and a Tobii Pro eyetracker. Configures display properties, eyetracker connection, data tracking, calibration, and logging before starting the eyetracking session.
#### What it does
-	Path Setup - Adds all necessary MATLAB paths for dependencies.
-	Presenter Setup
  -	Creates an ECKPresenter object (pres) and enables debug mode.
  -	Configures display settings: monitor selection, fullscreen mode, window size limits, and background colour.
  -	Prepares textures for image stimuli.
-	Eye Tracker Setup
  -	Assigns a Tobii Pro eyetracker object to pres.EyeTracker.
  -	Configures server name, sampling rate (300 Hz), and clears any previously defined Areas of Interest (AoIs).
  -	Connects to the eyetracker and enables the preview window for live monitoring.
-	Data Tracking and Logging
  -	Creates an ECKTracker object for storing eyetracking data, specifying the data root directory.
  -	Links the tracker to the eyetracker.
  -	Creates an ECKLog object (log) for recording session events.
-	Calibration
  -	Pauses to allow user input before calibration.
  -	Runs eyetracker calibration routine.
  -	Waits for user confirmation before proceeding to tasks.
-	Session Start
  -	Begins data logging via track.StartSession.
  -	Starts eyetracker recording (StartTracking).
<!-- end of the list -->
#### Outputs
-	pres — The configured ECKPresenter object, containing display and eyetracker settings.
-	log — An ECKLog object used for recording session-level information.
<!-- end of the list --><br />
### play_filler_movie.m
#### Purpose
Plays a looped, muted video with a separate audio stream to entertain infants between trials or while hardware setups are adjusted. Provides an interface for manually selecting from multiple filler videos and supports dual display (main and preview screens).
#### What it Does
-	**Movie Selection Interface (if movie_num is 0)**:
    -	Displays thumbnails of all available filler videos in a grid layout.
    -	Prompts the experimenter to choose a video via keyboard input.
    -	Extracts and displays a single frame from each muted video to serve as a preview.
-	**Audio/Video Setup**:
    -	Opens the selected muted video using Screen('OpenMovie').
    -	Calculates display rectangles for both the main (win) and preview (preview_win) windows to ensure the video is correctly centred and scaled.
    -	Loads the corresponding .wav audio file and routes it to a specific external sound card (e.g., SB Omni Surround) using PsychPortAudio.
-	**Synchronized Playback**:
    -	Starts both video and audio playback.
    -	Enters a loop that displays the video frame-by-frame on both screens, rewinding automatically at the end of the clip to play indefinitely.
-	**Reward functionality**:
    -	If the video is flagged as a reward video then loads a random movie and sets the playback to be within the first 10-30% of the movie. This skips any opening credits, while making it relatively quick to load.
    -	Plays the video with synchronised audio for the reward_duration set by the user (current default 15 seconds). Then auto closes and continues. 
-	**User Interaction**:
    -	Exits the video loop only when the TAB key is pressed, allowing manual control over when the task proceeds.
-	**Clean-Up**:
    -	Stops and closes the video and audio resources.
    -	Clears the screen to black on both windows to prevent lingering frames.
-	**Returns**:
    -	Updated Psychtoolbox window handles:
    -	win: the main display window.
    -	preview_win: the secondary (experimenter-facing) preview window.
<!-- end of the list --><br />
### run_training_bock_v2
#### Purpose
This function manages a multi-phase, interactive training block designed for a behavioural or psychophysical experiment involving tactile stimuli (via tactors), visual stimuli (jellyfish textures and videos), and audio instructions/rewards. It runs on Psychtoolbox and orchestrates the flow of stimuli presentation, user input, and feedback over several sequential phases.
run_training_block_v2 delivers an immersive training session where participants learn to discriminate between vibrotactile stimuli presented on different sides (left/right) while receiving synchronous visual and audio cues. The function handles stimulus presentation, participant responses, real-time feedback, and phase transitions within one cohesive training routine.
#### What it Does
-	**Initialization and Setup**:
    -	Loads a series of pre-recorded audio instructions and reward sounds. Instructions are clearly labelled and could be replaced if needed.
    -	Opens an audio handle for playback.
    -	Initializes control variables and phase tracking inside a tact_hist structure, which maintains state across the training.
-	**Training Phases 1 & 2 (Introductions)**:
    -	Each phase introduces the participant to tactile stimulation on either the left or right side, paired with corresponding visual jellyfish stimuli.
    -	Visual jitter (“buzz”) effects simulate vibration on screen.
    -	Audio instructions guide the participant, played once per phase, synchronized with the tactile buzz.
    -	Keyboard inputs allow advancing phases, skipping training, or quitting.
    -	Uses loops to display stimuli until the participant selects a response or signals to skip/quit.
-	**Phase 3 (Reward Phase)**:
    -	Plays a reward video and accompanying audio after the introductory phases.
    -	Continues to display jittering jellyfish stimuli synchronized with tactors.
    -	Participant input options remain consistent.
-	**Phase 4 (Practice Block)**:
    -	Presents a series of practice trials, each combining tactile buzzing, visual stimuli (jellyfish on screen with jitter), and audio prompts that cue participant attention.
    -	Trials start only after the researcher presses the down arrow.
    -	Tracks correct responses for feedback and performance monitoring.
    -	Participant responses via left/right arrow keys are recorded and scored.
    -	Implements inter-trial fixation periods featuring a rotating starfish visual to hold attention.
    -	Carefully manages timing of buzzing, pauses, and audio prompts to avoid participant confusion.
    -	Provides opportunity to retry the practice block if performance is unsatisfactory, controlled by the researcher via keyboard input (‘y’ to proceed, ‘n’ to repeat).
    -	All interactions support immediate skipping or quitting.
-	**Phase 5 (Final Reward and Transition)**:
    -	Similar structure to earlier reward phase but marks the end of training.
    -	Final audiovisual reward and participant input phase, readying for transition to main experiment trials.
-	**State and Flow Control**:
    -	The function returns an exit code (code):
        ~ 0 = quit
        ~ 1 = skip training
        ~ 2 = complete training as usual
    -	Manages internal timing and state flags to ensure stimuli, audio, and responses are synchronized and avoid premature inputs or stimuli overlap.
    -	Uses Psychtoolbox’s video and audio capabilities with double-screen updates (main and preview windows).
    -	Robustly handles real-time key checks and audio playback status for smooth transitions and user control.
    -	Updates tact_hist throughout to maintain a full log of training progress, responses, and phase completions.
<!-- end of the list --><br />
### play_tactor_stim.m
#### Purpose
Delivers tactile (tactor) stimulation for a single trial within the experiment. It determines the intensity levels for each tactor, fills the PsychPortAudio buffers, plays the corresponding stimuli, and records trial-specific information (e.g. intensities, correct side). Optionally sends EEG event markers for time-locking.
#### What it Does
**Trial Management**:
-	Increments the trial number in tact_hist.
-	Retrieves the number of tactors from settings.
-	Stimulus Intensity Calculation:
-	Calls next_weighted_tactor_intensity (see below), to determine intensity values for the current trial (f1, f2).
-	Updates the trial history struct (tact_hist) with these values.
<!-- end of the list -->
**Audio Buffer Preparation**:
-	If tactors are active (num_tactors > 0):
-	Fills both the main (pahandle) and master (pahandleMaster) PsychPortAudio buffers with the provided stimulus waveform (stim).
<!-- end of the list -->
**Tactor Playback**:
-	**1 Tactor**:
    -	Plays the stimulus in mono at intensity f1.
-	**2 Tactors**:
    -	Randomly assigns which tactor receives the higher intensity (f1 vs f2).
    -	Sets channel-specific volumes ([f1 f2] or [f2 f1]).
    -	Starts playback on both pahandle and pahandleMaster.
    -	Records the correct response side ('Left' or 'Right') in tact_hist.
-	**0 Tactors**:
    -	No physical stimulation is delivered, but the function still randomises a “virtual correct side” and logs it to maintain consistent trial structure.
-	**EEG Event Markers**:
    -	If EEG recording is enabled, sends an event marker ('200') via NetStation at stimulus onset.
    -	Errors during marker transmission are caught and displayed.
<!-- end of the list -->
**Trial Logging**:
-	Updates tact_hist.tracker with trial-specific intensity values and the correct side.
-	Prints trial progress and intensities to the MATLAB console (e.g. Trial 3/30 — intensities: L=0.40, R=0.60).
<!-- end of the list -->
#### Outputs
tact_hist (struct): Updated trial history containing:
-	Current trial number.
-	Intensity history.
-	Correct response history.
-	Any updates from EEG event transmission.
<!-- end of the list --><br />
### play_tactor_training
#### Purpose
Delivers tactile training stimuli across one or more tactors (or simulates them if no hardware is connected). Configures stimulus playback and sets the correct response for each training phase. This is very similar to play_tactor_stim but specific for the training phase.
#### What it does
**Setup**
-	Retrieves the number of tactors and current training phase from tact_hist.
-	Loads the stimulus waveform (stim) into the Psychtoolbox audio buffers (pahandle and pahandleMaster).
<!-- end of the list -->
**Playback Logic**
-	One tactor (num_tactors == 1)
    -	Plays the stimulus monaurally at intensity f1.
-	Two tactors (num_tactors == 2)
    -	Training is divided into phases:
        -	Phase 1: Strong left (L=3, R=0). Correct response = Left.
        -	Phase 2: Strong right (L=0, R=3). Correct response = Right.
        -	Phase 3: Silent (L=0, R=0). Correct response = Neither.
        -	Phase 4 (Practice): Pre-set intensity pairs (slightly unbalanced).
            -	Correct response alternates between Left and Right depending on trial.
        -	Phase 5: Silent again (L=0, R=0). Correct response = Neither.
    -	Sends intensities to PsychPortAudio, starts playback, and logs phase/intensities to the console.
-	**No tactors** (num_tactors == 0)
    -	Skips playback, but prints the intended phase/intensity values to the MATLAB console.
    -	Updates the correct response in the same way as above.
<!-- end of the list -->
**Correct Response Tracking**
For each phase (and practice trial within phase 4), updates tact_hist.training.correct_response to indicate the expected answer ('Left', 'Right', or 'Neither').
#### Outputs
Returns the updated tact_hist struct, with:
-	tact_hist.training.correct_response set according to the training phase.
-	(If practice phase) tact_hist.training.practice_trial influencing stimulus assignment.
<!-- end of the list --><br />
### next_weighted_tactor_intensity.m
#### Purpose
Determines the next pair of tactile stimulus intensities using a weighted 2-up / 1-down staircase procedure. This adaptive method gradually increases or decreases task difficulty based on participant performance, converging on an intensity separation that targets a specific accuracy threshold.
#### What it Does
**First Trial Exception**:
-	For trial 1, bypasses staircase logic and uses the default starting intensities from tact_hist.current_trial.unrounded_intensities.
-	Sets baseline f1 = 0.5 (or from settings) and f2 as the initial comparison intensity.
<!-- end of the list -->
**Parameter Setup**:
-	Extracts task parameters from tact_hist.settings:
-	baseline_intensity → fixed reference intensity (f1).
-	intensity_range → discrete set of allowable intensity values.
-	up_step → multiplier applied to increase separation after an incorrect response (makes task easier).
-	down_step → multiplier applied to decrease separation after repeated correct responses (makes task harder).
-	correct_to_step_down → number of consecutive correct responses required before applying a down-step.
-	max_intensity → upper bound for allowable intensities.
<!-- end of the list -->
**Staircase Logic**:
-	**Incorrect Response**: Multiplies f2 by up_step (easier because the intensities are further apart).
-	**Correct Response with Streak**: If the participant achieves correct_to_step_down in a row (default 2 responses in a row), multiplies f2 by down_step (harder), then resets streak counter.
-	**Correct Response without Streak**: Leaves intensities unchanged.
<!-- end of the list -->
**Boundary Enforcement**:
-	Caps f2 at the maximum allowed intensity.
-	Maintains f1 at the fixed baseline.
-	Ensures values fall within the discrete intensity_range by snapping f1 and f2 to the nearest valid steps. I.e. if the steps are in 0.01, 0.1 or 1 unit steps then will snap the current intensity to the nearest value for reproducibility and to give the researcher more control over the steps structure.
<!-- end of the list -->
**Trial History Updates**:
-	Records new unrounded intensities (before snapping) to avoid rounding artifacts that could stall difficulty adjustments.
-	Updates tact_hist.current_trial.current_intensities with the snapped values.
-	Appends the intensities to tact_hist.tracker.unrounded_intensity_hist for long-term tracking.
<!-- end of the list -->
**(Optional Debugging / Visualisation)**:
Contains commented-out code to simulate staircase progression across multiple trials. Useful for verifying that chosen up/down step multipliers yield a stable convergence and manageable difficulty range.
#### Outputs
-	f1 (float): The fixed baseline intensity, snapped to nearest available step.
-	f2 (float): The adaptive comparison intensity for this trial, adjusted by staircase rules and snapped to the nearest step.
-	tact_hist (struct): Updated trial history, including:
    -	New unrounded intensities.
    -	Updated current intensities.
    -	Tracker history logs.
<!-- end of the list --><br />
### is_tact_resp_correct.m
#### Purpose
Checks whether the participant’s selected response matches the correct response for the current trial and updates the trial history accordingly.
#### What it does
-	Retrieves the current trial number and the correct response from tact_hist.
-	Compares the correct response against the participant’s selected response (selected).
-	If the response is correct:
    -	Marks the trial as correct.
    -	Increments the streak of correct responses in a row.
    -	Increases the overall total correct count.
    -	Updates the trial history to show the trial was correct.
-	If the response is incorrect:
    -	Marks the trial as incorrect.
    -	Resets the streak of correct responses in a row.
    -	Updates the trial history to show the trial was incorrect.
<!-- end of the list -->
#### Outputs
Returns the updated tact_hist structure, with fields in current_trial and tracker modified to reflect response correctness.<br />
### save_jellyfish_data
#### Purpose
Saves participant data and trial history from a jellyfish eyetracking/tactile task session. Creates organised output folders, generates participant- and session-specific files, and stores both redundant backups and cleaned summary tables.
#### What it does
**Folder Setup**
-	Ensures the main output path exists.
-	Creates two persistent folders:
-	participant_data (stores session-level data by participant/wave/timestamp).
-	struct_backups (stores redundant full backups of the tact_hist struct).
<!-- end of the list -->
**Participant Information**
-	Extracts participant ID, study wave, and timestamp from the participant_ID string (expected format: pptID_wave_timestamp).
-	Builds a nested folder hierarchy:
  out_path/
    participant_data/
      pptID/
        wave/
          timestamp/
-	Creates any missing folders in the hierarchy.
<!-- end of the list -->
**Data Cleaning & Formatting**
-	Counts the number of completed trials.
-	Extracts and formats settings into temp_info, including min/max intensity, interval, number of completed trials, and training summary metrics.
-	Removes redundant fields (e.g., intensity_range).
-	Cleans the tracker data (temp_tracker), trimming all trial-level arrays to only the completed trials.
<!-- end of the list -->
**Table Conversion**
-	Converts participant settings (temp_info) into a MATLAB table (info).
-	Converts trial-by-trial tracker data (temp_tracker) into a table (tracker).
<!-- end of the list -->
**Saving**
-	Saves a redundant full copy of tact_hist as a .mat file in struct_backups.
-	Saves info and tracker tables as .mat files in the participant’s session-specific folder (date_folder).
<!-- end of the list -->
#### Outputs
Files saved to disk (no direct return values):
-	**Full backup**:
<out_path>/struct_backups/<participant_ID>.mat
-	**Session-specific tables**:
<out_path>/participant_data/<ppt>/<wave>/<timestamp>/ppt_info_<timestamp>.mat
<out_path>/participant_data/<ppt>/<wave>/<timestamp>/tracker_info_<timestamp>.mat
<!-- end of the list -->
