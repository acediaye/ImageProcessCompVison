clear
clc

myimage=double(imread('scene.ppm'));
myimage=imresize(myimage,0.60);
myimage=myimage./255;%rescaled down to [0 1]
%[row,col,channels]=size(myimage);

R=myimage(:,:,1);%red channel
G=myimage(:,:,2);%green channel
B=myimage(:,:,3);%blue channel
RGB=cat(3,R,G,B);%recombined 
figure(1)
subplot(1,2,1)
imshow(uint8(255.*RGB),[])%rescaled up to [0 255]
title('RGB')
segment=mysegment(myimage,RGB);
subplot(1,2,2)
imshow(uint8(255.*segment),[])%display color segmentaion

C=1-R;%convert red to cyan
M=1-G;%convert green to magenta
Y=1-B;%convert blue to yellow
CMY=cat(3,C,M,Y);
figure(2)
subplot(1,2,1)
imshow(uint8(255.*CMY),[])%rescaled up to [0 255]
title('CMY')
segment=mysegment(myimage,CMY);
subplot(1,2,2)
imshow(uint8(255.*segment),[])%display color segmentaion

Hnum=1/2*((R-G)+(R-B));
Hden=sqrt((R-G).^2+(R-B).*(G-B));
H=acosd(Hnum./Hden);%convert rgb to hue
H(B>G)=360-H(B>G);%rescale hue to [0 360]
H=H/360;%rescale hue [0 1]
S=1-(3./(R+G+B)).*min(myimage,[],3);%convert rgb to saturation
I=(R+G+B)./3;%convert rgb to intensity
HSI=cat(3,H,S,I);%recombine 3 planes
figure(3)
subplot(1,2,1)
imshow(uint8(255.*HSI),[])%rescaled up to [0 255]
title('HSI')
segment=mysegment(myimage,HSI);
subplot(1,2,2)
imshow(uint8(255.*segment),[])%display color segmentaion

function output=mysegment(myimage,colorspace)
    [row,col,channel]=size(myimage);
    segment=colorspace;
    %size(segment)
    cube1=[0.75;0.25;0.75];%divide whole color space into 8 smaller equal cubes with each center point listed
    cube2=[0.25;0.25;0.75];
    cube3=[0.75;0.75;0.75];
    cube4=[0.25;0.75;0.75];
    cube5=[0.75;0.25;0.25];
    cube6=[0.25;0.25;0.25];
    cube7=[0.75;0.75;0.25];
    cube8=[0.25;0.75;0.25];
    w=0.5;%width of each small cube
    for i=1:row
        for j=1:col
            r=[colorspace(i,j,1);colorspace(i,j,2);colorspace(i,j,3)];% vector of current pixel location
            if abs(r(1)-cube1(1))<w/2 && abs(r(2)-cube1(2))<w/2 && abs(r(3)-cube1(3))<w/2%comparison size of small color cube
                segment(i,j,:)=[1;0;1];%cube near magenta assign to magenta
            elseif abs(r(1)-cube2(1))<w/2 && abs(r(2)-cube2(2))<w/2 && abs(r(3)-cube2(3))<w/2
                segment(i,j,:)=[0;0;1];%cube near blue assign to blue
            elseif abs(r(1)-cube3(1))<w/2 && abs(r(2)-cube3(2))<w/2 && abs(r(3)-cube3(3))<w/2
                segment(i,j,:)=[1;1;1];%cube near white assign to white
            elseif abs(r(1)-cube4(1))<w/2 && abs(r(2)-cube4(2))<w/2 && abs(r(3)-cube4(3))<w/2
                segment(i,j,:)=[0;1;1];%cube near cyan assign to cyan
            elseif abs(r(1)-cube5(1))<w/2 && abs(r(2)-cube5(2))<w/2 && abs(r(3)-cube5(3))<w/2
                segment(i,j,:)=[1;0;0];%cube near red assign to red
            elseif abs(r(1)-cube6(1))<w/2 && abs(r(2)-cube6(2))<w/2 && abs(r(3)-cube6(3))<w/2
                segment(i,j,:)=[0;0;0];%cube near black assign to black
            elseif abs(r(1)-cube7(1))<w/2 && abs(r(2)-cube7(2))<w/2 && abs(r(3)-cube7(3))<w/2
                segment(i,j,:)=[1;1;0];%cube near yellow assign to yellow
            elseif abs(r(1)-cube8(1))<w/2 && abs(r(2)-cube8(2))<w/2 && abs(r(3)-cube8(3))<w/2
                segment(i,j,:)=[0;1;0];%cube near green assign to green
            else
                segment(i,j,:)=[0.5;0.5;0.5];%surface between each small cube assign to gray
            end
        end
    end
    output=segment;
end