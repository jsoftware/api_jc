NB. test script for api/jc addon

winbug=: 0 : 0
Windows bug(?)
 unlink/ferase fails (when it should work) on file after fd open/close
 manually delete file foo.txt in windows explorer
)

sclose_jc_ streams_jc_
close_jc_ files_jc_
fn=: 'foo.txt'
d=: 'testing'

3 : 0''
if. IFWIN *. (fexist fn) *. 0=unlink_jc_ :: 0: fn do. assert 0[echo winbug end.
)

unlink_jc_ :: 0: fn
s=: sopen_jc_  fn;'w+'
swrite_jc_ s;d
assert 7=stell_jc_ s
sseek_jc_ s,0
assert d-:sread_jc_ s;_1
sclose_jc_ s
unlink_jc_ fn
assert 0=unlink_jc_ :: 0: fn

f=: open_jc_  fn;'rdwr creat'
write_jc_ f;d
assert 7=tell_jc_ f
seek_jc_ f,0
assert d-:read_jc_ f;_1
close_jc_ f

3 : 0''
if. IFWIN do.
 r=. systemr_jc_'dir ',fn
else.
 r=. systemr_jc_'ls -l ',fn
end.
assert +./fn E. r
assert 0=status_jc_
)

(0=unlink_jc_ :: 0: fn)#winbug

assert 0~:system_jc_'asdfasdf'

j=: ((IFUNIX>'/'e.LIBFILE){::'/jconsole';'/ijconsole'),~jpath'~bin'
r=: '   'clean_jc_ j run_jc_ 'i.2 3 4',LF,'BINPATH',LF
assert' 0  1  2  3'-:>{.<;._2 r-.CR

3 : 0''
if. IFWIN do.
 echo'run task interactively not supported in windows'
else.
 j=: j conew 'jc'
 assert (i.5)-:".LF-.~dg__j'i.5'
end.
)
