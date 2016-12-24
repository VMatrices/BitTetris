Program BitTetris;
uses crt,dos;
// Ver 1.0 
// By iBelieve 

const BlockMod:array[1..10,1..4,1..4] of integer=
	(((1,1,0,0),(0,1,0,0),(0,1,1,0),(0,0,0,0)),
	((0,1,1,0),(0,1,0,0),(1,1,0,0),(0,0,0,0)),
	((0,1,0,0),(0,1,0,0),(0,1,1,0),(0,0,0,0)),
	((0,1,0,0),(0,1,0,0),(1,1,0,0),(0,0,0,0)),
	((0,1,0,0),(1,1,1,0),(0,0,0,0),(0,0,0,0)),
	((0,0,0,0),(0,1,1,0),(0,1,1,0),(0,0,0,0)),
	((0,0,1,0),(0,0,1,0),(0,0,1,0),(0,0,1,0)),
	((0,0,0,0),(0,1,0,0),(0,0,0,0),(0,0,0,0)),
	((0,1,0,0),(0,1,0,0),(0,0,0,0),(0,0,0,0)),
	((0,1,0,0),(1,1,0,0),(0,0,0,0),(0,0,0,0)));
	BlockN:array[1..10] of 3..4=(3,3,3,3,3,4,4,3,2,2);
	scorelevel:array[0..4] of 0..8=(0,10,20,40,80);
	wide=12;
	high=22;
	ver='3.2';

type
	model=record
		a :array[1..4,1..4] of integer;
		n,c :integer;
	end;

var
	block:array[1..10] of model;
	map:array[0..23,0..13] of integer;
	bx,by,i,j,top,score,level,speed,counttime,countlines,leveluplines,life,randlifea,randlifeb :longint;
	blockcolor,plugblock,blockhead,x,hardspeed :integer;
	ts,tm,th,state:string;
	nowblock,nextblock:model;
        ta1,ta2,ta3,ta4,tb1,tb2,tb3,tb4,ts1,ts2,ts3,ts4 :word;
	key,key2:integer;
	blockchar,blockwall,blockback:string;
	flag :boolean;
	
function getkey():integer;
var key:char;
begin
	getkey:=ord(readkey);
	if getkey=0 then exit(256+getkey());
end;

procedure placeint(x,y:integer;t:integer);
begin
	gotoxy(y,x);
	write(t);
end;

procedure placestring(x,y,z:integer;c:string);
begin
	gotoxy(y,x);
	TextBackground(z);
	write(c);
end;

procedure pause();
var key:integer;
begin
	repeat
		key:=getkey;
	until (key=13)or(key=284);
end;


procedure printblock();
var i,j :integer;
begin
	for i:=1 to 4 do
		for j:=1 to 4 do
			if (i<=nextblock.n)and(j<=nextblock.n)and(nextblock.a[i,j]>0) then placestring(i+3,(wide+j)*2+9,nextblock.c*blockcolor,blockchar) else placestring(i+3,(wide+j)*2+9,8*blockcolor,blockback);
end;

procedure printinfo();
var it1,it2:word;
begin
	placestring(10,wide*2+15,8,chr(level+65));
	placestring(12,wide*2+15,8,'      ');
	placeint(12,wide*2+15,score);
	placestring(14,wide*2+15,8,'      ');
	placeint(14,wide*2+15,countlines);
	placestring(16,wide*2+14,8,'      ');
	placeint(16,wide*2+14,life);
	placestring(18,wide*2+15,8,'      ');
	placeint(18,wide*2+15,speed);
	gettime(it1,it1,it1,it2);
	if (it1 div 5) mod 2=1 then placestring(24,wide*2+9,8,'ircr@qq.com') else placestring(24,wide*2+9,8,'iBelieve     ');
end;

