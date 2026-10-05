clear

h = 0.01;

g = 46000;
gg = fix(g);

T = 10;

q0 = 0.001; %初期の角度
p0 = 0;

tt = 0:h:T;

sz = size(tt);
tsz = sz(2);


z0 = [q0; p0];

%initial

zz = zeros(2, tsz);

zz(:, 1) = z0;

for i = 1:tsz-1
    zz(:, i+1) = symp_1(zz(:, i), g, h);
end

%% グラフデータの作成

q = zz(1, :);

x = sin(q);
y = - cos(q);

Rad = 0.1; %円の半径.
Rad_origin = Rad*0.3; %留具の半径.

rr = Rad*ones(sz);
Pos_center = [x-Rad; y-Rad; 2*rr; 2*rr];
% pos = [x y w h] は, x, yで左下隅の座標を指定. wで幅, hで高さを指定.


%% 画像データ生成
fig = figure; % Figure オブジェクトの生成

theta = 0:0.01:2*pi;
plot(cos(theta), sin(theta), 'LineStyle','--');

daspect([3 3 1]);

% Text オブジェクトの生成
txt = text(0.8, 1.1, '', 'FontSize', 12, 'HorizontalAlignment', 'center'); 
txt2 = text(0.8, 1.0, '', 'FontSize', 12, 'HorizontalAlignment', 'center'); 
txt2.String = sprintf('g = %f', g);

% lineオブジェクトの生成.
pl = line([0 x(1)], [0, y(1)], 'Color','black');

% rectangleオブジェクト. 円の生成.
cir = rectangle('Position',Pos_center(:, 1),'Curvature',[1, 1], FaceColor="red"); 
origin = rectangle('Position', [-Rad_origin, -Rad_origin, 2*Rad_origin, 2*Rad_origin],'Curvature',[1, 1], FaceColor="black");

xlim([-1.2 1.2]); ylim([-1.2 1.2]); % 描画範囲の固定
frames(100) = struct('cdata', [], 'colormap', []); % 各フレームの画像データを格納する配列
for i = 1:tsz % 動画の長さは100フレームとする
    txt.String = sprintf('t = %f', tt(i)); % 表示する文字列を書き換え
    pl.XData = [0 x(i)]; % 紐を動かす(x方向)
    pl.YData = [0 y(i)]; % 紐を動かす(x方向)
    cir.Position = Pos_center(:, i); %おもりを動かす.
    drawnow; % 描画を確実に実行させる
    frames(i) = getframe(fig); % 図を画像データとして得る
end

%% 動画出力.

exporttype = 'mp4';

switch exporttype % 今回は出力方法を exporttype 変数で指定することにする
    case 'mp4' % 普通の動画の場合
        filename = sprintf('pendulum_q0_%.3f_g_%d.mp4', q0, gg);
        video = VideoWriter(filename, 'MPEG-4'); % ファイル名や出力形式などを設定
        open(video); % 書き込むファイルを開く
        writeVideo(video, frames); % ファイルに書き込む
        close(video); % 書き込むファイルを閉じる
    case 'gif'
        filename = sprintf('pendulum_q0_%.3f_g_%d.gif', q0, gg); % ファイル名
        for i = 1:tsz
            [A, map] = rgb2ind(frame2im(frames(i)), 256); % 画像形式変換
            if i == 1
                imwrite(A, map, filename, 'gif', 'DelayTime', 1/30); % 出力形式(30FPS)を設定
            else
                imwrite(A, map, filename, 'gif', 'DelayTime', 1/30, 'WriteMode', 'append'); % 2フレーム目以降は"追記"の設定も必要
            end
        end
end

%% 

function PT = potential(q, A)
    PT = -A.*cos(q);
end

function dPT = dpotential(q, A)
    dPT = A.*sin(q);
end

function SE = symp_1(z, A, step)
    q = z(1);
    p = z(2);
    pp = p - step.*dpotential(q, A);
    qq = q + step.*pp;
    SE = [qq; pp];
end