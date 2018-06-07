clear all; close all; clc;
%% Parameters
Groups = {'Older','Young'};
Subjects1 = [50:51 55 57:62 64:69];%:51 55 57:62 64:69]; %62 66 %59?
Subjects2 = [3:9 14:22 24:26];%:9 14:22 24:26]; %younger adults
Conds = {'SKHL','SU'};
InDir = 'D:\Expectation\Step7\Trial5'; 
EpochLabel = 'Faces';
centralEOIs = {'CPZ','PZ','POZ','P1','P2','C1','C2','CP5','CP3'};
plv = {'F3','F5','F1','AF3','AF7','FP1'};
leftEOIs = {'P7','P1','P5','P3','PO3','PO7'}; %P3,P7  %PZ,P5,P1
rightEOIs = {'P2','P4','P6','P8','PO4','PO8'}; %PO8
%clustEOIs ={'P1','P9','P7','P5','P2','P4','P6','P8','PO7','PO3','P10','PO4','CP1','CP2','CP5','CP4','CP6','CP3','O1','O2','PO4','PO8','IZ'};
clustEOIs= {'CP1','CP2','CP4','CP6','P2','P7','P8','PO3','P10','PO4','PO8','TP7','TP8'};%'P9','PO3','P7','P1','P2','P4','P6','P8','P10','PO4','PO7','PO8'};
load('ChanLocs64.mat');
load('bhv_master');
load('posthoc_master');
twin = [-1000 500];
fwin = [12 30];
cwin = [-.85 .85]; 
cwin1 = [.9 1];

%% Load data
for G = 1:length(Groups)
    eval(sprintf('Subjects = Subjects%d;',G));
    for C = 1:length(Conds)
        for S = 1:length(Subjects)
            power = [];
            Cond = Conds{C};
            fprintf('Processing subject %d, condition: %s\n',Subjects(S), Cond)
            infile = sprintf('%d_%s_%s.mat', Subjects(S), Conds{C}, EpochLabel);
            inpath = sprintf('%s\\%s\\%d', InDir, Groups{G}, Subjects(S));
            load(sprintf('%s/%s',inpath,infile));
            for e = 1:length(centralEOIs)
                centralIndx(e) = strmatch(upper(centralEOIs{e}),upper(Induced.Labels),'exact');
            end
            for e = 1:length(leftEOIs)
                leftIndx(e) = strmatch(upper(leftEOIs{e}),upper(Induced.Labels),'exact');
            end
            for e = 1:length(rightEOIs)
                rightIndx(e) = strmatch(upper(rightEOIs{e}),upper(Induced.Labels),'exact');
            end
            
            for  e = 1:length(clustEOIs)
                clustIndx(e) = strmatch(upper(clustEOIs{e}),upper(Induced.Labels),'exact');
            end
            Ind.L{G}(:,:,C,S) = mean(Induced.Data(:,:,leftIndx),3);%left
            Ind.R{G}(:,:,C,S) = mean(Induced.Data(:,:,rightIndx),3);%Right
            Ind.C{G}(:,:,C,S) = mean(Induced.Data(:,:,centralIndx),3);%center
            Ind.T{G}(:,:,C,S) = mean(Induced.Data(:,:,clustIndx),3);
            
            tindx = find(Induced.Times >= twin(1)& Induced.Times <= twin(2));
            findx = find(Induced.Freqs >= fwin(1)& Induced.Freqs <= fwin(2));
            Topo{G}(:,C,S)=mean(mean(Induced.Data(findx,tindx,:),1),2);%Data vector for topoplot %averaging over alpha frequecies
        
%             [plv phasediff stats] = fPLV(leftEOIs,plv);

        end %for subjects
        %% Plots
        
        % time- freq spectrum
        
        figure; pcolor(Induced.Times(tindx),Induced.Freqs,mean(Ind.L{G}(:,tindx,C,:),4));shading('interp');caxis(cwin);title(sprintf('%s %s: Left EOI',Conds{C},Groups{G}));colorbar;ylabel('Frequency (hz)');xlabel('time (ms)');ylabel(colorbar, 'Normalized Power');
        figure; pcolor(Induced.Times(tindx),Induced.Freqs,mean(Ind.R{G}(:,tindx,C,:),4));shading('interp');caxis(cwin);title(sprintf('%s %s: Right EOI',Conds{C},Groups{G}));colorbar;ylabel('Frequency (hz)');xlabel('time (ms)');ylabel(colorbar, 'Normalized Power');
        figure; pcolor(Induced.Times(tindx),Induced.Freqs,mean(Ind.C{G}(:,tindx,C,:),4));shading('interp');caxis(cwin);title(sprintf('%s %s: Central EOI',Conds{C},Groups{G}));colorbar;ylabel('Frequency (hz)');xlabel('time (ms)');ylabel(colorbar, 'Normalized Power');
