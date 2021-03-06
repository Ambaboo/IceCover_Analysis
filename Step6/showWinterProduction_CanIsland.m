function showWinterProduction_CanIsland(YS,YE,monSelect,varargin)
% show the accumulated ice production map
% usage:
%       showWinterProduction(YS,YE,monSelect)
%
close all;
if nargin==1
   YE=YS; 
   monSelect=1:3;
elseif nargin==2
   if numel(YE)>2
      monSelect=YE; YE=YS;
   elseif YE<=12
      monSelect=YE; YE=YS;
   else
      monSelect=1:3;
   end
elseif nargin<3
   help showWinterProduction
   return
end
clc;
CF='CREG012-EXH003'; fileStr='icemod';
rdt=180; % model timestep (s)
rootP='/mnt/storage0/xhu/CREG012-EXH003/';
% maskfile='mask.nc';
maskfile='/mnt/storage0/xhu/CREG012-I/mask/CREG12_mask_v34.nc'; % mask file
isSave=0;
isProj=1;
isDebug=0;
coastType=2;
landC=[0 0 0];

while(size(varargin,2)>0)
    switch lower(varargin{1})
        case {'cf','conf'}
            CF=varargin{2};
            varargin(1:2)=[];
        case {'mask','maskfile'}
            maskfile=varargin{2};
            varargin(1:2)=[];
        case {'dataroot','datap','rootp','src','datasrc'}
            rootP=varargin{2};
            varargin(1:2)=[];
        case {'save','figure','print'}
            isSave=1;
            varargin(1)=[];
        case {'timestep','rdt'}
            rdt=varargin{2};
            varargin(1:2)=[];
        case {'proj','map'}
            isProj=1;
            varargin(1)=[];
        case {'land','landc','landcolor'}
            landC=varargin{2};
            varargin(1:2)=[];
        case {'coastype','coast'}
            coastType=varargin{2};
            varargin(1:2)=[];
        case {'-d','-debug','debug'}
            isDebug=1;
            varargin(1)=[];
        otherwise
            disp(['Unkown option: ',varargin{1}])
            varargin(1)=[];
    end
end
monStr=[datestr(datenum(0,monSelect(1),15),'mmm'),'_to_',datestr(datenum(0,monSelect(end),15),'mmm')];
ratio5Day=3600*24*5/rdt;

NX=GetNcDimLen(maskfile,'x');
NY=GetNcDimLen(maskfile,'y');
iceP=zeros(NY,NX);
lsmask=GetNcVar(maskfile,'tmask',[0 0 0 0],[NX NY 1 1]);
if isProj==1
   navLon=GetNcVar(maskfile,'nav_lon');
   navLat=GetNcVar(maskfile,'nav_lat');
end

nRec=0;
for ny=YS:YE
    yystr=num2str(ny,'%04d');
    
    for nmon=monSelect(1):monSelect(end)
        if nmon>12
           yystr=num2str(ny+1,'%04d');
           [mmstr,ddstr]=getyymmdd(nmon-12);
        else
           [mmstr,ddstr]=getyymmdd(nmon);
        end
        for nd=1:size(mmstr,1)
            timeTag=['y',yystr,'m',mmstr(nd,:),'d',ddstr(nd,:)];
            if isDebug==1
               disp(['reading timeTag: ',timeTag])
            end
            icefile=[rootP,CF,'_',timeTag,'_',fileStr,'.nc'];
            if ~exist(icefile,'file')
               error([icefile,' is not found!'])
            end
            nRec=nRec+1;
            if nRec==1
               iceH1=GetNcVar(icefile,'iicethic');
            end
            iceP(:,:)=iceP(:,:)+GetNcVar(icefile,'iiceprod');
        end
    end
end
iceH2=GetNcVar(icefile,'iicethic');
iceH1(lsmask==0)=nan;
iceP(lsmask==0)=nan;
iceP=iceP*ratio5Day;

