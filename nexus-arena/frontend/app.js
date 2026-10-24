const $=s=>document.querySelector(s);
async function api(path,opt={}){const t=localStorage.getItem('token');
 const r=await fetch('/api'+path,{...opt,headers:{'Content-Type':'application/json',...(t?{Authorization:'Bearer '+t}:{})}});
 const d=await r.json().catch(()=>({}));if(!r.ok)throw new Error(d.error||'Request failed ('+r.status+')');return d}
function toast(m){const e=$('#toast');e.textContent=m;e.classList.add('show');setTimeout(()=>e.classList.remove('show'),2800)}
const post=(p,b)=>api(p,{method:'POST',body:JSON.stringify(b)});

// auth state in nav
const name=localStorage.getItem('username');
if(name&&$('#auth'))$('#auth').innerHTML=`<span>${name.replace(/[<>&]/g,'')}</span> | <a href="#" id="out">Log out</a>`;
$('#out')?.addEventListener('click',e=>{e.preventDefault();localStorage.clear();location.reload()});

// login page
if($('#authForm')){let reg=false;
 const mode=r=>{reg=r;$('#unWrap').hidden=!r;$('#ttl').textContent=r?'Create your account':'Log in to your account';$('#go').textContent=r?'Sign up':'Log in';
  $('#tLogin').className='btn'+(r?' out':'');$('#tReg').className='btn'+(r?'':' out')};
 $('#tLogin').onclick=()=>mode(false);$('#tReg').onclick=()=>mode(true);
 $('#authForm').onsubmit=async e=>{e.preventDefault();
  try{const d=await post(reg?'/auth/register':'/auth/login',{email:$('#em').value,username:$('#un').value,password:$('#pw').value});
   localStorage.setItem('token',d.token);localStorage.setItem('username',d.username);location.href='/'}catch(x){toast(x.message)}}}

// home page
if($('#joinForm')){
 const loadQueue=async()=>{try{$('#qcount').textContent=(await api('/matchmaking/queue')).length}catch{}};
 const loadLb=async()=>{try{const s=(await api('/leaderboard/scores')).sort((a,b)=>b.score-a.score).slice(0,10);
  $('#lb').innerHTML=s.map((x,i)=>`<tr><td>${i+1}</td><td></td><td>${x.score}</td></tr>`).join('');
  [...$('#lb').rows].forEach((r,i)=>r.cells[1].textContent=s[i].team);$('#lbEmpty').hidden=s.length>0}catch{}};
 const loadChat=async()=>{try{const m=(await api('/chat/messages')).slice(-30);const box=$('#msgs');box.innerHTML='';
  m.forEach(x=>{const p=document.createElement('p'),b=document.createElement('b');b.textContent=(x.user||'guest')+': ';p.append(b,x.text||'');box.append(p)});box.scrollTop=box.scrollHeight}catch{}};
 $('#joinForm').onsubmit=async e=>{e.preventDefault();
  try{const team=$('#team').value;await post('/matchmaking/queue',{team,email:$('#email').value,category:$('#cat').value});
   await post('/leaderboard/scores',{team,score:0});toast('You are in the queue');e.target.reset();loadQueue();loadLb()}catch(x){toast(x.message)}};
 $('#send').onclick=async()=>{const t=$('#msg').value.trim();if(!t)return;
  try{await post('/chat/messages',{user:localStorage.getItem('username')||'guest',text:t});$('#msg').value='';loadChat()}catch(x){toast(x.message)}};
 loadQueue();loadLb();loadChat();setInterval(()=>{loadQueue();loadChat()},5000)}