%         
        StatsEOI{G}(:,:,:,C)=mean(Topo{G}(:,C,:),3);
        % topoplots
        
%         figure; [h v grid]= topoplot(mean(Topo{G}(:,C,:),3),locs,'maplimits',cwin,'shrink',['off'],'electrodes','labels');colorbar;title(sprintf('%s %s: Alpha Power',Conds{C},Groups{G}))
        StatsL{G}(:,C)=squeeze(mean(Topo{G}(leftIndx,C,:),1))';    %Left
        StatsR{G}(:,C)=squeeze(mean(Topo{G}(rightIndx,C,:),1))';   %Right
        StatsC{G}(:,C)=squeeze(mean(Topo{G}(clustIndx,C,:),1))'; %cluster
      
    end %for conditions
    % time- freq spectrum (difference)
% %     
%     figure; pcolor(Induced.Times(tindx),Induced.Freqs,mean(Ind.L{G}(:,tindx,1,:)-Ind.L{G}(:,tindx,2,:),4));shading('interp');caxis(cwin);title(sprintf('%s-%s %s: Left EOI',Conds{1},Conds{2},Groups{G}));colorbar;ylabel('Frequency (hz)');
%     figure; pcolor(Induced.Times(tindx),Induced.Freqs,mean(Ind .R{G}(:,tindx,1,:)-Ind.R{G}(:,tindx,2,:),4));shading('interp');caxis(cwin);title(sprintf('%s-%s %s: Right EOI',Conds{1},Conds{2},Groups{G}));colorbar;ylabel('Frequency (hz)');
%     figure; pcolor(Induced.Times(tindx),Induced.Freqs,mean(Ind.C{G}(:,tindx,1,:)-Ind.C{G}(:,tindx,2,:),4));shading('interp');caxis(cwin);title(sprintf('%s-%s %s: Central EOI',Conds{1},Conds{2},Groups{G}));colorbar;ylabel('Frequency (hz)');
%     

    
   % figure; [h v grid]= topoplot(mean(Topo{G}(:,1,:)-Topo{G}(:,2,:),3),locs,'maplimits',cwin,'shrink',['off'],'electrodes','labels');colorbar;title(sprintf('%s-%s %s: Alpha Power',Conds{1},Conds{2},Groups{G}));
    

end %for Group
%% Clustering & Finding Significant Electrodes

DiffLO=StatsL{1}(:,1)-StatsL{1}(:,2);
DiffLY=StatsL{2}(:,1)-StatsL{2}(:,2);
y1=shiftdim(Topo{2},2);
o1=shiftdim(Topo{1},2);
[h pm1 ci stats]= ttest(y1(:,:,1),y1(:,:,2));%electrode locations which are different SU vs SKHL across all YAs
[h pm3 ci stats]=ttest(o1(:,:,1),o1(:,:,2)); %electrode locations which are different SU vws SKHL acroos all OAs
[h pm2 ci stats]= ttest2((y1(:,:,1)-y1(:,:,2)),(o1(:,:,1)-o1(:,:,2))); %electrode locations which are different SU vs SKHL across groups
[h pm4 ci stats]=ttest2(o1(:,:,1),y1(:,:,1)); %electrode locations which are different between OAs and YAs for SU
[h pm5 ci stats]=ttest2(o1(:,:,2),y1(:,:,2)); %electrode locations which are different between OAs and YAs for SKHL
s1=find (pm1<.05);
s2=find  (pm2<.05);
s3= find (pm3<.05);
s4= find (pm4<.05);
s5= find (pm5<.05);
L1=Induced.Labels(s1); L2=Induced.Labels(s2); %locations
figure; [h v grid]= topoplot(1-pm2,locs,'maplimits',cwin1,'shrink',['off'],'electrodes','labels');colorbar;title('Significant Electrodes Modualtion YA vs OA');
figure; [h v grid]= topoplot(1-pm1,locs,'maplimits',cwin1,'shrink',['off'],'electrodes','labels');colorbar;title('Significant Elecs YA (SU vs SKHL) ');
figure; [h v grid]= topoplot(1-pm3,locs,'maplimits',cwin1,'shrink',['off'],'electrodes','labels');colorbar;title('Significant Electodes OA (SU vs SKHL)');
figure; [h v grid]= topoplot(1-pm4,locs,'maplimits',cwin1,'shrink',['off'],'electrodes','labels');colorbar;title('Significant Elecs YA vs OA: SU ');
figure; [h v grid]= topoplot(1-pm5,locs,'maplimits',cwin1,'shrink',['off'],'electrodes','labels');colorbar;title('Significant Elecs YA vs OA: SKHL ');

