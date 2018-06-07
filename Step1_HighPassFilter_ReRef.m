%% Load EEG data,rereference data, highpass filter

clear all; clc; close all;

%% Parameters

Groups={'Older','Young'};
Subjects1 = [70];%50:51 55 57:62 64:69];%:51 55 57:62 64:69];% [50:51 55]% 57:62 64:69];
Subjects2 = [3:9 14:22 24:26];
Conds ={'SKHL1','SKHL2','SKLL1','SKLL2','SU1', 'SU2', 'SU3', 'SU4'};
InDir = 'X:\GazzData\TedZanto\ANT\Raw_data'; % Raw setfile data
OutDir = 'D:\Expectation\Step1\Trial1'; % Output directory for .set files
ElecLoc = 'Z:\TanyaPadgaonkar\ANT\Scripts\ModifiedScripts\ChanLocs64.mat';  %since these are network drives, need to make sure the letter name of the drive is correct, otherwise permissions errors!
RemoveElecs = {'M1','M2','LEOG','REOG','IEOG','Nose','SEOG','EXG8'};
load('Chanlocs64');
HighPass = .1;
LowPass= 30;
FiltOrderh = 1000;


%% Setup
for G = 1%:length(Groups)
    eval(sprintf('Subjects = Subjects%d;',G));
    
    for S = 1:length(Subjects)
        subject_outdir = sprintf('%s\\%s\\%d', OutDir,Groups{G}, Subjects(S));
        for c = 1:length(Conds)
            
            outfile = sprintf('%d_%s.set', Subjects(S),Conds{c});
            if ~exist(subject_outdir,'dir')
                mkdir(subject_outdir);
            else
                if exist(sprintf('%s\\%s', subject_outdir, outfile),'file')
                    % error('This data file has already been preprocessed');
                end
            end
            
            %% Load data      
            fprintf('Processing subject %d, condition: %s,\n',Subjects(S), Conds{c})
            inpath = sprintf('%s\\%s\\%d', InDir,Groups{G},Subjects(S));                        
            temp=dir(sprintf('%s\\%d_*%s*.bdf',inpath,Subjects(S),Conds{c}));
            infile = temp.name;
            EEG=pop_biosig(sprintf('%s\\%s',inpath,infile));
          
            %% Remove Extra Channels
            
            load ('ChanLocs64.mat');            
            labels = {EEG.chanlocs.labels};
            indx = [];
            for e = 1:length(RemoveElecs)
                indx = strmatch(RemoveElecs{e}, labels, 'exact');
                EEG.data(indx,:) = [];
                EEG.chanlocs(indx) = [];
                EEG.nbchan = EEG.nbchan - 1;
                labels(indx) = [];
            end
               EEG.urchanlocs = locs;
               EEG.chanlocs = locs;
            clear indx
            
     
            %% Filter data
            fprintf(1,'\n\nBandpass filtering the data...');
            Nf = EEG.srate/2; %nyquist frequency
            B = fir1(FiltOrderh,[HighPass/Nf LowPass/Nf],'Bandpass');
            EEG.data = filtfilt(B,1,double(EEG.data'))';
            
            fprintf(1,'Done\n\n');
        
            %% Save data
            EEG = pop_saveset(EEG,'filename',outfile,'filepath',subject_outdir,'savemode','onefile');
            clear exindx EEG labels indx_out indx_in
       
        end %conditions
    end %Subjects
end %Groups