function allData = loop_vidDeconv_extract_pca(options)

if nargin < 1
    options = vidDeconv_options(); % your custom options loader
end

% Load the new session info file
sessionTable = readtable('/Users/heiwinglau/Documents/Research/DPhil/rotation/lak/deconvolGlm/videoDeconvGLM/data/instrumentalSessionInfo.csv');

% Initialise empty table
allData = table();

% for i = 1:height(sessionTable)
for i = 1 % Just testing the first session
    animal = sessionTable.animal_name{i};
    expRef = sessionTable.expRef{i};
    dateStr = sessionTable.date(i);
    sessionNum = sessionTable.session(i);

    sess = extractSVD(expRef, animal, dateStr, sessionNum, options);

    if sess.Valid
        disp('Processing valid session...');
        sess = sess.processFacemapData();
        
        % Debug: Check if Data is populated
        disp('Checking processed data:');
        disp(sess.Data);

        if ~isempty(sess.Data)
            allData = [allData; sess.Data]; 
            disp('Data appended to allData');
        else
            disp('sess.Data is empty!');
        end
    else
        disp('Session is not valid.');

    end

end

% Write output
writetable(allData, 'instrumental_facemap_data.csv');
disp('Finished processing all valid sessions.');
end