%% Correlation (Bhv vs Neural)
% 
[r pc1]=corr((StatsC{2}(:,1)-StatsC{2}(:,2)),(mALLBHV{2}(:,1)-mALLBHV{2}(:,3)));
[r pc2]=corr((StatsC{2}(:,1)-StatsC{2}(:,2)),(mALLACC{2}(:,1)-mALLACC{2}(:,3)));
[r pc3]=corr((StatsC{2}(:,1)-StatsC{2}(:,2)),(mALLRT{2}(:,1)-mALLRT{2}(:,3)));
[r pc4]=corr((StatsL{2}(:,1)-StatsL{2}(:,2)),(mALLACC{2}(:,1)-mALLACC{2}(:,3)));
[r pcc5]=corr((StatsL{2}(:,1)-StatsL{2}(:,2)),(mALLBHV{2}(:,1)-mALLBHV{2}(:,3)));
[r pc5]=corr((StatsL{2}(:,1)-StatsL{2}(:,2)),(mALLBHV{2}(:,1)-mALLBHV{2}(:,3)),'Type','Spearman');
[r pc6]=corr((StatsL{2}(:,1)-StatsL{2}(:,2)),(mALLRT{2}(:,1)-mALLRT{2}(:,3)));
[r pcc7]=corr((StatsR{2}(:,1)-StatsR{2}(:,2)),(mALLBHV{2}(:,1)-mALLBHV{2}(:,3)));
[r pc8]=corr((StatsR{2}(:,1)-StatsR{2}(:,2)),(mALLBHV{2}(:,1)-mALLBHV{2}(:,3)),'Type','Spearman');
[r pc9]=corr((StatsR{2}(:,1)-StatsR{2}(:,2)),(mALLRT{2}(:,1)-mALLRT{2}(:,3)));
[r pc9]=corr(StatsC{1}(:,1),(mALLRT{1}(:,1)));
[r pc10]=corr(StatsC{2}(:,1),(mALLRT{2}(:,1)));
[r pc11]=corr(StatsC{1}(:,1),(mALLACC{1}(:,1))); 
[r pc12]=corr(StatsC{2}(:,1),(mALLACC{2}(:,1)));
[r pc13]=corr(StatsC{2}(:,2),(mALLACC{2}(:,2)));
[r pc14]=corr(StatsC{1}(:,1),(mALLBHV{1}(:,1)));
[r pc15]=corr(StatsC{2}(:,1),(mALLBHV{2}(:,1)));
[r pc16]=corr(StatsL{2}([1:18],1),((mAllRESP{2}(:,1))/(mAllRESP{2}(:,3))));
[r pc17]=corr(StatsL{2}([1:18],2),(mAllRESP{2}(:,2)));
[r pc18]=corr(StatsL{2}([1:18],1),(mAllRESP{2}(:,3)));

[r pc19]=corr(StatsL{1}([1:11 13:15],1),(mAllRT{1}([1:11 13:15],1)));
[r pc20]=corr(StatsL{1}([1:11 13:15],1),(mAllRESP{1}([1:11 13:15],1)));
[r pc25]=corr(StatsL{1}(:,1),(mAllRT{1}(:,3)));
[r pc20]=corr(StatsL{1}(:,1),(mAllRESP{1}(:,3)));
[r pc21]=corr(StatsL{1}([1:11 13:15],2),(mAllRT{1}([1:11 13:15],2)));
[r pc22]=corr(StatsL{1}([1:11 13:15],2),(mAllRESP{1}([1:11 13:15],2)));
[r pc23]=corr(StatsL{1}(:,2),(mAllRT{1}(:,3)));
[r pc24]=corr(StatsL{1}(:,2),(mAllRESP{1}(:,3)));



