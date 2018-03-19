coclass'jc' NB. see man page
jsystemdefs'hostdefs'
coinsert 'jdefs'

manfile=: '~addons/api/jc/man.txt'

3 : 0''
if. _1=nc<'streams' do. files=: streams=: '' end.
)

libc=: ' ',~>(-.UNAME-:'Win'){'msvcrt';unxlib'c'
U=: IFWIN#'_' NB. windows prefix for some names

sopen=: 3 : 0
y=. ,each y
y=. (<hpath>{.y) 0}y
r=. (libc,' fopen > x *c *c')cd y
chk r~:0
addstream r
)

sclose=: 3 : 0 "0
es y
chk 0=(libc,' fclose > i x')cd y
streams_jc_=: streams_jc_-.y
i.0 0
)

swrite=: 3 : 0
's d'=: y
d=. ,d
es s
'fwrite did not write all data' assert (#d)=(libc,' fwrite > x *c x x x')cd d;1;(#d);s
)

NB. y is count of bytes to read -_1 read till no more data
sread=: 3 : 0
's a'=: y
es s
if. _1=a do.
 d=. ''
 while. 0~:#n=.sread s;50000 do.
  d=. d,n
 end. 
else.
 r=. (libc,' fread x *c x x x')cd (a$' ');1;a;s
 (>{.r){.>1{r
end. 
)

stell=: 3 : 0
es y
chk _1~:r=. (libc,' ftell > x x')cd y
r
)

sseek=: 3 : 0
's a'=. y
es s
chk 0=(libc,' fseek > x x x x')cd s;a;0 NB. SEEK_SET hardwired as 0
)

NB. file section

open=: 3 : 0
y=. ,each y
y=. (<hpath>{.y) 0}y
'n b'=. y
b=. (<'O_'),each ;:toupper b
'bad flags'assert 0=nc b
b=. OR >".each b
r=. (libc,U,'open > i *c i')cd n;b
chk r~:_1
addfile r
)

close=: 3 : 0 "0
ef y
chk 0=(libc,U,'close > i i')cd y
files=: files-.y
i.0 0
)

write=: 3 : 0
'f d'=: y
d=. ,d
ef f
'write did not write all data' assert (#d)=(libc,U,'write > x i *c x')cd f;d;#d
)

read=: 3 : 0
'f a'=: y
ef f
if. _1=a do.
 d=. ''
 while. 0~:#n=.read f,50000 do.
  d=. d,n
 end. 
else.
 r=. (libc,U,'read x i *c x')cd f;(a$' ');a
 (>{.r){.>2{r
end. 
)

seeksub=: 3 : 0
'f n whence'=: y
ef f
chk _1~:(libc,U,'lseek',(IFWIN#'i64'),' > x i x i')cd f;n;whence
)

seek=: 3 : 'seeksub y,SEEK_SET'

tell=: 3 : 'seeksub y,0,SEEK_CUR'

system=: 3 : 0
status_jc_=: (libc,' system > x *c')cd <y,~IFWIN#'cmd /s /c'
)

systemr=: 3 : 0
p=. temppath''
system y,' > "',p,'rout','" 2>&1'
fread p,'rout'
)

NB. both

unlink=: 3 : 0
if. IFWIN do.
 chk 0=(libc,' _unlink > i *c')cd <hpath ,y
else. 
 chk 0=(libc,' unlink > i *c')cd <hpath ,y
end. 
)

NB. task with stdin/stdout
run=: 4 : 0
p=.    temppath''
pin=.  hpath p,'in'
pout=. hpath p,'out'
if. 1=L.y do. y=. ;y,each LF end.
y fwrite pin
system '"<CMD>" < "<PIN>" > "<POUT>"'rplc '<PIN>';pin;'<POUT>';pout;'<CMD>';hpath x
fread pout
)

NB. task with interactive stdin/stdout
NB. not in windows because no tail
tailpids=: 3 : 0
t=. dlb each}.<;._2[systemr'ps -C tail'
t=. >0".each(t i.each' '){.each t
)

create=: 3 : 0
'not supported in windows - no tail'assert -.UNAME-:'Win'
cmd=: y
path=: temppath''
pout=:   path,'out'
pin=:    path,'in'
sclose   sopen pin;'w'
sout=:   sopen pout;'w+'
pids=. tailpids''
system 'tail -f "<PIN>" | "<CMD>" > "<POUT>" 2>&1 &' rplc '<PIN>';pin;'<POUT>';pout;'<CMD>';cmd
pid=: pids-.~tailpids''
'no pid (task failed) or too many pids)'assert 1=#pid
)

destroy=: 3 : 0
system'kill ',":pid
rmdir_j_ path 
codestroy''
)

do=: 3 : 0
pos=: stell sout
sin=: sopen pin;'a+'
swrite sin;y,LF
sclose sin
)

dg=: 3 : 0
do y
gt 5
)

NB. programs (bash/powershell/j/...) do not write input lines to stdout
NB. stdout is the record of output and not of the session
NB. prompts are written to stdout and this can mess things up
gt=: 3 : 0
t=. >(2=3!:0 y){y;0
while. (t>0)*.pos=stell sout do. t=. t-0.01 [ 6!:3[0.01 end.
sseek sout,pos
r=. sread sout,_1
pos=: pos+#r
r
)

NB. replace prompts with LFs - not always right, but improves most output
clean=: 4 : 0
y=. ((x-:(#x){.y){0,#x)}.y NB. remove prompt at start
y=. y rplc (LF,x);2#LF     NB. replace prompt with LFs
)

NB. utils

lasterrnotxt=: 3 : 0
'errno: ',memr((libc,' strerror > x i')cd >{.cderx''),0,_1
)

chk=: 3 : 0
if. -.y do. 0 assert~ lasterrnotxt'' end.
)

hpath=: hostpathsep@jpath

temppath=: 3 : 0
p=. (jpath'~temp/jc/'),(":2!:6''),'/',(>coname''),'/'
mkdir_j_ p
hostpathsep p
)

OR=: $:/ :(23 b.)

es=: 3 : '''not a stream''assert y e. streams'
ef=: 3 : '''not a file''  assert y e. files'

addstream=: 3 : 'y[streams_jc_=: y,streams_jc_-.y'
remstream=: 3 : 'streams_jc_=: streams_jc_-.y'
addfile=:   3 : 'y[files_jc_=: y,files_jc_-.y'
remfile=:   3 : 'files_jc_=: files_jc_-.y'

NB. experimental man

man_z_=: 3 : 0
if.''-:y do. 'man''jc''   NB. jc locale',LF,'man''jc ''  NB. sections',LF,'man''jc 2'' NB. section 2' return. end.
i=. y i. ' '
a=. i{.y
q=. i}.y
d=. fread ('manfile_',a,'_')~
if. 0=#q do. d return. end.
d=. <;.2 d
b=. '+'=>{.each d
if. q-:,' ' do.
 ;(":each<"0 i.+/b),each' ',each b#d
else.
 ss=. (0 1+0".q){(b#i.#d),#d
 ;({.ss)}.({:ss){.d
end.
)
