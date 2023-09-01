clear; clc
length = 2400;
width = 1500;
unit = 30; % cell의 단위 길이
d = unit*sqrt(2); % 9칸에서의 대각선 방향으로의 거리라서 root2를 곱했습니다
l = length/unit;
w = width/unit;

% A : 아직 불에 타지 않은 구역의 수
% B : 현재 불에 타고 있는 구역의 수
% C : 전소된 구역의 수

A = l*w - 1;
B = 1;
C = 0;

% pd : 단위 구역당 개채 수, 나중에 높이값 받으면 높이에 따라 값이 달라지므로 for구문 안으로 들어갑니다
% e : 높이차이(원래는 delta e), 나중에 높이 값 받으면 이것도 for구문 안으로 들어갑니다

pd = 128300/1790000;
e=0;

%08:30~16:59 기온, 풍향, 풍속, 습도 1분단위로
Weather = xlsread('April_11_Gangneung_weather_information.xlsx','input','C32:F541');
mosu = readtable('mosu.xlsx');
dt = 1:510;
% r : gamma, 1/r = 단위 구역이 불에 타는데 걸리는 시간
r = 1/30;

%그 논문에서 설정한 상수들
p0 = 0.58; % 평지에서 바람이 불지 않을 때 불이 번질 확률, 이 아래는 그냥 상수
as = 0.078;
C1 = 0.045;
C2 = 0.165;

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

      if N(dl,dw,t-1) > 0 % 불에 타고있다면 주위에 불을 번질 수 있으므로 난수 생성
      rand_val = rand;

        for i = -1 : 1
        for j = -1 : 1

            % theta : 풍향과 불의 진행방향 사이의 각도
            vector1 = [i j];
            [vx, vy] = pol2cart(Weather(t,2)*2*pi/360,1);
            vector2 = [-vx -vy];
            theta = acos(dot(vector1,vector2)/(norm(vector1)*norm(vector2)));
            
            % b = 불이 번질 확률
            if norm(i*j) == 1 % 대각선 방향일 때
            b = (p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1))+as*atan(e/d)))/sqrt(2);
            elseif (i==0)&&(j==0) % 본인 칸 일때(따라서 확률이 0)
            b = 0;
            else % 위 아래 양 옆 방향에서
            b = p0*(1+pd)*exp(V*(C1+C2*(cos(theta)-1))+as*atan(e/d));   
            end

            
            if (dl+i > 0) && (dw+j > 0) && (dl+i < l+1) && (dw+j < w+1) % 불 번질 칸이 행렬 내부에 있을 때
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

    if B == 0 % (2400*1500이 모두 전소되든, 중간에 방화를 성공하든 여러 이유로) 만약 타고있는 구역이 없다면 break
        t
        break
   end

end