procedure drawsquare(x,y,w,h,cl:integer;c:string);
var i,j:longint;
begin
	for i:=1 to w do placestring(x,(i+y-2)*2+1,cl,c);
	for i:=1 to h-2 do begin
		placestring(x+i,y*2-1,cl,c);
		placestring(x+i,(y+w)*2-3,cl,c);
	end;
	for i:=1 to w do placestring(x+h-1,(i+y-2)*2+1,cl,c);
end;

procedure animi(s,t,cl:integer;c:string);
var i:integer;
begin
	if s=1 then i:=1 else i:=wide div 2;
	while (i>0)and(i<=wide div 2) do begin
		drawsquare(2+i,2+i,wide-2*i+2,high-2*i+2,cl,c);
		delay(t);
		i:=i+s;
	end;
end;

procedure clearbottom(x:integer);
var i,j:integer;
begin
	if top+x-1<=22 then begin
		for i:=high-x downto top do
			for j:=1 to wide do begin
				map[i+x,j]:=map[i,j];
				map[i,j]:=0;
			end;
			for i:=top to top+x-1 do
				for j:=1 to wide do
					map[i,j]:=0;
		top:=top+x;
	end;
end;


procedure printmap();
var i,j,c:integer;
	m:boolean;
begin
	for i:=1 to high do begin
		for j:=1 to wide do begin
			m:=false;
			if (bx<=i)and(i<bx+nowblock.n)and(by<=j)and(j<by+nowblock.n) then
				if nowblock.a[i-bx+1,j-by+1]>0 then begin
					m:=true;
					c:=nowblock.c;
				end;
			if map[i,j]>0 then begin
				m:=true;
				c:=map[i,j];
			end;
			if m then placestring(i+2,j*2+3,c*blockcolor,blockchar) else placestring(i+2,j*2+3,8*blockcolor,blockback);
		end;
	end;
	printblock;
	printinfo;
end;

procedure autoclear(n:integer);
var i:integer;
begin
	placestring(22,wide*2+15,8,'Clear');
	for i:=1 to n do begin
		printmap;
		clearbottom(1);
		delay(50);
	end;
	printmap;
end;

procedure levelup();
var i,n,x,l:integer;
	cn:string;
begin
	placestring(22,wide*2+15,8,'UP!  ');
	animi(1,50,7,blockwall);
	animi(-1,50,8,'  ');
	printinfo;
	x:=0;
	if high-top<2 then n:=high-top+1 else n:=random(high-top-1)+3;
	str(n,cn);
	placestring(4,7,8,'LEVEL UP');
	placestring(6,7,8,'Congratulation! You');
	placestring(7,7,8,'have unlocked next');
	placestring(8,7,8,chr(level+65));
	placestring(8,9,8,'level.');
	placestring(10,7,8,'Speed will be faster.');
	placestring(12,7,8,'As a reward, We will');
	placestring(13,7,8,'clear '+cn+' lines.');
	if random(randlifea)=0 then begin
		l:=random(randlifeb)+1;
		life:=life+l;
		printinfo;
		placestring(15,7,8,'You have got '+chr(48+l)+' lifes.');
		x:=x+2;
	end;
	if (level div 3>blockhead-7) then begin
		inc(blockhead);
		nextblock:=block[blockhead];
		nextblock.c:=7;
		printblock;
		placestring(15+x,7,8,'NewBlock has unlocked.');
		x:=x+2;
	end;
	placestring(15+x,7,8,'We`re looking forward');
	placestring(16+x,7,8,'to your performance.');
	for i:=1 to wide*2-2 do placestring(22,5+i,8,'-');
	placestring(23,7,8,'Press Enter to play');
	pause;
	placestring(22,wide*2+15,8,'Play ');
	animi(-1,50,7,blockwall);
	animi(1,50,8,'  ');
	autoclear(n);
end;


function caltime(a1,a2,a3,a4,b1,b2,b3,b4:word):longint;
begin
	if b1<a1 then b1:=b1+24;
	exit((b1-a1)*360000+(b2-a2)*6000+(b3-a3)*100+b4-a4);
