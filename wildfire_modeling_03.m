clear; clc
length = 2400;
width = 1500;
unit = 30; 
l = length/unit;
w = width/unit;

A = l*w - 1;
B = 1;
C = 0;

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
C1 = 0.3;
C2 = 0.265;

% N 행렬은 행: 구역의 가로좌표, 열: 구역의 세로좌표, 510은 시간의 흐름(1분 단위로)
N_ini = zeros(l,w,510);
N = zeros(l,w,510);
% 처음 발화지 좌표가 2,6이라고 합니다!
N_ini(2,6,1) = r;

N(:,:,1) = N_ini(:,:,1);

% W_d는 figure을 그리기 위해 만든 새로운 행렬입니다
W_d = zeros(l*w,3,510);

for t = 2:510
    N(:,:,t) = N(:,:,t-1);
    % V : 풍속
    V = Weather(t-1,3);
    for dl = 1:l
    for dw = 1:w

      if N(dl,dw,t-1) > 0 
      rand_val = rand;

        for i = -1 : 1
        for j = -1 : 1

            if (dl+i > 0) && (dw+j > 0) && (dl+i < l+1) && (dw+j < w+1) 

            % theta : 풍향과 불의 진행방향 사이의 각도
            vector1 = [i j];
            [vx, vy] = pol2cart(Weather(t,2)*2*pi/360,1);
            vector2 = [-vx -vy];
            theta = acos(dot(vector1,vector2)/(norm(vector1)*norm(vector2)));

            % b = 불이 번질 확률
            if norm(i*j) == 1 % 대각선 방향일 때
            E = mosu(dl,dw,13/2-i/2-j);
            b = (p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1)))*E)/sqrt(2);
            elseif (i==0)&&(j==0) % 본인 칸 일때(따라서 확률이 0)
            b = 0;
            else % 위 아래 양 옆 방향에서
            E = mosu(dl,dw,5/2-3*i/2+j/2);
            b = p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1)))*E;   
            end
            
            if rand_val <= b % 그 확률을 뚫고
                if N(dl+i, dw+j, t) == 0 % 아직 불타고있지 않다면
                   N(dl+i, dw+j, t) = r; % 불에 타기 시작한다
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
    % 여기 3줄은 시간에 흐름에 따라 불이 커지는 코드 
    N_d = N(:,:,t);
    N_d(0<N_d & N_d<1) = N_d(0<N_d & N_d<1)+r;
    N_d(N_d>1) = 1;
    N(:,:,t) = N_d;

    % 여기 3줄은 A,B,C의 값이 시간에 흐름에 따라 바뀌는 코드
    A = nnz(N_d==0);
    C = nnz(N_d==1);
    B = l*w - (A+C);

%     if B == 0 % (2400*1500이 모두 전소되든, 중간에 방화를 성공하든 여러 이유로) 만약 타고있는 구역이 없다면 break
%         t
%         break
%     end

end