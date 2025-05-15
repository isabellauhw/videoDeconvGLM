classdef extractSVD
    properties
        ExpRef
        Animal
        Date
        SessionNum
        Options
        Valid = false
        Data = table()
    end
    
    methods
        function sess = extractSVD(expRef, animal, date, sessionNum, options)
            sess.ExpRef = expRef;
            sess.Animal = animal;
            sess.Date = date;
            sess.SessionNum = sessionNum;
            sess.Options = options;

            % Check if this session should be processed
            if ismember(animal, options.dataReview.subjectIDs)
                sess.Valid = true;
            end
        end

        function obj = processFacemapData(sess)
            if ~sess.Valid
                return
            end

            try
                mouseName = sess.Animal;
                expRef = sess.ExpRef;

                % Define the path to the processed data file
                procfile = fullfile('/Volumes/Data/', mouseName, ...
                    expRef(1:10), expRef(12), [expRef '_face_proc.mat']);

                % Check if the file exists before loading
                if ~isfile(procfile)
                    warning('Missing file: %s', procfile);
                    return;
                end

                % Load motion PCs
                load(procfile, 'movSVD_0');

                % Ensure movSVD_0 is loaded correctly
                if ~exist('movSVD_0', 'var')
                    warning('No movSVD_0 found in %s', procfile);
                    return;
                end

                % Get the number of PCs available in the matrix
                [nFrames, nPCs] = size(movSVD_0);

                % Ensure we do not try to access more PCs than available
                nUse = min(nPCs, 10); % Use up to 10 PCs, but no more than you have
                if nPCs < 10
                    warning('Session %s has only %d motion PCs; using all of them.', expRef, nPCs);
                end

                % Extract the motion PCs (up to 10)
                motionPCs = movSVD_0(:, 1:nUse);
              
                % Define dat.expRefRegExp for getEventTimes()
                event_times = getEventTimes(expRef, 'face_camera_strobe');
                
                % Store the extracted data in the object
                obj.Data = table(...
                    motionPCs, ...
                    event_times, ...
                    'VariableNames', {'MotionPC', 'eventTimes'});

            catch ME
                % Catch any unexpected errors and provide a helpful warning
                warning('Error processing session %s: %s', sess.ExpRef, ME.message);
            end
        end
    end
end