end;
	

function rotate(p:model):model;
var i:integer;
begin
	rotate.n:=p.n;
	rotate.c:=p.c;
	for i:=1 to p.n do
		for j:=1 to p.n do 
			rotate.a[p.n+1-j,i]:=p.a[i,j];
end;


function ifout(x,y:integer;b:model):boolean;
var i,j:integer;
begin
	for i:=1 to b.n do
		for j:=1 to b.n do
			if not((x+i-1<=high)and(y+j-1<=wide)and(x+i-1>-3)and(y+j-1>0))and(b.a[i,j]>0) then exit(true);
	exit(false);
end;
	

function ifcover(x,y:integer;b:model):boolean;
var i,j:integer;
begin
	for i:=1 to b.n do
		for j:=1 to b.n do
			if (x+i-1<=high+1)and(y+j-1<=wide)and(x+i-1>0)and(y+j-1>0) then 
				if (b.a[i,j]>0)and(map[x+i-1,y+j-1]>0) then exit(true);
	exit(false);
end;


function move(key:integer;var b:model):boolean;
var tmp:model;
	dy:integer;
begin
	case key of 
		331: begin
			if not(ifout(bx,by-1,b)) then
				if not(ifcover(bx,by-1,b)) then dec(by);
			exit(true);
		end;
		333: begin
			if not(ifout(bx,by+1,b)) then 
				if not(ifcover(bx,by+1,b)) then inc(by);
			exit(true);
		end;
		336: begin
			if not(ifcover(bx+1,by,b)) then begin
				inc(bx);
				exit(true);
			end;
			if bx<top then top:=bx;
			exit(false);
		end;
		328: begin
			tmp:=rotate(b);
			if ifout(bx,by,tmp) then begin
				if by<1 then dy:=1 else dy:=-1;
				if ifout(bx,by+dy,tmp) then dy:=dy*2;
				if not(ifcover(bx,by+dy,tmp)) then begin
					by:=by+dy;
					b:=tmp;
				end;
				exit(true);
			end;
			if not(ifcover(bx,by,tmp)) then b:=tmp;
			exit(true);
		end;
	end;
	exit(true);
end;


procedure makeblock();
var i:longint;
begin
	inc(score);
	nowblock:=nextblock;
	if plugblock=0 then nextblock:=block[random(blockhead)+1] else nextblock:=block[plugblock];
	nextblock.c:=random(7)+1;
	for i:=1 to random(4) do nextblock:=rotate(nextblock);
	bx:=-2;
	by:=random(wide-nextblock.n+1)+1;
end;


procedure placeblock(x,y:integer;b:model);
var i,j:integer;
begin
	for i:=1 to b.n do
		for j:=1 to b.n do 
			if b.a[i,j]>0 then 
				map[x+i-1,y+j-1]:=nowblock.c;
end;

procedure clearline();
var i,j,num,dh,st :integer;
	h:array[1..64] of integer;
begin
	dh:=0;
	st:=0;
	for i:=high downto top do begin
		h[i]:=0;
		num:=0;
		for j:=1 to wide do if map[i,j]>0 then inc(num);
		if num=wide then begin;
			if st=0 then st:=i;
			inc(dh);
			h[i]:=dh;
		end;
	end;
	countlines:=countlines+dh;
	score:=score+scorelevel[dh];
	if dh>0 then begin
		dh:=h[st];
		for i:=st-1 downto top do begin
			if h[i]=0 then begin
				for j:=1 to wide do begin
					map[i+dh,j]:=map[i,j];
					map[i,j]:=0;
				end;
			end else dh:=h[i];
		end;
	end;
	for i:=top to top+dh-1 do
		for j:=1 to wide do
			map[i,j]:=0;
	top:=top+dh;
end;


