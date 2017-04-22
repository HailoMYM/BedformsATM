function [] = runCorrelationAnalysis(varargin)

    % This execute the correlation analysis after the discrimination
    % process
    % This function could have:
    % 
    % One parameter: which should be the path to the
    %            MyProject_ForAnalysis.mat files that is generated by the
    %            BedformsATM_ScaleBasedDiscrimination application. This
    %            version is called automatically from BedformsATM_ScaleBasedDiscrimination
    % 
    % No parameters: This case is designed to be called from MATLAB console
    %            and then select the MyProject_ForAnalysis.mat file
    %            manually
    % 
    %%

if ( nargin > 1 )
    display ('Too many parameters.');
    return;
end

if ( nargin==1 )
    files = varargin{1};
else
    DocumentsPath = winqueryreg('HKEY_CURRENT_USER',...
                    ['Software\Microsoft\Windows\CurrentVersion\' ...
                     'Explorer\Shell Folders'],'Personal');
    projectfolder = [DocumentsPath '\MATLAB\BedFormsATM\Projects'];
    
    loaded = uipickfiles('FilterSpec',projectfolder);
    load(loaded{1},'forAnalysis');
    files = forAnalysis;
end

titleFont = 16;
labelFont = 16;
axisFont = 14;

load(files{1},'toprint');
toprint = [toprint 'CorrelationAnalysis\'];
[~,~,~] = mkdir(toprint);

NFiles = length(files);

depth (NFiles) = 0;
SVR12 (NFiles) = 0;
SVR23 (NFiles) = 0;

for i=1:NFiles
   load(files{i},'BedformsDiscrimination');

   var1 = ( std (BedformsDiscrimination(:,5)) );
   var2 = ( std (BedformsDiscrimination(:,4)) );
   var3 = ( std (BedformsDiscrimination(:,3)) );
   depth(i) = mean(BedformsDiscrimination(:,2));
   
   SVR12(i) = var2/var1;
   SVR23(i) = var3/var2;
end

Xlimit = [min(depth) max(depth)];

figure();
subplot(2,1,1);
plot(depth,SVR12,'ok');
ylabel('SVR_{1,2}','fontsize',labelFont);
set(gca,'fontsize',axisFont);
set(gca,'Xlim',Xlimit);

subplot(2,1,2);
plot(depth,SVR23,'ob');
set(gca,'fontsize',axisFont);
set(gca,'Ylim',[0 8]);
xlabel('Ave. depth (m)','fontsize',labelFont);
ylabel('SVR_{2,3}','fontsize',labelFont);
set(gca,'Xlim',Xlimit);

uicontrol('style','text','Units','normalized','FontSize',8,...
          'String','Plotted by Bedforms-ATM','BackgroundColor',[1 1 1],...
          'Position',[0.7 0.02 0.25 0.03]);

set(gcf,'paperunits','centimeters');
set(gcf,'papersize',[28,19]);
set(gcf,'paperposition',[0.05,0.05,29*.95,20*.95]); 

print(gcf,'-dpdf',[toprint 'CorrelationAnalysis']);
close;
