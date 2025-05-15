clear all; close all;

sessionInfo = readtable('../rawData/intrumentalSessionInfo.csv','FileType','text','Delimiter',',','ReadVariableNames',true,'TreatAsEmpty','');

data_table = table();

for session = 1:height(sessionInfo)
    
    disp(['Processing video ' num2str(session) ' of ' num2str(height(sessionInfo))]);
    
    if strcmp(sessionInfo.Facemap(session),"yes")
        
        exp_ref = sessionInfo.expRef{session};
        mouse_name = sessionInfo.mouseName{session};
        
        % load h5 file
        filename = ['//QNAP-AL001/Data/', mouse_name, '/', ...
            exp_ref(1:10),'/',exp_ref(12),'/',exp_ref,'_face_FacemapPose.h5'];
        
        % read mouth keypoints from h5 file
        mouth_x = h5read(filename,'/Facemap/mouth/x');
        mouth_y = h5read(filename,'/Facemap/mouth/y');
        
        lowerlip_x = h5read(filename,'/Facemap/lowerlip/x');
        lowerlip_y = h5read(filename,'/Facemap/lowerlip/y');
        
        % load motion PCs
        load(['//QNAP-AL001/Data/', sessionInfo.mouseName{session}, '/', ...
            exp_ref(1:10),'/',exp_ref(12),'/',exp_ref,'_face_proc.mat'],'movSVD_0');
        
        % retain the first 10 PCs
        motion_pc = movSVD_0(:,1:10);
        
        % get event times
        event_times = getEventTimes(exp_ref, 'face_camera_strobe');
        
        if length(event_times) > length(mouth_x)
            
            event_times = event_times(1:length(mouth_x));
            
        elseif length(event_times) < length(mouth_x)
            
            mouth_x = mouth_x(1:length(event_times));
            mouth_y = mouth_y(1:length(event_times));
            lowerlip_x = lowerlip_x(1:length(event_times));
            lowerlip_y = lowerlip_y(1:length(event_times));
            motion_pc = motion_pc(1:length(event_times),:);
        end
        
        mouse_name = repmat(categorical({mouse_name}),length(mouth_x),1);
        exp_ref = repmat(categorical({exp_ref}),length(mouth_x),1);
        
        session_table = table(...
            mouse_name,...
            exp_ref,...
            event_times,...
            mouth_x,mouth_y,...
            lowerlip_x,lowerlip_y,...
            motion_pc);
        
        data_table = [data_table; session_table];
        
    end
    
end

writetable(data_table,'pavlov_probability_facemap_data.csv')
    

%% extract images of motion PCs
for session = 1:height(sessionInfo)
    
    disp(['Processing video ' num2str(session) ' of ' num2str(height(sessionInfo))]);
    
    if strcmp(sessionInfo.Facemap(session),"yes")
        
        exp_ref = sessionInfo.expRef{session};
        mouse_name = sessionInfo.mouseName{session};
        
        % load motion PCs
        load(['//QNAP-AL001/Data/', sessionInfo.mouseName{session}, '/', ...
            exp_ref(1:10),'/',exp_ref(12),'/',exp_ref,'_face_proc.mat'],'movMask_reshape_0');
        
        % retain the first 10 PCs
        mov_mask(session,:,:,:) = movMask_reshape_0(:,:,1:10);   
               
    end
    
end

mean_mov_mask = squeeze(mean(mov_mask,1));

figure;
for i = 1:6
    subplot(2,3,i);
    imagesc(mean_mov_mask(:,:,i));
end


for session = 1:height(sessionInfo)
    
    figure;

    for i = 1:10    
        subplot(2,5,i)
        imagesc(mov_mask(session,:,:,i))   
    end

end