procedure drawframe();
begin
	drawsquare(2,2,wide+2,high+2,7*blockcolor,blockwall);
	drawsquare(3,wide+5,6,6,7*blockcolor,blockwall);
	placestring(2,wide*2+10,8,'Next Block');
	placestring(10,wide*2+9,8,'Level:0');
	placestring(12,wide*2+9,8,'Score:0');
	placestring(14,wide*2+9,8,'Clear:0');
	placestring(16,wide*2+9,8,'Life:0');
	placestring(18,wide*2+9,8,'Speed:0 ');
	placestring(20,wide*2+9,8,'Time:0:0:0');
	placestring(22,wide*2+9,8,'State:Play ');
	placestring(24,wide*2+9,8,'iBelieve     ');

end;
	

procedure plug();
var 
	i,j,x,code :longint;
	order:string;
	p :array[1..3] of integer;
begin
	
	while true do begin
		for i:=1 to wide*2 do placestring(3,4+i,8,'-');
		placestring(4,5,8,' BitTetris V'+ver+' ExtPlug ');
		for i:=1 to wide*2 do placestring(5,4+i,8,'-');
		placestring(6,5,8,' clear n                ');
		placestring(7,5,8,'  -Clear bottom n lines.');
		placestring(8,5,8,' block n                ');
		placestring(9,5,8,'  -Appear wandted block.');
		placestring(10,5,8,'   n:1-7, 0 is random.  ');
		placestring(11,5,8,' score/life/lines n     ');
		placestring(12,5,8,'  -Change num to N.     ');
		placestring(13,5,8,' speed t                ');
		placestring(14,5,8,'  -Set drop speed(ms).  ');
		placestring(15,5,8,' rank n                 ');
		placestring(16,5,8,'  -Set level up rank.   ');
		placestring(17,5,8,' free                   ');
		placestring(18,5,8,'  -Open/Close auto drop.');
		placestring(19,5,8,' drawdot                ');
		placestring(20,5,8,'  -Draw background dot. ');
		placestring(21,5,8,' quit                   ');
		placestring(22,5,8,'  -Quit ExtPlug tool.   ');
		for i:=1 to wide*2 do placestring(23,4+i,8,'-');
		placestring(22,wide*2+15,8,'Debug');
		placestring(24,5,8,'>');
		for i:=1 to wide*2-1 do placestring(24,5+i,8,' ');
		gotoxy(6,24);
		cursoron;
		readln(order);
		cursoroff;
		if Copy(order,1,1)='q' then  begin
			exit;
		end else if Copy(order,1,6)='clear ' then begin
			val(Copy(order,7,length(order)-6),x,code);
			if x=0 then begin
				placestring(24,6,8,' Clear lines failed! ');
			end else begin
				if x>high-top then x:=high-top;
				autoclear(x);
				placestring(24,6,8,' Clear lines success! ');
			end;
		end else if Copy(order,1,6)='block ' then begin
			val(Copy(order,7,length(order)-6),x,code);
			if x<=10 then begin
				plugblock:=x;
				makeblock;
				makeblock;
				score:=score-2;
				printblock;
				if x=0 then begin
					placestring(24,6,8,' Set Random block! ');
				end else begin
					placestring(24,6,8,' Set block success! ');
				end;
			end else placestring(24,6,8,'  Set block failed! ');
		end else if Copy(order,1,6)='score ' then begin
			val(Copy(order,7,length(order)-6),x,code);
			if x=0 then begin
				placestring(24,6,8,' Change score failed! ');
			end else begin
				score:=x;
				printinfo;
				placestring(24,6,8,' Change score success! ');
			end;
		end else if Copy(order,1,6)='speed ' then begin
			val(Copy(order,7,length(order)-6),x,code);
			if x<6 then begin
				placestring(24,6,8,' Set speed failed! ');
			end else begin
				speed:=x;
				printinfo;
				placestring(24,6,8,' Set speed success! ');
			end;
		end else if Copy(order,1,4)='free' then begin
			if flag then placestring(24,6,8,' Close auto drop! ') else placestring(24,6,8,' Open auto drop! ');
			flag:=not flag;
		end else if Copy(order,1,7)='drawdot' then begin
			if blockback='  ' then begin
				blockback:=' .';
				placestring(24,5,8,' Enable background dot!');
			end else begin
				blockback:='  ';
				placestring(24,5,8,' Disable background dot!');
			end;
			printblock;
		end else if Copy(order,1,6)='lines ' then begin
			val(Copy(order,7,length(order)-6),x,code);
			if x=0 then begin
				placestring(24,6,8,' Change failed! ');
			end else begin
				countlines:=x;
				printinfo;
				placestring(24,6,8,' Change success! ');
			end;
		end else if Copy(order,1,5)='rank ' then begin
			val(Copy(order,6,length(order)-5),x,code);
			if x=0 then begin
				placestring(24,6,8,' Set rank failed! ');
			end else begin
				leveluplines:=x;
				placestring(24,6,8,' Now rank is ');
				placeint(24,20,x);
			end;
		end else if Copy(order,1,5)='life ' then begin
			val(Copy(order,6,length(order)-5),x,code);
			if x=0 then begin
				placestring(24,6,8,' Change life failed! ');
			end else begin
				life:=x;
				placestring(24,6,8,' Change life success! ');
			end;
		end else begin
			placestring(24,6,8,'  Wrong command!');
		end;
		delay(1000);
		if length(order)>wide*2-1 then ClrScr;
		drawframe();
		printinfo;
	end;
