// Bound negative proof experiments without changing the proof/kernel budget.
// Resource stops remain infrastructure errors, never useful mutation rejections.
import {spawn} from 'node:child_process';
import fs from 'node:fs';
function groupRss(group){
 if(process.platform!=='linux')return 0;
 let bytes=0;
 for(const pid of fs.readdirSync('/proc')){
  if(!/^\d+$/.test(pid))continue;
  try{
   const stat=fs.readFileSync('/proc/'+pid+'/stat','utf8'),fields=stat.slice(stat.lastIndexOf(')')+2).split(' ');
   if(Number(fields[2])!==group)continue;
   const rss=fs.readFileSync('/proc/'+pid+'/status','utf8').match(/^VmRSS:\s+(\d+)\s+kB/m);
   if(rss)bytes+=Number(rss[1])*1024;
  }catch{} // A child can exit between the process list and either read.
 }
 return bytes;
}
export async function proofProcess(command,args,{cwd,env,timeout=90000,maxBuffer=1024*1024,maxRss=4*1024**3}={}){
 return await new Promise(resolve=>{
  const child=spawn(command,args,{cwd,env,detached:process.platform!=='win32'});
  let stdout='',stderr='',bytes=0,error;
  const stop=reason=>{
   if(error)return;error=new Error(reason);
   try{if(process.platform==='win32')child.kill('SIGKILL');else process.kill(-child.pid,'SIGKILL');}catch{}
  };
  const read=kind=>chunk=>{
   bytes+=chunk.length;
   if(bytes>maxBuffer){stop('proof output limit');return;}
   if(kind==='stdout')stdout+=chunk;else stderr+=chunk;
  };
  child.stdout.on('data',read('stdout'));child.stderr.on('data',read('stderr'));
  child.on('error',reason=>{error=reason;});
  const timer=setTimeout(()=>stop('proof timeout'),timeout);
  const memory=setInterval(()=>{if(child.pid&&groupRss(child.pid)>maxRss)stop('proof process-group RSS limit');},200);
  child.on('close',(status,signal)=>{clearTimeout(timer);clearInterval(memory);resolve({status,signal,error,stdout,stderr});});
 });
}