[r pc25]=corr(StatsL{2}([1:18],1),(mAllRT{2}(:,1)));
[r pc26]=corr(StatsL{2}([1:18],1),(mAllRESP{2}(:,1)));
[r pc27]=corr(StatsL{2}([1:18],1),(mAllRT{2}(:,3)));
[r pc28]=corr(StatsL{2}([1:18],1),(mAllRESP{2}(:,3)));
[r pc29]=corr(StatsL{2}([1:18],2),(mAllRT{2}(:,2)));
[r pc30]=corr(StatsL{2}([1:18],2),(mAllRESP{2}(:,2)));
[r pc31]=corr(StatsL{2}([1:18],2),(mAllRT{2}(:,3)));
[r pc32]=corr(StatsL{2}([1:18],2),(mAllRESP{2}(:,3))); %significant 
figure;scatter(StatsL{2}([1:18],2),(mAllRESP{2}(:,3)),50,'red');title('Post-hoc Corr Left Posterior');ylabel('ACC');

[r pc33]=corr(StatsR{2}([1:18],1),(mAllRT{2}(:,1)));
[r pc34]=corr(StatsR{2}([1:18],1),(mAllRESP{2}(:,1)));
[r pc35]=corr(StatsR{2}([1:18],1),(mAllRT{2}(:,3)));
[r pc36]=corr(StatsR{2}([1:18],1),(mAllRESP{2}(:,3)));
[r pc37]=corr(StatsR{2}([1:18],2),(mAllRT{2}(:,2)));
[r pc38]=corr(StatsR{2}([1:18],2),(mAllRESP{2}(:,2)));
[r pc39]=corr(StatsR{2}([1:18],2),(mAllRT{2}(:,3)));
[r pc40]=corr(StatsR{2}([1:18],2),(mAllRESP{2}(:,3))); %significant almost
figure;scatter(StatsR{2}([1:18],2),(mAllRESP{2}(:,3)),50,'red');title('Post-hoc Corr Right Posterior');ylabel('ACC');

[r pc41]=corr(StatsL{1}([1:11 13:15],1),mAllRESP{1}([1:11 13:15],1)-mAllRESP{1}([1:11 13:15],3));
[r pc42]=corr(StatsL{1}([1:11 13:15],2),mAllRESP{1}([1:11 13:15],2)-mAllRESP{1}([1:11 13:15],3));
[r pc43]=corr(StatsL{2}(1:18,1),mAllRESP{2}(1:18,1)-mAllRESP{2}(1:18,3));
[r pc44]=corr(StatsL{2}(1:18,2),mAllRESP{2}(1:18,2)-mAllRESP{2}(1:18,3));
[r pc45]=corr(StatsL{1}([1:11 13:15],1),mAllRT{1}([1:11 13:15],1)-mAllRT{1}([1:11 13:15],3));
[r pc46]=corr(StatsL{1}([1:11 13:15],2),mAllRT{1}([1:11 13:15],2)-mAllRT{1}([1:11 13:15],3));

% 
% 
figure;scatter((StatsL{2}(:,1)-StatsL{2}(:,2)),(mALLBHV{2}(:,1)-mALLBHV{2}(:,3)),100,'red');title('Bhv L');
figure;scatter((StatsL{2}(:,1)-StatsL{2}(:,2)),(mALLRT{2}(:,1)-mALLRT{2}(:,3))); title('Rt L');
figure;scatter((StatsL{2}(:,1)-StatsL{2}(:,2)),(mALLACC{2}(:,1)-mALLACC{2}(:,3))),title('ACC L'); %CLOSER
figure;scatter((StatsR{2}(:,1)-StatsR{2}(:,2)),(mALLBHV{2}(:,1)-mALLBHV{2}(:,3)));title('Bhv R');
figure;scatter((StatsR{2}(:,1)-StatsR{2}(:,2)),(mALLRT{2}(:,1)-mALLRT{2}(:,3))); title('Rt R');
figure;scatter((StatsR{2}(:,1)-StatsR{2}(:,2)),(mALLACC{2}(:,1)-mALLACC{2}(:,3))),title('ACC R');
%% Phase-locking