end;

procedure choosedifficulty();
var i:integer;
begin
	for i:=1 to wide*2 do placestring(3,4+i,8,'-');
	placestring(4,6,8,'BitTetris V'+ver);
	for i:=1 to wide*2 do placestring(5,4+i,8,'-');
	placestring(7,7,8,'Choose a difficulty:');
	placestring(9,9,8,'1.Easy');
	placestring(11,9,8,'2.Normal');
	placestring(13,9,8,'3.Difficult');
	placestring(15,9,8,'4.Very Hard');
	placestring(17,9,8,'5.Extrem Hard');
	placestring(19,9,8,'6.Want To Die');
	for i:=1 to wide*2 do placestring(22,4+i,8,'-');
	placestring(23,6,8,'Press a key begin play');
	while true do begin
		key:=getkey;
		case key of
			161:begin
				life:=99;
				randlifea:=1;
				randlifeb:=10;
				break;
			end;
			49:begin
				life:=3;
				randlifea:=2;
				randlifeb:=5;
				break;
			end;
			50:begin
				life:=2;
				randlifea:=3;
				randlifeb:=4;
				break;
			end;
			51:begin
				life:=1;
				randlifea:=4;
				randlifeb:=3;
				break;
			end;
			52:begin
				life:=1;
				hardspeed:=30;
				speed:=30;
				randlifea:=5;
				randlifeb:=2;
				break;
			end;
			53:begin
				life:=0;
				hardspeed:=20;
				speed:=20;
				randlifea:=0;
				randlifeb:=0;
				break;
			end;
			54:begin
				life:=0;
				hardspeed:=10;
				speed:=10;
				randlifea:=0;
				randlifeb:=0;
				break;
			end;
		end;
	end;
	animi(1,50,7,blockwall);
	animi(-1,50,8,'  ');
end;

