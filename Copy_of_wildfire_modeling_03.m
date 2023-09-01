clear; clc
length = 2400;
width = 1500;
unit = 30; 
l = length/unit;
w = width/unit;






pd = 128300/1790000;
e=0;

Weather = xlsread('April_11_Gangneung_weather_information.xlsx','input','C32:F541');
mosu_1 = readmatrix('mosu.xlsx');
mosu = zeros(l,w,8);
for t_m = 1:8
    for l_m = 1:l
        for w_m = 1:w
            mosu(l_m,w_m,t_m) = mosu_1(100*(w_m-1)+l_m,t_m+1);
        end
    end
end

dt = 1:510;
r = 1/60;

p0 = 0.58;
C1 = 0.245;
C2 = 0.231;

N_ini = zeros(l,w,510);
N = zeros(l,w,510);
N_ini(2,6,1) = r;

N(:,:,1) = N_ini(:,:,1);

W_d = zeros(l*w,3,510);

N1 = N_ini; N2 = N_ini; N3 = N_ini;
W_d1 = zeros(l*w,3,510); W_d2 = zeros(l*w,3,510); W_d3 = zeros(l*w,3,510);

A = l*w - 1;
B = 1;
C = 0;
A1 = l*w - 1;
B1 = 1;
C_1 = 0;
A2 = l*w - 1;
B2 = 1;
C_2 = 0;
A3 = l*w - 1;
B3 = 1;
C_3 = 0;

rand_val = rand(1,510);

for t = 2:1:510
    N(:,:,t) = N(:,:,t-1);
    rv = rand_val(1,t);
    V = Weather(t-1,3);



    for dl = 1:l
    for dw = 1:w

      if N(dl,dw,t-1) > 0 

        for i = -1 : 1
        for j = -1 : 1

            if (dl+i > 0) && (dw+j > 0) && (dl+i < l+1) && (dw+j < w+1) 

            vector1 = [i j];
            [vx, vy] = pol2cart(Weather(t,2)*2*pi/360,1);
            vector2 = [-vx -vy];
            theta = acos(dot(vector1,vector2)/(norm(vector1)*norm(vector2)));

            if norm(i*j) == 1
            E = mosu(dl,dw,13/2-i/2-j);
            b = p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1)))*E;
            elseif (i==0)&&(j==0) 
            b = 0;
            else 
            E = mosu(dl,dw,5/2-3*i/2+j/2);
            b = p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1)))*E;   
            end

            if rv <= b 
                if N(dl+i, dw+j, t) == 0 
                   N(dl+i, dw+j, t) = r; 
                end
            end

            end

        end
        end

      end

    W_d(w*(dl-1)+dw,1,t) = dl;
    W_d(w*(dl-1)+dw,2,t) = dw;
    W_d(w*(dl-1)+dw,3,t) = N(dl,dw,t);
   
    end
    end
    N_d = N(:,:,t);
    N_d(0<N_d & N_d<1) = N_d(0<N_d & N_d<1)+r;
    N_d(N_d>1) = 1;
    N(:,:,t) = N_d;

    A = nnz(N_d==0);
    C = nnz(N_d==1);
    B = l*w - (A+C);
 
end

v_w = 6/50;

for t = 2:1:510
 
    N1(:,:,t) = N1(:,:,t-1);
    V = Weather(t-1,3);
    rv = rand_val(1,t);
    x_w = v_w*(t-60);

    if t>60
    if 30-fix(x_w)>0 && 25+fix(x_w) < 50
        if N1(30-fix(x_w), 25+fix(x_w), t) <= 0
        N1(30-fix(x_w), 25+fix(x_w), t) = -rem(x_w,50);
        if fix(x_w) ~= fix(v_w*(t-61))
        N1(30-fix(v_w*(t-61)), 25+fix(v_w*(t-61)), t)= -1;
        end
        end
    end
    end



    for dl = 1:l
    for dw = 1:w

         if N1(dl,dw,t-1) > 0 

        for i = -1 : 1
        for j = -1 : 1

            if (dl+i > 0) && (dw+j > 0) && (dl+i < l+1) && (dw+j < w+1) 

            vector1 = [i j];
            [vx, vy] = pol2cart(Weather(t,2)*2*pi/360,1);
            vector2 = [-vx -vy];
            theta = acos(dot(vector1,vector2)/(norm(vector1)*norm(vector2)));

            if norm(i*j) == 1 
            E = mosu(dl,dw,13/2-i/2-j);
            b = p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1)))*E;
            elseif (i==0)&&(j==0) 
            b = 0;
            else 
            E = mosu(dl,dw,5/2-3*i/2+j/2);
            b = p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1)))*E;   
            end

            if N1(dl+i, dw+j, t) == 0
                if N1(dl+i, dw, t) >= 0 || N1(dl, dw+j, t) >= 0
                if rv <= b 
                N1(dl+i, dw+j, t) = r; 
                end
                elseif N1(dl+i, dw, t) < 0 && N1(dl, dw+j, t) < 0
                if rv <= b/3
                    N1(dl+i, dw+j, t) = r;                     
                end                
                end
            elseif N1(dl+i, dw+j, t) < 0
                 if rv <= b/3
                     N1(dl+i, dw+j, t) = r;                     
                 end
               
             end
            
            end
        end
        end
        end

    W_d1(w*(dl-1)+dw,1,t) = dl;
    W_d1(w*(dl-1)+dw,2,t) = dw;
    W_d1(w*(dl-1)+dw,3,t) = N1(dl,dw,t);

    end
    end

    N_d1 = N1(:,:,t);
    N_d1(0<N_d1 & N_d1<1) = N_d1(0<N_d1 & N_d1<1)+r;
    N_d1(N_d1>1) = 1;
    A1 = nnz(N_d1==0);
    C_1 = nnz(N_d1==1);
    B1 = l*w - (A1+C_1);
    N1(:,:,t) = N_d1;