%% Stats

[h p1 ci stats]=ttest2(StatsL{1}(:,1),StatsL{2}(:,1)); %SU Young vs Old  L %SIGNIFICANT
[h p2 ci stats]=ttest2(StatsR{1}(:,1),StatsR{2}(:,1)); %SU Young vs Old  R %SIGNIFICANT
[h p3 ci stats]=ttest2(StatsR{1}(:,2),StatsR{2}(:,2)); %SKHL Young vs Old R
[h p4 ci stats]=ttest2(StatsL{1}(:,2),StatsL{2}(:,2)); %SKHL Young vs Old L

[h p5 ci stats]=ttest2(StatsL{1}(:,1),StatsL{1}(:,2)); %Young SKHLvsSU L
[h p6 ci stats]=ttest2(StatsR{1}(:,1),StatsR{1}(:,2)); %Young SKHLvsSU R
[h p7 ci stats]=ttest2(StatsL{2}(:,1),StatsL{2}(:,2)); %Old SKHLvsSU L
[h p8 ci stats]=ttest2(StatsR{2}(:,1),StatsR{2}(:,2)); %Old SKHLvsSU R


[h p9 ci stats]=ttest2((StatsL{1}(:,1)-StatsL{1}(:,2)),(StatsL{2}(:,1)-StatsL{2}(:,2))); %diff 
[h p10 ci stats]=ttest2((StatsR{1}(:,1)-StatsR{1}(:,2)),(StatsR{2}(:,1)-StatsR{2}(:,2))); %diff
[h p11 ci stats]=ttest2((StatsC{1}(:,1)-StatsC{1}(:,2)),(StatsC{2}(:,1)-StatsC{2}(:,2))); %diff cluster

[h p12 ci stats]=ttest2((StatsC{1}(:,1)-StatsC{1}(:,2)),StatsC{2}(:,1)-StatsC{2}(:,2)); %SU Young vs Old 
[h p13 ci stats]=ttest2(StatsC{1}(:,2),StatsC{2}(:,2)); %SKHL Young vs Old  

%[h p14 ci stats]=ttest(mAllRESP{1}([1:11 13:15],1),mAllRESP{1}(1:11 13:15,2)); %posthoc bhv
[h p15 ci stats]=ttest(mAllRESP{2}(:,1),mAllRESP{2}(:,2));  %posthoc bhv
[h p17 ci stats]=ttest(mAllRT{1}(:,1),mAllRT{1}(:,2));  %posthoc bhv
[h p18 ci stats]=ttest(mAllRT{2}(:,1),mAllRT{2}(:,2));  %posthoc bhv
[h p19 ci stats]=ttest2(mAllRT{1}([1:11 13:15],1),mAllRT{2}(:,1)); %posthov bhv %ALMOST
[h p20 ci stats]=ttest2(mAllRESP{1}([1:11 13:15],1),mAllRESP{2}(:,1)); %posthov bhv %significant
[h p21 ci stats]=ttest2(mAllRT{1}([1:11 13:15],2),mAllRT{2}(:,2)); %posthoc bhv %significant
[h p22 ci stats]=ttest2(mAllRESP{1}([1:11 13:15],2),mAllRESP{2}(:,2)); %posthoc bhv % significant
[h p23 ci stats]=ttest2(mAllRESP{1}([1:11 13:15],1)-mAllRESP{1}([1:11 13:15],3),mAllRESP{2}(:,1)-mAllRESP{2}(:,3));%mod %significant
[h p24 ci stats]=ttest2(mAllRT{1}([1:11 13:15],1)-mAllRT{1}([1:11 13:15],3),mAllRT{2}(:,1)-mAllRT{2}(:,3));%mod
[h p25 ci stats]=ttest2(mAllRESP{1}([1:11 13:15],2)-mAllRESP{1}([1:11 13:15],3),mAllRESP{2}(:,2)-mAllRESP{2}(:,3));%mod
[h p26 ci stats]=ttest2(mAllRT{1}([1:11 13:15],2)-mAllRT{1}([1:11 13:15],3),mAllRT{2}(:,2)-mAllRT{2}(:,3));%mod %almost