procedure initialize();
var i,j,k:integer;   
begin
	exec('cmd','/c mode con cols=46 lines=26');
	randomize;
	top:=high;
	flag:=true;
	score:=-1;
	blockback:='  ';
	level:=0;
	speed:=65;
	plugblock:=0;
	hardspeed:=0;
	blockhead:=7;
	countlines:=0;
	leveluplines:=20;
	State:='Playing';
	fillchar(map,sizeof(map),0);
	for k:=1 to 10 do begin
		for i:=1 to BlockN[k] do
			for j:=1 to BlockN[k] do
				block[k].a[i,j]:=BlockMod[k,i,j];
		block[k].n:=BlockN[k];
	end;
	for i:=1 to wide do map[high+1,i]:=1;
	makeblock();
	makeblock();
	drawframe();
	gettime(ts1,ts2,ts3,ts4);
	gettime(ta1,ta2,ta3,ta4);
end;


procedure welcome();
var i:integer;
begin
	for i:=1 to wide*2 do placestring(3,4+i,8,'-');
	placestring(4,6,8,'BitTetris V'+ver);
	for i:=1 to wide*2 do placestring(5,4+i,8,'-');
	placestring(6,6,8,'Control Keys:');
	placestring(7,6,8,'[Up] for rotate block ');
	placestring(8,6,8,'[Down] for speed up');
	placestring(9,6,8,'[Left/Right] move block');
	placestring(10,6,8,'[Space] for quick drop');
	placestring(11,6,8,'[0] to pause game.');
	placestring(12,6,8,'[Enter] consume a life ');
	placestring(13,8,8,'to clear some lines.');
	for i:=1 to wide*2 do placestring(15,4+i,8,'-');
	placestring(16,6,8,'Warning:');
	placestring(18,7,8,'Open [Caps-Lock" for ');
	placestring(19,7,8,'avoid game run error.');
	for i:=1 to wide*2 do placestring(22,4+i,8,'-');
	placestring(23,7,8,'Press Enter continue');
	pause;
	animi(-1,50,8,'  ');
end;

procedure gameover();
var i:integer;
begin
	placestring(22,wide*2+15,8,'Lost!');
	animi(1,50,7,blockwall);
	animi(-1,50,8,'  ');
	placestring(4,7,8,'Game Over');
	placestring(6,7,8,'Sorry! You lost this');
	placestring(7,7,8,'game.');
	placestring(9,7,8,'But please don`t give');
	placestring(10,7,8,'up.');
	if life>0 then begin
		placestring(12,7,8,'You have a chance to');
		placestring(13,7,8,'return game.');
		placestring(15,7,8,'But you must cost one');
		placestring(16,7,8,'life!');
		placestring(18,7,8,'Would you like to do:');
		placestring(20,7,8,'1.Yes,I would');
		placestring(21,7,8,'2.No,I want to replay');
		for i:=1 to wide*2-2 do placestring(22,5+i,8,'-');
		placestring(23,6,8,'Please select a choice');
		while true do begin
			key:=getkey;
			case key of
				49:begin
					animi(1,50,7,blockwall);
					animi(-1,50,8,'  ');
					top:=1;
					dec(life);
					printinfo;
					//placestring(22,wide*2+15,8,'Clear');
					autoclear(high*3 div 4);
					placestring(22,wide*2+15,8,'Play ');
					exit;
				end;
				50:break
			end;
		end;
	end else begin
		placestring(9,7,8,'But please don`t give');
		placestring(10,7,8,'up.');
		placestring(12,7,8,'You have tried your');
		placestring(13,7,8,'best.');
		placestring(15,7,8,'You still have chance');
		placestring(16,7,8,'to success!');
		for i:=1 to wide*2-2 do placestring(21,5+i,8,'-');
		placestring(22,7,8,'Please press Enter to');
		placestring(23,7,8,'try again.');
		pause;
	end;
	initialize();
	animi(1,50,7,blockwall);
	animi(-1,50,8,'  ');
	choosedifficulty;
end;