if isProj==0
   figure;
   hsub(1)=subplot(1,2,1);mypcolor_imagesc(iceP);caxis([-2 2]); hbar(1)=colorbar;
   axis equal;axis tight;
   hsub(2)=subplot(1,2,2);mypcolor_imagesc(iceH2-iceH1);caxis([-2 2]);hbar(2)=colorbar;
   axis equal;axis tight;
   figurenicer; set(hsub,'xcolor','k','ycolor','k')
   fixFont(14)
   dx=0; x0=0.13; y0=0.11; wx=0.4; hy=0.8;
   set(hsub(1),'position',[x0 y0 wx hy]);
   set(hsub(2),'position',[x0+dx+wx-0.1 y0 wx hy]);
   set(hbar,'position',[x0+dx+wx*2-0.05 y0 0.02 hy])
   linkaxes([hsub(1) hsub(2)],'xy')
else
  hsub(1)=subplot(1,2,1);
  %m_proj('stereographic','latitude',90,'radius',55,'rotangle',45,'rect','on');
  %m_proj('stereographic','latitude',80,'radius',55,'rotangle',45,'rect','on');
  %m_proj('stereographic','latitude',90,'radius',55,'rotangle',45,'rect','on');
  m_proj('stereographic','lat',71,'radius',20,'long',-90,'rect','on','rotation',-35)
