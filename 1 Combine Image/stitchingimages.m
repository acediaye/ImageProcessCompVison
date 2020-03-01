%andy yeh
clear all, clc

odddata=load('odd_rows.mat');
figure(1)
imshow(odddata.odd_channel,[0,255])%2nd arg to map values from 0 to 255
title('odd rows')

evendata=load('even_rows.mat');
figure(2)
imshow(evendata.even_corrupted_channel,[0,255])
title('corrupted even rows')

res=zeros(440,560);%contruct empty result array
res(1:2:end,:)=odddata.odd_channel;%put odd rows into result's by starting from 1st to last and incrementing by 2  
res(2:2:end,:)=evendata.even_corrupted_channel;%put even rows into result's by starting from 2nd to last and incrementing by 2
figure(3)
imshow(res,[0,255])%show odd rows with corrupted even rows together
title('odd + corrupted even rows')

[m,n]=size(odddata.odd_channel);%measure array size
mean=sum(odddata.odd_channel,2)/n;%find mean of each row, get a vector
correction=evendata.even_corrupted_channel(1:end,:)+mean(1:end,:);%+[mean(2:end,:);0];%corrected even rows by adding means of corresponding odd rows 
figure(4)
imshow(correction,[0,255])%show corrected even rows
title('corrected even rows')

res2=zeros(440,560);
res2(1:2:end,:)=odddata.odd_channel;
res2(2:2:end,:)=correction;
figure(5)
imshow(res2,[0,255])%show odd rows with corrected even rows together
title('odd + corrected even rows')
%{
temp =[0 2 4 6; 8 10 12 14; 16 18 20 22];
image(temp)
colorbar

A=[1,2,3;4,5,6;7,8,9];
B=[11,12,13;14,15,16;17,18,19];

C=zeros(3,6);
C(:,1:2:end)=A;%odd columns of C
C(:,2:2:end)=B;%even columns of C
C

C=zeros(6,3);
C(1:2:end,:)=A;%start from row 1 to last row of C matrix, increment by 2(odd rows), equals A
C(2:2:end,:)=B;%from row 2 to last row, increment by 2(even rows), equals B
C

sum(A)%sum of each columns
sum(A,2)%sum of each rows
[m,n]=size(A)
mean=(sum(A,2)/n)%mean of each row
AA=A(:,1:end)+mean(:,1:end)%each row of A add by each row of mean vector
%}