procedure win();
var i:integer;
begin
	placestring(22,wide*2+15,8,'WIN! ');
	animi(1,50,7,blockwall);
	animi(-1,50,8,'  ');
	placestring(4,7,8,'YOU WIN');
	placestring(6,7,8,'Congratulation! You');
	placestring(7,7,8,'win the game.');
	placestring(9,7,8,'ExtPlug has unlocked');
	placestring(11,7,8,'Press key [0] and [*] ');
	placestring(12,7,8,'to enter.');
	placestring(14,7,8,'Then you can change');
	placestring(15,7,8,'anything you want!');
	placestring(17,7,8,'Thank you for your');
	placestring(18,7,8,'support!');
	for i:=1 to wide*2-2 do placestring(22,5+i,8,'-');
	placestring(23,7,8,'Press Enter to reaply');
	pause;
	i:=score;
	initialize();
	score:=i;
	animi(-1,50,7,blockwall);
	animi(1,50,8,'  ');
end;

begin
	exec('cmd','/c chcp 437');
	exec('cmd','/c mode con cp select=936');
	cursoroff;
	exec('cmd','/c mode con cols=36 lines=11');
	exec('cmd','/c title BitTetris');
	placestring(1,1,8,'------------------------------------');
	placestring(2,12,8,'BitTetris V'+ver);
	placestring(3,1,8,'------------------------------------');
	placestring(4,5,8,' Press choose a display mode:');
	placestring(6,11,8,'1.Normal mode');
	placestring(8,11,8,'2.Colorful mode');
	placestring(10,1,8,'____________________________________');
	placestring(11,4,8,'By iBelieve   Email:ircr@qq.com');
	while true do begin
		key:=getkey;
		case key of
			49:begin
				assign(output,'CON');
				rewrite(output);
				blockchar:='¡ö';
				blockwall:='¡õ';
				blockcolor:=0;
				break;
			end;
			50:begin
				blockchar:='  ';
				blockwall:='  ';
				blockcolor:=1;
				break;
			end;
		end;
	end;
	
	
	initialize();
	welcome();
	
	choosedifficulty();
        while true do begin
		key:=336;
		if top<=0 then gameover;
		if countlines div leveluplines>level then begin
			level:=countlines div leveluplines;
			if level>11 then win else begin
				if speed>5 then speed:=65-5*level;
				if hardspeed>0 then begin
					if hardspeed>10 then hardspeed:=hardspeed-5;
					speed:=hardspeed;
				end;
				delay(500);
				levelup;
			end;
		end;
                while true do begin
			gettime(tb1,tb2,tb3,tb4);
			if  (caltime(ta1,ta2,ta3,ta4,tb1,tb2,tb3,tb4)>speed)and(flag) then begin
				counttime:=caltime(ts1,ts2,ts3,ts4,tb1,tb2,tb3,tb4) div 100;
				str(counttime mod 60,ts);
				counttime:=counttime div 60;
				str(counttime mod 60,tm);
				counttime:=counttime div 60;
				str(counttime mod 60,th);
				placestring(20,wide*2+14,8,'         ');
				placestring(20,wide*2+14,8,th+':'+tm+':'+ts);
				gettime(ta1,ta2,ta3,ta4);
				break;
			end else
                        if keypressed then begin
				key:=getkey;
				if key=48 then begin
					placestring(22,wide*2+15,8,'Pause');
					key2:=getkey;
					if key2=42 then begin
						animi(-1,50,7,blockwall);
						animi(-1,50,8,'  ');
						plug();
						animi(1,50,7,blockwall);
						animi(1,50,8,'  ');
					end;
					placestring(22,wide*2+15,8,'Play ');
				end else if (key=13)and(life>0) then begin
					dec(life);
					x:=random((high-top) div 2)+(high-top+1) div 3;
					if x<3 then x:=3;
					autoclear(x);
					break;
				end;
				break;
			end;
		end;
		if key=32 then begin
			while move(336,nowblock) do;
			placeblock(bx,by,nowblock);
			makeblock();
		end else if not(move(key,nowblock)) then begin
			placeblock(bx,by,nowblock);
			makeblock();
		end;
		clearline();
		printmap();
        end;
	while true do;
end.