%   m_proj('stereographic','latitude',80,'radius',[-90 40],'rotangle',60,'rect','on')
  hp=m_pcolor(navLon,navLat,iceP); set(hp,'linestyle','none','facecolor','interp');
  set(gcf, 'Position', [560 524 1000 500]);
  if coastType>0
     fillType='patch';
  else
     fillType='color';
  end
  if coastType==0
     m_coast('color','k');
  elseif abs(coastType)==1
     m_coast(fillType,landC);
     if coastType>0, set(findobj('tag','m_coast'),'linestyle','none'); end
  elseif abs(coastType)==2
     m_gshhs_i(fillType,landC);
     if coastType>0, set(findobj('tag','m_gshhs_i'),'linestyle','none'); end
  end
  myxtick=-150:30:180; myytick=60:10:80;
  m_grid('tickdir','in','bac','none','xtick',myxtick,'ytick',myytick,'linestyle','-','linewidth',1,'tickdir','out')
  set(findobj('tag','m_grid_ygrid'),'color',[0.75 0.75 0.75],'linestyle','-')
  set(findobj('tag','m_grid_xgrid'),'color',[0.75 0.75 0.75],'linestyle','-')
  set(gcf,'color','w');
  if fillType>0,   m_nolakes; end
  delete(findobj('tag','m_grid_xticks-lower'));
  delete(findobj('tag','m_grid_xticks-upper'));
  delete(findobj('tag','m_grid_yticks-left'));
  delete(findobj('tag','m_grid_yticks-right'));
  hxlabel=findobj(gca,'tag','m_grid_xticklabel');  set(hxlabel,'fontweight','b','fontsize',14,'fontname','Nimbus Sans L');
  hylabel=findobj(gca,'tag','m_grid_yticklabels'); set(hylabel,'fontweight','b','fontsize',14,'fontname','Nimbus Sans L');
  load nclcolormap
  colormap(nclcolormap.NCV_jaisnd)
  hbar=colorbar; 
  set(hbar,'tag','cbar','fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
  set(gca, 'CLim', [-2.0, 2.0]);
  delete(hxlabel([1, 2]));
  set(hylabel,'rotation',0)
  set(hxlabel([3 4 5]),'rotation',0)
  movePostion(hylabel([1 2]),0.04,'y')
  movePostion(hxlabel(5),-0.11,'x')
  t1 = title(['Thermodynamic Change ',num2str(YS),' ',monStr], 'fontweight','bold','fontsize', 12,'fontname','Nimbus Sans L');
  set(t1,'Interpreter','none');
  set(t1,'Position',get(t1,'Position') + [0 0.07 0]);
%   pos0=get(hxlabel(12),'position');
%   pos1=get(hxlabel(1),'position'); pos1(1)=pos0(1);
%   set(hxlabel(1),'position',pos1)
%   delete(hxlabel(5:7))
  if exist('myCAXIS','var')
     caxis(myCAXIS)
  else
     caxis([-2 2])
  end
  hsub(2)=subplot(1,2,2);
  m_proj('stereographic','lat',71,'radius',20,'long',-90,'rect','on','rotation',-35)
%   m_proj('stereographic','latitude',80,'radius',[-90 40],'rotangle',60,'rect','on')
  hp=m_pcolor(navLon,navLat,iceH2-iceH1-iceP); set(hp,'linestyle','none','facecolor','interp');
  if coastType>0
     fillType='patch';
  else
     fillType='color';
  end
  if coastType==0
     m_coast('color','k');
  elseif abs(coastType)==1
     m_coast(fillType,landC);
     if coastType>0, set(findobj('tag','m_coast'),'linestyle','none'); end
  elseif abs(coastType)==2
     m_gshhs_i(fillType,landC);
     if coastType>0, set(findobj('tag','m_gshhs_i'),'linestyle','none'); end
  end
  myxtick=-150:30:180; myytick=60:10:80;
  m_grid('tickdir','in','bac','none','xtick',myxtick,'ytick',myytick,'linestyle','-','linewidth',1,'tickdir','out')
  set(findobj('tag','m_grid_ygrid'),'color',[0.75 0.75 0.75],'linestyle','-')
  set(findobj('tag','m_grid_xgrid'),'color',[0.75 0.75 0.75],'linestyle','-')
  set(gcf,'color','w');
  if fillType>0,   m_nolakes; end
  delete(findobj('tag','m_grid_xticks-lower'));
  delete(findobj('tag','m_grid_xticks-upper'));
  delete(findobj('tag','m_grid_yticks-left'));
  delete(findobj('tag','m_grid_yticks-right'));
  hxlabel=findobj(gca,'tag','m_grid_xticklabel');  set(hxlabel,'fontweight','b','fontsize',14,'fontname','Nimbus Sans L');
  hylabel=findobj(gca,'tag','m_grid_yticklabels'); set(hylabel,'fontweight','b','fontsize',14,'fontname','Nimbus Sans L');
  load nclcolormap
  colormap(nclcolormap.NCV_jaisnd)
  hbar=colorbar; 
  set(hbar,'tag','cbar','fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
  set(gca, 'CLim', [-2.0, 2.0]);
  delete(hxlabel([1, 2]));
  set(hylabel,'rotation',0)
  set(hxlabel([3 4 5]),'rotation',0)
  movePostion(hylabel([1 2]),0.04,'y')
  movePostion(hxlabel(5),-0.11,'x')
  t2 = title(['Dynamic Change ',num2str(YS),' ',monStr], 'fontweight','bold','fontsize', 12,'fontname','Nimbus Sans L');
  set(t2,'Interpreter','none');
  set(t2,'Position',get(t2,'Position') + [0 0.07 0]);
%   pos0=get(hxlabel(12),'position');
%   pos1=get(hxlabel(1),'position'); pos1(1)=pos0(1);
%   set(hxlabel(1),'position',pos1)
%   delete(hxlabel(5:7))
  if exist('myCAXIS','var')
     caxis(myCAXIS)
  else
     caxis([-2 2])
  end
  set(hsub(1), 'position', [0.09 0.03 0.3 0.9])
  set(hsub(2), 'position', [0.57 0.03 0.3 0.9])
end
set(gcf, 'paperPosition', [0.25 2.5 10 5]);
print(gcf, '-dpng', '-r300', ['slide_iceP_vs_totalIceHChange_',num2str(YS),'_',monStr,'.png']);

if isSave==1
   maxWIN;
   eval(['print -dpng -r300 iceP_vs_totalIceHChange_',num2str(YS),'_',monStr,'.png'])
else
   disp(['print -dpng -r300 iceP_vs_totalIceHChange_',num2str(YS),'_',monStr,'.png'])
end