end



 for t = 1 : 50
     N2(t,51-t,:) = -1;
 end


for t = 2:1:510
 
    N2(:,:,t) = N2(:,:,t-1);
    V = Weather(t-1,3);
    rv = rand_val(1,t);

    for dl = 1:l
    for dw = 1:w

        if N2(dl,dw,t-1) > 0 

        for i = -1 : 1
        for j = -1 : 1

            if (dl+i > 0) && (dw+j > 0) && (dl+i < l+1) && (dw+j < w+1) 

            vector1 = [i j];
            [vx, vy] = pol2cart(Weather(t,2)*2*pi/360,1);
            vector2 = [-vx -vy];
            theta = acos(dot(vector1,vector2)/(norm(vector1)*norm(vector2)));

            if norm(i*j) == 1 
            E = mosu(dl,dw,13/2-i/2-j);
            b = p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1)))*E;
            elseif (i==0)&&(j==0) 
            b = 0;
            else 
            E = mosu(dl,dw,5/2-3*i/2+j/2);
            b = p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1)))*E;   
            end

            if N2(dl+i, dw+j, t) == 0
                if N2(dl+i, dw, t) >= 0 || N2(dl, dw+j, t) >= 0
                if rv <= b 
                N2(dl+i, dw+j, t) = r; 
                end
                elseif N2(dl+i, dw, t) < 0 && N2(dl, dw+j, t) < 0
                if rv <= b/10
                    N2(dl+i, dw+j, t) = r;                     
                end                
                end
            elseif N2(dl+i, dw+j, t) < 0
                 if rv <= b/10
                     N2(dl+i, dw+j, t) = r;                     
                 end
               
             end
            
            end
        end
        end
        end

    W_d2(w*(dl-1)+dw,1,t) = dl;
    W_d2(w*(dl-1)+dw,2,t) = dw;
    W_d2(w*(dl-1)+dw,3,t) = N2(dl,dw,t);

    end
    end

    N_d2 = N2(:,:,t);
    N_d2(0<N_d2 & N_d2<1) = N_d2(0<N_d2 & N_d2<1)+r;
    N_d2(N_d2>1) = 1;
    A2 = nnz(N_d2<=0);
    C_2 = nnz(N_d2==1);
    B2 = l*w - (A2+C_2);
    N2(:,:,t) = N_d2;


end


 for t = 1 : 50
     N3(t,51-t,:) = -1;
 end

for t = 2:1:510
 
    N3(:,:,t) = N3(:,:,t-1);
    V = Weather(t-1,3);
    rv = rand_val(1,t);

    for dl = 1:l
    for dw = 1:w

        if N3(dl,dw,t-1) > 0 

        for i = -1 : 1
        for j = -1 : 1

            if (dl+i > 0) && (dw+j > 0) && (dl+i < l+1) && (dw+j < w+1) 

            vector1 = [i j];
            [vx, vy] = pol2cart(Weather(t,2)*2*pi/360,1);
            vector2 = [-vx -vy];
            theta = acos(dot(vector1,vector2)/(norm(vector1)*norm(vector2)));

            if norm(i*j) == 1 
            E = mosu(dl,dw,13/2-i/2-j);
            b = p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1)))*E;
            elseif (i==0)&&(j==0) 
            b = 0;
            else 
            E = mosu(dl,dw,5/2-3*i/2+j/2);
            b = p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1)))*E;   
            end

            if N3(dl+i, dw+j, t) == 0
                if N3(dl+i, dw, t) >= 0 || N3(dl, dw+j, t) >= 0
                if rv <= b 
                N3(dl+i, dw+j, t) = r; 
                end
                elseif N3(dl+i, dw, t) < 0 && N3(dl, dw+j, t) < 0
                if rv <= b/36
                    N3(dl+i, dw+j, t) = r;                     
                end                
                end
            elseif N3(dl+i, dw+j, t) < 0
                 if rv <= b/36
                     N3(dl+i, dw+j, t) = r;                     
                 end
               
            end            
            end
        end
        end
        end

    W_d3(w*(dl-1)+dw,1,t) = dl;
    W_d3(w*(dl-1)+dw,2,t) = dw;
    W_d3(w*(dl-1)+dw,3,t) = N3(dl,dw,t);

    end
    end

    N_d3 = N3(:,:,t);
    N_d3(0<N_d3 & N_d3<1) = N_d3(0<N_d3 & N_d3<1)+r;
    N_d3(N_d3>1) = 1;
    A3 = nnz(N_d3<=0);
    C_3 = nnz(N_d3==1);
    B3 = l*w - (A3+C_3);
    N3(:,:,t) = N_d3;

end


(4000-A)/4000
(4000-A1)/4000
(4000-A2)/4000
(4000-A3)/4000
   