(function dartProgram(){function copyProperties(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
b[q]=a[q]}}function mixinPropertiesHard(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
if(!b.hasOwnProperty(q)){b[q]=a[q]}}}function mixinPropertiesEasy(a,b){Object.assign(b,a)}var z=function(){var s=function(){}
s.prototype={p:{}}
var r=new s()
if(!(Object.getPrototypeOf(r)&&Object.getPrototypeOf(r).p===s.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var q=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(q))return true}}catch(p){}return false}()
function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){Object.setPrototypeOf(a.prototype,b.prototype)
return}var s=Object.create(b.prototype)
copyProperties(a.prototype,s)
a.prototype=s}}function inheritMany(a,b){for(var s=0;s<b.length;s++){inherit(b[s],a)}}function mixinEasy(a,b){mixinPropertiesEasy(b.prototype,a.prototype)
a.prototype.constructor=a}function mixinHard(a,b){mixinPropertiesHard(b.prototype,a.prototype)
a.prototype.constructor=a}function lazy(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){a[b]=d()}a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){var r=d()
if(a[b]!==s){A.cD(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a){a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.hJ(b)
return new s(c,this)}:function(){if(s===null)s=A.hJ(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.hJ(a).prototype
return s}}var x=0
function tearOffParameters(a,b,c,d,e,f,g,h,i,j){if(typeof h=="number"){h+=x}return{co:a,iS:b,iI:c,rC:d,dV:e,cs:f,fs:g,fT:h,aI:i||0,nDA:j}}function installStaticTearOff(a,b,c,d,e,f,g,h){var s=tearOffParameters(a,true,false,c,d,e,f,g,h,false)
var r=staticTearOffGetter(s)
a[b]=r}function installInstanceTearOff(a,b,c,d,e,f,g,h,i,j){c=!!c
var s=tearOffParameters(a,false,c,d,e,f,g,h,i,!!j)
var r=instanceTearOffGetter(c,s)
a[b]=r}function setOrUpdateInterceptorsByTag(a){var s=v.interceptorsByTag
if(!s){v.interceptorsByTag=a
return}copyProperties(a,s)}function setOrUpdateLeafTags(a){var s=v.leafTags
if(!s){v.leafTags=a
return}copyProperties(a,s)}function updateTypes(a){var s=v.types
var r=s.length
s.push.apply(s,a)
return r}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var s=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e,false)}},r=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixinEasy,mixinHard:mixinHard,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:s(0,0,null,["$0"],0),_instance_1u:s(0,1,null,["$1"],0),_instance_2u:s(0,2,null,["$2"],0),_instance_0i:s(1,0,null,["$0"],0),_instance_1i:s(1,1,null,["$1"],0),_instance_2i:s(1,2,null,["$2"],0),_static_0:r(0,null,["$0"],0),_static_1:r(1,null,["$1"],0),_static_2:r(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,updateHolder:updateHolder,convertToFastObject:convertToFastObject,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}var J={
hP(a,b,c,d){return{i:a,p:b,e:c,x:d}},
fT(a){var s,r,q,p,o,n=a[v.dispatchPropertyName]
if(n==null)if($.hM==null){A.m3()
n=a[v.dispatchPropertyName]}if(n!=null){s=n.p
if(!1===s)return n.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return n.i
if(n.e===r)throw A.d(A.hr("Return interceptor for "+A.n(s(a,n))))}q=a.constructor
if(q==null)p=null
else{o=$.fw
if(o==null)o=$.fw=v.getIsolateTag("_$dart_js")
p=q[o]}if(p!=null)return p
p=A.m7(a)
if(p!=null)return p
if(typeof a=="function")return B.aq
s=Object.getPrototypeOf(a)
if(s==null)return B.Z
if(s===Object.prototype)return B.Z
if(typeof q=="function"){o=$.fw
if(o==null)o=$.fw=v.getIsolateTag("_$dart_js")
Object.defineProperty(q,o,{value:B.M,enumerable:false,writable:true,configurable:true})
return B.M}return B.M},
i7(a,b){if(a<0||a>4294967295)throw A.d(A.a1(a,0,4294967295,"length",null))
return J.k8(new Array(a),b)},
i8(a,b){if(a<0)throw A.d(A.a_("Length must be a non-negative integer: "+a,null))
return A.b(new Array(a),b.h("o<0>"))},
k8(a,b){var s=A.b(a,b.h("o<0>"))
s.$flags=1
return s},
b2(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.bI.prototype
return J.cU.prototype}if(typeof a=="string")return J.ba.prototype
if(a==null)return J.bJ.prototype
if(typeof a=="boolean")return J.bG.prototype
if(Array.isArray(a))return J.o.prototype
if(typeof a!="object"){if(typeof a=="function")return J.B.prototype
if(typeof a=="symbol")return J.bc.prototype
if(typeof a=="bigint")return J.bb.prototype
return a}if(a instanceof A.e)return a
return J.fT(a)},
b3(a){if(typeof a=="string")return J.ba.prototype
if(a==null)return a
if(Array.isArray(a))return J.o.prototype
if(typeof a!="object"){if(typeof a=="function")return J.B.prototype
if(typeof a=="symbol")return J.bc.prototype
if(typeof a=="bigint")return J.bb.prototype
return a}if(a instanceof A.e)return a
return J.fT(a)},
b4(a){if(a==null)return a
if(Array.isArray(a))return J.o.prototype
if(typeof a!="object"){if(typeof a=="function")return J.B.prototype
if(typeof a=="symbol")return J.bc.prototype
if(typeof a=="bigint")return J.bb.prototype
return a}if(a instanceof A.e)return a
return J.fT(a)},
j8(a){if(a==null)return a
if(typeof a!="object"){if(typeof a=="function")return J.B.prototype
if(typeof a=="symbol")return J.bc.prototype
if(typeof a=="bigint")return J.bb.prototype
return a}if(a instanceof A.e)return a
return J.fT(a)},
h5(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.b2(a).X(a,b)},
jD(a,b){if(typeof b==="number")if(Array.isArray(a)||typeof a=="string"||A.m6(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.b3(a).j(a,b)},
hU(a,b){return J.b4(a).m(a,b)},
jE(a){return J.j8(a).bT(a)},
jF(a,b,c){return J.j8(a).bU(a,b,c)},
h6(a,b){return J.b4(a).E(a,b)},
ao(a){return J.b2(a).gv(a)},
aQ(a){return J.b4(a).gA(a)},
ai(a){return J.b3(a).gn(a)},
jG(a){return J.b2(a).gB(a)},
dx(a,b,c){return J.b4(a).ab(a,b,c)},
jH(a,b){return J.b4(a).cf(a,b)},
jI(a,b){return J.b4(a).c2(a,b)},
Z(a){return J.b2(a).i(a)},
cT:function cT(){},
bG:function bG(){},
bJ:function bJ(){},
z:function z(){},
aJ:function aJ(){},
da:function da(){},
c9:function c9(){},
B:function B(){},
bb:function bb(){},
bc:function bc(){},
o:function o(a){this.$ti=a},
en:function en(a){this.$ti=a},
bu:function bu(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
bK:function bK(){},
bI:function bI(){},
cU:function cU(){},
ba:function ba(){}},A={hh:function hh(){},
kf(a){return new A.bN("Field '"+a+"' has been assigned during initialization.")},
aM(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
hp(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
cB(a,b,c){return a},
hN(a){var s,r
for(s=$.a2.length,r=0;r<s;++r)if(a===$.a2[r])return!0
return!1},
ho(a,b,c,d){A.db(b,"start")
if(c!=null){A.db(c,"end")
if(b>c)A.X(A.a1(b,0,c,"start",null))}return new A.c4(a,b,c,d.h("c4<0>"))},
id(a,b,c,d){if(t.V.b(a))return new A.bB(a,b,c.h("@<0>").u(d).h("bB<1,2>"))
return new A.au(a,b,c.h("@<0>").u(d).h("au<1,2>"))},
i5(){return new A.bh("No element")},
bj:function bj(){},
bx:function bx(a,b){this.a=a
this.$ti=b},
ch:function ch(){},
ap:function ap(a,b){this.a=a
this.$ti=b},
bN:function bN(a){this.a=a},
eJ:function eJ(){},
l:function l(){},
F:function F(){},
c4:function c4(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
aV:function aV(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
au:function au(a,b,c){this.a=a
this.b=b
this.$ti=c},
bB:function bB(a,b,c){this.a=a
this.b=b
this.$ti=c},
bR:function bR(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
U:function U(a,b,c){this.a=a
this.b=b
this.$ti=c},
cc:function cc(a,b,c){this.a=a
this.b=b
this.$ti=c},
cd:function cd(a,b,c){this.a=a
this.b=b
this.$ti=c},
aR:function aR(a){this.$ti=a},
bC:function bC(a){this.$ti=a},
Q:function Q(){},
c0:function c0(a,b){this.a=a
this.$ti=b},
cx:function cx(){},
jf(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
m6(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.aU.b(a)},
n(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.Z(a)
return s},
bZ(a){var s,r=$.ii
if(r==null)r=$.ii=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
eC(a){var s,r,q,p
if(a instanceof A.e)return A.W(A.b5(a),null)
s=J.b2(a)
if(s===B.al||s===B.ar||t.ak.b(a)){r=B.O(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.W(A.b5(a),null)},
ku(a){if(a==null||typeof a=="number"||A.fL(a))return J.Z(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.aF)return a.i(0)
if(a instanceof A.cp)return a.eF(!0)
return"Instance of '"+A.eC(a)+"'"},
ih(a){var s,r,q,p,o=a.length
if(o<=500)return String.fromCharCode.apply(null,a)
for(s="",r=0;r<o;r=q){q=r+500
p=q<o?q:o
s+=String.fromCharCode.apply(null,a.slice(r,p))}return s},
kv(a){var s,r,q,p=A.b([],t.t)
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.am)(a),++r){q=a[r]
if(!A.fM(q))throw A.d(A.cA(q))
if(q<=65535)B.a.m(p,q)
else if(q<=1114111){B.a.m(p,55296+(B.b.a3(q-65536,10)&1023))
B.a.m(p,56320+(q&1023))}else throw A.d(A.cA(q))}return A.ih(p)},
ij(a){var s,r,q
for(s=a.length,r=0;r<s;++r){q=a[r]
if(!A.fM(q))throw A.d(A.cA(q))
if(q<0)throw A.d(A.cA(q))
if(q>65535)return A.kv(a)}return A.ih(a)},
kw(a,b,c){var s,r,q,p
if(c<=500&&b===0&&c===a.length)return String.fromCharCode.apply(null,a)
for(s=b,r="";s<c;s=q){q=s+500
p=q<c?q:c
r+=String.fromCharCode.apply(null,a.subarray(s,p))}return r},
aX(a){var s
if(0<=a){if(a<=65535)return String.fromCharCode(a)
if(a<=1114111){s=a-65536
return String.fromCharCode((B.b.a3(s,10)|55296)>>>0,s&1023|56320)}}throw A.d(A.a1(a,0,1114111,null,null))},
bf(a){if(a.date===void 0)a.date=new Date(a.a)
return a.date},
kt(a){var s=A.bf(a).getUTCFullYear()+0
return s},
kr(a){var s=A.bf(a).getUTCMonth()+1
return s},
kn(a){var s=A.bf(a).getUTCDate()+0
return s},
ko(a){var s=A.bf(a).getUTCHours()+0
return s},
kq(a){var s=A.bf(a).getUTCMinutes()+0
return s},
ks(a){var s=A.bf(a).getUTCSeconds()+0
return s},
kp(a){var s=A.bf(a).getUTCMilliseconds()+0
return s},
km(a){var s=a.$thrownJsError
if(s==null)return null
return A.aO(s)},
ik(a,b){var s
if(a.$thrownJsError==null){s=new Error()
A.I(a,s)
a.$thrownJsError=s
s.stack=b.i(0)}},
a(a,b){if(a==null)J.ai(a)
throw A.d(A.fR(a,b))},
fR(a,b){var s,r="index"
if(!A.fM(b))return new A.a7(!0,b,r,null)
s=J.ai(a)
if(b<0||b>=s)return A.hd(b,s,a,r)
return new A.bg(null,null,!0,b,r,"Value not in range")},
lX(a,b,c){if(a>c)return A.a1(a,0,c,"start",null)
if(b!=null)if(b<a||b>c)return A.a1(b,a,c,"end",null)
return new A.a7(!0,b,"end",null)},
cA(a){return new A.a7(!0,a,null,null)},
d(a){return A.I(a,new Error())},
I(a,b){var s
if(a==null)a=new A.aw()
b.dartException=a
s=A.mb
if("defineProperty" in Object){Object.defineProperty(b,"message",{get:s})
b.name=""}else b.toString=s
return b},
mb(){return J.Z(this.dartException)},
X(a,b){throw A.I(a,b==null?new Error():b)},
v(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.X(A.lk(a,b,c),s)},
lk(a,b,c){var s,r,q,p,o,n,m,l,k
if(typeof b=="string")s=b
else{r="[]=;add;removeWhere;retainWhere;removeRange;setRange;setInt8;setInt16;setInt32;setUint8;setUint16;setUint32;setFloat32;setFloat64".split(";")
q=r.length
p=b
if(p>q){c=p/q|0
p%=q}s=r[p]}o=typeof c=="string"?c:"modify;remove from;add to".split(";")[c]
n=t.j.b(a)?"list":"ByteData"
m=a.$flags|0
l="a "
if((m&4)!==0)k="constant "
else if((m&2)!==0){k="unmodifiable "
l="an "}else k=(m&1)!==0?"fixed-length ":""
return new A.ca("'"+s+"': Cannot "+o+" "+l+k+n)},
am(a){throw A.d(A.a8(a))},
ax(a){var s,r,q,p,o,n
a=A.je(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.b([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.eT(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
eU(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
it(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
hi(a,b){var s=b==null,r=s?null:b.method
return new A.cX(a,r,s?null:b.receiver)},
an(a){var s
if(a==null)return new A.eA(a)
if(a instanceof A.bE){s=a.a
return A.aP(a,s==null?t.K.a(s):s)}if(typeof a!=="object")return a
if("dartException" in a)return A.aP(a,a.dartException)
return A.lO(a)},
aP(a,b){if(t.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
lO(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.b.a3(r,16)&8191)===10)switch(q){case 438:return A.aP(a,A.hi(A.n(s)+" (Error "+q+")",null))
case 445:case 5007:A.n(s)
return A.aP(a,new A.bY())}}if(a instanceof TypeError){p=$.jm()
o=$.jn()
n=$.jo()
m=$.jp()
l=$.js()
k=$.jt()
j=$.jr()
$.jq()
i=$.jv()
h=$.ju()
g=p.U(s)
if(g!=null)return A.aP(a,A.hi(A.k(s),g))
else{g=o.U(s)
if(g!=null){g.method="call"
return A.aP(a,A.hi(A.k(s),g))}else if(n.U(s)!=null||m.U(s)!=null||l.U(s)!=null||k.U(s)!=null||j.U(s)!=null||m.U(s)!=null||i.U(s)!=null||h.U(s)!=null){A.k(s)
return A.aP(a,new A.bY())}}return A.aP(a,new A.dg(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.c2()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.aP(a,new A.a7(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.c2()
return a},
aO(a){var s
if(a instanceof A.bE)return a.b
if(a==null)return new A.cq(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.cq(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
dw(a){if(a==null)return J.ao(a)
if(typeof a=="object")return A.bZ(a)
return J.ao(a)},
lT(a){if(typeof a=="number")return B.ao.gv(a)
if(a instanceof A.ds)return A.bZ(a)
if(a instanceof A.cp)return a.gv(a)
return A.dw(a)},
j7(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.k(0,a[s],a[r])}return b},
lu(a,b,c,d,e,f){t.Z.a(a)
switch(A.ab(b)){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.d(new A.fi("Unsupported number of arguments for wrapped closure"))},
cC(a,b){var s=a.$identity
if(!!s)return s
s=A.lU(a,b)
a.$identity=s
return s},
lU(a,b){var s
switch(b){case 0:s=a.$0
break
case 1:s=a.$1
break
case 2:s=a.$2
break
case 3:s=a.$3
break
case 4:s=a.$4
break
default:s=null}if(s!=null)return s.bind(a)
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.lu)},
jW(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.dd().constructor.prototype):Object.create(new A.b9(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.i2(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.jS(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.i2(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
jS(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.d("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.jO)}throw A.d("Error in functionType of tearoff")},
jT(a,b,c,d){var s=A.i0
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
i2(a,b,c,d){if(c)return A.jV(a,b,d)
return A.jT(b.length,d,a,b)},
jU(a,b,c,d){var s=A.i0,r=A.jP
switch(b?-1:a){case 0:throw A.d(new A.dc("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
jV(a,b,c){var s,r
if($.hZ==null)$.hZ=A.hY("interceptor")
if($.i_==null)$.i_=A.hY("receiver")
s=b.length
r=A.jU(s,c,a,b)
return r},
hJ(a){return A.jW(a)},
jO(a,b){return A.cv(v.typeUniverse,A.b5(a.a),b)},
i0(a){return a.a},
jP(a){return a.b},
hY(a){var s,r,q,p=new A.b9("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.d(A.a_("Field name "+a+" not found.",null))},
m_(a){return v.getIsolateTag(a)},
lV(a){var s,r=A.b([],t.s)
if(a==null)return r
if(Array.isArray(a)){for(s=0;s<a.length;++s)r.push(String(a[s]))
return r}r.push(String(a))
return r},
mJ(a,b,c){Object.defineProperty(a,b,{value:c,enumerable:false,writable:true,configurable:true})},
m7(a){var s,r,q,p,o,n=A.k($.j9.$1(a)),m=$.fS[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.fX[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=A.E($.j4.$2(a,n))
if(q!=null){m=$.fS[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.fX[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.h0(s)
$.fS[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.fX[n]=s
return s}if(p==="-"){o=A.h0(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.jb(a,s)
if(p==="*")throw A.d(A.hr(n))
if(v.leafTags[n]===true){o=A.h0(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.jb(a,s)},
jb(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.hP(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
h0(a){return J.hP(a,!1,null,!!a.$ia0)},
m9(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.h0(s)
else return J.hP(s,c,null,null)},
m3(){if(!0===$.hM)return
$.hM=!0
A.m4()},
m4(){var s,r,q,p,o,n,m,l
$.fS=Object.create(null)
$.fX=Object.create(null)
A.m2()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.jd.$1(o)
if(n!=null){m=A.m9(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
m2(){var s,r,q,p,o,n,m=B.ac()
m=A.bp(B.ad,A.bp(B.ae,A.bp(B.P,A.bp(B.P,A.bp(B.af,A.bp(B.ag,A.bp(B.ah(B.O),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.j9=new A.fU(p)
$.j4=new A.fV(o)
$.jd=new A.fW(n)},
bp(a,b){return a(b)||b},
lW(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
kd(a,b,c,d,e,f){var s=b?"m":"",r=c?"":"i",q=d?"u":"",p=e?"s":"",o=function(g,h){try{return new RegExp(g,h)}catch(n){return n}}(a,s+r+q+p+f)
if(o instanceof RegExp)return o
throw A.d(A.hc("Illegal RegExp pattern ("+String(o)+")",a,null))},
lY(a){if(a.indexOf("$",0)>=0)return a.replace(/\$/g,"$$$$")
return a},
je(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
br(a,b,c){var s=A.ma(a,b,c)
return s},
ma(a,b,c){var s,r,q
if(b===""){if(a==="")return c
s=a.length
r=""+c
for(q=0;q<s;++q)r=r+a[q]+c
return r.charCodeAt(0)==0?r:r}if(a.indexOf(b,0)<0)return a
if(a.length<500||c.indexOf("$",0)>=0)return a.split(b).join(c)
return a.replace(new RegExp(A.je(b),"g"),A.lY(c))},
bz:function bz(){},
bF:function bF(a,b){this.a=a
this.$ti=b},
eT:function eT(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
bY:function bY(){},
cX:function cX(a,b,c){this.a=a
this.b=b
this.c=c},
dg:function dg(a){this.a=a},
eA:function eA(a){this.a=a},
bE:function bE(a,b){this.a=a
this.b=b},
cq:function cq(a){this.a=a
this.b=null},
aF:function aF(){},
cI:function cI(){},
cJ:function cJ(){},
de:function de(){},
dd:function dd(){},
b9:function b9(a,b){this.a=a
this.b=b},
dc:function dc(a){this.a=a},
aq:function aq(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
ew:function ew(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
aU:function aU(a,b){this.a=a
this.$ti=b},
bP:function bP(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
as:function as(a,b){this.a=a
this.$ti=b},
bO:function bO(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
bM:function bM(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
fU:function fU(a){this.a=a},
fV:function fV(a){this.a=a},
fW:function fW(a){this.a=a},
cp:function cp(){},
cW:function cW(a,b){var _=this
_.a=a
_.b=b
_.e=_.d=_.c=null},
cD(a){throw A.I(A.kf(a),new Error())},
fg(a){var s=new A.ff(a)
return s.b=s},
ff:function ff(a){this.a=a
this.b=null},
li(a){return a},
fK(a,b,c){},
kj(a,b,c){var s
A.fK(a,b,c)
s=new DataView(a,b)
return s},
ie(a){return new Uint8Array(a)},
kk(a,b,c){var s
A.fK(a,b,c)
s=new Uint8Array(a,b,c)
return s},
b_(a,b,c){if(a>>>0!==a||a>=c)throw A.d(A.fR(b,a))},
lj(a,b,c){var s
if(!(a>>>0!==a))s=b>>>0!==b||a>b||b>c
else s=!0
if(s)throw A.d(A.lX(a,b,c))
return b},
bS:function bS(){},
bW:function bW(){},
dt:function dt(a){this.a=a},
bT:function bT(){},
bd:function bd(){},
bU:function bU(){},
bV:function bV(){},
d_:function d_(){},
d0:function d0(){},
d1:function d1(){},
d2:function d2(){},
d3:function d3(){},
d4:function d4(){},
d5:function d5(){},
bX:function bX(){},
aW:function aW(){},
cl:function cl(){},
cm:function cm(){},
cn:function cn(){},
co:function co(){},
hm(a,b){var s=b.c
return s==null?b.c=A.ct(a,"L",[b.x]):s},
im(a){var s=a.w
if(s===6||s===7)return A.im(a.x)
return s===11||s===12},
kz(a){return a.as},
aD(a){return A.fC(v.typeUniverse,a,!1)},
b0(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.b0(a1,s,a3,a4)
if(r===s)return a2
return A.iN(a1,r,!0)
case 7:s=a2.x
r=A.b0(a1,s,a3,a4)
if(r===s)return a2
return A.iM(a1,r,!0)
case 8:q=a2.y
p=A.bo(a1,q,a3,a4)
if(p===q)return a2
return A.ct(a1,a2.x,p)
case 9:o=a2.x
n=A.b0(a1,o,a3,a4)
m=a2.y
l=A.bo(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.hB(a1,n,l)
case 10:k=a2.x
j=a2.y
i=A.bo(a1,j,a3,a4)
if(i===j)return a2
return A.iO(a1,k,i)
case 11:h=a2.x
g=A.b0(a1,h,a3,a4)
f=a2.y
e=A.lL(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.iL(a1,g,e)
case 12:d=a2.y
a4+=d.length
c=A.bo(a1,d,a3,a4)
o=a2.x
n=A.b0(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.hC(a1,n,c,!0)
case 13:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.d(A.cG("Attempted to substitute unexpected RTI kind "+a0))}},
bo(a,b,c,d){var s,r,q,p,o=b.length,n=A.fH(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.b0(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
lM(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.fH(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.b0(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
lL(a,b,c,d){var s,r=b.a,q=A.bo(a,r,c,d),p=b.b,o=A.bo(a,p,c,d),n=b.c,m=A.lM(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.dn()
s.a=q
s.b=o
s.c=m
return s},
b(a,b){a[v.arrayRti]=b
return a},
j6(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.m1(s)
return a.$S()}return null},
m5(a,b){var s
if(A.im(b))if(a instanceof A.aF){s=A.j6(a)
if(s!=null)return s}return A.b5(a)},
b5(a){if(a instanceof A.e)return A.K(a)
if(Array.isArray(a))return A.V(a)
return A.hF(J.b2(a))},
V(a){var s=a[v.arrayRti],r=t.b
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
K(a){var s=a.$ti
return s!=null?s:A.hF(a)},
hF(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.lr(a,s)},
lr(a,b){var s=a instanceof A.aF?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.l1(v.typeUniverse,s.name)
b.$ccache=r
return r},
m1(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.fC(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
hL(a){return A.b1(A.K(a))},
hI(a){var s
if(a instanceof A.cp)return A.lZ(a.$r,a.eE())
s=a instanceof A.aF?A.j6(a):null
if(s!=null)return s
if(t.dm.b(a))return J.jG(a).a
if(Array.isArray(a))return A.V(a)
return A.b5(a)},
b1(a){var s=a.r
return s==null?a.r=new A.ds(a):s},
lZ(a,b){var s,r,q=b,p=q.length
if(p===0)return t.bQ
if(0>=p)return A.a(q,0)
s=A.cv(v.typeUniverse,A.hI(q[0]),"@<0>")
for(r=1;r<p;++r){if(!(r<q.length))return A.a(q,r)
s=A.iP(v.typeUniverse,s,A.hI(q[r]))}return A.cv(v.typeUniverse,s,a)},
ah(a){return A.b1(A.fC(v.typeUniverse,a,!1))},
lq(a){var s,r,q,p,o=this
if(o===t.K)return A.aC(o,a,A.lz)
if(A.b6(o))return A.aC(o,a,A.lD)
s=o.w
if(s===6)return A.aC(o,a,A.lo)
if(s===1)return A.aC(o,a,A.iY)
if(s===7)return A.aC(o,a,A.lv)
if(o===t.S)r=A.fM
else if(o===t.i||o===t.o)r=A.ly
else if(o===t.N)r=A.lB
else r=o===t.y?A.fL:null
if(r!=null)return A.aC(o,a,r)
if(s===8){q=o.x
if(o.y.every(A.b6)){o.f="$i"+q
if(q==="m")return A.aC(o,a,A.lx)
return A.aC(o,a,A.lC)}}else if(s===10){p=A.lW(o.x,o.y)
return A.aC(o,a,p==null?A.iY:p)}return A.aC(o,a,A.lm)},
aC(a,b,c){a.b=c
return a.b(b)},
lp(a){var s=this,r=A.ll
if(A.b6(s))r=A.lb
else if(s===t.K)r=A.la
else if(A.bq(s))r=A.ln
if(s===t.S)r=A.ab
else if(s===t.h6)r=A.l8
else if(s===t.N)r=A.k
else if(s===t.dk)r=A.E
else if(s===t.y)r=A.iT
else if(s===t.fQ)r=A.aA
else if(s===t.o)r=A.l9
else if(s===t.cg)r=A.iU
else if(s===t.i)r=A.l6
else if(s===t.cD)r=A.l7
s.a=r
return s.a(a)},
lm(a){var s=this
if(a==null)return A.bq(s)
return A.ja(v.typeUniverse,A.m5(a,s),s)},
lo(a){if(a==null)return!0
return this.x.b(a)},
lC(a){var s,r=this
if(a==null)return A.bq(r)
s=r.f
if(a instanceof A.e)return!!a[s]
return!!J.b2(a)[s]},
lx(a){var s,r=this
if(a==null)return A.bq(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.e)return!!a[s]
return!!J.b2(a)[s]},
ll(a){var s=this
if(a==null){if(A.bq(s))return a}else if(s.b(a))return a
throw A.I(A.iV(a,s),new Error())},
ln(a){var s=this
if(a==null||s.b(a))return a
throw A.I(A.iV(a,s),new Error())},
iV(a,b){return new A.bm("TypeError: "+A.iE(a,A.W(b,null)))},
lS(a,b,c,d){if(A.ja(v.typeUniverse,a,b))return a
throw A.I(A.kU("The type argument '"+A.W(a,null)+"' is not a subtype of the type variable bound '"+A.W(b,null)+"' of type variable '"+c+"' in '"+d+"'."),new Error())},
iE(a,b){return A.dR(a)+": type '"+A.W(A.hI(a),null)+"' is not a subtype of type '"+b+"'"},
kU(a){return new A.bm("TypeError: "+a)},
al(a,b){return new A.bm("TypeError: "+A.iE(a,b))},
lv(a){var s=this
return s.x.b(a)||A.hm(v.typeUniverse,s).b(a)},
lz(a){return a!=null},
la(a){if(a!=null)return a
throw A.I(A.al(a,"Object"),new Error())},
lD(a){return!0},
lb(a){return a},
iY(a){return!1},
fL(a){return!0===a||!1===a},
iT(a){if(!0===a)return!0
if(!1===a)return!1
throw A.I(A.al(a,"bool"),new Error())},
aA(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.I(A.al(a,"bool?"),new Error())},
l6(a){if(typeof a=="number")return a
throw A.I(A.al(a,"double"),new Error())},
l7(a){if(typeof a=="number")return a
if(a==null)return a
throw A.I(A.al(a,"double?"),new Error())},
fM(a){return typeof a=="number"&&Math.floor(a)===a},
ab(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.I(A.al(a,"int"),new Error())},
l8(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.I(A.al(a,"int?"),new Error())},
ly(a){return typeof a=="number"},
l9(a){if(typeof a=="number")return a
throw A.I(A.al(a,"num"),new Error())},
iU(a){if(typeof a=="number")return a
if(a==null)return a
throw A.I(A.al(a,"num?"),new Error())},
lB(a){return typeof a=="string"},
k(a){if(typeof a=="string")return a
throw A.I(A.al(a,"String"),new Error())},
E(a){if(typeof a=="string")return a
if(a==null)return a
throw A.I(A.al(a,"String?"),new Error())},
j2(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.W(a[q],b)
return s},
lG(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.j2(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.W(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
iW(a3,a4,a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1=", ",a2=null
if(a5!=null){s=a5.length
if(a4==null)a4=A.b([],t.s)
else a2=a4.length
r=a4.length
for(q=s;q>0;--q)B.a.m(a4,"T"+(r+q))
for(p=t.X,o="<",n="",q=0;q<s;++q,n=a1){m=a4.length
l=m-1-q
if(!(l>=0))return A.a(a4,l)
o=o+n+a4[l]
k=a5[q]
j=k.w
if(!(j===2||j===3||j===4||j===5||k===p))o+=" extends "+A.W(k,a4)}o+=">"}else o=""
p=a3.x
i=a3.y
h=i.a
g=h.length
f=i.b
e=f.length
d=i.c
c=d.length
b=A.W(p,a4)
for(a="",a0="",q=0;q<g;++q,a0=a1)a+=a0+A.W(h[q],a4)
if(e>0){a+=a0+"["
for(a0="",q=0;q<e;++q,a0=a1)a+=a0+A.W(f[q],a4)
a+="]"}if(c>0){a+=a0+"{"
for(a0="",q=0;q<c;q+=3,a0=a1){a+=a0
if(d[q+1])a+="required "
a+=A.W(d[q+2],a4)+" "+d[q]}a+="}"}if(a2!=null){a4.toString
a4.length=a2}return o+"("+a+") => "+b},
W(a,b){var s,r,q,p,o,n,m,l=a.w
if(l===5)return"erased"
if(l===2)return"dynamic"
if(l===3)return"void"
if(l===1)return"Never"
if(l===4)return"any"
if(l===6){s=a.x
r=A.W(s,b)
q=s.w
return(q===11||q===12?"("+r+")":r)+"?"}if(l===7)return"FutureOr<"+A.W(a.x,b)+">"
if(l===8){p=A.lN(a.x)
o=a.y
return o.length>0?p+("<"+A.j2(o,b)+">"):p}if(l===10)return A.lG(a,b)
if(l===11)return A.iW(a,b,null)
if(l===12)return A.iW(a.x,b,a.y)
if(l===13){n=a.x
m=b.length
n=m-1-n
if(!(n>=0&&n<m))return A.a(b,n)
return b[n]}return"?"},
lN(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
l2(a,b){var s=a.tR[b]
for(;typeof s=="string";)s=a.tR[s]
return s},
l1(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.fC(a,b,!1)
else if(typeof m=="number"){s=m
r=A.cu(a,5,"#")
q=A.fH(s)
for(p=0;p<s;++p)q[p]=r
o=A.ct(a,b,q)
n[b]=o
return o}else return m},
l0(a,b){return A.iR(a.tR,b)},
l_(a,b){return A.iR(a.eT,b)},
fC(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.iJ(A.iH(a,null,b,!1))
r.set(b,s)
return s},
cv(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.iJ(A.iH(a,b,c,!0))
q.set(c,r)
return r},
iP(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.hB(a,b,c.w===9?c.y:[c])
p.set(s,q)
return q},
aN(a,b){b.a=A.lp
b.b=A.lq
return b},
cu(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.aa(null,null)
s.w=b
s.as=c
r=A.aN(a,s)
a.eC.set(c,r)
return r},
iN(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.kY(a,b,r,c)
a.eC.set(r,s)
return s},
kY(a,b,c,d){var s,r,q
if(d){s=b.w
r=!0
if(!A.b6(b))if(!(b===t.P||b===t.T))if(s!==6)r=s===7&&A.bq(b.x)
if(r)return b
else if(s===1)return t.P}q=new A.aa(null,null)
q.w=6
q.x=b
q.as=c
return A.aN(a,q)},
iM(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.kW(a,b,r,c)
a.eC.set(r,s)
return s},
kW(a,b,c,d){var s,r
if(d){s=b.w
if(A.b6(b)||b===t.K)return b
else if(s===1)return A.ct(a,"L",[b])
else if(b===t.P||b===t.T)return t.eH}r=new A.aa(null,null)
r.w=7
r.x=b
r.as=c
return A.aN(a,r)},
kZ(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.aa(null,null)
s.w=13
s.x=b
s.as=q
r=A.aN(a,s)
a.eC.set(q,r)
return r},
cs(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
kV(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
ct(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.cs(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.aa(null,null)
r.w=8
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.aN(a,r)
a.eC.set(p,q)
return q},
hB(a,b,c){var s,r,q,p,o,n
if(b.w===9){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.cs(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.aa(null,null)
o.w=9
o.x=s
o.y=r
o.as=q
n=A.aN(a,o)
a.eC.set(q,n)
return n},
iO(a,b,c){var s,r,q="+"+(b+"("+A.cs(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.aa(null,null)
s.w=10
s.x=b
s.y=c
s.as=q
r=A.aN(a,s)
a.eC.set(q,r)
return r},
iL(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.cs(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.cs(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.kV(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.aa(null,null)
p.w=11
p.x=b
p.y=c
p.as=r
o=A.aN(a,p)
a.eC.set(r,o)
return o},
hC(a,b,c,d){var s,r=b.as+("<"+A.cs(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.kX(a,b,c,r,d)
a.eC.set(r,s)
return s},
kX(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.fH(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.b0(a,b,r,0)
m=A.bo(a,c,r,0)
return A.hC(a,n,m,c!==m)}}l=new A.aa(null,null)
l.w=12
l.x=b
l.y=c
l.as=d
return A.aN(a,l)},
iH(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
iJ(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.kO(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.iI(a,r,l,k,!1)
else if(q===46)r=A.iI(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.aZ(a.u,a.e,k.pop()))
break
case 94:k.push(A.kZ(a.u,k.pop()))
break
case 35:k.push(A.cu(a.u,5,"#"))
break
case 64:k.push(A.cu(a.u,2,"@"))
break
case 126:k.push(A.cu(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.kQ(a,k)
break
case 38:A.kP(a,k)
break
case 63:p=a.u
k.push(A.iN(p,A.aZ(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.iM(p,A.aZ(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.kN(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.iK(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.kS(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-2)
break
case 43:n=l.indexOf("(",r)
k.push(l.substring(r,n))
k.push(-4)
k.push(a.p)
a.p=k.length
r=n+1
break
default:throw"Bad character "+q}}}m=k.pop()
return A.aZ(a.u,a.e,m)},
kO(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
iI(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===9)o=o.x
n=A.l2(s,o.x)[p]
if(n==null)A.X('No "'+p+'" in "'+A.kz(o)+'"')
d.push(A.cv(s,o,n))}else d.push(p)
return m},
kQ(a,b){var s,r=a.u,q=A.iG(a,b),p=b.pop()
if(typeof p=="string")b.push(A.ct(r,p,q))
else{s=A.aZ(r,a.e,p)
switch(s.w){case 11:b.push(A.hC(r,s,q,a.n))
break
default:b.push(A.hB(r,s,q))
break}}},
kN(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.iG(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.aZ(p,a.e,o)
q=new A.dn()
q.a=s
q.b=n
q.c=m
b.push(A.iL(p,r,q))
return
case-4:b.push(A.iO(p,b.pop(),s))
return
default:throw A.d(A.cG("Unexpected state under `()`: "+A.n(o)))}},
kP(a,b){var s=b.pop()
if(0===s){b.push(A.cu(a.u,1,"0&"))
return}if(1===s){b.push(A.cu(a.u,4,"1&"))
return}throw A.d(A.cG("Unexpected extended operation "+A.n(s)))},
iG(a,b){var s=b.splice(a.p)
A.iK(a.u,a.e,s)
a.p=b.pop()
return s},
aZ(a,b,c){if(typeof c=="string")return A.ct(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.kR(a,b,c)}else return c},
iK(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.aZ(a,b,c[s])},
kS(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.aZ(a,b,c[s])},
kR(a,b,c){var s,r,q=b.w
if(q===9){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==8)throw A.d(A.cG("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.d(A.cG("Bad index "+c+" for "+b.i(0)))},
ja(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.G(a,b,null,c,null)
r.set(c,s)}return s},
G(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(A.b6(d))return!0
s=b.w
if(s===4)return!0
if(A.b6(b))return!1
if(b.w===1)return!0
r=s===13
if(r)if(A.G(a,c[b.x],c,d,e))return!0
q=d.w
p=t.P
if(b===p||b===t.T){if(q===7)return A.G(a,b,c,d.x,e)
return d===p||d===t.T||q===6}if(d===t.K){if(s===7)return A.G(a,b.x,c,d,e)
return s!==6}if(s===7){if(!A.G(a,b.x,c,d,e))return!1
return A.G(a,A.hm(a,b),c,d,e)}if(s===6)return A.G(a,p,c,d,e)&&A.G(a,b.x,c,d,e)
if(q===7){if(A.G(a,b,c,d.x,e))return!0
return A.G(a,b,c,A.hm(a,d),e)}if(q===6)return A.G(a,b,c,p,e)||A.G(a,b,c,d.x,e)
if(r)return!1
p=s!==11
if((!p||s===12)&&d===t.Z)return!0
o=s===10
if(o&&d===t.gT)return!0
if(q===12){if(b===t.g)return!0
if(s!==12)return!1
n=b.y
m=d.y
l=n.length
if(l!==m.length)return!1
c=c==null?n:n.concat(c)
e=e==null?m:m.concat(e)
for(k=0;k<l;++k){j=n[k]
i=m[k]
if(!A.G(a,j,c,i,e)||!A.G(a,i,e,j,c))return!1}return A.iX(a,b.x,c,d.x,e)}if(q===11){if(b===t.g)return!0
if(p)return!1
return A.iX(a,b,c,d,e)}if(s===8){if(q!==8)return!1
return A.lw(a,b,c,d,e)}if(o&&q===10)return A.lA(a,b,c,d,e)
return!1},
iX(a3,a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.G(a3,a4.x,a5,a6.x,a7))return!1
s=a4.y
r=a6.y
q=s.a
p=r.a
o=q.length
n=p.length
if(o>n)return!1
m=n-o
l=s.b
k=r.b
j=l.length
i=k.length
if(o+j<n+i)return!1
for(h=0;h<o;++h){g=q[h]
if(!A.G(a3,p[h],a7,g,a5))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.G(a3,p[o+h],a7,g,a5))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.G(a3,k[h],a7,g,a5))return!1}f=s.c
e=r.c
d=f.length
c=e.length
for(b=0,a=0;a<c;a+=3){a0=e[a]
for(;!0;){if(b>=d)return!1
a1=f[b]
b+=3
if(a0<a1)return!1
a2=f[b-2]
if(a1<a0){if(a2)return!1
continue}g=e[a+1]
if(a2&&!g)return!1
g=f[b-1]
if(!A.G(a3,e[a+2],a7,g,a5))return!1
break}}for(;b<d;){if(f[b+1])return!1
b+=3}return!0},
lw(a,b,c,d,e){var s,r,q,p,o,n=b.x,m=d.x
for(;n!==m;){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.cv(a,b,r[o])
return A.iS(a,p,null,c,d.y,e)}return A.iS(a,b.y,null,c,d.y,e)},
iS(a,b,c,d,e,f){var s,r=b.length
for(s=0;s<r;++s)if(!A.G(a,b[s],d,e[s],f))return!1
return!0},
lA(a,b,c,d,e){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.G(a,r[s],c,q[s],e))return!1
return!0},
bq(a){var s=a.w,r=!0
if(!(a===t.P||a===t.T))if(!A.b6(a))if(s!==6)r=s===7&&A.bq(a.x)
return r},
b6(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.X},
iR(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
fH(a){return a>0?new Array(a):v.typeUniverse.sEA},
aa:function aa(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
dn:function dn(){this.c=this.b=this.a=null},
ds:function ds(a){this.a=a},
dm:function dm(){},
bm:function bm(a){this.a=a},
kF(){var s,r,q
if(self.scheduleImmediate!=null)return A.lP()
if(self.MutationObserver!=null&&self.document!=null){s={}
r=self.document.createElement("div")
q=self.document.createElement("span")
s.a=null
new self.MutationObserver(A.cC(new A.f6(s),1)).observe(r,{childList:true})
return new A.f5(s,r,q)}else if(self.setImmediate!=null)return A.lQ()
return A.lR()},
kG(a){self.scheduleImmediate(A.cC(new A.f7(t.M.a(a)),0))},
kH(a){self.setImmediate(A.cC(new A.f8(t.M.a(a)),0))},
kI(a){A.hq(B.N,t.M.a(a))},
hq(a,b){return A.kT(0,b)},
kT(a,b){var s=new A.fy()
s.cl(a,b)
return s},
af(a){return new A.ce(new A.q($.u,a.h("q<0>")),a.h("ce<0>"))},
ae(a,b){a.$2(0,null)
b.b=!0
return b.a},
aB(a,b){b.toString
A.lc(a,b)},
ad(a,b){b.a6(a)},
ac(a,b){b.ba(A.an(a),A.aO(a))},
lc(a,b){var s,r,q=new A.fI(b),p=new A.fJ(b)
if(a instanceof A.q)a.bR(q,p,t.z)
else{s=t.z
if(a instanceof A.q)a.aq(q,p,s)
else{r=new A.q($.u,t._)
r.a=8
r.c=a
r.bR(q,p,s)}}},
ag(a){var s=function(b,c){return function(d,e){while(true){try{b(d,e)
break}catch(r){e=r
d=c}}}}(a,1)
return $.u.c0(new A.fO(s),t.H,t.S,t.z)},
h8(a){var s
if(t.C.b(a)){s=a.ga8()
if(s!=null)return s}return B.p},
k2(a,b){var s
if(!b.b(null))throw A.d(A.dB(null,"computation","The type parameter is not nullable"))
s=new A.q($.u,b.h("q<0>"))
A.kD(a,new A.dY(null,s,b))
return s},
ls(a,b){if($.u===B.h)return null
return null},
lt(a,b){if($.u!==B.h)A.ls(a,b)
if(b==null)if(t.C.b(a)){b=a.ga8()
if(b==null){A.ik(a,B.p)
b=B.p}}else b=B.p
else if(t.C.b(a))A.ik(a,b)
return new A.a3(a,b)},
hx(a,b){var s=new A.q($.u,b.h("q<0>"))
b.a(a)
s.a=8
s.c=a
return s},
fm(a,b,c){var s,r,q,p,o={},n=o.a=a
for(s=t._;r=n.a,(r&4)!==0;n=a){a=s.a(n.c)
o.a=a}if(n===b){s=A.kA()
b.aW(new A.a3(new A.a7(!0,n,null,"Cannot complete a future with itself"),s))
return}q=b.a&1
s=n.a=r|q
if((s&24)===0){p=t.F.a(b.c)
b.a=b.a&1|4
b.c=n
n.bI(p)
return}if(!c)if(b.c==null)n=(s&16)===0||q!==0
else n=!1
else n=!0
if(n){p=b.ah()
b.az(o.a)
A.aY(b,p)
return}b.a^=2
A.dv(null,null,b.b,t.M.a(new A.fn(o,b)))},
aY(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d={},c=d.a=a
for(s=t.n,r=t.F;!0;){q={}
p=c.a
o=(p&16)===0
n=!o
if(b==null){if(n&&(p&1)===0){m=s.a(c.c)
A.hH(m.a,m.b)}return}q.a=b
l=b.a
for(c=b;l!=null;c=l,l=k){c.a=null
A.aY(d.a,c)
q.a=l
k=l.a}p=d.a
j=p.c
q.b=n
q.c=j
if(o){i=c.c
i=(i&1)!==0||(i&15)===8}else i=!0
if(i){h=c.b.b
if(n){p=p.b===h
p=!(p||p)}else p=!1
if(p){s.a(j)
A.hH(j.a,j.b)
return}g=$.u
if(g!==h)$.u=h
else g=null
c=c.c
if((c&15)===8)new A.fr(q,d,n).$0()
else if(o){if((c&1)!==0)new A.fq(q,j).$0()}else if((c&2)!==0)new A.fp(d,q).$0()
if(g!=null)$.u=g
c=q.c
if(c instanceof A.q){p=q.a.$ti
p=p.h("L<2>").b(c)||!p.y[1].b(c)}else p=!1
if(p){f=q.a.b
if((c.a&24)!==0){e=r.a(f.c)
f.c=null
b=f.aE(e)
f.a=c.a&30|f.a&1
f.c=c.c
d.a=c
continue}else A.fm(c,f,!0)
return}}f=q.a.b
e=r.a(f.c)
f.c=null
b=f.aE(e)
c=q.b
p=q.c
if(!c){f.$ti.c.a(p)
f.a=8
f.c=p}else{s.a(p)
f.a=f.a&1|16
f.c=p}d.a=f
c=f}},
j0(a,b){var s
if(t.Q.b(a))return b.c0(a,t.z,t.K,t.l)
s=t.v
if(s.b(a))return s.a(a)
throw A.d(A.dB(a,"onError",u.c))},
lF(){var s,r
for(s=$.bn;s!=null;s=$.bn){$.cz=null
r=s.b
$.bn=r
if(r==null)$.cy=null
s.a.$0()}},
lK(){$.hG=!0
try{A.lF()}finally{$.cz=null
$.hG=!1
if($.bn!=null)$.hS().$1(A.j5())}},
j3(a){var s=new A.dj(a),r=$.cy
if(r==null){$.bn=$.cy=s
if(!$.hG)$.hS().$1(A.j5())}else $.cy=r.b=s},
lJ(a){var s,r,q,p=$.bn
if(p==null){A.j3(a)
$.cz=$.cy
return}s=new A.dj(a)
r=$.cz
if(r==null){s.b=p
$.bn=$.cz=s}else{q=r.b
s.b=q
$.cz=r.b=s
if(q==null)$.cy=s}},
mi(a,b){A.cB(a,"stream",t.K)
return new A.dq(b.h("dq<0>"))},
kD(a,b){var s=$.u
if(s===B.h)return A.hq(a,t.M.a(b))
return A.hq(a,t.M.a(s.bV(b)))},
hH(a,b){A.lJ(new A.fN(a,b))},
j1(a,b,c,d,e){var s,r=$.u
if(r===c)return d.$0()
$.u=c
s=r
try{r=d.$0()
return r}finally{$.u=s}},
lI(a,b,c,d,e,f,g){var s,r=$.u
if(r===c)return d.$1(e)
$.u=c
s=r
try{r=d.$1(e)
return r}finally{$.u=s}},
lH(a,b,c,d,e,f,g,h,i){var s,r=$.u
if(r===c)return d.$2(e,f)
$.u=c
s=r
try{r=d.$2(e,f)
return r}finally{$.u=s}},
dv(a,b,c,d){t.M.a(d)
if(B.h!==c)d=c.bV(d)
A.j3(d)},
f6:function f6(a){this.a=a},
f5:function f5(a,b,c){this.a=a
this.b=b
this.c=c},
f7:function f7(a){this.a=a},
f8:function f8(a){this.a=a},
fy:function fy(){},
fz:function fz(a,b){this.a=a
this.b=b},
ce:function ce(a,b){this.a=a
this.b=!1
this.$ti=b},
fI:function fI(a){this.a=a},
fJ:function fJ(a){this.a=a},
fO:function fO(a){this.a=a},
a3:function a3(a,b){this.a=a
this.b=b},
dY:function dY(a,b,c){this.a=a
this.b=b
this.c=c},
bk:function bk(){},
ay:function ay(a,b){this.a=a
this.$ti=b},
cr:function cr(a,b){this.a=a
this.$ti=b},
az:function az(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
q:function q(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
fj:function fj(a,b){this.a=a
this.b=b},
fo:function fo(a,b){this.a=a
this.b=b},
fn:function fn(a,b){this.a=a
this.b=b},
fl:function fl(a,b){this.a=a
this.b=b},
fk:function fk(a,b){this.a=a
this.b=b},
fr:function fr(a,b,c){this.a=a
this.b=b
this.c=c},
fs:function fs(a,b){this.a=a
this.b=b},
ft:function ft(a){this.a=a},
fq:function fq(a,b){this.a=a
this.b=b},
fp:function fp(a,b){this.a=a
this.b=b},
dj:function dj(a){this.a=a
this.b=null},
dq:function dq(a){this.$ti=a},
cw:function cw(){},
fN:function fN(a,b){this.a=a
this.b=b},
dp:function dp(){},
fx:function fx(a,b){this.a=a
this.b=b},
iF(a,b){var s=a[b]
return s===a?null:s},
hz(a,b,c){if(c==null)a[b]=a
else a[b]=c},
hy(){var s=Object.create(null)
A.hz(s,"<non-identifier-key>",s)
delete s["<non-identifier-key>"]
return s},
C(a,b,c){return b.h("@<0>").u(c).h("hj<1,2>").a(A.j7(a,new A.aq(b.h("@<0>").u(c).h("aq<1,2>"))))},
cY(a,b){return new A.aq(a.h("@<0>").u(b).h("aq<1,2>"))},
hl(a){var s,r
if(A.hN(a))return"{...}"
s=new A.bi("")
try{r={}
B.a.m($.a2,a)
s.a+="{"
r.a=!0
a.am(0,new A.ex(r,s))
s.a+="}"}finally{if(0>=$.a2.length)return A.a($.a2,-1)
$.a2.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
ci:function ci(){},
bl:function bl(a){var _=this
_.a=0
_.e=_.d=_.c=_.b=null
_.$ti=a},
cj:function cj(a,b){this.a=a
this.$ti=b},
ck:function ck(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
p:function p(){},
aK:function aK(){},
ex:function ex(a,b){this.a=a
this.b=b},
l4(a,b,c){var s,r,q,p,o=c-b
if(o<=4096)s=$.jB()
else s=new Uint8Array(o)
for(r=0;r<o;++r){q=b+r
if(!(q<a.length))return A.a(a,q)
p=a[q]
if((p&255)!==p)p=255
s[r]=p}return s},
l3(a,b,c,d){var s=a?$.jA():$.jz()
if(s==null)return null
if(0===c&&d===b.length)return A.iQ(s,b)
return A.iQ(s,b.subarray(c,d))},
iQ(a,b){var s,r
try{s=a.decode(b)
return s}catch(r){}return null},
l5(a){switch(a){case 65:return"Missing extension byte"
case 67:return"Unexpected extension byte"
case 69:return"Invalid UTF-8 byte"
case 71:return"Overlong encoding"
case 73:return"Out of unicode range"
case 75:return"Encoded surrogate"
case 77:return"Unfinished UTF-8 octet sequence"
default:return""}},
fF:function fF(){},
fE:function fE(){},
cE:function cE(){},
fB:function fB(){},
dD:function dD(){},
fA:function fA(){},
dC:function dC(a){this.a=a},
by:function by(){},
cM:function cM(){},
cQ:function cQ(){},
f0:function f0(){},
fG:function fG(a){this.b=0
this.c=a},
di:function di(a){this.a=a},
fD:function fD(a){this.a=a
this.b=16
this.c=0},
O(a,b){var s,r=b.length
while(!0){if(a>0){s=a-1
if(!(s<r))return A.a(b,s)
s=b[s]===0}else s=!1
if(!s)break;--a}return a},
hv(a,b,c,d){var s,r,q,p=new Uint16Array(d),o=c-b
for(s=a.length,r=0;r<o;++r){q=b+r
if(!(q>=0&&q<s))return A.a(a,q)
q=a[q]
if(!(r<d))return A.a(p,r)
p[r]=q}return p},
cf(a){var s
if(a===0)return $.P()
if(a===1)return $.aE()
if(a===2)return $.jy()
if(Math.abs(a)<4294967296)return A.dk(B.b.aM(a))
s=A.kJ(a)
return s},
dk(a){var s,r,q,p,o=a<0
if(o){if(a===-9223372036854776e3){s=new Uint16Array(4)
s[3]=32768
r=A.O(4,s)
return new A.D(r!==0,s,r)}a=-a}if(a<65536){s=new Uint16Array(1)
s[0]=a
r=A.O(1,s)
return new A.D(r===0?!1:o,s,r)}if(a<=4294967295){s=new Uint16Array(2)
s[0]=a&65535
s[1]=B.b.a3(a,16)
r=A.O(2,s)
return new A.D(r===0?!1:o,s,r)}r=B.b.F(B.b.gak(a)-1,16)+1
s=new Uint16Array(r)
for(q=0;a!==0;q=p){p=q+1
if(!(q<r))return A.a(s,q)
s[q]=a&65535
a=B.b.F(a,65536)}r=A.O(r,s)
return new A.D(r===0?!1:o,s,r)},
kJ(a){var s,r,q,p,o,n,m,l
if(isNaN(a)||a==1/0||a==-1/0)throw A.d(A.a_("Value must be finite: "+a,null))
s=a<0
if(s)a=-a
a=Math.floor(a)
if(a===0)return $.P()
r=$.jx()
for(q=r.$flags|0,p=0;p<8;++p){q&2&&A.v(r)
if(!(p<8))return A.a(r,p)
r[p]=0}q=J.jE(B.aA.gbW(r))
q.$flags&2&&A.v(q,13)
q.setFloat64(0,a,!0)
o=(r[7]<<4>>>0)+(r[6]>>>4)-1075
n=new Uint16Array(4)
n[0]=(r[1]<<8>>>0)+r[0]
n[1]=(r[3]<<8>>>0)+r[2]
n[2]=(r[5]<<8>>>0)+r[4]
n[3]=r[6]&15|16
m=new A.D(!1,n,4)
if(o<0)l=m.aR(0,-o)
else l=o>0?m.a_(0,o):m
if(s)return l.Z(0)
return l},
hw(a,b,c,d){var s,r,q,p,o
if(b===0)return 0
if(c===0&&d===a)return b
for(s=b-1,r=a.length,q=d.$flags|0;s>=0;--s){p=s+c
if(!(s<r))return A.a(a,s)
o=a[s]
q&2&&A.v(d)
if(!(p>=0&&p<d.length))return A.a(d,p)
d[p]=o}for(s=c-1;s>=0;--s){q&2&&A.v(d)
if(!(s<d.length))return A.a(d,s)
d[s]=0}return b+c},
iC(a,b,c,d){var s,r,q,p,o,n,m,l=B.b.F(c,16),k=B.b.Y(c,16),j=16-k,i=B.b.a_(1,j)-1
for(s=b-1,r=a.length,q=d.$flags|0,p=0;s>=0;--s){if(!(s<r))return A.a(a,s)
o=a[s]
n=s+l+1
m=B.b.b6(o,j)
q&2&&A.v(d)
if(!(n>=0&&n<d.length))return A.a(d,n)
d[n]=(m|p)>>>0
p=B.b.a_(o&i,k)}q&2&&A.v(d)
if(!(l>=0&&l<d.length))return A.a(d,l)
d[l]=p},
ix(a,b,c,d){var s,r,q,p=B.b.F(c,16)
if(B.b.Y(c,16)===0)return A.hw(a,b,p,d)
s=b+p+1
A.iC(a,b,c,d)
for(r=d.$flags|0,q=p;--q,q>=0;){r&2&&A.v(d)
if(!(q<d.length))return A.a(d,q)
d[q]=0}r=s-1
if(!(r>=0&&r<d.length))return A.a(d,r)
if(d[r]===0)s=r
return s},
kM(a,b,c,d){var s,r,q,p,o,n,m=B.b.F(c,16),l=B.b.Y(c,16),k=16-l,j=B.b.a_(1,l)-1,i=a.length
if(!(m>=0&&m<i))return A.a(a,m)
s=B.b.b6(a[m],l)
r=b-m-1
for(q=d.$flags|0,p=0;p<r;++p){o=p+m+1
if(!(o<i))return A.a(a,o)
n=a[o]
o=B.b.a_(n&j,k)
q&2&&A.v(d)
if(!(p<d.length))return A.a(d,p)
d[p]=(o|s)>>>0
s=B.b.b6(n,l)}q&2&&A.v(d)
if(!(r>=0&&r<d.length))return A.a(d,r)
d[r]=s},
fc(a,b,c,d){var s,r,q,p,o=b-d
if(o===0)for(s=b-1,r=a.length,q=c.length;s>=0;--s){if(!(s<r))return A.a(a,s)
p=a[s]
if(!(s<q))return A.a(c,s)
o=p-c[s]
if(o!==0)return o}return o},
kK(a,b,c,d,e){var s,r,q,p,o,n
for(s=a.length,r=c.length,q=e.$flags|0,p=0,o=0;o<d;++o){if(!(o<s))return A.a(a,o)
n=a[o]
if(!(o<r))return A.a(c,o)
p+=n+c[o]
q&2&&A.v(e)
if(!(o<e.length))return A.a(e,o)
e[o]=p&65535
p=p>>>16}for(o=d;o<b;++o){if(!(o>=0&&o<s))return A.a(a,o)
p+=a[o]
q&2&&A.v(e)
if(!(o<e.length))return A.a(e,o)
e[o]=p&65535
p=p>>>16}q&2&&A.v(e)
if(!(b>=0&&b<e.length))return A.a(e,b)
e[b]=p},
dl(a,b,c,d,e){var s,r,q,p,o,n
for(s=a.length,r=c.length,q=e.$flags|0,p=0,o=0;o<d;++o){if(!(o<s))return A.a(a,o)
n=a[o]
if(!(o<r))return A.a(c,o)
p+=n-c[o]
q&2&&A.v(e)
if(!(o<e.length))return A.a(e,o)
e[o]=p&65535
p=0-(B.b.a3(p,16)&1)}for(o=d;o<b;++o){if(!(o>=0&&o<s))return A.a(a,o)
p+=a[o]
q&2&&A.v(e)
if(!(o<e.length))return A.a(e,o)
e[o]=p&65535
p=0-(B.b.a3(p,16)&1)}},
iD(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k
if(a===0)return
for(s=b.length,r=d.length,q=d.$flags|0,p=0;--f,f>=0;e=l,c=o){o=c+1
if(!(c<s))return A.a(b,c)
n=b[c]
if(!(e>=0&&e<r))return A.a(d,e)
m=a*n+d[e]+p
l=e+1
q&2&&A.v(d)
d[e]=m&65535
p=B.b.F(m,65536)}for(;p!==0;e=l){if(!(e>=0&&e<r))return A.a(d,e)
k=d[e]+p
l=e+1
q&2&&A.v(d)
d[e]=k&65535
p=B.b.F(k,65536)}},
kL(a,b,c){var s,r,q,p=b.length
if(!(c>=0&&c<p))return A.a(b,c)
s=b[c]
if(s===a)return 65535
r=c-1
if(!(r>=0&&r<p))return A.a(b,r)
q=B.b.cj((s<<16|b[r])>>>0,a)
if(q>65535)return 65535
return q},
k_(a,b){a=A.I(a,new Error())
if(a==null)a=t.K.a(a)
a.stack=b.i(0)
throw a},
a9(a,b,c,d){var s,r=c?J.i8(a,d):J.i7(a,d)
if(a!==0&&b!=null)for(s=0;s<r.length;++s)r[s]=b
return r},
bQ(a,b,c){var s,r=A.b([],c.h("o<0>"))
for(s=J.aQ(a);s.p();)B.a.m(r,c.a(s.gq()))
if(b)return r
r.$flags=1
return r},
a5(a,b){var s,r
if(Array.isArray(a))return A.b(a.slice(0),b.h("o<0>"))
s=A.b([],b.h("o<0>"))
for(r=J.aQ(a);r.p();)B.a.m(s,r.gq())
return s},
ki(a,b,c){var s,r=J.i8(a,c)
for(s=0;s<a;++s)B.a.k(r,s,b.$1(s))
return r},
hk(a,b){var s=A.bQ(a,!1,b)
s.$flags=3
return s},
ir(a,b,c){var s,r,q,p
A.db(b,"start")
s=c-b
if(s<0)throw A.d(A.a1(c,b,null,"end",null))
if(s===0)return""
if(Array.isArray(a)){r=a
q=r.length
return A.ij(b>0||c<q?r.slice(b,c):r)}if(t.bm.b(a))return A.kC(a,b,c)
a=J.jI(a,c)
if(b>0)a=J.jH(a,b)
p=A.a5(a,t.S)
return A.ij(p)},
kC(a,b,c){var s=a.length
if(b>=s)return""
return A.kw(a,b,c==null||c>s?s:c)},
ky(a){return new A.cW(a,A.kd(a,!1,!0,!1,!1,""))},
io(a,b,c){var s=J.aQ(b)
if(!s.p())return a
if(c.length===0){do a+=A.n(s.gq())
while(s.p())}else{a+=A.n(s.gq())
for(;s.p();)a=a+c+A.n(s.gq())}return a},
kA(){return A.aO(new Error())},
jY(a){var s=Math.abs(a),r=a<0?"-":""
if(s>=1000)return""+a
if(s>=100)return r+"0"+s
if(s>=10)return r+"00"+s
return r+"000"+s},
i3(a){if(a>=100)return""+a
if(a>=10)return"0"+a
return"00"+a},
cO(a){if(a>=10)return""+a
return"0"+a},
dR(a){if(typeof a=="number"||A.fL(a)||a==null)return J.Z(a)
if(typeof a=="string")return JSON.stringify(a)
return A.ku(a)},
k0(a,b){A.cB(a,"error",t.K)
A.cB(b,"stackTrace",t.l)
A.k_(a,b)},
cG(a){return new A.cF(a)},
a_(a,b){return new A.a7(!1,null,b,a)},
dB(a,b,c){return new A.a7(!0,a,b,c)},
a1(a,b,c,d,e){return new A.bg(b,c,!0,a,d,"Invalid value")},
c_(a,b,c){if(0>a||a>c)throw A.d(A.a1(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.d(A.a1(b,a,c,"end",null))
return b}return c},
db(a,b){if(a<0)throw A.d(A.a1(a,0,null,b,null))
return a},
hd(a,b,c,d){return new A.cR(b,!0,a,d,"Index out of range")},
dh(a){return new A.ca(a)},
hr(a){return new A.df(a)},
hn(a){return new A.bh(a)},
a8(a){return new A.cL(a)},
hc(a,b,c){return new A.dU(a,b,c)},
k3(a,b,c){var s,r
if(A.hN(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.b([],t.s)
B.a.m($.a2,a)
try{A.lE(a,s)}finally{if(0>=$.a2.length)return A.a($.a2,-1)
$.a2.pop()}r=A.io(b,t.R.a(s),", ")+c
return r.charCodeAt(0)==0?r:r},
i6(a,b,c){var s,r
if(A.hN(a))return b+"..."+c
s=new A.bi(b)
B.a.m($.a2,a)
try{r=s
r.a=A.io(r.a,a,", ")}finally{if(0>=$.a2.length)return A.a($.a2,-1)
$.a2.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
lE(a,b){var s,r,q,p,o,n,m,l=a.gA(a),k=0,j=0
while(!0){if(!(k<80||j<3))break
if(!l.p())return
s=A.n(l.gq())
B.a.m(b,s)
k+=s.length+2;++j}if(!l.p()){if(j<=5)return
if(0>=b.length)return A.a(b,-1)
r=b.pop()
if(0>=b.length)return A.a(b,-1)
q=b.pop()}else{p=l.gq();++j
if(!l.p()){if(j<=4){B.a.m(b,A.n(p))
return}r=A.n(p)
if(0>=b.length)return A.a(b,-1)
q=b.pop()
k+=r.length+2}else{o=l.gq();++j
for(;l.p();p=o,o=n){n=l.gq();++j
if(j>100){while(!0){if(!(k>75&&j>3))break
if(0>=b.length)return A.a(b,-1)
k-=b.pop().length+2;--j}B.a.m(b,"...")
return}}q=A.n(p)
r=A.n(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
while(!0){if(!(k>80&&b.length>3))break
if(0>=b.length)return A.a(b,-1)
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)B.a.m(b,m)
B.a.m(b,q)
B.a.m(b,r)},
kl(a,b,c,d){var s
if(B.o===c){s=B.b.gv(a)
b=J.ao(b)
return A.hp(A.aM(A.aM($.h4(),s),b))}if(B.o===d){s=B.b.gv(a)
b=J.ao(b)
c=J.ao(c)
return A.hp(A.aM(A.aM(A.aM($.h4(),s),b),c))}s=B.b.gv(a)
b=J.ao(b)
c=J.ao(c)
d=J.ao(d)
d=A.hp(A.aM(A.aM(A.aM(A.aM($.h4(),s),b),c),d))
return d},
D:function D(a,b,c){this.a=a
this.b=b
this.c=c},
fd:function fd(){},
fe:function fe(){},
cN:function cN(a,b,c){this.a=a
this.b=b
this.c=c},
cP:function cP(){},
fh:function fh(){},
w:function w(){},
cF:function cF(a){this.a=a},
aw:function aw(){},
a7:function a7(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
bg:function bg(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
cR:function cR(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
ca:function ca(a){this.a=a},
df:function df(a){this.a=a},
bh:function bh(a){this.a=a},
cL:function cL(a){this.a=a},
d6:function d6(){},
c2:function c2(){},
fi:function fi(a){this.a=a},
dU:function dU(a,b,c){this.a=a
this.b=b
this.c=c},
cS:function cS(){},
i:function i(){},
T:function T(a,b,c){this.a=a
this.b=b
this.$ti=c},
H:function H(){},
e:function e(){},
dr:function dr(){},
bi:function bi(a){this.a=a},
kh(a,b){return a},
kb(a){return a},
k4(a,b){var s,r,q,p,o,n
if(b.length===0)return!1
s=b.split(".")
r=v.G
for(q=s.length,p=t.A,o=0;o<q;++o){n=s[o]
r=p.a(r[n])
if(r==null)return!1}return a instanceof t.g.a(r)},
k1(a){return t.m.a(new v.G.Promise(A.y(new A.dX(a))))},
dX:function dX(a){this.a=a},
dV:function dV(a){this.a=a},
dW:function dW(a){this.a=a},
x(a){var s
if(typeof a=="function")throw A.d(A.a_("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(){return b(c)}}(A.ld,a)
s[$.bs()]=a
return s},
f(a){var s
if(typeof a=="function")throw A.d(A.a_("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d){return b(c,d,arguments.length)}}(A.le,a)
s[$.bs()]=a
return s},
y(a){var s
if(typeof a=="function")throw A.d(A.a_("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e){return b(c,d,e,arguments.length)}}(A.lf,a)
s[$.bs()]=a
return s},
hD(a){var s
if(typeof a=="function")throw A.d(A.a_("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e,f){return b(c,d,e,f,arguments.length)}}(A.lg,a)
s[$.bs()]=a
return s},
hE(a){var s
if(typeof a=="function")throw A.d(A.a_("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e,f,g){return b(c,d,e,f,g,arguments.length)}}(A.lh,a)
s[$.bs()]=a
return s},
ld(a){return t.Z.a(a).$0()},
le(a,b,c){t.Z.a(a)
if(A.ab(c)>=1)return a.$1(b)
return a.$0()},
lf(a,b,c,d){t.Z.a(a)
A.ab(d)
if(d>=2)return a.$2(b,c)
if(d===1)return a.$1(b)
return a.$0()},
lg(a,b,c,d,e){t.Z.a(a)
A.ab(e)
if(e>=3)return a.$3(b,c,d)
if(e===2)return a.$2(b,c)
if(e===1)return a.$1(b)
return a.$0()},
lh(a,b,c,d,e,f){t.Z.a(a)
A.ab(f)
if(f>=4)return a.$4(b,c,d,e)
if(f===3)return a.$3(b,c,d)
if(f===2)return a.$2(b,c)
if(f===1)return a.$1(b)
return a.$0()},
j_(a){return a==null||A.fL(a)||typeof a=="number"||typeof a=="string"||t.gj.b(a)||t.gc.b(a)||t.go.b(a)||t.dQ.b(a)||t.h7.b(a)||t.k.b(a)||t.bv.b(a)||t.E.b(a)||t.d.b(a)||t.B.b(a)||t.Y.b(a)},
fY(a){if(A.j_(a))return a
return new A.fZ(new A.bl(t.J)).$1(a)},
m0(a,b,c){return c.a(a[b])},
fP(a,b,c){var s,r
if(b==null)return c.a(new a())
if(b instanceof Array)switch(b.length){case 0:return c.a(new a())
case 1:return c.a(new a(b[0]))
case 2:return c.a(new a(b[0],b[1]))
case 3:return c.a(new a(b[0],b[1],b[2]))
case 4:return c.a(new a(b[0],b[1],b[2],b[3]))}s=[null]
B.a.a5(s,b)
r=a.bind.apply(a,s)
String(r)
return c.a(new r())},
jc(a,b){var s=new A.q($.u,b.h("q<0>")),r=new A.ay(s,b.h("ay<0>"))
a.then(A.cC(new A.h1(r,b),1),A.cC(new A.h2(r),1))
return s},
iZ(a){return a==null||typeof a==="boolean"||typeof a==="number"||typeof a==="string"||a instanceof Int8Array||a instanceof Uint8Array||a instanceof Uint8ClampedArray||a instanceof Int16Array||a instanceof Uint16Array||a instanceof Int32Array||a instanceof Uint32Array||a instanceof Float32Array||a instanceof Float64Array||a instanceof ArrayBuffer||a instanceof DataView},
hK(a){if(A.iZ(a))return a
return new A.fQ(new A.bl(t.J)).$1(a)},
fZ:function fZ(a){this.a=a},
h1:function h1(a,b){this.a=a
this.b=b},
h2:function h2(a){this.a=a},
fQ:function fQ(a){this.a=a},
ez:function ez(a){this.a=a},
fv:function fv(a){this.a=a},
dP:function dP(){},
hX(a,b){var s,r,q,p,o,n,m,l,k=B.Y.j(0,b)
k.toString
s=A.jM(a)
for(r=k.length,q="";s.aH(0,$.P())>0;s=o){p=A.cf(58)
if(p.c===0)A.X(B.x)
o=s.bs(p)
p=A.cf(58)
if(p.c===0)A.X(B.x)
n=s.bJ(p)
if(n.a)n=p.a?n.ar(0,p):n.aO(0,p)
p=n.aM(0)
if(!(p>=0&&p<r))return A.a(k,p)
q=k[p]+q}for(p=a.length,m=0,l=0;l<p;++l)if(a[l]===0)++m
else break
if(0>=r)return A.a(k,0)
return B.e.V(k[0],p-(p-m))+q},
hW(a,b){var s,r,q,p,o,n,m,l,k=B.Y.j(0,b)
k.toString
s=$.P()
for(r=a.length,q=r-1,p=0;p<r;++p){o=q-p
if(!(o>=0))return A.a(a,o)
n=B.e.ek(k,a[o])
if(n===-1)throw A.d(B.ay)
s=s.aO(0,A.cf(n).V(0,A.cf(58).er(p)))}m=A.jN(s,A.jL(s))
for(q=k.length,l=0,p=0;p<r;++p){o=a[p]
if(0>=q)return A.a(k,0)
if(o===k[0])++l
else break}k=t.S
r=A.a5(A.a9(l,0,!1,k),t.z)
B.a.a5(r,m)
return A.bQ(r,!0,k)},
bv:function bv(a){this.b=a},
dF:function dF(a,b){this.a=a
this.b=b},
iv(a){var s,r,q,p,o,n,m,l,k,j,i,h=A.br(a,"=",""),g=A.b([],t.t)
for(s=h.length,r=0;q=r+4,q<=s;r=q){p=$.h3()
if(!(r<s))return A.a(h,r)
o=J.b3(p)
n=o.j(p,h.charCodeAt(r))
m=r+1
if(!(m<s))return A.a(h,m)
m=o.j(p,h.charCodeAt(m))
l=r+2
if(!(l<s))return A.a(h,l)
l=o.j(p,h.charCodeAt(l))
k=r+3
if(!(k<s))return A.a(h,k)
j=n<<18|m<<12|l<<6|o.j(p,h.charCodeAt(k))
B.a.m(g,j>>>16&255)
B.a.m(g,j>>>8&255)
B.a.m(g,j&255)}i=s-r
if(i===2){p=$.h3()
if(!(r<s))return A.a(h,r)
o=J.b3(p)
n=o.j(p,h.charCodeAt(r))
m=r+1
if(!(m<s))return A.a(h,m)
B.a.m(g,(n<<18|o.j(p,h.charCodeAt(m))<<12)>>>16&255)}else if(i===3){p=$.h3()
if(!(r<s))return A.a(h,r)
o=J.b3(p)
n=o.j(p,h.charCodeAt(r))
m=r+1
if(!(m<s))return A.a(h,m)
m=o.j(p,h.charCodeAt(m))
l=r+2
if(!(l<s))return A.a(h,l)
j=n<<18|m<<12|o.j(p,h.charCodeAt(l))<<6
B.a.m(g,j>>>16&255)
B.a.m(g,j>>>8&255)}return g},
jK(a,b,c){var s,r,q
a=a
r=B.b.Y(J.ai(a),4)
if(r!==0)throw A.d(A.jJ("Invalid length, must be multiple of four"))
r=a
r=A.br(r,"-","+")
a=A.br(r,"_","/")
s=new A.f9(A.b([],t.t))
try{J.hU(s,a)
r=s
q=r.b
if(q.length!==0)B.a.a5(r.a,A.iv(B.e.ep(q,4,"=")))
r=A.kg(r.a,t.S)
return r}finally{r=s
B.a.bX(r.a)
r.b=""}},
f9:function f9(a){this.a=a
this.b=""},
fa:function fa(){},
iw(a){var s,r,q,p,o,n,m,l,k,j=u.n
for(s=a.length,r=0,q="";p=r+3,p<=s;r=p){if(!(r<s))return A.a(a,r)
o=a[r]
n=r+1
if(!(n<s))return A.a(a,n)
n=a[n]
m=r+2
if(!(m<s))return A.a(a,m)
l=o<<16|n<<8|a[m]
q=q+j[l>>>18&63]+j[l>>>12&63]+j[l>>>6&63]+j[l&63]}k=s-r
if(k===1){if(!(r<s))return A.a(a,r)
l=a[r]<<16
s=q+j[l>>>18&63]+j[l>>>12&63]+"=="}else if(k===2){if(!(r<s))return A.a(a,r)
o=a[r]
n=r+1
if(!(n<s))return A.a(a,n)
l=o<<16|a[n]<<8
q=q+j[l>>>18&63]+j[l>>>12&63]+j[l>>>6&63]+"="
s=q}else s=q
return s.charCodeAt(0)==0?s:s},
hV(a,b,c){var s,r,q,p,o=new A.fb(new A.bi(""),A.b([],t.t))
try{A.hb(a)
J.hU(o,a)
r=o
q=r.b
if(q.length!==0){p=r.a
q=A.iw(q)
p.a+=q}r=r.a.a
s=r.charCodeAt(0)==0?r:r
if(c){r=s
r=A.br(r,"+","-")
s=A.br(r,"/","_")}r=s
return r}finally{r=o
r.a.a=""
B.a.bX(r.b)}},
fb:function fb(a,b){this.a=a
this.b=b},
jJ(a){return new A.dE(a,null)},
dE:function dE(a,b){this.a=a
this.b=b},
dN:function dN(a,b){this.a=a
this.b=b},
eI(a){var s,r=t.S,q=A.a9(8,0,!1,r),p=A.a9(64,0,!1,r),o=A.a9(128,0,!1,r),n=new A.eH(q,p,o,A.hk(B.as,r))
n.c1()
n.aN(a)
s=A.a9(32,0,!1,r)
n.eg(s)
A.jg(o)
A.jg(p)
n.c1()
return s},
eH:function eH(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.e=_.d=0
_.f=!1
_.r=d},
h7(a,b){return new A.b8(a,b)},
dG:function dG(){},
dH:function dH(){},
dI:function dI(){},
b8:function b8(a,b){this.a=a
this.b=b},
ey:function ey(a,b){this.a=a
this.b=b},
fu:function fu(){},
kB(a){if(B.e.bi(a.toLowerCase(),"0x"))return B.e.aS(a,2)
return a},
iq(a){var s,r,q,p,o,n,m,l=!0,k=B.w,j=B.L,i=!0
try{switch(j){case B.L:r=B.aj.al(a)
return r
case B.v:case B.a0:r=A.jK(a,l,i)
return r
case B.a1:r=A.hW(a,k)
return r
case B.a2:q=A.hW(a,k)
p=B.a.W(q,0,q.length-4)
o=B.a.bj(q,q.length-4)
n=B.a.W(A.eI(A.eI(p)),0,4)
if(!A.jQ(o,n))A.X(new A.dF("Invalid checksum (expected "+A.ha(n)+", got "+A.ha(o)+")",null))
return p
case B.a3:r=A.i1(a)
return r
case B.a_:r=B.aa.al(a)
return r}}catch(m){s=A.an(m)
throw A.d(A.h7("Failed to convert string as "+j.b+" bytes.",A.C(["error",J.Z(s)],t.N,t.z)))}},
ip(a,b){var s,r,q,p,o,n,m=!1,l=!1,k=B.w
a=a
r=a
A.hb(r)
a=r
try{switch(b){case B.L:r=t.L.a(a)
q=A.aA(m)
r=new A.fD((q===!0?B.aO:B.aN).a).cL(r,0,null,!0)
return r
case B.v:r=A.hV(a,l,!1)
return r
case B.a0:r=A.hV(a,l,!0)
return r
case B.a1:r=A.hX(a,k)
return r
case B.a2:r=a
A.hb(r)
q=t.S
p=A.hk(r,q)
o=B.a.W(A.eI(A.eI(p)),0,4)
r=A.a5(p,t.z)
B.a.a5(r,o)
r=A.hX(A.bQ(r,!0,q),k)
return r
case B.a3:r=A.ha(a)
return r
case B.a_:r=B.a9.ed(a,m)
return r}}catch(n){s=A.an(n)
r=A.h7("Failed to convert bytes as "+b.b,A.C(["error",J.Z(s)],t.N,t.z))
throw A.d(r)}},
av:function av(a){this.b=a},
kE(){var s,r,q,p=A.ki(16,new A.eV($.ji()),t.S)
B.a.k(p,6,p[6]&15|64)
B.a.k(p,8,p[8]&63|128)
s=A.V(p)
r=s.h("U<1,j>")
q=A.a5(new A.U(p,s.h("j(1)").a(new A.eW()),r),r.h("F.E"))
return B.a.T(B.a.W(q,0,4),"")+"-"+B.a.T(B.a.W(q,4,6),"")+"-"+B.a.T(B.a.W(q,6,8),"")+"-"+B.a.T(B.a.W(q,8,10),"")+"-"+B.a.T(B.a.bj(q,10),"")},
eV:function eV(a){this.a=a},
eW:function eW(){},
dQ:function dQ(){},
cZ:function cZ(a){this.b=a},
eP:function eP(a){this.a=a},
cb:function cb(a,b){this.a=a
this.b=b},
du:function du(){},
k7(a){var s,r,q,p,o,n
try{s=null
q=a.rawTransaction
r=q==null?null:J.Z(q)
if(r!=null){q=$.jk()
p=t.K
if(q.b.test(r)){q=A.i1(r)
s=p.a(v.G.Uint8Array.from(A.fY(q)))}else s=p.a(a.rawTransaction.bcsToBytes())
q=s
p=a.feePayerAddress
p=p==null?null:J.Z(p)
o=t.r.a(a.secondarySignerAddresses)
if(o==null)o=null
else{o=t.ew.b(o)?o:new A.ap(o,A.V(o).h("ap<1,e>"))
o=J.dx(o,new A.e6(),t.N)
o=A.a5(o,o.$ti.h("F.E"))}o={rawTransaction:q,feePayerAddress:p,secondarySignerAddresses:o}
return o}}catch(n){}throw A.d(new A.cb("Invalid method parameters: Invalid Aptos transaction. The transaction must be a valid Aptos transaction and include a method like bcsToBytes.",-32602))},
k5(a){return new A.e5(a)},
k6(a){return new A.e4(a)},
he(a){a.bcsToBytes=A.x(new A.e1(a))
a.serialize=A.f(new A.e2(a))
a.bcsToHex=A.x(new A.e3(a))
a.toStringWithoutPrefix=A.x(A.k6(a))
a.toString=A.x(A.k5(a))},
hf(a){return B.a.a7(B.aw,new A.e7(a),new A.e8())},
hg(a,b){var s={}
s.status="Approved"
s.args=a
return s},
e6:function e6(){},
e5:function e5(a){this.a=a},
e4:function e4(a){this.a=a},
e1:function e1(a){this.a=a},
e2:function e2(a){this.a=a},
e3:function e3(a){this.a=a},
aG:function aG(a,b){this.c=a
this.b=b},
e7:function e7(a){this.a=a},
e8:function e8(){},
aL:function aL(a,b,c){this.a=a
this.b=b
this.$ti=c},
d7:function d7(a,b){this.a=a
this.b=b},
jZ(a){var s=v.G,r=t.m,q=r.a(new s.CustomEvent("eip6963:announceProvider",{bubbles:!0,cancelable:!1,detail:t.K.a(s.Object.freeze({info:$.jh(),provider:a}))}))
r.a(s.window).addEventListener("eip6963:requestProvider",A.f(new A.dO(q)))
r.a(s.window).dispatchEvent(q)},
dO:function dO(a){this.a=a},
Y(a,b){return t.m.a(new v.G.Promise(A.y(new A.f4(a))))},
a6(a,b){return A.fP(v.G.Proxy,[a,new A.eG(new A.aL(null,a,b.h("aL<0>"))).$0()],t.m)},
il(a){var s=A.V(a),r=s.h("U<1,j>")
s=A.a5(new A.U(a,s.h("j(1)").a(new A.eD()),r),r.h("F.E"))
return s},
f4:function f4(a){this.a=a},
f1:function f1(a){this.a=a},
f2:function f2(a){this.a=a},
f3:function f3(a,b){this.a=a
this.b=b},
eE:function eE(a){this.a=a},
eF:function eF(a){this.a=a},
eG:function eG(a){this.a=a},
eD:function eD(){},
hO(a){return A.m8(a)},
m8(a){var s=0,r=A.af(t.H),q,p,o
var $async$hO=A.ag(function(b,c){if(b===1)return A.ac(c,r)
while(true)switch(s){case 0:p={}
o=new A.cV(new A.eP(A.cY(t.fs,t.W)),new A.ay(new A.q($.u,t.U),t.h))
o.d3()
q=v.G
q.onChain={}
p.a=!1
t.m.a(q.window).addEventListener("WALLET_ACTIVATION",A.f(new A.h_(p,o)))
return A.ad(null,r)}})
return A.ae($async$hO,r)},
h_:function h_(a,b){this.a=a
this.b=b},
ke(a){return B.a.a7(B.at,new A.ep(a),new A.eq())},
ka(a){return B.a.a7(B.av,new A.eg(a),new A.eh())},
k9(a){return B.a.a7(B.W,new A.ee(a),new A.ef())},
bH(a){return A.kx(B.W,new A.ed(a),t.G)},
ic(a){return B.a.a7(B.ax,new A.eu(a),new A.ev())},
i9(a){return B.a.a7(B.au,new A.eb(a),new A.ec())},
ig(a,b){var s=a==null?null:a.b
return{data:b,requestId:"event",client:s}},
be(a){return{type:"event",event:a.b,data:null,providerType:"walletStandard"}},
aH:function aH(a){this.b=a},
ep:function ep(a){this.a=a},
eq:function eq(){},
R:function R(a){this.b=a},
eg:function eg(a){this.a=a},
eh:function eh(){},
a4:function a4(a){this.b=a},
ee:function ee(a){this.a=a},
ef:function ef(){},
ed:function ed(a){this.a=a},
aI:function aI(a){this.b=a},
eu:function eu(a){this.a=a},
ev:function ev(){},
J:function J(a,b){this.c=a
this.b=b},
eb:function eb(a){this.a=a},
ec:function ec(){},
d9:function d9(a){this.b=a},
hA(a){var s
if(a!=null&&typeof a==="string"){s=A.k(a).length
if(s===64||s===66)throw A.d({message:"Please use static method `TronWeb.TRX.sign` for signing with own private key"})}},
e9:function e9(){},
ea:function ea(a){this.a=a},
cV:function cV(a,b){var _=this
_.b=_.a=$
_.c=a
_.d=b
_.e=null
_.f=$},
bL:function bL(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
el:function el(a,b){this.a=a
this.b=b},
ei:function ei(a,b){this.a=a
this.b=b},
ej:function ej(a){this.a=a},
ek:function ek(a){this.a=a},
N:function N(){},
d8:function d8(a,b){this.a=a
this.b=b},
bt:function bt(a,b,c){this.c=a
this.a=b
this.b=c},
dz:function dz(){},
dA:function dA(){},
dy:function dy(){},
bw:function bw(a,b){this.a=a
this.b=b},
bA:function bA(a,b){var _=this
_.d=_.c=null
_.a=a
_.b=b},
dL:function dL(a,b){this.a=a
this.b=b},
dM:function dM(a,b,c){this.a=a
this.b=b
this.c=c},
dJ:function dJ(a,b){this.a=a
this.b=b},
dK:function dK(a,b,c){this.a=a
this.b=b
this.c=c},
bD:function bD(a,b,c){var _=this
_.c=null
_.d=a
_.a=b
_.b=c},
c1:function c1(a,b){this.a=a
this.b=b},
c3:function c3(a,b){this.a=a
this.b=b},
c5:function c5(a,b,c){var _=this
_.c=a
_.e=_.d=null
_.a=b
_.b=c},
eM:function eM(a){this.a=a},
eN:function eN(a){this.a=a},
eO:function eO(a){this.a=a},
eK:function eK(){},
eL:function eL(a){this.a=a},
c6:function c6(a,b){this.a=a
this.b=b},
c7:function c7(a,b){this.a=a
this.b=b},
c8:function c8(a,b,c,d){var _=this
_.d=_.c=null
_.e=a
_.f=b
_.a=c
_.b=d},
eQ:function eQ(a){this.a=a},
eR:function eR(a){this.a=a},
eS:function eS(a){this.a=a},
aj(a){var s={}
s.on=a
s.version="1.0.0"
return s},
aT(a){var s={}
s.disconnect=a
s.version="1.0.0"
return s},
er(a){var s,r,q=t.c.a(a.types)
q=t.a.b(q)?q:new A.ap(q,A.V(q).h("ap<1,j>"))
q=J.dx(q,new A.es(),t.N)
s=q.$ti
r=s.h("U<F.E,R>")
q=A.a5(new A.U(q,s.h("R(F.E)").a(new A.et()),r),r.h("F.E"))
return q},
ib(a){var s=t.c.a(a.accounts)
s=t.cl.b(s)?s:new A.ap(s,A.V(s).h("ap<1,h>"))
s=J.dx(s,new A.eo(),t.N)
s=A.a5(s,s.$ti.h("F.E"))
return s},
es:function es(){},
et:function et(){},
eo:function eo(){},
kg(a,b){return A.bQ(a,!0,b)},
hQ(a,b,c){B.a.k(b,c,a>>>24&255)
B.a.k(b,c+1,a>>>16&255)
B.a.k(b,c+2,a>>>8&255)
B.a.k(b,c+3,a&255)},
jg(a){var s,r
for(s=a.length,r=0;r<s;++r)B.a.k(a,r,0)},
ha(a){var s=B.Q.ef(a,!0)
return s},
i1(a){var s,r,q,p=!1
try{s=A.kB(a)
if(J.ai(s)===0){r=A.b([],t.t)
return r}if(p&&(J.ai(s)&1)===1)s="0"+A.n(s)
r=B.Q.ec(s)
return r}catch(q){throw A.d(B.a4)}},
jR(a,b){var s,r,q
for(s=J.b4(a),r=0;r<a.length;++r){q=s.E(a,r)
if(q<0||q>255)throw A.d(A.h7(b+" at index "+r+" "+A.n(q),null))}},
hb(a){var s,r,q
for(s=a.length,r=0;r<s;++r){q=a[r]
if(q<0||q>255)throw A.d(A.a_("Invalid bytes at index "+r+": "+q,null))}},
jQ(a,b){var s,r,q=a.length,p=b.length
if(q!==p)return!1
if(a===b)return!0
for(s=0;s<q;++s){r=a[s]
if(!(s<p))return A.a(b,s)
if(r!==b[s])return!1}return!0},
jX(a,b,c){var s,r,q
if(a===b)return!0
for(s=0;s<2;++s){r=a[s]
q=b[s]
if(r!==q)return!1}return!0},
i4(a){var s,r,q,p
for(s=J.aQ(a),r=t.R,q=12;s.p();){p=s.gq()
q=r.b(p)?(q^A.i4(p))>>>0:(q^J.ao(p))>>>0}return q},
jL(a){var s=a.gak(0)
return B.b.F((a.a?s+1:s)+7,8)},
jN(a,b){var s,r,q,p=a.aH(0,$.P())
if(p===0)return A.a9(b,0,!1,t.S)
s=A.cf(255)
p=t.S
r=A.a9(b,0,!1,p)
for(q=0;q<b;++q){B.a.k(r,b-q-1,a.c6(0,s).aM(0))
a=a.aR(0,8)}return A.bQ(r,!0,p)},
jM(a){var s,r,q,p=$.P()
for(s=0;r=a.length,s<r;++s){q=r-s-1
if(!(q>=0))return A.a(a,q)
p=p.aO(0,A.cf(a[q]).a_(0,8*s))}r=p.aH(0,$.P())
if(r===0)return p
return p},
kx(a,b,c){var s,r,q=null
try{s=B.a.eh(a,b)
return s}catch(r){if(A.an(r) instanceof A.bh){s=q
s=s==null?null:s.$0()
return s}else throw r}},
ia(a){var s={}
s.showBalanceChanges=A.aA(a.showBalanceChanges)
s.showEffects=A.aA(a.showEffects)
s.showEvents=A.aA(a.showEvents)
s.showInput=A.aA(a.showInput)
s.showObjectChanges=A.aA(a.showObjectChanges)
s.showRawEffects=A.aA(a.showRawEffects)
s.showRawInput=A.aA(a.showRawInput)
return s},
em(a){return A.kc(a)},
kc(a){var s=0,r=A.af(t.K),q,p=2,o=[],n,m,l,k,j,i,h,g
var $async$em=A.ag(function(b,c){if(b===1){o.push(c)
s=p}while(true)switch(s){case 0:p=4
s=a.transaction!=null?7:8
break
case 7:n=null
k=a.transaction
s=k!=null&&typeof k==="string"?9:11
break
case 9:n=A.k(a.transaction)
s=10
break
case 11:s=12
return A.aB(A.jc(t.m.a(a.transaction.toJSON()),t.N),$async$em)
case 12:m=c
n=A.ip(A.iq(m),B.v)
case 10:j={}
j.chain=A.E(a.chain)
k=a.account
if(k==null)k=a.address
j.account=k
j.transaction=n
j.requestType=A.E(a.requestType)
k=a.options
k=k==null?null:A.ia(k)
j.options=k
q=j
s=1
break
case 8:if(a.transactionBlock!=null){l=null
k=a.transactionBlock
if(k!=null&&typeof k==="string")l=A.k(a.transactionBlock)
else{k=a.transactionBlock
if(k==null)k=null
else{k=t.K.a(k.blockData)
k=k!=null&&typeof k==="string"}i=t.K
if(k===!0)l=A.k(i.a(a.transactionBlock.blockData))
else l=A.ip(A.iq(A.k(t.m.a(v.G.JSON).stringify(i.a(a.transactionBlock.blockData)))),B.v)}j={}
j.chain=A.E(a.chain)
k=a.account
if(k==null)k=a.address
j.account=k
j.transaction=l
j.requestType=A.E(a.requestType)
k=a.options
k=k==null?null:A.ia(k)
j.options=k
q=j
s=1
break}p=2
s=6
break
case 4:p=3
g=o.pop()
s=6
break
case 3:s=2
break
case 6:throw A.d($.jl())
case 1:return A.ad(q,r)
case 2:return A.ac(o.at(-1),r)}})
return A.ae($async$em,r)},
is(a){var s={}
s.signTransaction=a
s.version="1.0.0"
return s},
S(a){var s,r
if(a==null)return A.b([],t.f)
s=[]
r=A.k4(a,"Array")
if(r){t.c.a(a)
s=a}else s.push(a)
return A.bQ(s,!0,t.X)},
ar(a){if(a==null)return null
if(typeof a==="string")return a
return null}},B={}
var w=[A,J,B]
var $={}
A.hh.prototype={}
J.cT.prototype={
X(a,b){return a===b},
gv(a){return A.bZ(a)},
i(a){return"Instance of '"+A.eC(a)+"'"},
gB(a){return A.b1(A.hF(this))}}
J.bG.prototype={
i(a){return String(a)},
bf(a,b){return b||a},
gv(a){return a?519018:218159},
gB(a){return A.b1(t.y)},
$it:1,
$iA:1}
J.bJ.prototype={
X(a,b){return null==b},
i(a){return"null"},
gv(a){return 0},
$it:1}
J.z.prototype={$ih:1}
J.aJ.prototype={
gv(a){return 0},
i(a){return String(a)}}
J.da.prototype={}
J.c9.prototype={}
J.B.prototype={
i(a){var s=a[$.bs()]
if(s==null)return this.cg(a)
return"JavaScript function for "+J.Z(s)},
$iaS:1}
J.bb.prototype={
gv(a){return 0},
i(a){return String(a)}}
J.bc.prototype={
gv(a){return 0},
i(a){return String(a)}}
J.o.prototype={
m(a,b){A.V(a).c.a(b)
a.$flags&1&&A.v(a,29)
a.push(b)},
ap(a,b){var s
a.$flags&1&&A.v(a,"remove",1)
for(s=0;s<a.length;++s)if(J.h5(a[s],b)){a.splice(s,1)
return!0}return!1},
a5(a,b){var s
A.V(a).h("i<1>").a(b)
a.$flags&1&&A.v(a,"addAll",2)
if(Array.isArray(b)){this.cp(a,b)
return}for(s=J.aQ(b);s.p();)a.push(s.gq())},
cp(a,b){var s,r
t.b.a(b)
s=b.length
if(s===0)return
if(a===b)throw A.d(A.a8(a))
for(r=0;r<s;++r)a.push(b[r])},
bX(a){a.$flags&1&&A.v(a,"clear","clear")
a.length=0},
ab(a,b,c){var s=A.V(a)
return new A.U(a,s.u(c).h("1(2)").a(b),s.h("@<1>").u(c).h("U<1,2>"))},
T(a,b){var s,r=A.a9(a.length,"",!1,t.N)
for(s=0;s<a.length;++s)this.k(r,s,A.n(a[s]))
return r.join(b)},
bc(a){return this.T(a,"")},
c2(a,b){return A.ho(a,0,A.cB(b,"count",t.S),A.V(a).c)},
a7(a,b,c){var s,r,q,p=A.V(a)
p.h("A(1)").a(b)
p.h("1()?").a(c)
s=a.length
for(r=0;r<s;++r){q=a[r]
if(b.$1(q))return q
if(a.length!==s)throw A.d(A.a8(a))}if(c!=null)return c.$0()
throw A.d(A.i5())},
eh(a,b){b.toString
return this.a7(a,b,null)},
E(a,b){if(!(b>=0&&b<a.length))return A.a(a,b)
return a[b]},
W(a,b,c){if(b<0||b>a.length)throw A.d(A.a1(b,0,a.length,"start",null))
if(c==null)c=a.length
else if(c<b||c>a.length)throw A.d(A.a1(c,b,a.length,"end",null))
if(b===c)return A.b([],A.V(a))
return A.b(a.slice(b,c),A.V(a))},
bj(a,b){return this.W(a,b,null)},
i(a){return A.i6(a,"[","]")},
gA(a){return new J.bu(a,a.length,A.V(a).h("bu<1>"))},
gv(a){return A.bZ(a)},
gn(a){return a.length},
j(a,b){if(!(b>=0&&b<a.length))throw A.d(A.fR(a,b))
return a[b]},
k(a,b,c){A.V(a).c.a(c)
a.$flags&2&&A.v(a)
if(!(b>=0&&b<a.length))throw A.d(A.fR(a,b))
a[b]=c},
$il:1,
$ii:1,
$im:1}
J.en.prototype={}
J.bu.prototype={
gq(){var s=this.d
return s==null?this.$ti.c.a(s):s},
p(){var s,r=this,q=r.a,p=q.length
if(r.b!==p){q=A.am(q)
throw A.d(q)}s=r.c
if(s>=p){r.d=null
return!1}r.d=q[s]
r.c=s+1
return!0},
$iM:1}
J.bK.prototype={
aM(a){var s
if(a>=-2147483648&&a<=2147483647)return a|0
if(isFinite(a)){s=a<0?Math.ceil(a):Math.floor(a)
return s+0}throw A.d(A.dh(""+a+".toInt()"))},
ew(a,b){var s,r,q,p,o
if(b<2||b>36)throw A.d(A.a1(b,2,36,"radix",null))
s=a.toString(b)
r=s.length
q=r-1
if(!(q>=0))return A.a(s,q)
if(s.charCodeAt(q)!==41)return s
p=/^([\da-z]+)(?:\.([\da-z]+))?\(e\+(\d+)\)$/.exec(s)
if(p==null)A.X(A.dh("Unexpected toString result: "+s))
r=p.length
if(1>=r)return A.a(p,1)
s=p[1]
if(3>=r)return A.a(p,3)
o=+p[3]
r=p[2]
if(r!=null){s+=r
o-=r.length}return s+B.e.V("0",o)},
i(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gv(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
Y(a,b){var s=a%b
if(s===0)return 0
if(s>0)return s
return s+b},
cj(a,b){if((a|0)===a)if(b>=1)return a/b|0
return this.bQ(a,b)},
F(a,b){return(a|0)===a?a/b|0:this.bQ(a,b)},
bQ(a,b){var s=a/b
if(s>=-2147483648&&s<=2147483647)return s|0
if(s>0){if(s!==1/0)return Math.floor(s)}else if(s>-1/0)return Math.ceil(s)
throw A.d(A.dh("Result of truncating division is "+A.n(s)+": "+A.n(a)+" ~/ "+b))},
a_(a,b){if(b<0)throw A.d(A.cA(b))
return b>31?0:a<<b>>>0},
a3(a,b){var s
if(a>0)s=this.bL(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
b6(a,b){if(0>b)throw A.d(A.cA(b))
return this.bL(a,b)},
bL(a,b){return b>31?0:a>>>b},
gB(a){return A.b1(t.o)},
$ir:1,
$ib7:1}
J.bI.prototype={
gak(a){var s,r=a<0?-a-1:a,q=r
for(s=32;q>=4294967296;){q=this.F(q,4294967296)
s+=32}return s-Math.clz32(q)},
gB(a){return A.b1(t.S)},
$it:1,
$ic:1}
J.cU.prototype={
gB(a){return A.b1(t.i)},
$it:1}
J.ba.prototype={
bi(a,b){var s=b.length
if(s>a.length)return!1
return b===a.substring(0,s)},
au(a,b,c){return a.substring(b,A.c_(b,c,a.length))},
aS(a,b){return this.au(a,b,null)},
V(a,b){var s,r
if(0>=b)return""
if(b===1||a.length===0)return a
if(b!==b>>>0)throw A.d(B.ai)
for(s=a,r="";!0;){if((b&1)===1)r=s+r
b=b>>>1
if(b===0)break
s+=s}return r},
bZ(a,b,c){var s=b-a.length
if(s<=0)return a
return this.V(c,s)+a},
ep(a,b,c){var s=b-a.length
if(s<=0)return a
return a+this.V(c,s)},
ek(a,b){var s=a.indexOf(b,0)
return s},
i(a){return a},
gv(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
gB(a){return A.b1(t.N)},
gn(a){return a.length},
$it:1,
$ieB:1,
$ij:1}
A.bj.prototype={
gA(a){return new A.bx(J.aQ(this.gaF()),A.K(this).h("bx<1,2>"))},
gn(a){return J.ai(this.gaF())},
E(a,b){return A.K(this).y[1].a(J.h6(this.gaF(),b))},
i(a){return J.Z(this.gaF())}}
A.bx.prototype={
p(){return this.a.p()},
gq(){return this.$ti.y[1].a(this.a.gq())},
$iM:1}
A.ch.prototype={
j(a,b){return this.$ti.y[1].a(J.jD(this.a,b))},
$il:1,
$im:1}
A.ap.prototype={
gaF(){return this.a}}
A.bN.prototype={
i(a){return"LateInitializationError: "+this.a}}
A.eJ.prototype={}
A.l.prototype={}
A.F.prototype={
gA(a){var s=this
return new A.aV(s,s.gn(s),A.K(s).h("aV<F.E>"))},
T(a,b){var s,r,q,p=this,o=p.gn(p)
if(b.length!==0){if(o===0)return""
s=A.n(p.E(0,0))
if(o!==p.gn(p))throw A.d(A.a8(p))
for(r=s,q=1;q<o;++q){r=r+b+A.n(p.E(0,q))
if(o!==p.gn(p))throw A.d(A.a8(p))}return r.charCodeAt(0)==0?r:r}else{for(q=0,r="";q<o;++q){r+=A.n(p.E(0,q))
if(o!==p.gn(p))throw A.d(A.a8(p))}return r.charCodeAt(0)==0?r:r}},
bc(a){return this.T(0,"")},
ab(a,b,c){var s=A.K(this)
return new A.U(this,s.u(c).h("1(F.E)").a(b),s.h("@<F.E>").u(c).h("U<1,2>"))}}
A.c4.prototype={
gcV(){var s=J.ai(this.a),r=this.c
if(r==null||r>s)return s
return r},
ge5(){var s=J.ai(this.a),r=this.b
if(r>s)return s
return r},
gn(a){var s,r=J.ai(this.a),q=this.b
if(q>=r)return 0
s=this.c
if(s==null||s>=r)return r-q
return s-q},
E(a,b){var s=this,r=s.ge5()+b
if(b<0||r>=s.gcV())throw A.d(A.hd(b,s.gn(0),s,"index"))
return J.h6(s.a,r)},
cf(a,b){var s,r,q=this
A.db(b,"count")
s=q.b+b
r=q.c
if(r!=null&&s>=r)return new A.aR(q.$ti.h("aR<1>"))
return A.ho(q.a,s,r,q.$ti.c)}}
A.aV.prototype={
gq(){var s=this.d
return s==null?this.$ti.c.a(s):s},
p(){var s,r=this,q=r.a,p=J.b3(q),o=p.gn(q)
if(r.b!==o)throw A.d(A.a8(q))
s=r.c
if(s>=o){r.d=null
return!1}r.d=p.E(q,s);++r.c
return!0},
$iM:1}
A.au.prototype={
gA(a){var s=this.a
return new A.bR(s.gA(s),this.b,A.K(this).h("bR<1,2>"))},
gn(a){var s=this.a
return s.gn(s)},
E(a,b){var s=this.a
return this.b.$1(s.E(s,b))}}
A.bB.prototype={$il:1}
A.bR.prototype={
p(){var s=this,r=s.b
if(r.p()){s.a=s.c.$1(r.gq())
return!0}s.a=null
return!1},
gq(){var s=this.a
return s==null?this.$ti.y[1].a(s):s},
$iM:1}
A.U.prototype={
gn(a){return J.ai(this.a)},
E(a,b){return this.b.$1(J.h6(this.a,b))}}
A.cc.prototype={
gA(a){return new A.cd(J.aQ(this.a),this.b,this.$ti.h("cd<1>"))},
ab(a,b,c){var s=this.$ti
return new A.au(this,s.u(c).h("1(2)").a(b),s.h("@<1>").u(c).h("au<1,2>"))}}
A.cd.prototype={
p(){var s,r
for(s=this.a,r=this.b;s.p();)if(r.$1(s.gq()))return!0
return!1},
gq(){return this.a.gq()},
$iM:1}
A.aR.prototype={
gA(a){return B.ab},
gn(a){return 0},
E(a,b){throw A.d(A.a1(b,0,0,"index",null))},
ab(a,b,c){this.$ti.u(c).h("1(2)").a(b)
return new A.aR(c.h("aR<0>"))}}
A.bC.prototype={
p(){return!1},
gq(){throw A.d(A.i5())},
$iM:1}
A.Q.prototype={}
A.c0.prototype={
gn(a){return J.ai(this.a)},
E(a,b){var s=this.a,r=J.b3(s)
return r.E(s,r.gn(s)-1-b)}}
A.cx.prototype={}
A.bz.prototype={
i(a){return A.hl(this)},
$iat:1}
A.bF.prototype={
aB(){var s=this,r=s.$map
if(r==null){r=new A.bM(s.$ti.h("bM<1,2>"))
A.j7(s.a,r)
s.$map=r}return r},
j(a,b){return this.aB().j(0,b)},
am(a,b){this.$ti.h("~(1,2)").a(b)
this.aB().am(0,b)},
gan(){var s=this.aB()
return new A.aU(s,A.K(s).h("aU<1>"))},
gn(a){return this.aB().a}}
A.eT.prototype={
U(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
if(p==null)return null
s=Object.create(null)
r=q.b
if(r!==-1)s.arguments=p[r+1]
r=q.c
if(r!==-1)s.argumentsExpr=p[r+1]
r=q.d
if(r!==-1)s.expr=p[r+1]
r=q.e
if(r!==-1)s.method=p[r+1]
r=q.f
if(r!==-1)s.receiver=p[r+1]
return s}}
A.bY.prototype={
i(a){return"Null check operator used on a null value"}}
A.cX.prototype={
i(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.dg.prototype={
i(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.eA.prototype={
i(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.bE.prototype={}
A.cq.prototype={
i(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$iak:1}
A.aF.prototype={
i(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.jf(r==null?"unknown":r)+"'"},
$iaS:1,
geD(){return this},
$C:"$1",
$R:1,
$D:null}
A.cI.prototype={$C:"$0",$R:0}
A.cJ.prototype={$C:"$2",$R:2}
A.de.prototype={}
A.dd.prototype={
i(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.jf(s)+"'"}}
A.b9.prototype={
X(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.b9))return!1
return this.$_target===b.$_target&&this.a===b.a},
gv(a){return(A.dw(this.a)^A.bZ(this.$_target))>>>0},
i(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.eC(this.a)+"'")}}
A.dc.prototype={
i(a){return"RuntimeError: "+this.a}}
A.aq.prototype={
gn(a){return this.a},
gan(){return new A.aU(this,A.K(this).h("aU<1>"))},
aa(a){var s=this.em(a)
return s},
em(a){var s=this.d
if(s==null)return!1
return this.aJ(s[this.aI(a)],a)>=0},
j(a,b){var s,r,q,p,o=null
if(typeof b=="string"){s=this.b
if(s==null)return o
r=s[b]
q=r==null?o:r.b
return q}else if(typeof b=="number"&&(b&0x3fffffff)===b){p=this.c
if(p==null)return o
r=p[b]
q=r==null?o:r.b
return q}else return this.en(b)},
en(a){var s,r,q=this.d
if(q==null)return null
s=q[this.aI(a)]
r=this.aJ(s,a)
if(r<0)return null
return s[r].b},
k(a,b,c){var s,r,q,p,o,n,m=this,l=A.K(m)
l.c.a(b)
l.y[1].a(c)
if(typeof b=="string"){s=m.b
m.bk(s==null?m.b=m.b2():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=m.c
m.bk(r==null?m.c=m.b2():r,b,c)}else{q=m.d
if(q==null)q=m.d=m.b2()
p=m.aI(b)
o=q[p]
if(o==null)q[p]=[m.b3(b,c)]
else{n=m.aJ(o,b)
if(n>=0)o[n].b=c
else o.push(m.b3(b,c))}}},
ap(a,b){var s=this.dr(this.b,b)
return s},
am(a,b){var s,r,q=this
A.K(q).h("~(1,2)").a(b)
s=q.e
r=q.r
for(;s!=null;){b.$2(s.a,s.b)
if(r!==q.r)throw A.d(A.a8(q))
s=s.c}},
bk(a,b,c){var s,r=A.K(this)
r.c.a(b)
r.y[1].a(c)
s=a[b]
if(s==null)a[b]=this.b3(b,c)
else s.b=c},
dr(a,b){var s
if(a==null)return null
s=a[b]
if(s==null)return null
this.e6(s)
delete a[b]
return s.b},
bF(){this.r=this.r+1&1073741823},
b3(a,b){var s=this,r=A.K(s),q=new A.ew(r.c.a(a),r.y[1].a(b))
if(s.e==null)s.e=s.f=q
else{r=s.f
r.toString
q.d=r
s.f=r.c=q}++s.a
s.bF()
return q},
e6(a){var s=this,r=a.d,q=a.c
if(r==null)s.e=q
else r.c=q
if(q==null)s.f=r
else q.d=r;--s.a
s.bF()},
aI(a){return J.ao(a)&1073741823},
aJ(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.h5(a[r].a,b))return r
return-1},
i(a){return A.hl(this)},
b2(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
$ihj:1}
A.ew.prototype={}
A.aU.prototype={
gn(a){return this.a.a},
gA(a){var s=this.a
return new A.bP(s,s.r,s.e,this.$ti.h("bP<1>"))}}
A.bP.prototype={
gq(){return this.d},
p(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.d(A.a8(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.a
r.c=s.c
return!0}},
$iM:1}
A.as.prototype={
gn(a){return this.a.a},
gA(a){var s=this.a
return new A.bO(s,s.r,s.e,this.$ti.h("bO<1,2>"))}}
A.bO.prototype={
gq(){var s=this.d
s.toString
return s},
p(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.d(A.a8(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=new A.T(s.a,s.b,r.$ti.h("T<1,2>"))
r.c=s.c
return!0}},
$iM:1}
A.bM.prototype={
aI(a){return A.lT(a)&1073741823},
aJ(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.h5(a[r].a,b))return r
return-1}}
A.fU.prototype={
$1(a){return this.a(a)},
$S:23}
A.fV.prototype={
$2(a,b){return this.a(a,b)},
$S:44}
A.fW.prototype={
$1(a){return this.a(A.k(a))},
$S:49}
A.cp.prototype={}
A.cW.prototype={
i(a){return"RegExp/"+this.a+"/"+this.b.flags},
$ieB:1}
A.ff.prototype={
N(){var s=this.b
if(s===this)throw A.d(new A.bN("Field '"+this.a+"' has not been initialized."))
return s}}
A.bS.prototype={
gB(a){return B.aB},
bU(a,b,c){var s
A.fK(a,b,c)
s=new Uint8Array(a,b,c)
return s},
e9(a,b,c){var s
A.fK(a,b,c)
s=new DataView(a,b)
return s},
bT(a){return this.e9(a,0,null)},
$it:1,
$ibS:1,
$icH:1}
A.bW.prototype={
gbW(a){if(((a.$flags|0)&2)!==0)return new A.dt(a.buffer)
else return a.buffer}}
A.dt.prototype={
bU(a,b,c){var s=A.kk(this.a,b,c)
s.$flags=3
return s},
bT(a){var s=A.kj(this.a,0,null)
s.$flags=3
return s},
$icH:1}
A.bT.prototype={
gB(a){return B.aC},
$it:1,
$ih9:1}
A.bd.prototype={
gn(a){return a.length},
$ia0:1}
A.bU.prototype={
j(a,b){A.b_(b,a,a.length)
return a[b]},
$il:1,
$ii:1,
$im:1}
A.bV.prototype={$il:1,$ii:1,$im:1}
A.d_.prototype={
gB(a){return B.aD},
$it:1,
$idS:1}
A.d0.prototype={
gB(a){return B.aE},
$it:1,
$idT:1}
A.d1.prototype={
gB(a){return B.aF},
j(a,b){A.b_(b,a,a.length)
return a[b]},
$it:1,
$idZ:1}
A.d2.prototype={
gB(a){return B.aG},
j(a,b){A.b_(b,a,a.length)
return a[b]},
$it:1,
$ie_:1}
A.d3.prototype={
gB(a){return B.aH},
j(a,b){A.b_(b,a,a.length)
return a[b]},
$it:1,
$ie0:1}
A.d4.prototype={
gB(a){return B.aJ},
j(a,b){A.b_(b,a,a.length)
return a[b]},
$it:1,
$ieX:1}
A.d5.prototype={
gB(a){return B.aK},
j(a,b){A.b_(b,a,a.length)
return a[b]},
$it:1,
$ieY:1}
A.bX.prototype={
gB(a){return B.aL},
gn(a){return a.length},
j(a,b){A.b_(b,a,a.length)
return a[b]},
$it:1,
$ieZ:1}
A.aW.prototype={
gB(a){return B.aM},
gn(a){return a.length},
j(a,b){A.b_(b,a,a.length)
return a[b]},
$it:1,
$iaW:1,
$if_:1}
A.cl.prototype={}
A.cm.prototype={}
A.cn.prototype={}
A.co.prototype={}
A.aa.prototype={
h(a){return A.cv(v.typeUniverse,this,a)},
u(a){return A.iP(v.typeUniverse,this,a)}}
A.dn.prototype={}
A.ds.prototype={
i(a){return A.W(this.a,null)}}
A.dm.prototype={
i(a){return this.a}}
A.bm.prototype={$iaw:1}
A.f6.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:24}
A.f5.prototype={
$1(a){var s,r
this.a.a=t.M.a(a)
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:32}
A.f7.prototype={
$0(){this.a.$0()},
$S:25}
A.f8.prototype={
$0(){this.a.$0()},
$S:25}
A.fy.prototype={
cl(a,b){if(self.setTimeout!=null)self.setTimeout(A.cC(new A.fz(this,b),0),a)
else throw A.d(A.dh("`setTimeout()` not found."))}}
A.fz.prototype={
$0(){this.b.$0()},
$S:2}
A.ce.prototype={
a6(a){var s,r=this,q=r.$ti
q.h("1/?").a(a)
if(a==null)a=q.c.a(a)
if(!r.b)r.a.bm(a)
else{s=r.a
if(q.h("L<1>").b(a))s.bn(a)
else s.bp(a)}},
ba(a,b){var s=this.a
if(this.b)s.a2(new A.a3(a,b))
else s.aW(new A.a3(a,b))},
$icK:1}
A.fI.prototype={
$1(a){return this.a.$2(0,a)},
$S:12}
A.fJ.prototype={
$2(a,b){this.a.$2(1,new A.bE(a,t.l.a(b)))},
$S:46}
A.fO.prototype={
$2(a,b){this.a(A.ab(a),b)},
$S:47}
A.a3.prototype={
i(a){return A.n(this.a)},
$iw:1,
ga8(){return this.b}}
A.dY.prototype={
$0(){this.c.a(null)
this.b.bo(null)},
$S:2}
A.bk.prototype={
ba(a,b){if((this.a.a&30)!==0)throw A.d(A.hn("Future already completed"))
this.a2(A.lt(a,b))},
b9(a){return this.ba(a,null)},
$icK:1}
A.ay.prototype={
a6(a){var s,r=this.$ti
r.h("1/?").a(a)
s=this.a
if((s.a&30)!==0)throw A.d(A.hn("Future already completed"))
s.bm(r.h("1/").a(a))},
b8(){return this.a6(null)},
a2(a){this.a.aW(a)}}
A.cr.prototype={
a6(a){var s,r=this.$ti
r.h("1/?").a(a)
s=this.a
if((s.a&30)!==0)throw A.d(A.hn("Future already completed"))
s.bo(r.h("1/").a(a))},
b8(){return this.a6(null)},
a2(a){this.a.a2(a)}}
A.az.prototype={
eo(a){if((this.c&15)!==6)return!0
return this.b.b.be(t.al.a(this.d),a.a,t.y,t.K)},
ei(a){var s,r=this,q=r.e,p=null,o=t.z,n=t.K,m=a.a,l=r.b.b
if(t.Q.b(q))p=l.eu(q,m,a.b,o,n,t.l)
else p=l.be(t.v.a(q),m,o,n)
try{o=r.$ti.h("2/").a(p)
return o}catch(s){if(t.eK.b(A.an(s))){if((r.c&1)!==0)throw A.d(A.a_("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.d(A.a_("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.q.prototype={
aq(a,b,c){var s,r,q,p=this.$ti
p.u(c).h("1/(2)").a(a)
s=$.u
if(s===B.h){if(b!=null&&!t.Q.b(b)&&!t.v.b(b))throw A.d(A.dB(b,"onError",u.c))}else{c.h("@<0/>").u(p.c).h("1(2)").a(a)
if(b!=null)b=A.j0(b,s)}r=new A.q(s,c.h("q<0>"))
q=b==null?1:3
this.aw(new A.az(r,q,a,b,p.h("@<1>").u(c).h("az<1,2>")))
return r},
aL(a,b){a.toString
return this.aq(a,null,b)},
bR(a,b,c){var s,r=this.$ti
r.u(c).h("1/(2)").a(a)
s=new A.q($.u,c.h("q<0>"))
this.aw(new A.az(s,19,a,b,r.h("@<1>").u(c).h("az<1,2>")))
return s},
dA(a){this.a=this.a&1|16
this.c=a},
az(a){this.a=a.a&30|this.a&1
this.c=a.c},
aw(a){var s,r=this,q=r.a
if(q<=3){a.a=t.F.a(r.c)
r.c=a}else{if((q&4)!==0){s=t._.a(r.c)
if((s.a&24)===0){s.aw(a)
return}r.az(s)}A.dv(null,null,r.b,t.M.a(new A.fj(r,a)))}},
bI(a){var s,r,q,p,o,n,m=this,l={}
l.a=a
if(a==null)return
s=m.a
if(s<=3){r=t.F.a(m.c)
m.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){n=t._.a(m.c)
if((n.a&24)===0){n.bI(a)
return}m.az(n)}l.a=m.aE(a)
A.dv(null,null,m.b,t.M.a(new A.fo(l,m)))}},
ah(){var s=t.F.a(this.c)
this.c=null
return this.aE(s)},
aE(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
bo(a){var s,r=this,q=r.$ti
q.h("1/").a(a)
if(q.h("L<1>").b(a))A.fm(a,r,!0)
else{s=r.ah()
q.c.a(a)
r.a=8
r.c=a
A.aY(r,s)}},
bp(a){var s,r=this
r.$ti.c.a(a)
s=r.ah()
r.a=8
r.c=a
A.aY(r,s)},
cF(a){var s,r,q=this
if((a.a&16)!==0){s=q.b===a.b
s=!(s||s)}else s=!1
if(s)return
r=q.ah()
q.az(a)
A.aY(q,r)},
a2(a){var s=this.ah()
this.dA(a)
A.aY(this,s)},
bm(a){var s=this.$ti
s.h("1/").a(a)
if(s.h("L<1>").b(a)){this.bn(a)
return}this.cu(a)},
cu(a){var s=this
s.$ti.c.a(a)
s.a^=2
A.dv(null,null,s.b,t.M.a(new A.fl(s,a)))},
bn(a){A.fm(this.$ti.h("L<1>").a(a),this,!1)
return},
aW(a){this.a^=2
A.dv(null,null,this.b,t.M.a(new A.fk(this,a)))},
$iL:1}
A.fj.prototype={
$0(){A.aY(this.a,this.b)},
$S:2}
A.fo.prototype={
$0(){A.aY(this.b,this.a.a)},
$S:2}
A.fn.prototype={
$0(){A.fm(this.a.a,this.b,!0)},
$S:2}
A.fl.prototype={
$0(){this.a.bp(this.b)},
$S:2}
A.fk.prototype={
$0(){this.a.a2(this.b)},
$S:2}
A.fr.prototype={
$0(){var s,r,q,p,o,n,m,l,k=this,j=null
try{q=k.a.a
j=q.b.b.es(t.fO.a(q.d),t.z)}catch(p){s=A.an(p)
r=A.aO(p)
if(k.c&&t.n.a(k.b.a.c).a===s){q=k.a
q.c=t.n.a(k.b.a.c)}else{q=s
o=r
if(o==null)o=A.h8(q)
n=k.a
n.c=new A.a3(q,o)
q=n}q.b=!0
return}if(j instanceof A.q&&(j.a&24)!==0){if((j.a&16)!==0){q=k.a
q.c=t.n.a(j.c)
q.b=!0}return}if(j instanceof A.q){m=k.b.a
l=new A.q(m.b,m.$ti)
j.aq(new A.fs(l,m),new A.ft(l),t.H)
q=k.a
q.c=l
q.b=!1}},
$S:2}
A.fs.prototype={
$1(a){this.a.cF(this.b)},
$S:24}
A.ft.prototype={
$2(a,b){t.K.a(a)
t.l.a(b)
this.a.a2(new A.a3(a,b))},
$S:26}
A.fq.prototype={
$0(){var s,r,q,p,o,n,m,l
try{q=this.a
p=q.a
o=p.$ti
n=o.c
m=n.a(this.b)
q.c=p.b.b.be(o.h("2/(1)").a(p.d),m,o.h("2/"),n)}catch(l){s=A.an(l)
r=A.aO(l)
q=s
p=r
if(p==null)p=A.h8(q)
o=this.a
o.c=new A.a3(q,p)
o.b=!0}},
$S:2}
A.fp.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=t.n.a(l.a.a.c)
p=l.b
if(p.a.eo(s)&&p.a.e!=null){p.c=p.a.ei(s)
p.b=!1}}catch(o){r=A.an(o)
q=A.aO(o)
p=t.n.a(l.a.a.c)
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.h8(p)
m=l.b
m.c=new A.a3(p,n)
p=m}p.b=!0}},
$S:2}
A.dj.prototype={}
A.dq.prototype={}
A.cw.prototype={$iiu:1}
A.fN.prototype={
$0(){A.k0(this.a,this.b)},
$S:2}
A.dp.prototype={
ev(a){var s,r,q
t.M.a(a)
try{if(B.h===$.u){a.$0()
return}A.j1(null,null,this,a,t.H)}catch(q){s=A.an(q)
r=A.aO(q)
A.hH(t.K.a(s),t.l.a(r))}},
bV(a){return new A.fx(this,t.M.a(a))},
es(a,b){b.h("0()").a(a)
if($.u===B.h)return a.$0()
return A.j1(null,null,this,a,b)},
be(a,b,c,d){c.h("@<0>").u(d).h("1(2)").a(a)
d.a(b)
if($.u===B.h)return a.$1(b)
return A.lI(null,null,this,a,b,c,d)},
eu(a,b,c,d,e,f){d.h("@<0>").u(e).u(f).h("1(2,3)").a(a)
e.a(b)
f.a(c)
if($.u===B.h)return a.$2(b,c)
return A.lH(null,null,this,a,b,c,d,e,f)},
c0(a,b,c,d){return b.h("@<0>").u(c).u(d).h("1(2,3)").a(a)}}
A.fx.prototype={
$0(){return this.a.ev(this.b)},
$S:2}
A.ci.prototype={
gn(a){return this.a},
gan(){return new A.cj(this,this.$ti.h("cj<1>"))},
aa(a){var s,r
if(typeof a=="string"&&a!=="__proto__"){s=this.b
return s==null?!1:s[a]!=null}else if(typeof a=="number"&&(a&1073741823)===a){r=this.c
return r==null?!1:r[a]!=null}else return this.cK(a)},
cK(a){var s=this.d
if(s==null)return!1
return this.b0(this.bv(s,a),a)>=0},
j(a,b){var s,r,q
if(typeof b=="string"&&b!=="__proto__"){s=this.b
r=s==null?null:A.iF(s,b)
return r}else if(typeof b=="number"&&(b&1073741823)===b){q=this.c
r=q==null?null:A.iF(q,b)
return r}else return this.cZ(b)},
cZ(a){var s,r,q=this.d
if(q==null)return null
s=this.bv(q,a)
r=this.b0(s,a)
return r<0?null:s[r+1]},
k(a,b,c){var s,r,q,p,o,n,m=this,l=m.$ti
l.c.a(b)
l.y[1].a(c)
if(typeof b=="string"&&b!=="__proto__"){s=m.b
m.bl(s==null?m.b=A.hy():s,b,c)}else if(typeof b=="number"&&(b&1073741823)===b){r=m.c
m.bl(r==null?m.c=A.hy():r,b,c)}else{q=m.d
if(q==null)q=m.d=A.hy()
p=A.dw(b)&1073741823
o=q[p]
if(o==null){A.hz(q,p,[b,c]);++m.a
m.e=null}else{n=m.b0(o,b)
if(n>=0)o[n+1]=c
else{o.push(b,c);++m.a
m.e=null}}}},
am(a,b){var s,r,q,p,o,n,m=this,l=m.$ti
l.h("~(1,2)").a(b)
s=m.bq()
for(r=s.length,q=l.c,l=l.y[1],p=0;p<r;++p){o=s[p]
q.a(o)
n=m.j(0,o)
b.$2(o,n==null?l.a(n):n)
if(s!==m.e)throw A.d(A.a8(m))}},
bq(){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.e
if(h!=null)return h
h=A.a9(i.a,null,!1,t.z)
s=i.b
r=0
if(s!=null){q=Object.getOwnPropertyNames(s)
p=q.length
for(o=0;o<p;++o){h[r]=q[o];++r}}n=i.c
if(n!=null){q=Object.getOwnPropertyNames(n)
p=q.length
for(o=0;o<p;++o){h[r]=+q[o];++r}}m=i.d
if(m!=null){q=Object.getOwnPropertyNames(m)
p=q.length
for(o=0;o<p;++o){l=m[q[o]]
k=l.length
for(j=0;j<k;j+=2){h[r]=l[j];++r}}}return i.e=h},
bl(a,b,c){var s=this.$ti
s.c.a(b)
s.y[1].a(c)
if(a[b]==null){++this.a
this.e=null}A.hz(a,b,c)},
bv(a,b){return a[A.dw(b)&1073741823]}}
A.bl.prototype={
b0(a,b){var s,r,q
if(a==null)return-1
s=a.length
for(r=0;r<s;r+=2){q=a[r]
if(q==null?b==null:q===b)return r}return-1}}
A.cj.prototype={
gn(a){return this.a.a},
gA(a){var s=this.a
return new A.ck(s,s.bq(),this.$ti.h("ck<1>"))}}
A.ck.prototype={
gq(){var s=this.d
return s==null?this.$ti.c.a(s):s},
p(){var s=this,r=s.b,q=s.c,p=s.a
if(r!==p.e)throw A.d(A.a8(p))
else if(q>=r.length){s.d=null
return!1}else{s.d=r[q]
s.c=q+1
return!0}},
$iM:1}
A.p.prototype={
gA(a){return new A.aV(a,this.gn(a),A.b5(a).h("aV<p.E>"))},
E(a,b){return this.j(a,b)},
ab(a,b,c){var s=A.b5(a)
return new A.U(a,s.u(c).h("1(p.E)").a(b),s.h("@<p.E>").u(c).h("U<1,2>"))},
c2(a,b){return A.ho(a,0,A.cB(b,"count",t.S),A.b5(a).h("p.E"))},
i(a){return A.i6(a,"[","]")}}
A.aK.prototype={
am(a,b){var s,r,q,p=A.K(this)
p.h("~(1,2)").a(b)
for(s=this.gan(),s=s.gA(s),p=p.y[1];s.p();){r=s.gq()
q=this.j(0,r)
b.$2(r,q==null?p.a(q):q)}},
e8(a){var s,r
for(s=J.aQ(A.K(this).h("i<T<1,2>>").a(a));s.p();){r=s.gq()
this.k(0,r.a,r.b)}},
gn(a){var s=this.gan()
return s.gn(s)},
i(a){return A.hl(this)},
$iat:1}
A.ex.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.n(a)
r.a=(r.a+=s)+": "
s=A.n(b)
r.a+=s},
$S:34}
A.fF.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:true})
return s}catch(r){}return null},
$S:20}
A.fE.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:false})
return s}catch(r){}return null},
$S:20}
A.cE.prototype={
ed(a,b){var s
t.L.a(a)
s=B.a7.al(a)
return s}}
A.fB.prototype={
al(a){var s,r,q=a.length,p=A.c_(0,null,q),o=new Uint8Array(p)
for(s=0;s<p;++s){if(!(s<q))return A.a(a,s)
r=a.charCodeAt(s)
if((r&4294967168)!==0)throw A.d(A.dB(a,"string","Contains invalid characters."))
if(!(s<p))return A.a(o,s)
o[s]=r}return o}}
A.dD.prototype={}
A.fA.prototype={
al(a){var s,r,q,p
t.L.a(a)
s=a.length
r=A.c_(0,null,s)
for(q=0;q<r;++q){if(!(q<s))return A.a(a,q)
p=a[q]
if((p&4294967168)>>>0!==0){if(!this.a)throw A.d(A.hc("Invalid value in input: "+p,null,null))
return this.cM(a,0,r)}}return A.ir(a,0,r)},
cM(a,b,c){var s,r,q
t.L.a(a)
for(s=b,r="";s<c;++s){if(!(s<a.length))return A.a(a,s)
q=a[s]
r+=A.aX((q&4294967168)>>>0!==0?65533:q)}return r.charCodeAt(0)==0?r:r}}
A.dC.prototype={}
A.by.prototype={}
A.cM.prototype={}
A.cQ.prototype={}
A.f0.prototype={
al(a){var s,r,q,p,o=a.length,n=A.c_(0,null,o)
if(n===0)return new Uint8Array(0)
s=n*3
r=new Uint8Array(s)
q=new A.fG(r)
if(q.cY(a,0,n)!==n){p=n-1
if(!(p>=0&&p<o))return A.a(a,p)
q.b7()}return new Uint8Array(r.subarray(0,A.lj(0,q.b,s)))}}
A.fG.prototype={
b7(){var s,r=this,q=r.c,p=r.b,o=r.b=p+1
q.$flags&2&&A.v(q)
s=q.length
if(!(p<s))return A.a(q,p)
q[p]=239
p=r.b=o+1
if(!(o<s))return A.a(q,o)
q[o]=191
r.b=p+1
if(!(p<s))return A.a(q,p)
q[p]=189},
e7(a,b){var s,r,q,p,o,n=this
if((b&64512)===56320){s=65536+((a&1023)<<10)|b&1023
r=n.c
q=n.b
p=n.b=q+1
r.$flags&2&&A.v(r)
o=r.length
if(!(q<o))return A.a(r,q)
r[q]=s>>>18|240
q=n.b=p+1
if(!(p<o))return A.a(r,p)
r[p]=s>>>12&63|128
p=n.b=q+1
if(!(q<o))return A.a(r,q)
r[q]=s>>>6&63|128
n.b=p+1
if(!(p<o))return A.a(r,p)
r[p]=s&63|128
return!0}else{n.b7()
return!1}},
cY(a,b,c){var s,r,q,p,o,n,m,l,k=this
if(b!==c){s=c-1
if(!(s>=0&&s<a.length))return A.a(a,s)
s=(a.charCodeAt(s)&64512)===55296}else s=!1
if(s)--c
for(s=k.c,r=s.$flags|0,q=s.length,p=a.length,o=b;o<c;++o){if(!(o<p))return A.a(a,o)
n=a.charCodeAt(o)
if(n<=127){m=k.b
if(m>=q)break
k.b=m+1
r&2&&A.v(s)
s[m]=n}else{m=n&64512
if(m===55296){if(k.b+4>q)break
m=o+1
if(!(m<p))return A.a(a,m)
if(k.e7(n,a.charCodeAt(m)))o=m}else if(m===56320){if(k.b+3>q)break
k.b7()}else if(n<=2047){m=k.b
l=m+1
if(l>=q)break
k.b=l
r&2&&A.v(s)
if(!(m<q))return A.a(s,m)
s[m]=n>>>6|192
k.b=l+1
s[l]=n&63|128}else{m=k.b
if(m+2>=q)break
l=k.b=m+1
r&2&&A.v(s)
if(!(m<q))return A.a(s,m)
s[m]=n>>>12|224
m=k.b=l+1
if(!(l<q))return A.a(s,l)
s[l]=n>>>6&63|128
k.b=m+1
if(!(m<q))return A.a(s,m)
s[m]=n&63|128}}}return o}}
A.di.prototype={}
A.fD.prototype={
cL(a,b,c,d){var s,r,q,p,o,n,m,l=this
t.L.a(a)
s=A.c_(b,c,a.length)
if(b===s)return""
if(a instanceof Uint8Array){r=a
q=r
p=0}else{q=A.l4(a,b,s)
s-=b
p=b
b=0}if(s-b>=15){o=l.a
n=A.l3(o,q,b,s)
if(n!=null){if(!o)return n
if(n.indexOf("\ufffd")<0)return n}}n=l.aX(q,b,s,!0)
o=l.b
if((o&1)!==0){m=A.l5(o)
l.b=0
throw A.d(A.hc(m,a,p+l.c))}return n},
aX(a,b,c,d){var s,r,q=this
if(c-b>1000){s=B.b.F(b+c,2)
r=q.aX(a,b,s,!1)
if((q.b&1)!==0)return r
return r+q.aX(a,s,c,d)}return q.ee(a,b,c,d)},
ee(a,b,a0,a1){var s,r,q,p,o,n,m,l,k=this,j="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFFFFFFFFFFFFFFFFGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHHHHHHHHIHHHJEEBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBKCCCCCCCCCCCCDCLONNNMEEEEEEEEEEE",i=" \x000:XECCCCCN:lDb \x000:XECCCCCNvlDb \x000:XECCCCCN:lDb AAAAA\x00\x00\x00\x00\x00AAAAA00000AAAAA:::::AAAAAGG000AAAAA00KKKAAAAAG::::AAAAA:IIIIAAAAA000\x800AAAAA\x00\x00\x00\x00 AAAAA",h=65533,g=k.b,f=k.c,e=new A.bi(""),d=b+1,c=a.length
if(!(b>=0&&b<c))return A.a(a,b)
s=a[b]
$label0$0:for(r=k.a;!0;){for(;!0;d=o){if(!(s>=0&&s<256))return A.a(j,s)
q=j.charCodeAt(s)&31
f=g<=32?s&61694>>>q:(s&63|f<<6)>>>0
p=g+q
if(!(p>=0&&p<144))return A.a(i,p)
g=i.charCodeAt(p)
if(g===0){p=A.aX(f)
e.a+=p
if(d===a0)break $label0$0
break}else if((g&1)!==0){if(r)switch(g){case 69:case 67:p=A.aX(h)
e.a+=p
break
case 65:p=A.aX(h)
e.a+=p;--d
break
default:p=A.aX(h)
e.a=(e.a+=p)+A.aX(h)
break}else{k.b=g
k.c=d-1
return""}g=0}if(d===a0)break $label0$0
o=d+1
if(!(d>=0&&d<c))return A.a(a,d)
s=a[d]}o=d+1
if(!(d>=0&&d<c))return A.a(a,d)
s=a[d]
if(s<128){while(!0){if(!(o<a0)){n=a0
break}m=o+1
if(!(o>=0&&o<c))return A.a(a,o)
s=a[o]
if(s>=128){n=m-1
o=m
break}o=m}if(n-d<20)for(l=d;l<n;++l){if(!(l<c))return A.a(a,l)
p=A.aX(a[l])
e.a+=p}else{p=A.ir(a,d,n)
e.a+=p}if(n===a0)break $label0$0
d=o}else d=o}if(a1&&g>32)if(r){c=A.aX(h)
e.a+=c}else{k.b=77
k.c=a0
return""}k.b=g
k.c=f
c=e.a
return c.charCodeAt(0)==0?c:c}}
A.D.prototype={
Z(a){var s,r,q=this,p=q.c
if(p===0)return q
s=!q.a
r=q.b
p=A.O(p,r)
return new A.D(p===0?!1:s,r,p)},
cQ(a){var s,r,q,p,o,n,m,l=this.c
if(l===0)return $.P()
s=l+a
r=this.b
q=new Uint16Array(s)
for(p=l-1,o=r.length;p>=0;--p){n=p+a
if(!(p<o))return A.a(r,p)
m=r[p]
if(!(n>=0&&n<s))return A.a(q,n)
q[n]=m}o=this.a
n=A.O(s,q)
return new A.D(n===0?!1:o,q,n)},
cR(a){var s,r,q,p,o,n,m,l,k=this,j=k.c
if(j===0)return $.P()
s=j-a
if(s<=0)return k.a?$.hT():$.P()
r=k.b
q=new Uint16Array(s)
for(p=r.length,o=a;o<j;++o){n=o-a
if(!(o>=0&&o<p))return A.a(r,o)
m=r[o]
if(!(n<s))return A.a(q,n)
q[n]=m}n=k.a
m=A.O(s,q)
l=new A.D(m===0?!1:n,q,m)
if(n)for(o=0;o<a;++o){if(!(o<p))return A.a(r,o)
if(r[o]!==0)return l.ar(0,$.aE())}return l},
a_(a,b){var s,r,q,p,o,n=this
if(b<0)throw A.d(A.a_("shift-amount must be posititve "+b,null))
s=n.c
if(s===0)return n
r=B.b.F(b,16)
if(B.b.Y(b,16)===0)return n.cQ(r)
q=s+r+1
p=new Uint16Array(q)
A.iC(n.b,s,b,p)
s=n.a
o=A.O(q,p)
return new A.D(o===0?!1:s,p,o)},
aR(a,b){var s,r,q,p,o,n,m,l,k,j=this
if(b<0)throw A.d(A.a_("shift-amount must be posititve "+b,null))
s=j.c
if(s===0)return j
r=B.b.F(b,16)
q=B.b.Y(b,16)
if(q===0)return j.cR(r)
p=s-r
if(p<=0)return j.a?$.hT():$.P()
o=j.b
n=new Uint16Array(p)
A.kM(o,s,b,n)
s=j.a
m=A.O(p,n)
l=new A.D(m===0?!1:s,n,m)
if(s){s=o.length
if(!(r>=0&&r<s))return A.a(o,r)
if((o[r]&B.b.a_(1,q)-1)!==0)return l.ar(0,$.aE())
for(k=0;k<r;++k){if(!(k<s))return A.a(o,k)
if(o[k]!==0)return l.ar(0,$.aE())}}return l},
aH(a,b){var s,r=this.a
if(r===b.a){s=A.fc(this.b,this.c,b.b,b.c)
return r?0-s:s}return r?-1:1},
av(a,b){var s,r,q,p=this,o=p.c,n=a.c
if(o<n)return a.av(p,b)
if(o===0)return $.P()
if(n===0)return p.a===b?p:p.Z(0)
s=o+1
r=new Uint16Array(s)
A.kK(p.b,o,a.b,n,r)
q=A.O(s,r)
return new A.D(q===0?!1:b,r,q)},
a1(a,b){var s,r,q,p=this,o=p.c
if(o===0)return $.P()
s=a.c
if(s===0)return p.a===b?p:p.Z(0)
r=new Uint16Array(o)
A.dl(p.b,o,a.b,s,r)
q=A.O(o,r)
return new A.D(q===0?!1:b,r,q)},
cn(a,b){var s,r,q,p,o,n,m,l,k=this.c,j=a.c
k=k<j?k:j
s=this.b
r=a.b
q=new Uint16Array(k)
for(p=s.length,o=r.length,n=0;n<k;++n){if(!(n<p))return A.a(s,n)
m=s[n]
if(!(n<o))return A.a(r,n)
l=r[n]
if(!(n<k))return A.a(q,n)
q[n]=m&l}p=A.O(k,q)
return new A.D(!1,q,p)},
cm(a,b){var s,r,q,p,o,n=this.c,m=this.b,l=a.b,k=new Uint16Array(n),j=a.c
if(n<j)j=n
for(s=m.length,r=l.length,q=0;q<j;++q){if(!(q<s))return A.a(m,q)
p=m[q]
if(!(q<r))return A.a(l,q)
o=l[q]
if(!(q<n))return A.a(k,q)
k[q]=p&~o}for(q=j;q<n;++q){if(!(q>=0&&q<s))return A.a(m,q)
r=m[q]
if(!(q<n))return A.a(k,q)
k[q]=r}s=A.O(n,k)
return new A.D(!1,k,s)},
co(a,b){var s,r,q,p,o,n,m,l,k=this.c,j=a.c,i=k>j?k:j,h=this.b,g=a.b,f=new Uint16Array(i)
if(k<j){s=k
r=a}else{s=j
r=this}for(q=h.length,p=g.length,o=0;o<s;++o){if(!(o<q))return A.a(h,o)
n=h[o]
if(!(o<p))return A.a(g,o)
m=g[o]
if(!(o<i))return A.a(f,o)
f[o]=n|m}l=r.b
for(q=l.length,o=s;o<i;++o){if(!(o>=0&&o<q))return A.a(l,o)
p=l[o]
if(!(o<i))return A.a(f,o)
f[o]=p}q=A.O(i,f)
return new A.D(q!==0,f,q)},
c6(a,b){var s,r,q,p=this
t.ev.a(b)
if(p.c===0||b.c===0)return $.P()
s=p.a
if(s===b.a){if(s){s=$.aE()
return p.a1(s,!0).co(b.a1(s,!0),!0).av(s,!0)}return p.cn(b,!1)}if(s){r=p
q=b}else{r=b
q=p}return q.cm(r.a1($.aE(),!1),!1)},
aO(a,b){var s,r,q=this,p=q.c
if(p===0)return b
s=b.c
if(s===0)return q
r=q.a
if(r===b.a)return q.av(b,r)
if(A.fc(q.b,p,b.b,s)>=0)return q.a1(b,r)
return b.a1(q,!r)},
ar(a,b){var s,r,q=this,p=q.c
if(p===0)return b.Z(0)
s=b.c
if(s===0)return q
r=q.a
if(r!==b.a)return q.av(b,r)
if(A.fc(q.b,p,b.b,s)>=0)return q.a1(b,r)
return b.a1(q,!r)},
V(a,b){var s,r,q,p,o,n,m,l=this.c,k=b.c
if(l===0||k===0)return $.P()
s=l+k
r=this.b
q=b.b
p=new Uint16Array(s)
for(o=q.length,n=0;n<k;){if(!(n<o))return A.a(q,n)
A.iD(q[n],r,0,p,n,l);++n}o=this.a!==b.a
m=A.O(s,p)
return new A.D(m===0?!1:o,p,m)},
bs(a){var s,r,q,p
if(this.c<a.c)return $.P()
this.bt(a)
s=$.ht.N()-$.cg.N()
r=A.hv($.hs.N(),$.cg.N(),$.ht.N(),s)
q=A.O(s,r)
p=new A.D(!1,r,q)
return this.a!==a.a&&q>0?p.Z(0):p},
bJ(a){var s,r,q,p=this
if(p.c<a.c)return p
p.bt(a)
s=A.hv($.hs.N(),0,$.cg.N(),$.cg.N())
r=A.O($.cg.N(),s)
q=new A.D(!1,s,r)
if($.hu.N()>0)q=q.aR(0,$.hu.N())
return p.a&&q.c>0?q.Z(0):q},
bt(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b=c.c
if(b===$.iz&&a.c===$.iB&&c.b===$.iy&&a.b===$.iA)return
s=a.b
r=a.c
q=r-1
if(!(q>=0&&q<s.length))return A.a(s,q)
p=16-B.b.gak(s[q])
if(p>0){o=new Uint16Array(r+5)
n=A.ix(s,r,p,o)
m=new Uint16Array(b+5)
l=A.ix(c.b,b,p,m)}else{m=A.hv(c.b,0,b,b+2)
n=r
o=s
l=b}q=n-1
if(!(q>=0&&q<o.length))return A.a(o,q)
k=o[q]
j=l-n
i=new Uint16Array(l)
h=A.hw(o,n,j,i)
g=l+1
q=m.$flags|0
if(A.fc(m,l,i,h)>=0){q&2&&A.v(m)
if(!(l>=0&&l<m.length))return A.a(m,l)
m[l]=1
A.dl(m,g,i,h,m)}else{q&2&&A.v(m)
if(!(l>=0&&l<m.length))return A.a(m,l)
m[l]=0}q=n+2
f=new Uint16Array(q)
if(!(n>=0&&n<q))return A.a(f,n)
f[n]=1
A.dl(f,n+1,o,n,f)
e=l-1
for(q=m.length;j>0;){d=A.kL(k,m,e);--j
A.iD(d,f,0,m,j,n)
if(!(e>=0&&e<q))return A.a(m,e)
if(m[e]<d){h=A.hw(f,n,j,i)
A.dl(m,g,i,h,m)
for(;--d,m[e]<d;)A.dl(m,g,i,h,m)}--e}$.iy=c.b
$.iz=b
$.iA=s
$.iB=r
$.hs.b=m
$.ht.b=g
$.cg.b=n
$.hu.b=p},
gv(a){var s,r,q,p,o=new A.fd(),n=this.c
if(n===0)return 6707
s=this.a?83585:429689
for(r=this.b,q=r.length,p=0;p<n;++p){if(!(p<q))return A.a(r,p)
s=o.$2(s,r[p])}return new A.fe().$1(s)},
X(a,b){if(b==null)return!1
return b instanceof A.D&&this.aH(0,b)===0},
gak(a){var s,r,q,p,o,n,m=this.c
if(m===0)return 0
s=this.b
r=m-1
q=s.length
if(!(r>=0&&r<q))return A.a(s,r)
p=s[r]
o=16*r+B.b.gak(p)
if(!this.a)return o
if((p&p-1)!==0)return o
for(n=m-2;n>=0;--n){if(!(n<q))return A.a(s,n)
if(s[n]!==0)return o}return o-1},
er(a){var s,r
if(a===0)return $.aE()
s=$.aE()
for(r=this;a!==0;){if((a&1)===1)s=s.V(0,r)
a=a>>>1
if(a!==0)r=r.V(0,r)}return s},
aM(a){var s,r,q,p
for(s=this.c-1,r=this.b,q=r.length,p=0;s>=0;--s){if(!(s<q))return A.a(r,s)
p=p*65536+r[s]}return this.a?-p:p},
i(a){var s,r,q,p,o,n=this,m=n.c
if(m===0)return"0"
if(m===1){if(n.a){m=n.b
if(0>=m.length)return A.a(m,0)
return B.b.i(-m[0])}m=n.b
if(0>=m.length)return A.a(m,0)
return B.b.i(m[0])}s=A.b([],t.s)
m=n.a
r=m?n.Z(0):n
for(;r.c>1;){q=$.jw()
if(q.c===0)A.X(B.x)
p=r.bJ(q).i(0)
B.a.m(s,p)
o=p.length
if(o===1)B.a.m(s,"000")
if(o===2)B.a.m(s,"00")
if(o===3)B.a.m(s,"0")
r=r.bs(q)}q=r.b
if(0>=q.length)return A.a(q,0)
B.a.m(s,B.b.i(q[0]))
if(m)B.a.m(s,"-")
return new A.c0(s,t.bJ).bc(0)}}
A.fd.prototype={
$2(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
$S:42}
A.fe.prototype={
$1(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
$S:21}
A.cN.prototype={
X(a,b){var s
if(b==null)return!1
s=!1
if(b instanceof A.cN)if(this.a===b.a)s=this.b===b.b
return s},
gv(a){return A.kl(this.a,this.b,B.o,B.o)},
i(a){var s=this,r=A.jY(A.kt(s)),q=A.cO(A.kr(s)),p=A.cO(A.kn(s)),o=A.cO(A.ko(s)),n=A.cO(A.kq(s)),m=A.cO(A.ks(s)),l=A.i3(A.kp(s)),k=s.b,j=k===0?"":A.i3(k)
return r+"-"+q+"-"+p+" "+o+":"+n+":"+m+"."+l+j+"Z"}}
A.cP.prototype={
X(a,b){if(b==null)return!1
return b instanceof A.cP},
gv(a){return B.b.gv(0)},
i(a){return"0:00:00."+B.e.bZ(B.b.i(0),6,"0")}}
A.fh.prototype={
i(a){return this.R()}}
A.w.prototype={
ga8(){return A.km(this)}}
A.cF.prototype={
i(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.dR(s)
return"Assertion failed"}}
A.aw.prototype={}
A.a7.prototype={
gb_(){return"Invalid argument"+(!this.a?"(s)":"")},
gaZ(){return""},
i(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+p,n=s.gb_()+q+o
if(!s.a)return n
return n+s.gaZ()+": "+A.dR(s.gbb())},
gbb(){return this.b}}
A.bg.prototype={
gbb(){return A.iU(this.b)},
gb_(){return"RangeError"},
gaZ(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.n(q):""
else if(q==null)s=": Not greater than or equal to "+A.n(r)
else if(q>r)s=": Not in inclusive range "+A.n(r)+".."+A.n(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.n(r)
return s}}
A.cR.prototype={
gbb(){return A.ab(this.b)},
gb_(){return"RangeError"},
gaZ(){if(A.ab(this.b)<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gn(a){return this.f}}
A.ca.prototype={
i(a){return"Unsupported operation: "+this.a}}
A.df.prototype={
i(a){var s=this.a
return s!=null?"UnimplementedError: "+s:"UnimplementedError"}}
A.bh.prototype={
i(a){return"Bad state: "+this.a}}
A.cL.prototype={
i(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.dR(s)+"."}}
A.d6.prototype={
i(a){return"Out of Memory"},
ga8(){return null},
$iw:1}
A.c2.prototype={
i(a){return"Stack Overflow"},
ga8(){return null},
$iw:1}
A.fi.prototype={
i(a){return"Exception: "+this.a}}
A.dU.prototype={
i(a){var s,r,q,p,o,n,m,l,k,j,i,h=this.a,g=""!==h?"FormatException: "+h:"FormatException",f=this.c,e=this.b
if(typeof e=="string"){if(f!=null)s=f<0||f>e.length
else s=!1
if(s)f=null
if(f==null){if(e.length>78)e=B.e.au(e,0,75)+"..."
return g+"\n"+e}for(r=e.length,q=1,p=0,o=!1,n=0;n<f;++n){if(!(n<r))return A.a(e,n)
m=e.charCodeAt(n)
if(m===10){if(p!==n||!o)++q
p=n+1
o=!1}else if(m===13){++q
p=n+1
o=!0}}g=q>1?g+(" (at line "+q+", character "+(f-p+1)+")\n"):g+(" (at character "+(f+1)+")\n")
for(n=f;n<r;++n){if(!(n>=0))return A.a(e,n)
m=e.charCodeAt(n)
if(m===10||m===13){r=n
break}}l=""
if(r-p>78){k="..."
if(f-p<75){j=p+75
i=p}else{if(r-f<75){i=r-75
j=r
k=""}else{i=f-36
j=f+36}l="..."}}else{j=r
i=p
k=""}return g+l+B.e.au(e,i,j)+k+"\n"+B.e.V(" ",f-i+l.length)+"^\n"}else return f!=null?g+(" (at offset "+A.n(f)+")"):g}}
A.cS.prototype={
ga8(){return null},
i(a){return"IntegerDivisionByZeroException"},
$iw:1}
A.i.prototype={
ab(a,b,c){var s=A.K(this)
return A.id(this,s.u(c).h("1(i.E)").a(b),s.h("i.E"),c)},
T(a,b){var s,r,q=this.gA(this)
if(!q.p())return""
s=J.Z(q.gq())
if(!q.p())return s
if(b.length===0){r=s
do r+=J.Z(q.gq())
while(q.p())}else{r=s
do r=r+b+J.Z(q.gq())
while(q.p())}return r.charCodeAt(0)==0?r:r},
gn(a){var s,r=this.gA(this)
for(s=0;r.p();)++s
return s},
E(a,b){var s,r
A.db(b,"index")
s=this.gA(this)
for(r=b;s.p();){if(r===0)return s.gq();--r}throw A.d(A.hd(b,b-r,this,"index"))},
i(a){return A.k3(this,"(",")")}}
A.T.prototype={
i(a){return"MapEntry("+A.n(this.a)+": "+A.n(this.b)+")"}}
A.H.prototype={
gv(a){return A.e.prototype.gv.call(this,0)},
i(a){return"null"}}
A.e.prototype={$ie:1,
X(a,b){return this===b},
gv(a){return A.bZ(this)},
i(a){return"Instance of '"+A.eC(this)+"'"},
gB(a){return A.hL(this)},
toString(){return this.i(this)}}
A.dr.prototype={
i(a){return""},
$iak:1}
A.bi.prototype={
gn(a){return this.a.length},
i(a){var s=this.a
return s.charCodeAt(0)==0?s:s}}
A.dX.prototype={
$2(a,b){var s=t.g
this.a.aq(new A.dV(s.a(a)),new A.dW(s.a(b)),t.X)},
$S:22}
A.dV.prototype={
$1(a){var s=this.a
return s.call(s)},
$S:33}
A.dW.prototype={
$2(a,b){var s,r,q,p
t.K.a(a)
t.l.a(b)
s=t.g.a(v.G.Error)
r=["Dart exception thrown from converted Future. Use the properties 'error' to fetch the boxed error and 'stack' to recover the stack trace."]
r=A.fP(s,r,t.m)
if(t.e.b(a))A.X("Attempting to box non-Dart object.")
q={}
q[$.jC()]=a
r.error=q
r.stack=b.i(0)
p=this.a
p.call(p,r)},
$S:26}
A.fZ.prototype={
$1(a){var s,r,q,p
if(A.j_(a))return a
s=this.a
if(s.aa(a))return s.j(0,a)
if(t.eO.b(a)){r={}
s.k(0,a,r)
for(s=a.gan(),s=s.gA(s);s.p();){q=s.gq()
r[q]=this.$1(a.j(0,q))}return r}else if(t.R.b(a)){p=[]
s.k(0,a,p)
B.a.a5(p,J.dx(a,this,t.z))
return p}else return a},
$S:11}
A.h1.prototype={
$1(a){return this.a.a6(this.b.h("0/?").a(a))},
$S:12}
A.h2.prototype={
$1(a){if(a==null)return this.a.b9(new A.ez(a===undefined))
return this.a.b9(a)},
$S:12}
A.fQ.prototype={
$1(a){var s,r,q,p,o,n,m,l,k,j,i,h
if(A.iZ(a))return a
s=this.a
a.toString
if(s.aa(a))return s.j(0,a)
if(a instanceof Date){r=a.getTime()
if(r<-864e13||r>864e13)A.X(A.a1(r,-864e13,864e13,"millisecondsSinceEpoch",null))
A.cB(!0,"isUtc",t.y)
return new A.cN(r,0,!0)}if(a instanceof RegExp)throw A.d(A.a_("structured clone of RegExp",null))
if(typeof Promise!="undefined"&&a instanceof Promise)return A.jc(a,t.X)
q=Object.getPrototypeOf(a)
if(q===Object.prototype||q===null){p=t.X
o=A.cY(p,p)
s.k(0,a,o)
n=Object.keys(a)
m=[]
for(s=J.b4(n),p=s.gA(n);p.p();)m.push(A.hK(p.gq()))
for(l=0;l<s.gn(n);++l){k=s.j(n,l)
if(!(l<m.length))return A.a(m,l)
j=m[l]
if(k!=null)o.k(0,j,this.$1(a[k]))}return o}if(a instanceof Array){i=a
o=[]
s.k(0,a,o)
h=A.ab(a.length)
for(s=J.b3(i),l=0;l<h;++l)o.push(this.$1(s.j(i,l)))
return o}return a},
$S:11}
A.ez.prototype={
i(a){return"Promise was rejected with a value of `"+(this.a?"undefined":"null")+"`."}}
A.fv.prototype={
ck(){var s=self.crypto
if(s!=null)if(s.getRandomValues!=null)return
throw A.d(A.dh("No source of cryptographically secure random numbers available."))},
bd(a){var s,r,q,p,o,n,m,l,k=null
if(a<=0||a>4294967296)throw A.d(new A.bg(k,k,!1,k,k,"max must be in range 0 < max \u2264 2^32, was "+a))
if(a>255)if(a>65535)s=a>16777215?4:3
else s=2
else s=1
r=this.a
r.$flags&2&&A.v(r,11)
r.setUint32(0,0,!1)
q=4-s
p=A.ab(Math.pow(256,s))
for(o=a-1,n=(a&o)===0;!0;){crypto.getRandomValues(J.jF(B.az.gbW(r),q,s))
m=r.getUint32(0,!1)
if(n)return(m&o)>>>0
l=m%a
if(m-l+a<p)return l}}}
A.dP.prototype={}
A.bv.prototype={
R(){return"Base58Alphabets."+this.b}}
A.dF.prototype={}
A.f9.prototype={
m(a,b){var s=this,r=s.b,q=A.br(b,"\n","")
r=s.b=r+A.br(q,"\r","")
for(q=s.a;r.length>=4;){B.a.a5(q,A.iv(B.e.au(r,0,4)))
r=B.e.aS(s.b,4)
s.b=r}}}
A.fa.prototype={
$0(){var s,r=t.S,q=A.a9(256,-1,!1,r)
for(s=0;s<64;++s)B.a.k(q,u.n.charCodeAt(s),s)
return A.hk(q,r)},
$S:37}
A.fb.prototype={
m(a,b){var s,r,q,p=this.b
B.a.a5(p,t.L.a(b))
for(s=this.a,r=p.$flags|0;p.length>=3;){q=A.iw(B.a.W(p,0,3))
s.a+=q
r&1&&A.v(p,18)
A.c_(0,3,p.length)
p.splice(0,3)}}}
A.dE.prototype={}
A.dN.prototype={
i(a){return this.a}}
A.eH.prototype={
aN(a){var s,r,q,p,o,n=this
t.L.a(a)
if(n.f)throw A.d(B.ak)
s=a.length
n.e+=s
r=0
if(n.d>0){q=n.c
while(!0){p=n.d
if(!(p<64&&s>0))break
n.d=p+1
o=r+1
if(!(r<a.length))return A.a(a,r)
B.a.k(q,p,a[r]&255);--s
r=o}if(p===64){n.b1(n.b,n.a,q,0,64)
n.d=0}}if(s>=64){r=n.b1(n.b,n.a,a,r,s)
s=B.b.Y(s,64)}for(q=n.c;s>0;r=o){p=n.d++
o=r+1
if(!(r<a.length))return A.a(a,r)
B.a.k(q,p,a[r]&255);--s}return n},
eg(a){var s,r,q,p,o,n,m,l=this
t.L.a(a)
if(!l.f){s=l.e
r=l.d
q=B.b.F(s,536870912)
p=B.b.Y(s,64)<56?64:128
o=l.c
B.a.k(o,r,128)
for(n=r+1,m=p-8;n<m;++n)B.a.k(o,n,0)
A.hQ(q>>>0,o,m)
A.hQ(s<<3>>>0,o,p-4)
l.b1(l.b,l.a,o,0,p)
l.f=!0}for(q=l.a,n=0;n<8;++n)A.hQ(q[n],a,n*4)
return l},
c1(){var s=this,r=s.a
B.a.k(r,0,1779033703)
B.a.k(r,1,3144134277)
B.a.k(r,2,1013904242)
B.a.k(r,3,2773480762)
B.a.k(r,4,1359893119)
B.a.k(r,5,2600822924)
B.a.k(r,6,528734635)
B.a.k(r,7,1541459225)
s.e=s.d=0
s.f=!1
return s},
b1(a3,a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=t.L
a2.a(a3)
a2.a(a4)
a2.a(a5)
for(a2=this.r,s=a2.length;a7>=64;){r=a4[0]
q=a4[1]
p=a4[2]
o=a4[3]
n=a4[4]
m=a4[5]
l=a4[6]
k=a4[7]
for(j=0;j<16;++j){i=a6+j*4
h=a5.length
if(!(i<h))return A.a(a5,i)
g=a5[i]
f=i+1
if(!(f<h))return A.a(a5,f)
f=a5[f]
e=i+2
if(!(e<h))return A.a(a5,e)
e=a5[e]
d=i+3
if(!(d<h))return A.a(a5,d)
B.a.k(a3,j,(g<<24|f<<16|e<<8|a5[d])>>>0)}for(j=16;j<64;++j){c=a3[j-2]
b=a3[j-15]
B.a.k(a3,j,(((((c>>>17|c<<15)^(c>>>19|c<<13)^c>>>10)>>>0)+a3[j-7]>>>0)+(((b>>>7|b<<25)^(b>>>18|b<<14)^b>>>3)>>>0)>>>0)+a3[j-16]>>>0)}for(j=0;j<64;++j,k=l,l=m,m=n,n=a0,o=p,p=q,q=r,r=a1){if(!(j<s))return A.a(a2,j)
a=((((n>>>6|n<<26)^(n>>>11|n<<21)^(n>>>25|n<<7))>>>0)+((n&m^~n&l)>>>0)>>>0)+((k+a2[j]>>>0)+a3[j]>>>0)>>>0
a0=o+a>>>0
a1=a+((((r>>>2|r<<30)^(r>>>13|r<<19)^(r>>>22|r<<10))>>>0)+((r&q^r&p^q&p)>>>0)>>>0)>>>0}B.a.k(a4,0,a4[0]+r>>>0)
B.a.k(a4,1,a4[1]+q>>>0)
B.a.k(a4,2,a4[2]+p>>>0)
B.a.k(a4,3,a4[3]+o>>>0)
B.a.k(a4,4,a4[4]+n>>>0)
B.a.k(a4,5,a4[5]+m>>>0)
B.a.k(a4,6,a4[6]+l>>>0)
B.a.k(a4,7,a4[7]+k>>>0)
a6+=64
a7-=64}return a6}}
A.dG.prototype={
i(a){var s,r,q=this.b
if(q==null)q=null
else{s=A.K(q).h("as<1,2>")
s=new A.cc(new A.as(q,s),s.h("A(i.E)").a(new A.dH()),s.h("cc<i.E>"))
q=s}if(q==null)q=A.b([],t.ao)
s=t.N
r=A.cY(s,t.z)
r.e8(q)
if(r.a===0)return this.a
q=r.$ti.h("as<1,2>")
return this.a+" "+A.id(new A.as(r,q),q.h("j(i.E)").a(new A.dI()),q.h("i.E"),s).T(0,", ")}}
A.dH.prototype={
$1(a){return t.w.a(a).b!=null},
$S:63}
A.dI.prototype={
$1(a){t.w.a(a)
return A.n(a.a)+": "+A.n(a.b)},
$S:53}
A.b8.prototype={}
A.ey.prototype={}
A.fu.prototype={
ef(a,b){var s,r,q,p,o,n
t.L.a(a)
A.jR(a,"Invalid hex bytes")
s=a.length
r=A.a9(s*2,"",!1,t.N)
for(q=0;q<s;++q){if(!(q<a.length))return A.a(a,q)
p=a[q]
o=q*2
n=B.b.a3(p,4)
if(!(n<16))return A.a(B.u,n)
B.a.k(r,o,B.u[n])
n=p&15
if(!(n<16))return A.a(B.u,n)
B.a.k(r,o+1,B.u[n])}return B.a.bc(r)},
ec(a){var s,r,q,p,o,n,m=a.length
if(m===0){m=J.i7(0,t.S)
return m}if((m&1)!==0)throw A.d(B.a5)
s=A.a9(B.b.F(m,2),0,!1,t.S)
for(r=!1,q=0;q<m;q+=2){p=a.charCodeAt(q)
o=p<128?B.V[p]:256
p=q+1
if(!(p<m))return A.a(a,p)
p=a.charCodeAt(p)
n=p<128?B.V[p]:256
B.a.k(s,B.b.F(q,2),(o<<4|n)&255)
r=B.R.bf(r,B.R.bf(o===256,n===256))}if(r)throw A.d(B.a6)
return s}}
A.av.prototype={
R(){return"StringEncoding."+this.b}}
A.eV.prototype={
$1(a){var s
if(a===6)return this.a.bd(16)&15|64
else{s=this.a
if(a===8)return s.bd(4)&3|8
else return s.bd(256)}},
$S:21}
A.eW.prototype={
$1(a){return B.e.bZ(B.b.ew(A.ab(a),16),2,"0")},
$S:61}
A.dQ.prototype={
X(a,b){var s=this
if(b==null)return!1
if(s===b)return!0
if(!(b instanceof A.cb))return!1
if(A.hL(b)!==A.hL(s))return!1
return A.jX([s.b,s.a],[b.b,b.a],t.z)},
gv(a){return A.i4([this.b,this.a])}}
A.cZ.prototype={
R(){return"LockId."+this.b}}
A.eP.prototype={
ad(a,b){var s=B.X
return this.ci(b.h("0/()").a(a),b,b)},
ci(a,b,c){var s=0,r=A.af(c),q,p=2,o=[],n=[],m=this,l,k,j,i,h
var $async$ad=A.ag(function(d,e){if(d===1){o.push(e)
s=p}while(true)switch(s){case 0:k=B.X
j=m.a
i=j.j(0,k)
h=new A.cr(new A.q($.u,t.U),t.aj)
j.k(0,k,h.a)
p=3
s=i!=null?6:7
break
case 6:s=8
return A.aB(i,$async$ad)
case 8:case 7:l=a.$0()
s=l instanceof A.q?9:11
break
case 9:j=l
s=12
return A.aB(b.h("L<0>").b(j)?j:A.hx(b.a(j),b),$async$ad)
case 12:j=e
q=j
n=[1]
s=4
break
s=10
break
case 11:q=l
n=[1]
s=4
break
case 10:n.push(5)
s=4
break
case 3:n=[2]
case 4:p=2
h.toString
h.b8()
s=n.pop()
break
case 5:case 1:return A.ad(q,r)
case 2:return A.ac(o.at(-1),r)}})
return A.ae($async$ad,r)}}
A.cb.prototype={
i(a){return this.a}}
A.du.prototype={}
A.e6.prototype={
$1(a){return J.Z(t.K.a(a))},
$S:64}
A.e5.prototype={
$0(){return A.k(this.a.dataHex)},
$S:13}
A.e4.prototype={
$0(){return B.e.aS(A.k(this.a.dataHex),2)},
$S:13}
A.e1.prototype={
$0(){return t.K.a(this.a.data)},
$S:7}
A.e2.prototype={
$1(a){var s=t.K
s.a(a).serializeFixedBytes(s.a(this.a.data))},
$S:14}
A.e3.prototype={
$0(){return A.k(this.a.dataHex)},
$S:13}
A.aG.prototype={
R(){return"JSAptosWalletStandardUserResponseStatus."+this.b}}
A.e7.prototype={
$1(a){return t.c_.a(a).c===this.a},
$S:48}
A.e8.prototype={
$0(){return A.X(B.l)},
$S:4}
A.aL.prototype={
c8(a,b,c,d){var s,r,q
t.K.a(a)
try{r=v.G
s=r.Reflect.get(a,b,d)
if(typeof s==="undefined"){r=A.iT(r.Reflect.set(a,b,c,d))
return r}return!1}catch(q){return!1}},
c7(a,b,c){var s,r,q
t.K.a(a)
s=b==null
r=!s||null
if(r===!0)if(!s&&typeof b==="string")if(B.e.bi(A.k(A.hK(b)),"is")){q=v.G.Reflect.get(a,b,c)
if(q!=null)return q
return!0}return v.G.Reflect.get(a,b,c)}}
A.d7.prototype={}
A.dO.prototype={
$1(a){var s,r=t.m
r.a(a)
s=v.G
r.a(s.window).dispatchEvent(this.a)
r.a(s.window).removeEventListener("eip6963:requestProvider",A.f(this))},
$S:8}
A.f4.prototype={
$2(a,b){var s,r,q,p=t.g
p.a(a)
p.a(b)
p=this.a.aq(new A.f1(a),new A.f2(b),t.X)
s=new A.f3(b,a)
r=p.$ti
q=$.u
if(q!==B.h)s=A.j0(s,q)
p.aw(new A.az(new A.q(q,r),2,null,s,r.h("az<1,1>")))},
$S:22}
A.f1.prototype={
$1(a){var s=this.a
s.call(s,a)
return a},
$S:11}
A.f2.prototype={
$2(a,b){var s
t.K.a(a)
t.l.a(b)
s=this.a
s.call(s,a)
return a},
$S:57}
A.f3.prototype={
$1(a){this.a.call(this.b,a)
return a},
$S:23}
A.eE.prototype={
$0(){return this.a.a},
$S:9}
A.eF.prototype={
$0(){return this.a.b},
$S:15}
A.eG.prototype={
$0(){var s,r,q=this.a,p=v.G,o=t.m,n=o.a(p.Object),m=o.a(n.create.apply(n,[null]))
m.set=A.hE(q.gaQ())
m.get=A.hD(q.gaP())
n=o.a(p.Object)
s=o.a(n.create.apply(n,[null]))
s.get=A.x(new A.eE(q))
n=o.a(p.Object)
n.defineProperty.apply(n,[m,"debugKey",s])
n=o.a(p.Object)
r=o.a(n.create.apply(n,[null]))
r.get=A.x(new A.eF(q))
p=o.a(p.Object)
p.defineProperty.apply(p,[m,"object",r])
return m},
$S:7}
A.eD.prototype={
$1(a){return A.k(a)},
$S:27}
A.h_.prototype={
$1(a){var s,r,q=this,p=t.m
p.a(a)
s=q.a
if(s.a)return
r=p.a(p.a(a.detail).data)
if(A.ic(A.k(r.status))===B.K){s=r.data
if(s==null)s=t.K.a(s)
if(A.E(s.message)!=null)p.a(v.G.console).error(A.E(s.message))
p=q.b.d
if(p!=null)p.b9(s)
return}s.a=!0
p.a(v.G.window).addEventListener("WALLET_ACTIVATION",A.f(q))
p=r.data
q.b.el(A.k(p==null?null:A.hK(p)))},
$S:8}
A.aH.prototype={
R(){return"JSWalletMessageType."+this.b}}
A.ep.prototype={
$1(a){return t.fr.a(a).b===this.a},
$S:35}
A.eq.prototype={
$0(){return A.X(B.l)},
$S:4}
A.R.prototype={
R(){return"JSNetworkEventType."+this.b}}
A.eg.prototype={
$1(a){return t.bs.a(a).b===this.a},
$S:36}
A.eh.prototype={
$0(){return A.X(B.l)},
$S:4}
A.a4.prototype={
R(){return"JSEventType."+this.b}}
A.ee.prototype={
$1(a){return t.G.a(a).b===this.a},
$S:28}
A.ef.prototype={
$0(){return A.X(B.l)},
$S:4}
A.ed.prototype={
$1(a){return t.G.a(a).b===this.a},
$S:28}
A.aI.prototype={
R(){return"JSWalletResponseType."+this.b}}
A.eu.prototype={
$1(a){return t.e5.a(a).b===this.a},
$S:38}
A.ev.prototype={
$0(){return A.X(B.l)},
$S:4}
A.J.prototype={
R(){return"JSClientType."+this.b}}
A.eb.prototype={
$1(a){return t.D.a(a).b===this.a},
$S:39}
A.ec.prototype={
$0(){return A.X(B.l)},
$S:4}
A.d9.prototype={
R(){return"PageRequestType."+this.b}}
A.e9.prototype={
gM(){var s=this.a
if(s===$){s!==$&&A.cD("requestController")
s=this.a=new A.d8(this.gc_(),A.cY(t.N,t.p))}return s},
gbS(){var s,r,q=this,p=q.b
if(p===$){s=q.gM()
r=A.b([],t.I)
q.b!==$&&A.cD("_walletStandardController")
p=q.b=new A.bL(s,{},{},r)}return p},
aG(){var s=0,r=A.af(t.H),q,p=this,o
var $async$aG=A.ag(function(a,b){if(a===1)return A.ac(b,r)
while(true)switch(s){case 0:o=p.c
o=o==null?null:o.ad(new A.ea(p),t.H)
s=3
return A.aB(o instanceof A.q?o:A.hx(o,t.H),$async$aG)
case 3:q=b
s=1
break
case 1:return A.ad(q,r)}})
return A.ae($async$aG,r)},
gbH(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=this,a3=a2.f
if(a3===$){s=a2.gM()
r=t.I
q=t.G
p=t.u
o=A.C([B.f,A.b([],r),B.i,A.b([],r),B.k,A.b([],r),B.c,A.b([],r),B.m,A.b([],r)],q,p)
n=A.C([B.d,A.b([],r),B.c,A.b([],r)],q,p)
m=a2.gM()
l={base58:!1,hex:!1}
k=A.C([B.f,A.b([],r),B.i,A.b([],r),B.k,A.b([],r),B.m,A.b([],r)],q,p)
j=A.C([B.d,A.b([],r),B.c,A.b([],r)],q,p)
i=a2.gM()
h=A.C([B.d,A.b([],r),B.c,A.b([],r)],q,p)
g=a2.gM()
f=A.C([B.d,A.b([],r),B.c,A.b([],r)],q,p)
e=a2.gM()
d=A.C([B.d,A.b([],r),B.c,A.b([],r)],q,p)
c=a2.gM()
b=A.C([B.f,A.b([],r)],q,p)
a=A.C([B.d,A.b([],r),B.c,A.b([],r)],q,p)
a0=a2.gM()
a1=A.C([B.B,new A.bD(o,s,n),B.H,new A.c8(l,k,m,j),B.C,new A.c1(i,h),B.G,new A.c7(g,f),B.D,new A.c3(e,d),B.E,new A.c5(b,c,a),B.y,new A.bt(A.C([B.f,A.b([],r),B.i,A.b([],r)],q,p),a0,A.C([B.d,A.b([],r),B.c,A.b([],r)],q,p)),B.F,new A.c6(a2.gM(),A.C([B.d,A.b([],r),B.c,A.b([],r)],q,p)),B.A,new A.bA(a2.gM(),A.C([B.d,A.b([],r),B.c,A.b([],r)],q,p)),B.z,new A.bw(a2.gM(),A.C([B.d,A.b([],r),B.c,A.b([],r)],q,p))],t.D,t.aQ)
a2.f!==$&&A.cD("_networks")
a2.f=a1
a3=a1}return a3},
d3(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b="Initializing wallet failed: "
try{for(m=c.gbH(),m=new A.as(m,A.K(m).h("as<1,2>")).gA(0),l=t.m,k=v.G,j=t.I,i=c.gc_(),h=t.N,g=t.p;m.p();){f=m.d
f.toString
s=f
try{r=s.b
e=c.b
if(e===$){e=c.a
if(e===$){e!==$&&A.cD("requestController")
e=c.a=new A.d8(i,A.cY(h,g))}f=A.b([],j)
c.b!==$&&A.cD("_walletStandardController")
e=c.b=new A.bL(e,{},{},f)}r.S(e.c)}catch(d){q=A.an(d)
p=A.aO(d)
l.a(k.console).error(b+s.a.c+" "+A.n(q)+" "+A.n(p))}}c.gbS().ag()}catch(d){o=A.an(d)
n=A.aO(d)
t.m.a(v.G.console).error(b+A.n(o)+" "+A.n(n))}},
ej(a){var s,r,q,p,o=t.m
if(A.ke(A.k(o.a(a.data).type))===B.T){s=this.gM().b.j(0,A.k(a.requestId))
if(s!=null){o=o.a(a.data)
s.b.a6(o)}return}r=o.a(a.data)
if((A.E(a.client)==null?null:A.i9(A.E(a.client)))==null){s=this.gbS()
r=o.a(r.data)
o=t.r
if(o.a(r.accounts)!=null){q=o.a(r.accounts)
q.toString
s.b.accounts=q}if(o.a(r.chains)!=null){q=o.a(r.chains)
q.toString
s.b.chains=q}p={}
p.change=r
p.accounts=o.a(r.accounts)
p.chains=o.a(r.chains)
s.cS(p)
return}o=this.gbH()
o=o.j(0,A.E(a.client)==null?null:A.i9(A.E(a.client)))
if(o!=null)o.ao(r)}}
A.ea.prototype={
$0(){var s=0,r=A.af(t.H),q,p=2,o=[],n=[],m=this,l
var $async$$0=A.ag(function(a,b){if(a===1){o.push(b)
s=p}while(true)switch(s){case 0:p=3
l=m.a.d
l=l==null?null:l.a
s=6
return A.aB(l instanceof A.q?l:A.hx(l,t.H),$async$$0)
case 6:l=b
q=l
n=[1]
s=4
break
n.push(5)
s=4
break
case 3:n=[2]
case 4:p=2
l=m.a
l.c=l.d=null
s=n.pop()
break
case 5:case 1:return A.ad(q,r)
case 2:return A.ac(o.at(-1),r)}})
return A.ae($async$$0,r)},
$S:40}
A.cV.prototype={
aK(a){return this.eq(a)},
eq(a){var s=0,r=A.af(t.H),q=this,p,o,n
var $async$aK=A.ag(function(b,c){if(b===1)return A.ac(c,r)
while(true)switch(s){case 0:s=2
return A.aB(q.aG(),$async$aK)
case 2:p=q.e
o=v.G
n=t.m
p=n.a(new o.CustomEvent(p,{bubbles:!0,cancelable:!1,detail:a,data:null}))
n.a(o.window).dispatchEvent(p)
return A.ad(null,r)}})
return A.ae($async$aK,r)},
dk(a){var s=t.m
this.ej(s.a(s.a(a).detail))},
el(a){var s,r=this
if(r.e!=null)return
r.e="WALLET_"+a
t.m.a(v.G.window).addEventListener("ETH_"+a,A.f(r.gdj()))
s=r.d
if(s!=null)s.b8()}}
A.bL.prototype={
b4(a,b){var s
A.k(a)
t.g.a(b)
s=A.bH(a)
if(s!==B.d)return null
if(s!=null)B.a.m(this.d,b)
this.a.a.$1(A.ig(null,A.be(B.d)))
return A.x(new A.el(this,b))},
cS(a){var s,r,q,p=A.a5(this.d,t.g)
for(s=p.length,r=0;r<p.length;p.length===s||(0,A.am)(p),++r){q=p[r]
q.call(q,a)}},
t(a){return A.Y(new A.ei(this,t.A.a(a)).$0(),t.m)},
D(){return this.t(null)},
ag(){var s,r,q,p=this,o=p.c
o["standard:events"]=A.aj(A.y(p.gL()))
s={}
s.connect=A.f(p.gC())
s.version="1.0.0"
o["standard:connect"]=s
r=p.b
r.features=o
r.name="OnChain"
r.version="1.0.0"
r.icon=u.f
r.accounts=A.b([],t.O)
r=v.G
o=t.m
q=o.a(new r.CustomEvent("wallet-standard:register-wallet",{bubbles:!1,cancelable:!1,detail:A.f(new A.ej(p))}))
o.a(r.window).addEventListener("wallet-standard:app-ready",A.f(new A.ek(q)))
o.a(r.window).dispatchEvent(q)}}
A.el.prototype={
$0(){B.a.ap(this.a.d,this.b)},
$S:2}
A.ei.prototype={
$0(){var s=0,r=A.af(t.m),q,p=this,o,n,m
var $async$$0=A.ag(function(a,b){if(a===1)return A.ac(b,r)
while(true)switch(s){case 0:n=p.a
m=p.b
m=m!=null?A.b([m],t.O):null
s=3
return A.aB(n.a.J("connect",m,t.m),$async$$0)
case 3:o=b
n.b.accounts=t.c.a(o.accounts)
q=o
s=1
break
case 1:return A.ad(q,r)}})
return A.ae($async$$0,r)},
$S:43}
A.ej.prototype={
$1(a){t.K.a(a).register(this.a.b)},
$S:14}
A.ek.prototype={
$1(a){t.K.a(a)
t.m.a(v.G.window).dispatchEvent(this.a)},
$S:14}
A.N.prototype={
a0(a,b,c,d){return this.a.c5(this.gG(),a,b,c,d)},
l(a,b,c){return this.a0(a,b,B.n,c)},
c3(a,b){return this.a0(a,null,B.n,b)},
c4(a,b,c){return this.a0(a,null,b,c)},
J(a,b,c){return this.eB(a,b,c,c)},
ez(a,b){return this.J(a,null,b)},
eB(a,b,c,d){var s=0,r=A.af(d),q,p=this
var $async$J=A.ag(function(e,f){if(e===1)return A.ac(f,r)
while(true)switch(s){case 0:q=p.a.ac(p.gG(),a,b,B.n,c)
s=1
break
case 1:return A.ad(q,r)}})
return A.ae($async$J,r)},
cP(){return this.a.eC(this.gG(),"disconnect",t.X)},
a9(a){var s=A.k9(A.k(a.event))
if(!(s===B.f||s===B.i||s===B.k||s===B.d))return
this.a.a.$1(A.ig(this.gG(),a))},
b4(a,b){var s,r
A.k(a)
t.g.a(b)
s=A.bH(a)
r=this.b
if(r.j(0,s)==null)throw A.d({message:"Unsuported "+A.kb(a)+" event."})
if(s!=null){r=r.j(0,s)
r.toString
B.a.m(r,b)
this.a9(A.be(s))}},
aA(a,b){var s,r,q,p=A.a5(t.u.a(a),t.g)
for(s=p.length,r=0;r<p.length;p.length===s||(0,A.am)(p),++r){q=p[r]
q.call(q,b)}},
bu(a,b){var s=this.b
if(!s.aa(a))return
s=s.j(0,a)
s.toString
this.aA(s,b)},
ao(a){var s,r,q,p=t.m.a(a.data),o=A.er(p)
for(s=o.length,r=t.A,q=0;q<o.length;o.length===s||(0,A.am)(o),++q)switch(o[q]){case B.S:this.bu(B.d,r.a(p.change))
break}}}
A.d8.prototype={
aC(a,b){return this.d2(a,b)},
d2(a,b){var s=0,r=A.af(t.m),q,p=2,o=[],n=[],m=this,l,k,j,i
var $async$aC=A.ag(function(c,d){if(c===1){o.push(d)
s=p}while(true)switch(s){case 0:i=new A.d7(A.kE(),new A.ay(new A.q($.u,t.et),t.x))
p=3
k=i.a
j=a==null?null:a.b
l={data:b,requestId:k,client:j}
m.a.$1(l)
j=m.b
k=i.a
if(j.j(0,k)==null)j.k(0,k,i)
s=6
return A.aB(i.b.a,$async$aC)
case 6:k=d
q=k
n=[1]
s=4
break
n.push(5)
s=4
break
case 3:n=[2]
case 4:p=2
m.b.ap(0,i.a)
s=n.pop()
break
case 5:case 1:return A.ad(q,r)
case 2:return A.ac(o.at(-1),r)}})
return A.ae($async$aC,r)},
c5(a,b,c,d,e){return A.Y(this.ac(a,b,c,d,e),e)},
eC(a,b,c){return this.c5(a,b,null,B.n,c)},
ac(a,b,c,d,e){return this.eA(a,b,c,d,e,e)},
J(a,b,c){return this.ac(null,a,b,B.n,c)},
eA(a,b,c,d,e,f){var s=0,r=A.af(f),q,p=this,o,n
var $async$ac=A.ag(function(g,h){if(g===1)return A.ac(h,r)
while(true)$async$outer:switch(s){case 0:s=3
return A.aB(p.aC(a,{type:"request",method:b,params:c,providerType:d.b}),$async$ac)
case 3:n=h
switch(A.ic(A.k(n.status))){case B.U:q=e.a(n.data)
s=1
break $async$outer
case B.K:o=A.m0(n,"data",t.X)
throw A.d(o==null?t.K.a(o):o)}case 1:return A.ad(q,r)}})
return A.ae($async$ac,r)}}
A.bt.prototype={
cE(a){var s=t.K
return this.l("wallet_switchAptosChain",A.b([s.a(a)],t.f),s)},
I(a){var s=t.K
return A.Y(this.J("aptos_signMessage",A.b([s.a(a)],t.f),s).aL(new A.dz(),s),s)},
P(a){var s=t.K
return A.Y(this.J("aptos_signTransaction",A.b([A.k7(s.a(a))],t.f),s).aL(new A.dA(),s),s)},
bK(a){var s,r,q
A.E(a)
s=a!=null?A.ar(a):null
r=A.b([],t.s)
if(s!=null)r.push(s)
q=t.K
return A.Y(this.J("aptos_requestAccounts",r,q).aL(new A.dy(),q),q)},
dz(){return this.bK(null)},
de(){return this.c3("aptos_network",t.K)},
dg(a){var s
t.g.a(a)
s=this.c.j(0,B.f)
s.toString
B.a.m(s,a)
this.a9(A.be(B.f))},
di(a){var s
t.g.a(a)
s=this.c.j(0,B.i)
s.toString
B.a.m(s,a)
this.a9(A.be(B.i))},
aA(a,b){var s,r,q=A.a5(t.u.a(a),t.g)
for(s=q.length,r=0;r<q.length;q.length===s||(0,A.am)(q),++r)q[r].call(null,b)},
ao(a){var s,r,q,p,o,n,m,l,k=this
k.aT(a)
s=t.m.a(a.data)
r=A.er(s)
for(q=r.length,p=k.c,o=t.A,n=0;n<r.length;r.length===q||(0,A.am)(r),++n)switch(r[n]){case B.t:m=p.j(0,B.f)
m.toString
k.aA(m,o.a(s.account))
break
case B.r:l=s.chainChanged
if(l!=null){m=p.j(0,B.i)
m.toString
k.aA(m,l)}break}},
gG(){return B.y},
S(a){var s=this,r=s.gdw(),q={}
q.connect=A.f(r)
q.version="1.0.0"
a["aptos:connect"]=q
q={}
q.signTransaction=A.f(s.gO())
q.version="1.0.0"
a["aptos:signTransaction"]=q
q={}
q.signMessage=A.f(s.gH())
q.version="1.0.0"
a["aptos:signMessage"]=q
q={}
q.account=A.f(r)
q.version="1.0.0"
a["aptos:account"]=q
q={}
q.onNetworkChange=A.f(s.gdh())
q.version="1.0.0"
a["aptos:onNetworkChange"]=q
q={}
q.network=A.x(s.gdd())
q.version="1.0.0"
a["aptos:network"]=q
q={}
q.onAccountChange=A.f(s.gdf())
q.version="1.0.0"
a["aptos:onAccountChange"]=q
q={}
q.disconnect=A.x(s.gK())
q.version="1.0.0"
a["aptos:disconnect"]=q
q={}
q.changeNetwork=A.f(s.gcD())
q.version="1.0.0"
a["aptos:changeNetwork"]=q
a["aptos:events"]=A.aj(A.y(s.gL()))}}
A.dz.prototype={
$1(a){var s,r=t.K
r.a(a)
if(A.hf(A.k(a.status))===B.q)return a
s=r.a(a.args)
A.he(s)
return A.hg(s,r)},
$S:18}
A.dA.prototype={
$1(a){var s,r=t.K
r.a(a)
if(A.hf(A.k(a.status))===B.q)return a
s=r.a(a.args)
A.he(s)
return A.hg(s,r)},
$S:18}
A.dy.prototype={
$1(a){var s,r,q=t.K
q.a(a)
if(A.hf(A.k(a.status))===B.q)return a
s=t.m
r=s.a(q.a(a.args))
A.he(s.a(r.publicKey))
r.publicKey=A.a6(s.a(r.publicKey),s)
return A.hg(r,s)},
$S:18}
A.bw.prototype={
S(a){var s=this,r={}
r.connect=A.f(s.gC())
r.version="1.0.0"
a["bitcoin:connect"]=r
r={}
r.signPersonalMessage=A.f(s.gcz())
r.version="1.0.0"
a["bitcoin:signPersonalMessage"]=r
r={}
r.signTransaction=A.f(s.gcB())
r.version="1.0.0"
a["bitcoin:signTransaction"]=r
r={}
r.getAccountAddresses=A.f(s.gd_())
r.version="1.0.0"
a["bitcoin:getAccountAddresses"]=r
r={}
r.sendTransaction=A.f(s.gcv())
r.version="1.0.0"
a["bitcoin:sendTransaction"]=r
a["bitcoin:disconnect"]=A.aT(A.x(s.gK()))
a["bitcoin:events"]=A.aj(A.y(s.gL()))},
t(a){var s=A.ar(A.E(a)),r=s==null?null:A.b([s],t.s)
return this.l("bitcoin_requestAccounts",r,t.m)},
D(){return this.t(null)},
cA(a){var s=t.K
return this.l("bitcoin_signPersonalMessage",A.b([s.a(a)],t.f),s)},
cC(a){var s=t.K
return this.l("bitcoin_signTransaction",A.b([s.a(a)],t.f),s)},
d0(a){return this.l("bitcoin_getAccountAddresses",A.b([t.K.a(a)],t.f),t.c)},
cw(a){return this.l("bitcoin_sendTransaction",A.S(t.c.a(a)),t.K)},
gG(){return B.z}}
A.bA.prototype={
bY(a){var s=A.ar(A.E(a)),r=s==null?null:A.b([s],t.s)
return this.l("cosmos_requestAccounts",r,t.m)},
eb(){return this.bY(null)},
I(a){var s=t.K
return this.l("cosmos_signMessage",A.b([s.a(a)],t.f),s)},
cc(a){var s=t.K
return this.l("cosmos_signTransactionDirect",A.b([s.a(a)],t.f),s)},
ca(a){var s=t.K
return this.l("cosmos_signTransactionAmino",A.b([s.a(a)],t.f),s)},
by(a,b){var s,r,q
A.k(a)
s=A.x(new A.dL(this,a))
r=A.y(new A.dM(this,a,b))
q={}
q.getAccounts=s
q.signDirect=r
return A.a6(q,t.K)},
bx(a){return this.by(a,null)},
bC(a,b){var s,r,q
A.k(a)
s=A.x(new A.dJ(this,a))
r=A.y(new A.dK(this,a,b))
q={}
q.getAccounts=s
q.signAmino=r
return A.a6(q,t.K)},
bB(a){return this.bC(a,null)},
bP(a,b){var s,r
A.k(a)
s=this.bx(a)
r={}
r.amino=this.bB(a)
r.direct=s
return A.a6(r,t.K)},
e4(a){return this.bP(a,null)},
d1(a){A.k(a)
throw A.d(A.hr(null))},
gG(){return B.A},
aV(a){return this.l("wallet_addCosmosChain",A.b([t.K.a(a)],t.f),t.y)},
P(a){var s=t.K
return this.l("cosmos_signTransaction",A.b([s.a(a)],t.f),s)},
S(a){var s,r,q=this
if(q.c==null){s={}
s.getOfflineSigner=A.y(q.gbw())
s.getOfflineSignerOnlyAmino=A.y(q.gbA())
s.getOfflineSignerAuto=A.f(q.gbz())
r=A.a6(s,t.m)
q.c=s
q.d=r}r=v.G
r.cosmos=q.d
r.getOfflineSigner=A.y(q.gbw())
r.getOfflineSignerOnlyAmino=A.y(q.gbA())
r.getOfflineSignerAuto=A.f(q.gbz())
s={}
s.connect=A.f(q.gea())
s.version="1.0.0"
a["cosmos:connect"]=s
a["cosmos:events"]=A.aj(A.y(q.gL()))
s={}
s.signer=A.y(q.ge3())
s.version="1.0.0"
a["cosmos:signer"]=s
s={}
s.signTransactionDirect=A.f(q.gcb())
s.version="1.0.0"
a["cosmos:signTransactionDirect"]=s
s={}
s.signTransactionAmino=A.f(q.gc9())
s.version="1.0.0"
a["cosmos:signTransactionAmino"]=s
s={}
s.addNewChain=A.f(q.gaU())
s.version="1.0.0"
a["cosmos:addNewChain"]=s
s={}
s.signMessage=A.f(q.gH())
s.version="1.0.0"
a["cosmos:signMessage"]=s
s={}
s.signTransaction=A.f(q.gO())
s.version="1.0.0"
a["cosmos:signTransaction"]=s
a["cosmos:disconnect"]=A.aT(A.x(q.gK()))}}
A.dL.prototype={
$0(){return this.a.l("cosmos_requestAccounts",A.il(A.b([this.b],t.s)),t.c)},
$S:5}
A.dM.prototype={
$2(a,b){var s,r
A.k(a)
s=t.K
r={}
r.signDoc=s.a(b)
r.signerAddress=a
r.chainId=this.b
r.signOption=this.c
return this.a.l("cosmos_signTransactionDirect",A.b([r],t.f),s)},
$S:30}
A.dJ.prototype={
$0(){return this.a.l("cosmos_requestAccounts",A.il(A.b([this.b],t.s)),t.c)},
$S:5}
A.dK.prototype={
$2(a,b){var s,r
A.k(a)
s=t.K
s.a(b)
r={}
r.signDoc=A.k(t.m.a(v.G.JSON).stringify(b))
r.signerAddress=a
r.chainId=this.b
r.signOption=this.c
return this.a.l("cosmos_signTransactionAmino",A.b([r],t.f),s)},
$S:30}
A.bD.prototype={
b5(a){t.m.a(a)
return this.a0(A.k(a.method),A.S(a.params),B.j,t.X)},
ag(){var s,r,q,p,o,n,m,l,k=this,j=k.c
if(j==null){j=A.x(k.gcG())
r=A.f(k.gaD())
q=A.y(k.gcq())
p=A.y(k.gdn())
o=A.x(k.gK())
n={}
n.request=r
n.on=q
n.removeListener=p
n.disconnect=o
n.enable=j
n.connect=j
n.isOnChain=!0
k.c=n
j=n}r=t.m
m=A.a6(j,r)
s=m
try{v.G.ethereum=s}catch(l){r.a(v.G.console).error("failed to set ethereum ")}A.jZ(s)},
cH(){return this.c4("eth_requestAccounts",B.j,t.c)},
t(a){var s=A.ar(A.E(a)),r=s==null?null:A.b([s],t.s)
return this.l("eth_requestAccounts",r,t.m)},
D(){return this.t(null)},
aV(a){return this.l("wallet_addEthereumChain",A.S(t.m.a(a)),t.N)},
dZ(a){return this.l("eth_signTypedData",A.S(t.m.a(a)),t.N)},
e0(a){return this.l("eth_signTypedData_v3",A.S(t.m.a(a)),t.N)},
e2(a){return this.l("eth_signTypedData_v4",A.S(t.m.a(a)),t.N)},
dm(a){return this.l("personal_sign",A.S(t.m.a(a)),t.N)},
cX(a){return this.l("eth_sign",A.S(t.m.a(a)),t.N)},
aj(a){return this.l("eth_sendTransaction",A.S(t.m.a(a)),t.N)},
S(a){var s,r=this
r.ag()
s={}
s.connect=A.f(r.gC())
s.version="1.0.0"
a["ethereum:connect"]=s
s={}
s.addNewChain=A.f(r.gaU())
s.version="1.0.0"
a["ethereum:addNewChain"]=s
s={}
s.signTypedData=A.f(r.gdY())
s.version="1.0.0"
a["ethereum:signTypedData"]=s
s={}
s.signTypedDataV3=A.f(r.ge_())
s.version="1.0.0"
a["ethereum:signTypedDataV3"]=s
s={}
s.signTypedDataV4=A.f(r.ge1())
s.version="1.0.0"
a["ethereum:signTypedDataV4"]=s
s={}
s.personalSign=A.f(r.gdl())
s.version="1.0.0"
a["ethereum:personalSign"]=s
s={}
s.ethSign=A.f(r.gcW())
s.version="1.0.0"
a["ethereum:ethSign"]=s
s={}
s.sendTransaction=A.f(r.gai())
s.version="1.0.0"
a["ethereum:sendTransaction"]=s
s={}
s.request=A.f(r.gaD())
s.version="1.0.0"
a["ethereum:request"]=s
a["ethereum:events"]=A.aj(A.y(r.gL()))
a["ethereum:disconnect"]=A.aT(A.x(r.gK()))},
ao(a){var s,r,q,p,o,n,m,l,k=this,j=null
k.aT(a)
s=t.m.a(a.data)
r=A.er(s)
for(q=r.length,p=t.A,o=0;o<r.length;r.length===q||(0,A.am)(r),++o)switch(r[o]){case B.t:n=k.c
if(n!=null){m=p.a(s.account)
m=m==null?j:A.k(m.address)
n.selectedAddress=m}break
case B.J:k.ae(B.c,s.message)
k.bu(B.c,s.message)
break
case B.I:n=p.a(s.networkAccounts)
k.ae(B.f,n==null?j:A.ib(n))
break
case B.r:l=p.a(s.chainChanged)
n=k.c
if(n!=null){m=l==null?j:A.k(l.chainId)
n.chainId=m}n=k.c
if(n!=null){m=l==null?j:A.k(l.netVersion)
n.networkVersion=m}if(s.disconnect!=null)k.ae(B.m,s.disconnect)
if(l!=null){if(s.disconnect==null)k.ae(B.k,l)
k.ae(B.i,A.k(l.chainId))}break}},
ae(a,b){var s,r,q
if(b==null||!this.d.aa(a))return
s=this.d.j(0,a)
s.toString
s=A.a5(s,t.g)
for(r=s.length,q=0;q<s.length;s.length===r||(0,A.am)(s),++q)s[q].call(null,b)},
cr(a,b){var s,r
A.k(a)
t.g.a(b)
s=A.bH(a)
if(s==null)return
r=this.d.j(0,s)
if(r!=null)B.a.m(r,b)
this.a9(A.be(s))},
dq(a,b){var s
A.k(a)
t.g.a(b)
s=this.d.j(0,A.bH(a))
if(s!=null)B.a.ap(s,b)},
gG(){return B.B}}
A.c1.prototype={
S(a){var s=this,r=A.f(s.gdJ()),q=A.f(s.gdR()),p=A.f(s.gdB()),o=A.f(s.gH()),n=$.jj(),m={}
m.signAllTransactions=p
m.version="1.0.0"
m.supportedTransactionVersions=n
a["solana:signAllTransactions"]=m
m={}
m.signTransaction=q
m.version="1.0.0"
m.supportedTransactionVersions=n
a["solana:signTransaction"]=m
m={}
m.signAndSendTransaction=r
m.version="1.0.0"
m.supportedTransactionVersions=n
a["solana:signAndSendTransaction"]=m
m={}
m.signMessage=o
m.version="1.0.0"
a["solana:signMessage"]=m
m={}
m.signAndSendAllTransactions=A.y(s.gdH())
m.version="1.0.0"
m.supportedTransactionVersions=n
a["solana:signAndSendAllTransactions"]=m
a["solana:events"]=A.aj(A.y(s.gL()))
m={}
m.connect=A.f(s.gC())
m.version="1.0.0"
a["solana:connect"]=m
m={}
m.signIn=A.f(s.gdL())
m.version="1.0.0"
a["solana:signIn"]=m
a["solana:disconnect"]=A.aT(A.x(s.gK()))},
t(a){var s=A.ar(A.E(a)),r=s==null?null:A.b([s],t.s)
return this.l("solana_requestAccounts",r,t.m)},
D(){return this.t(null)},
dM(a){var s=t.m
return A.Y(this.J("solana_signIn",A.S(s.a(a)),s),s)},
I(a){var s=t.c
return A.Y(this.J("solana_signMessage",A.S(t.m.a(a)),s),s)},
dS(a){var s=t.c
return A.Y(this.J("solana_signTransaction",A.S(t.K.a(a)),s),s)},
dC(a){var s=t.c
return A.Y(this.J("solana_signAllTransactions",A.S(t.K.a(a)),s),s)},
dK(a){return this.l("solana_signAndSendTransaction",A.S(t.m.a(a)),t.c)},
bM(a,b){var s,r=t.c
r.a(a)
t.A.a(b)
s=A.S(a)
return this.l("solana_signAndSendAllTransactions",s,r)},
dI(a){return this.bM(a,null)},
gG(){return B.C}}
A.c3.prototype={
S(a){var s=this,r={}
r.signAndSendTransaction=A.f(s.gai())
r.version="1.0.0"
a["stellar:signAndSendTransaction"]=r
r={}
r.signTransaction=A.f(s.gO())
r.version="1.0.0"
a["stellar:signTransaction"]=r
r={}
r.signMessage=A.f(s.gH())
r.version="1.0.0"
a["stellar:signMessage"]=r
r={}
r.connect=A.f(s.gC())
r.version="1.0.0"
a["stellar:connect"]=r
a["stellar:events"]=A.aj(A.y(s.gL()))
a["stellar:disconnect"]=A.aT(A.x(s.gK()))},
t(a){var s=A.ar(A.E(a)),r=s==null?null:A.b([s],t.s)
return this.l("stellar_requestAccounts",r,t.m)},
D(){return this.t(null)},
P(a){var s=t.K
return this.l("stellar_signTransaction",A.b([s.a(a)],t.f),s)},
aj(a){var s=t.K
return this.l("stellar_sendTransaction",A.b([s.a(a)],t.f),s)},
I(a){return this.l("stellar_signMessage",A.b([t.m.a(a)],t.O),t.K)},
gG(){return B.D}}
A.c5.prototype={
S(a){var s,r=this
r.d4()
s={}
s.signTransaction=A.f(r.gbh())
s.version="1.0.0"
a["polkadot:signTransaction"]=s
s={}
s.signMessage=A.f(r.gbg())
s.version="1.0.0"
a["polkadot:signMessage"]=s
s={}
s.addNewChain=A.f(r.gbE())
s.version="1.0.0"
a["polkadot:addNewChain"]=s
s={}
s.connect=A.f(r.gC())
s.version="1.0.0"
a["polkadot:connect"]=s
a["polkadot:events"]=A.aj(A.y(r.gL()))
a["polkadot:disconnect"]=A.aT(A.x(r.gK()))},
d4(){var s,r,q,p,o=this,n=o.d
if(n==null){s={}
r={}
q={}
p={}
q.signPayload=A.f(o.gbh())
q.signRaw=A.f(o.gbg())
q.update=A.f(o.gex())
s.get=A.f(o.gd5())
s.provide=A.f(o.gbE())
r.get=A.f(o.gcI())
r.subscribe=A.f(o.gd7())
n=t.m
p.metadata=A.a6(s,n)
p.accounts=A.a6(r,n)
p.signer=A.a6(q,n)
n=o.gaY()
p.connect=A.f(n)
p.enable=A.f(n)
p.name="OnChain"
p.version="0.4.0"
n=o.d=new A.aL(null,p,t.q)}if(o.e==null)o.e=A.fP(v.G.Proxy,[n.b,new A.eO(o).$0()],t.m)
n=v.G
if(t.A.a(n.injectedWeb3)==null)n.injectedWeb3={}
t.m.a(n.injectedWeb3)["0"]=o.e
n.substrate=o.e},
bD(a){A.aA(a)
return this.c3("polkadot_knownMetadata",t.m)},
d6(){return this.bD(null)},
d9(a){return this.l("wallet_addPolkadotChain",A.b([t.m.a(a)],t.O),t.y)},
ce(a){var s=t.m
return this.l("polkadot_signTransaction",A.b([s.a(a)],t.O),s)},
cd(a){var s=t.m
return this.l("polkadot_signMessage",A.b([s.a(a)],t.O),s)},
t(a){var s=A.ar(A.E(a)),r=s==null?null:A.b([s],t.s)
return this.l("polkadot_requestAccounts",r,t.m)},
D(){return this.t(null)},
br(a){var s=t.c
return A.Y(this.ez("polkadot_requestAccounts",t.m).aL(new A.eK(),s),s)},
cJ(){return this.br(null)},
aN(a){throw A.d($.hR())},
ey(){return this.aN(null)},
cU(a){A.k(a)
return A.Y(new A.eL(this).$0(),t.A)},
d8(a){var s
t.g.a(a)
s=this.c.j(0,B.f)
s.toString
B.a.m(s,a)
this.a9(A.be(B.f))},
gG(){return B.E}}
A.eM.prototype={
$0(){return this.a.a},
$S:9}
A.eN.prototype={
$0(){return this.a.b},
$S:15}
A.eO.prototype={
$0(){var s,r,q,p,o,n,m=this.a.d
m.toString
s=v.G
r=t.m
q=r.a(s.Object)
p=r.a(q.create.apply(q,[null]))
p.set=A.hE(m.gaQ())
p.get=A.hD(m.gaP())
q=r.a(s.Object)
o=r.a(q.create.apply(q,[null]))
o.get=A.x(new A.eM(m))
q=r.a(s.Object)
q.defineProperty.apply(q,[p,"debugKey",o])
q=r.a(s.Object)
n=r.a(q.create.apply(q,[null]))
n.get=A.x(new A.eN(m))
s=r.a(s.Object)
s.defineProperty.apply(s,[p,"object",n])
return p},
$S:7}
A.eK.prototype={
$1(a){return t.c.a(t.m.a(a).accounts)},
$S:58}
A.eL.prototype={
$0(){var s=0,r=A.af(t.A),q,p=this
var $async$$0=A.ag(function(a,b){if(a===1)return A.ac(b,r)
while(true)switch(s){case 0:q=p.a.e
s=1
break
case 1:return A.ad(q,r)}})
return A.ae($async$$0,r)},
$S:59}
A.c6.prototype={
I(a){var s=t.K
return this.l("sui_signMessage",A.b([s.a(a)],t.f),s)},
dQ(a){var s=t.K
return this.l("sui_signPersonalMessage",A.b([s.a(a)],t.f),s)},
a4(a,b,c){A.lS(c,t.K,"T","_signTransction_")
return this.dX(a,b,c,c)},
dX(a,b,c,d){var s=0,r=A.af(d),q,p=this,o,n
var $async$a4=A.ag(function(e,f){if(e===1)return A.ac(f,r)
while(true)switch(s){case 0:o=a
n=A
s=3
return A.aB(A.em(b),$async$a4)
case 3:q=p.J(o,n.b([f],t.f),c)
s=1
break
case 1:return A.ad(q,r)}})
return A.ae($async$a4,r)},
P(a){var s=t.K
return A.Y(this.a4("sui_signTransaction",s.a(a),s),s)},
dG(a){var s=t.K
return A.Y(this.a4("sui_signAndExecuteTransaction",s.a(a),s),s)},
dE(a){var s=t.K
return A.Y(this.a4("sui_signAndExecuteTransactionBlock",s.a(a),s),s)},
dU(a){var s=t.K
return A.Y(this.a4("sui_signTransactionBlock",s.a(a),s),s)},
dv(a){t.K.a(a)
return A.k1(A.k2(B.N,t.z))},
gG(){return B.F},
t(a){var s=A.ar(A.E(a)),r=s==null?null:A.b([s],t.s)
return this.l("sui_requestAccounts",r,t.m)},
D(){return this.t(null)},
S(a){var s=this,r={}
r.signTransaction=A.f(s.gO())
r.version="1.0.0"
a["sui:signTransaction"]=r
r={}
r.connect=A.f(s.gC())
r.version="1.0.0"
a["sui:connect"]=r
r={}
r.signTransactionBlock=A.f(s.gdT())
r.version="1.0.0"
a["sui:signTransactionBlock"]=r
r={}
r.signAndExecuteTransactionBlock=A.f(s.gdD())
r.version="1.0.0"
a["sui:signAndExecuteTransactionBlock"]=r
r={}
r.signAndExecuteTransaction=A.f(s.gdF())
r.version="2.0.0"
a["sui:signAndExecuteTransaction"]=r
r={}
r.signPersonalMessage=A.f(s.gdP())
r.version="1.0.0"
a["sui:signPersonalMessage"]=r
r={}
r.signMessage=A.f(s.gH())
r.version="1.0.0"
a["sui:signMessage"]=r
r={}
r.reportTransactionEffects=A.f(s.gdu())
r.version="1.0.0"
a["sui:reportTransactionEffects"]=r
r={}
r.disconnect=A.x(s.gK())
r.version="1.0.0"
a["sui:disconnect"]=r
a["sui:events"]=A.aj(A.y(s.gL()))}}
A.c7.prototype={
S(a){var s=this,r={}
r.signAndSendTransaction=A.f(s.gai())
r.version="1.0.0"
a["ton:signAndSendTransaction"]=r
r={}
r.signTransaction=A.f(s.gO())
r.version="1.0.0"
a["ton:signTransaction"]=r
r={}
r.signMessage=A.f(s.gH())
r.version="1.0.0"
a["ton:signMessage"]=r
r={}
r.connect=A.f(s.gC())
r.version="1.0.0"
a["ton:connect"]=r
a["ton:disconnect"]=A.aT(A.x(s.gK()))
a["ton:events"]=A.aj(A.y(s.gL()))},
t(a){var s=A.ar(A.E(a)),r=s==null?null:A.b([s],t.s)
return this.l("ton_requestAccounts",r,t.m)},
D(){return this.t(null)},
P(a){return this.l("ton_signTransaction",A.b([t.m.a(a)],t.O),t.K)},
aj(a){return this.l("ton_sendTransaction",A.b([t.m.a(a)],t.O),t.K)},
I(a){return this.l("ton_signMessage",A.b([t.m.a(a)],t.O),t.K)},
gG(){return B.G}}
A.c8.prototype={
ag(){var s,r,q,p,o,n,m,l,k,j=this,i=v.G,h=new i.TronWeb("https://api.shasta.trongrid.io","https://api.shasta.trongrid.io","https://api.shasta.trongrid.io"),g=j.e,f=t.m,e=A.fP(i.Proxy,[g,new A.eS(new A.aL(null,g,t.q)).$0()],f)
f.a(h.trx).sign=A.y(j.gdV())
f.a(h.trx).signMessageV2=A.y(j.gdN())
f.a(h.trx).multiSign=A.y(j.gda())
g=j.gcN()
h.setPrivateKey=A.f(g)
h.setAddress=A.f(g)
h.setFullNode=A.f(g)
h.setSolidityNode=A.f(g)
h.setHeader=A.f(g)
h.setFullNodeHeader=A.f(g)
h.setDefaultBlock=A.f(g)
h.defaultPrivateKey=""
h.defaultAddress=e
g=t.K
s=A.a6(h,g)
r=A.f(j.gaD())
q=A.y(j.gcs())
p=A.x(j.gaY())
o=A.y(j.gds())
n=A.x(j.gK())
m={}
m.dappIcon=""
m.dappName=""
m.openTronLinkAppOnMobile=!0
m.openUrlWhenWalletNotFound=!0
l={}
l.config=m
l.request=r
l.on=q
l.removeListener=o
l.tronWeb=s
l.enable=p
l.connect=p
l.ready=!0
l.disconnect=n
k=f.a(i.Object.freeze(l))
i.tronLink=A.a6(k,f)
i.tronWeb=A.a6(h,g)
i.tron=A.a6(k,f)
j.c=k
j.d=h},
cO(a){throw A.d($.hR())},
bN(a,b){t.K.a(a)
if(b!=null)A.hA(b)
return this.a0("tron_signMessageV2",A.b([a],t.f),B.j,t.N)},
dO(a){return this.bN(a,null)},
bO(a,b){t.K.a(a)
if(b!=null)A.hA(b)
return this.a0("tron_signTransaction",A.b([a],t.f),B.j,t.m)},
dW(a){return this.bO(a,null)},
bG(a,b){t.K.a(a)
if(b!=null)A.hA(b)
return this.a0("tron_signTransaction",A.b([a],t.f),B.j,t.X)},
dc(a){return this.bG(a,null)},
af(a,b){var s,r,q
if(b==null||!this.f.aa(a))return
s=this.f.j(0,a)
s.toString
s=A.a5(s,t.g)
for(r=s.length,q=0;q<s.length;s.length===r||(0,A.am)(s),++q)s[q].call(null,b)},
ct(a,b){var s,r
A.k(a)
t.g.a(b)
s=A.bH(a)
if(s==null)return
r=this.f.j(0,s)
if(r!=null)B.a.m(r,b)
this.a9(A.be(s))},
dt(a,b){var s
A.k(a)
t.g.a(b)
s=this.f.j(0,A.bH(a))
if(s!=null)B.a.ap(s,b)},
cT(){return this.c4("tron_requestAccounts",B.j,t.c)},
b5(a){t.m.a(a)
return this.a0(A.k(a.method),A.S(a.params),B.j,t.X)},
gG(){return B.H},
ao(a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=this,a=null
b.aT(a0)
s=t.m
r=s.a(a0.data)
q=A.er(r)
for(p=q.length,o=t.A,n=v.G,m=t.N,l=t.X,k=t.z,j=b.e,i=0;i<q.length;q.length===p||(0,A.am)(q),++i)switch(q[i]){case B.t:h=o.a(r.account)
g=b.c
f=g==null
e=f?a:A.E(g.selectedAddress)
d=h==null
if(e!=(d?a:A.k(h.address))){if(!f){f=d?a:A.k(h.address)
g.selectedAddress=f}g=d?a:A.k(h.address)
if(g==null)g=!1
j.base58=g
g=d?a:A.k(h.hex)
if(g==null)g=!1
j.hex=g
s.a(n.window).postMessage(A.fY(A.C(["message",A.C(["action","accountsChanged","data",h],m,l),"source","contentScript"],m,k)))}break
case B.J:b.af(B.c,r.message)
break
case B.I:g=o.a(r.networkAccounts)
b.af(B.f,g==null?a:A.ib(g))
break
case B.r:c=o.a(r.chainChanged)
g=b.c
if(g!=null){f=c==null?a:A.k(c.chainId)
g.chainId=f}g=b.c
if(g!=null){f=c==null?a:A.k(c.netVersion)
g.networkVersion=f}if(r.disconnect!=null)b.af(B.m,r.disconnect)
if(c!=null){if(r.disconnect==null){b.af(B.k,c)
s.a(n.window).postMessage(A.fY(A.C(["message",A.C(["action","connect","data",null],m,l),"source","contentScript"],m,k)))}g=A.k(c.fullNode)
f=b.d
if(f!=null)f.fullNode=new n.TronWeb.providers.HttpProvider(g)
f=b.d
if(f!=null)f.solidityNode=new n.TronWeb.providers.HttpProvider(g)
f=b.d
if(f!=null)f.setEventServer(new n.TronWeb.providers.HttpProvider(g))
b.af(B.i,A.k(c.chainId))
s.a(n.window).postMessage(A.fY(A.C(["message",A.C(["action","setNode","data",A.C(["node",c],m,o)],m,l),"source","contentScript"],m,k)))}break}},
t(a){var s=A.ar(A.E(a)),r=s==null?null:A.b([s],t.s)
return this.l("tron_requestAccounts",r,t.m)},
D(){return this.t(null)},
I(a){var s=t.m
return this.l("tron_signMessageV2",A.b([s.a(a)],t.O),s)},
P(a){var s=t.m
return this.l("tron_signTransaction",A.b([s.a(a)],t.O),s)},
S(a){var s,r,q=this
q.ag()
s={}
s.connect=A.f(q.gC())
s.version="1.0.0"
a["tron:connect"]=s
s={}
s.signMessage=A.f(q.gH())
s.version="1.0.0"
a["tron:signMessage"]=s
r=q.gO()
a["tron:signTransaction"]=A.is(A.f(r))
a["tron:signTransaction"]=A.is(A.f(r))
a["tron:disconnect"]=A.aT(A.x(q.gK()))
a["tron:events"]=A.aj(A.y(q.gL()))}}
A.eQ.prototype={
$0(){return this.a.a},
$S:9}
A.eR.prototype={
$0(){return this.a.b},
$S:15}
A.eS.prototype={
$0(){var s,r,q=this.a,p=v.G,o=t.m,n=o.a(p.Object),m=o.a(n.create.apply(n,[null]))
m.set=A.hE(q.gaQ())
m.get=A.hD(q.gaP())
n=o.a(p.Object)
s=o.a(n.create.apply(n,[null]))
s.get=A.x(new A.eQ(q))
n=o.a(p.Object)
n.defineProperty.apply(n,[m,"debugKey",s])
n=o.a(p.Object)
r=o.a(n.create.apply(n,[null]))
r.get=A.x(new A.eR(q))
p=o.a(p.Object)
p.defineProperty.apply(p,[m,"object",r])
return m},
$S:7}
A.es.prototype={
$1(a){return A.k(a)},
$S:27}
A.et.prototype={
$1(a){return A.ka(A.k(a))},
$S:62}
A.eo.prototype={
$1(a){return A.k(t.m.a(a).address)},
$S:45};(function aliases(){var s=J.aJ.prototype
s.cg=s.i
s=A.N.prototype
s.aT=s.ao})();(function installTearOffs(){var s=hunkHelpers._static_1,r=hunkHelpers._static_0,q=hunkHelpers.installInstanceTearOff,p=hunkHelpers._instance_1u,o=hunkHelpers._instance_2u,n=hunkHelpers._instance_0u
s(A,"lP","kG",16)
s(A,"lQ","kH",16)
s(A,"lR","kI",16)
r(A,"j5","lK",2)
var m
q(m=A.aL.prototype,"gaQ",0,4,null,["$4"],["c8"],51,0,0)
q(m,"gaP",0,3,null,["$3"],["c7"],52,0,0)
p(m=A.cV.prototype,"gc_","aK",8)
p(m,"gdj","dk",8)
o(m=A.bL.prototype,"gL","b4",41)
q(m,"gC",0,0,null,["$1","$0"],["t","D"],54,0,0)
n(m=A.N.prototype,"gK","cP",5)
o(m,"gL","b4",6)
p(m=A.bt.prototype,"gcD","cE",0)
p(m,"gH","I",0)
p(m,"gO","P",0)
q(m,"gdw",0,0,null,["$1","$0"],["bK","dz"],3,0,0)
n(m,"gdd","de",5)
p(m,"gdf","dg",17)
p(m,"gdh","di",17)
q(m=A.bw.prototype,"gC",0,0,null,["$1","$0"],["t","D"],3,0,0)
p(m,"gcz","cA",0)
p(m,"gcB","cC",0)
p(m,"gd_","d0",0)
p(m,"gcv","cw",50)
q(m=A.bA.prototype,"gea",0,0,null,["$1","$0"],["bY","eb"],3,0,0)
p(m,"gH","I",0)
p(m,"gcb","cc",0)
p(m,"gc9","ca",0)
q(m,"gbw",0,1,null,["$2","$1"],["by","bx"],19,0,0)
q(m,"gbA",0,1,null,["$2","$1"],["bC","bB"],19,0,0)
q(m,"ge3",0,1,null,["$2","$1"],["bP","e4"],19,0,0)
p(m,"gbz","d1",29)
p(m,"gaU","aV",0)
p(m,"gO","P",0)
p(m=A.bD.prototype,"gaD","b5",1)
n(m,"gcG","cH",5)
q(m,"gC",0,0,null,["$1","$0"],["t","D"],3,0,0)
p(m,"gaU","aV",1)
p(m,"gdY","dZ",1)
p(m,"ge_","e0",1)
p(m,"ge1","e2",1)
p(m,"gdl","dm",1)
p(m,"gcW","cX",1)
p(m,"gai","aj",1)
o(m,"gcq","cr",6)
o(m,"gdn","dq",6)
q(m=A.c1.prototype,"gC",0,0,null,["$1","$0"],["t","D"],3,0,0)
p(m,"gdL","dM",1)
p(m,"gH","I",1)
p(m,"gdR","dS",0)
p(m,"gdB","dC",0)
p(m,"gdJ","dK",1)
q(m,"gdH",0,1,null,["$2","$1"],["bM","dI"],55,0,0)
q(m=A.c3.prototype,"gC",0,0,null,["$1","$0"],["t","D"],3,0,0)
p(m,"gO","P",0)
p(m,"gai","aj",0)
p(m,"gH","I",1)
q(m=A.c5.prototype,"gd5",0,0,null,["$1","$0"],["bD","d6"],56,0,0)
p(m,"gbE","d9",1)
p(m,"gbh","ce",1)
p(m,"gbg","cd",1)
q(m,"gC",0,0,null,["$1","$0"],["t","D"],3,0,0)
q(m,"gcI",0,0,null,["$1","$0"],["br","cJ"],31,0,0)
q(m,"gex",0,0,null,["$1","$0"],["aN","ey"],31,0,0)
p(m,"gaY","cU",29)
p(m,"gd7","d8",17)
p(m=A.c6.prototype,"gH","I",0)
p(m,"gdP","dQ",0)
p(m,"gO","P",0)
p(m,"gdF","dG",0)
p(m,"gdD","dE",0)
p(m,"gdT","dU",0)
p(m,"gdu","dv",0)
q(m,"gC",0,0,null,["$1","$0"],["t","D"],3,0,0)
q(m=A.c7.prototype,"gC",0,0,null,["$1","$0"],["t","D"],3,0,0)
p(m,"gO","P",1)
p(m,"gai","aj",1)
p(m,"gH","I",1)
p(m=A.c8.prototype,"gcN","cO",60)
q(m,"gdN",0,1,null,["$2","$1"],["bN","dO"],10,0,0)
q(m,"gdV",0,1,null,["$2","$1"],["bO","dW"],10,0,0)
q(m,"gda",0,1,null,["$2","$1"],["bG","dc"],10,0,0)
o(m,"gcs","ct",6)
o(m,"gds","dt",6)
n(m,"gaY","cT",5)
p(m,"gaD","b5",1)
q(m,"gC",0,0,null,["$1","$0"],["t","D"],3,0,0)
p(m,"gH","I",1)
p(m,"gO","P",1)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.e,null)
q(A.e,[A.hh,J.cT,J.bu,A.i,A.bx,A.w,A.eJ,A.aV,A.bR,A.cd,A.bC,A.Q,A.bz,A.eT,A.eA,A.bE,A.cq,A.aF,A.aK,A.ew,A.bP,A.bO,A.cp,A.cW,A.ff,A.dt,A.aa,A.dn,A.ds,A.fy,A.ce,A.a3,A.bk,A.az,A.q,A.dj,A.dq,A.cw,A.ck,A.p,A.by,A.cM,A.fG,A.fD,A.D,A.cN,A.cP,A.fh,A.d6,A.c2,A.fi,A.dU,A.cS,A.T,A.H,A.dr,A.bi,A.ez,A.fv,A.dP,A.dG,A.f9,A.fb,A.eH,A.fu,A.dQ,A.eP,A.du,A.aL,A.d7,A.e9,A.bL,A.N,A.d8])
q(J.cT,[J.bG,J.bJ,J.z,J.bb,J.bc,J.bK,J.ba])
q(J.z,[J.aJ,J.o,A.bS,A.bW])
q(J.aJ,[J.da,J.c9,J.B])
r(J.en,J.o)
q(J.bK,[J.bI,J.cU])
q(A.i,[A.bj,A.l,A.au,A.cc])
r(A.cx,A.bj)
r(A.ch,A.cx)
r(A.ap,A.ch)
q(A.w,[A.bN,A.aw,A.cX,A.dg,A.dc,A.dm,A.cF,A.a7,A.ca,A.df,A.bh,A.cL])
q(A.l,[A.F,A.aR,A.aU,A.as,A.cj])
q(A.F,[A.c4,A.U,A.c0])
r(A.bB,A.au)
r(A.bF,A.bz)
r(A.bY,A.aw)
q(A.aF,[A.cI,A.cJ,A.de,A.fU,A.fW,A.f6,A.f5,A.fI,A.fs,A.fe,A.dV,A.fZ,A.h1,A.h2,A.fQ,A.dH,A.dI,A.eV,A.eW,A.e6,A.e2,A.e7,A.dO,A.f1,A.f3,A.eD,A.h_,A.ep,A.eg,A.ee,A.ed,A.eu,A.eb,A.ej,A.ek,A.dz,A.dA,A.dy,A.eK,A.es,A.et,A.eo])
q(A.de,[A.dd,A.b9])
q(A.aK,[A.aq,A.ci])
r(A.bM,A.aq)
q(A.cJ,[A.fV,A.fJ,A.fO,A.ft,A.ex,A.fd,A.dX,A.dW,A.f4,A.f2,A.dM,A.dK])
q(A.bW,[A.bT,A.bd])
q(A.bd,[A.cl,A.cn])
r(A.cm,A.cl)
r(A.bU,A.cm)
r(A.co,A.cn)
r(A.bV,A.co)
q(A.bU,[A.d_,A.d0])
q(A.bV,[A.d1,A.d2,A.d3,A.d4,A.d5,A.bX,A.aW])
r(A.bm,A.dm)
q(A.cI,[A.f7,A.f8,A.fz,A.dY,A.fj,A.fo,A.fn,A.fl,A.fk,A.fr,A.fq,A.fp,A.fN,A.fx,A.fF,A.fE,A.fa,A.e5,A.e4,A.e1,A.e3,A.e8,A.eE,A.eF,A.eG,A.eq,A.eh,A.ef,A.ev,A.ec,A.ea,A.el,A.ei,A.dL,A.dJ,A.eM,A.eN,A.eO,A.eL,A.eQ,A.eR,A.eS])
q(A.bk,[A.ay,A.cr])
r(A.dp,A.cw)
r(A.bl,A.ci)
r(A.cQ,A.by)
r(A.cE,A.cQ)
q(A.cM,[A.fB,A.fA,A.f0,A.di])
r(A.dD,A.fB)
r(A.dC,A.fA)
q(A.a7,[A.bg,A.cR])
q(A.fh,[A.bv,A.av,A.cZ,A.aG,A.aH,A.R,A.a4,A.aI,A.J,A.d9])
q(A.dG,[A.dF,A.dE,A.dN,A.b8,A.ey])
r(A.cb,A.du)
r(A.cV,A.e9)
q(A.N,[A.bt,A.bw,A.bA,A.bD,A.c1,A.c3,A.c5,A.c6,A.c7,A.c8])
s(A.cx,A.p)
s(A.cl,A.p)
s(A.cm,A.Q)
s(A.cn,A.p)
s(A.co,A.Q)
s(A.du,A.dQ)})()
var v={G:typeof self!="undefined"?self:globalThis,typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{c:"int",r:"double",b7:"num",j:"String",A:"bool",H:"Null",m:"List",e:"Object",at:"Map"},mangledNames:{},types:["h(e)","h(h)","~()","h([j?])","0&()","h()","~(j,B)","e()","~(h)","j?()","h(e[e?])","e?(e?)","~(@)","j()","H(e)","e?()","~(~())","~(B)","e(e)","h(j[e?])","@()","c(c)","H(B,B)","@(@)","H(@)","H()","H(e,ak)","j(j)","A(a4)","h(j)","h(j,e)","h([e?])","H(~())","e?(~)","~(e?,e?)","A(aH)","A(R)","m<c>()","A(aI)","A(J)","L<~>()","B?(j,B)","c(c,c)","L<h>()","@(@,j)","j(h)","H(@,ak)","~(c,@)","A(aG)","@(j)","h(o<e?>)","A(e,e?,e?,e?)","e?(e,e?,e?)","j(T<j,@>)","h([h?])","h(o<e?>[h?])","h([A?])","e(e,ak)","o<e?>(h)","L<h?>()","~(e?)","j(c)","R(j)","A(T<j,@>)","j(e)"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti"),rttc:{}}
A.l0(v.typeUniverse,JSON.parse('{"B":"aJ","da":"aJ","c9":"aJ","o":{"m":["1"],"z":[],"l":["1"],"h":[],"i":["1"]},"bG":{"A":[],"t":[]},"bJ":{"t":[]},"z":{"h":[]},"aJ":{"z":[],"h":[]},"en":{"o":["1"],"m":["1"],"z":[],"l":["1"],"h":[],"i":["1"]},"bu":{"M":["1"]},"bK":{"r":[],"b7":[]},"bI":{"r":[],"c":[],"b7":[],"t":[]},"cU":{"r":[],"b7":[],"t":[]},"ba":{"j":[],"eB":[],"t":[]},"bj":{"i":["2"]},"bx":{"M":["2"]},"ch":{"p":["2"],"m":["2"],"bj":["1","2"],"l":["2"],"i":["2"]},"ap":{"ch":["1","2"],"p":["2"],"m":["2"],"bj":["1","2"],"l":["2"],"i":["2"],"p.E":"2","i.E":"2"},"bN":{"w":[]},"l":{"i":["1"]},"F":{"l":["1"],"i":["1"]},"c4":{"F":["1"],"l":["1"],"i":["1"],"F.E":"1","i.E":"1"},"aV":{"M":["1"]},"au":{"i":["2"],"i.E":"2"},"bB":{"au":["1","2"],"l":["2"],"i":["2"],"i.E":"2"},"bR":{"M":["2"]},"U":{"F":["2"],"l":["2"],"i":["2"],"F.E":"2","i.E":"2"},"cc":{"i":["1"],"i.E":"1"},"cd":{"M":["1"]},"aR":{"l":["1"],"i":["1"],"i.E":"1"},"bC":{"M":["1"]},"c0":{"F":["1"],"l":["1"],"i":["1"],"F.E":"1","i.E":"1"},"bz":{"at":["1","2"]},"bF":{"bz":["1","2"],"at":["1","2"]},"bY":{"aw":[],"w":[]},"cX":{"w":[]},"dg":{"w":[]},"cq":{"ak":[]},"aF":{"aS":[]},"cI":{"aS":[]},"cJ":{"aS":[]},"de":{"aS":[]},"dd":{"aS":[]},"b9":{"aS":[]},"dc":{"w":[]},"aq":{"aK":["1","2"],"hj":["1","2"],"at":["1","2"]},"aU":{"l":["1"],"i":["1"],"i.E":"1"},"bP":{"M":["1"]},"as":{"l":["T<1,2>"],"i":["T<1,2>"],"i.E":"T<1,2>"},"bO":{"M":["T<1,2>"]},"bM":{"aq":["1","2"],"aK":["1","2"],"hj":["1","2"],"at":["1","2"]},"cW":{"eB":[]},"bS":{"z":[],"h":[],"cH":[],"t":[]},"bW":{"z":[],"h":[]},"dt":{"cH":[]},"bT":{"z":[],"h9":[],"h":[],"t":[]},"bd":{"a0":["1"],"z":[],"h":[]},"bU":{"p":["r"],"m":["r"],"a0":["r"],"z":[],"l":["r"],"h":[],"i":["r"],"Q":["r"]},"bV":{"p":["c"],"m":["c"],"a0":["c"],"z":[],"l":["c"],"h":[],"i":["c"],"Q":["c"]},"d_":{"dS":[],"p":["r"],"m":["r"],"a0":["r"],"z":[],"l":["r"],"h":[],"i":["r"],"Q":["r"],"t":[],"p.E":"r"},"d0":{"dT":[],"p":["r"],"m":["r"],"a0":["r"],"z":[],"l":["r"],"h":[],"i":["r"],"Q":["r"],"t":[],"p.E":"r"},"d1":{"dZ":[],"p":["c"],"m":["c"],"a0":["c"],"z":[],"l":["c"],"h":[],"i":["c"],"Q":["c"],"t":[],"p.E":"c"},"d2":{"e_":[],"p":["c"],"m":["c"],"a0":["c"],"z":[],"l":["c"],"h":[],"i":["c"],"Q":["c"],"t":[],"p.E":"c"},"d3":{"e0":[],"p":["c"],"m":["c"],"a0":["c"],"z":[],"l":["c"],"h":[],"i":["c"],"Q":["c"],"t":[],"p.E":"c"},"d4":{"eX":[],"p":["c"],"m":["c"],"a0":["c"],"z":[],"l":["c"],"h":[],"i":["c"],"Q":["c"],"t":[],"p.E":"c"},"d5":{"eY":[],"p":["c"],"m":["c"],"a0":["c"],"z":[],"l":["c"],"h":[],"i":["c"],"Q":["c"],"t":[],"p.E":"c"},"bX":{"eZ":[],"p":["c"],"m":["c"],"a0":["c"],"z":[],"l":["c"],"h":[],"i":["c"],"Q":["c"],"t":[],"p.E":"c"},"aW":{"f_":[],"p":["c"],"m":["c"],"a0":["c"],"z":[],"l":["c"],"h":[],"i":["c"],"Q":["c"],"t":[],"p.E":"c"},"dm":{"w":[]},"bm":{"aw":[],"w":[]},"ce":{"cK":["1"]},"a3":{"w":[]},"bk":{"cK":["1"]},"ay":{"bk":["1"],"cK":["1"]},"cr":{"bk":["1"],"cK":["1"]},"q":{"L":["1"]},"cw":{"iu":[]},"dp":{"cw":[],"iu":[]},"ci":{"aK":["1","2"],"at":["1","2"]},"bl":{"ci":["1","2"],"aK":["1","2"],"at":["1","2"]},"cj":{"l":["1"],"i":["1"],"i.E":"1"},"ck":{"M":["1"]},"aK":{"at":["1","2"]},"cE":{"by":["j","m<c>"]},"cQ":{"by":["j","m<c>"]},"r":{"b7":[]},"c":{"b7":[]},"m":{"l":["1"],"i":["1"]},"j":{"eB":[]},"cF":{"w":[]},"aw":{"w":[]},"a7":{"w":[]},"bg":{"w":[]},"cR":{"w":[]},"ca":{"w":[]},"df":{"w":[]},"bh":{"w":[]},"cL":{"w":[]},"d6":{"w":[]},"c2":{"w":[]},"cS":{"w":[]},"dr":{"ak":[]},"e0":{"m":["c"],"l":["c"],"i":["c"]},"f_":{"m":["c"],"l":["c"],"i":["c"]},"eZ":{"m":["c"],"l":["c"],"i":["c"]},"dZ":{"m":["c"],"l":["c"],"i":["c"]},"eX":{"m":["c"],"l":["c"],"i":["c"]},"e_":{"m":["c"],"l":["c"],"i":["c"]},"eY":{"m":["c"],"l":["c"],"i":["c"]},"dS":{"m":["r"],"l":["r"],"i":["r"]},"dT":{"m":["r"],"l":["r"],"i":["r"]},"bt":{"N":[]},"bw":{"N":[]},"bA":{"N":[]},"bD":{"N":[]},"c1":{"N":[]},"c3":{"N":[]},"c5":{"N":[]},"c6":{"N":[]},"c7":{"N":[]},"c8":{"N":[]}}'))
A.l_(v.typeUniverse,JSON.parse('{"cx":2,"bd":1,"cM":2}'))
var u={n:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type",f:"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAhGVYSWZNTQAqAAAACAAFARIAAwAAAAEAAQAAARoABQAAAAEAAABKARsABQAAAAEAAABSASgAAwAAAAEAAgAAh2kABAAAAAEAAABaAAAAAAAAAEgAAAABAAAASAAAAAEAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAIKADAAQAAAABAAAAIAAAAABfvA/wAAAACXBIWXMAAAsTAAALEwEAmpwYAAACyGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNi4wLjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgICAgICAgICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iPgogICAgICAgICA8dGlmZjpZUmVzb2x1dGlvbj43MjwvdGlmZjpZUmVzb2x1dGlvbj4KICAgICAgICAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+MjwvdGlmZjpSZXNvbHV0aW9uVW5pdD4KICAgICAgICAgPHRpZmY6WFJlc29sdXRpb24+NzI8L3RpZmY6WFJlc29sdXRpb24+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWERpbWVuc2lvbj41MDwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOkNvbG9yU3BhY2U+MTwvZXhpZjpDb2xvclNwYWNlPgogICAgICAgICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+NTA8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KZxgR6QAAB6lJREFUWAnlVmlsXFcZPfe9ecvsYzt2SihSk1SQBUWCqKUJSEkQyw+qSqXEKhKFssROLSTU0MQJAtUI0WYtKkJpYtqoqBJLDAXyB4kSakUlZSkCEtwQoRYqJXU2e+zxvHnztns5903sOBlH6o9KCHGleXPX7zvfud9ygf/3Jm5CgIDiil6d/W/1brJ9wem3Q8aCgudPaog3M2L+vpv22w8rJbB7oAJlGAhtBTsUCFWARw96VKUwNGQAowYeHU3SsRat2BvZbODV1XpdckZgaCAPWzhzMoSU2HlwCkJoTufafAC6TwEPVuDaJyDUOyHRgGE6sIwAnrcR3/jBa3Mn9z2Qzwb5ih6XnMLUxe37vbm1x7+wDLYzili5kEkAAzkocR7K3IBdT1W5r6WLnczcodmOk+VisgSm2QkTnem0lIOp8r4+C8vFRii5AgngZ2So1wM1bWf3PkQ9yVmvjBfRP/w6DvR/F4bYRzktyTEPKI/sXd/aAWCaG3MNwOyiokkk8b3Y+cwJ7N6ynuOPIjFPIxONdKNUtExVqFgWlIrrZ86Nz6CQXWcju8vcu/W4/9VD+7G77/fIGD+nwYu4qQHXuo5+DaUNUYrPJO3a/RPMKt9CCtchmD6QyVpTrlF80i26v+ypVH5V4e8dXYuPfWLN+568f9XaWnj6Fwf8RN7p7u3vw87hlxDLe6mcmgwHzUhTn4pO//lpBxAUAphGk0uD2Hn4BB7bsoW+0ISTPyhyHc/GGfN4T6nQ223ZK0UcL+4yrMXvLvesqJRLvaZj/ubT9ww+N/TetYebSeTNgTCM7bBMH5aiXLYWjBu76bj1GaITDR15Hfv619GR1iPAU8gbLxuuvUb6UXRnpVvcVu4ywjgQPbkibNNQkYxlV66opo3Eqk3X/r7cdj8wdPqVrdmM+Qd/x6HfYVbmPDW6e9VDbpgd/UuV4ZSBWXsQgfU95NWzcJ1Nqu43y5btCEijk3+3FMuiaLlCCIjufMlwbNv0/EbTzueWnPfqK0+/9MzXjZ73fCZZtvYkDjw9cYOWdNh+BWmccy07voEXNIZifAds61Oo+xFj2E3jh3dqCh7l1dJyFJ0s8vzpccYw3LjeiEzH+uT99+y4KwzD03kdObrNyk4HrU87gFVjVx1FrkIkTiJSfVowf0LTVZMJOqnMtR36l8Qlr4bxmUl4QRN2JoOsaSOKY6YdiZlm0IfEO0mGVrTUjbbpa7+Co2NAuZZl+L0fInmD1n8FUvYYUmkcwjZMLCt1IWfZCKIA9cAnC0x+ZMU2LW5VqPp1eGEomioxGD3PX46S23s+vmrM+9qxEN9sQZn9tiFKU6XvVchxyKsuMJl0IpEMBCUUre+2s5zOoBGFDBYLHXRCl4oNXkkjJKCwiZkwEF4QoCFlpysyBYk4nJFWmd6vuZwXAwtlwllokjVBN202f0Uzg9hQyLkuM5/Em14dJgEtrXSjSFAhWfB9D5ONGVQ1K2SkQfO8KGJEU4LOBQu0dgZ0McrmWTSk5Vhihrl8suQ4eFdHj7qtczHLgonppod/1qp4g1T/7cp5XKLSehzhvJ6bmUI9itS0jDAdBpMXkrDOYHMaRjSt/ahl0jUk7QBGeg1s+46vGQ8iFqNInqrT8su1qozjmDfEmKOkDEU1mN/HSfUEHbBGSyXB1QhkIgzkJFm60vBPBQhoBH1k+3NeWjGv6U577QB0SU2bOMMw/BAy5jD9Cpf8umrS6bR3K9J5a2URlhQruCVfhk9QV+gT434D50n/lShQlzmuy2gYifVB3uE/UpFzslsa9LcdQKueA0snR3lwJWT4ZxWGP3E6ylYpV2henKmiQYuTpPUcsDMm7z9OPf/s1GWm+7DpOaaVNPyfwpv4I+laDf/WF1OVs7Kv6V8AgF781ueWo3eEGtSvyetWjFc/Hzb8v/47nHEbcRyVcsV4oj4tz05cUOeql9WFqQn5WvVSzKQUiULOhd88BWvys3A6+hkqLzABxanMeYpnu/PzQMvrH3kgj47CK/jYHQ52HP4xPrJ2BfLualyobgtt83bpWGtCFRuTUUBnEKIpE+FDCuU6hiAdvKcRZCbvRljezPiJMTh8DPsHdjCfHML6pcMYfVW/IVq62Gm/gq6CzSRkM/4ex7f7NmHX94+k+3rKX16EeIv0401TtdoPlRBjTH3jwrHGRSYzhiD4kWqGH4YKv4ioY4BPOhu7hp9mNd0AyD2IKTPIssyzXfUy3V34QSJzLMkkxzJ+RhD3UdAR7PnSXVeU+TCFncllzUca9YTPrKSkXIZIIuuQpoeMpMNxjxAvYPDwy9hL5Yb5fGqw5Luy++qDZM7+BQGUuZ/CNUxDdMAxf4snBnZh28HdOLr5T/hX58ZGqO6DTfaUGSBh3lAsABkmS5hn0Dj7GIZGYxx4aJAidmsrW9lM5NDkA/eG1s6AYN6FOsdKo7NXgynZoVUDdKIR9KaP0uOUcRxPPJyFTtn6OnXi0rljtunaDwwwZi+SnYCM5LjtTYg8ZV/f2hBRqcCe/hKtMuD6Ck0+UgO+bIeG+U5k0yVVV8zNRyUFt25Tn9EJ7NqznPv6cmTPmZOhDRs8XJs7cz2O/96onYEWloXm5/nuWwL8dsh4S4r+tzf9Bwpfgk0+0buPAAAAAElFTkSuQmCC"}
var t=(function rtii(){var s=A.aD
return{n:s("a3"),B:s("cH"),Y:s("h9"),V:s("l<@>"),C:s("w"),E:s("dS"),d:s("dT"),Z:s("aS"),dQ:s("dZ"),k:s("e_"),gj:s("e0"),R:s("i<@>"),c_:s("aG"),O:s("o<h>"),I:s("o<B>"),ao:s("o<T<j,@>>"),f:s("o<e>"),s:s("o<j>"),b:s("o<@>"),t:s("o<c>"),c:s("o<e?>"),D:s("J"),G:s("a4"),bs:s("R"),T:s("bJ"),m:s("h"),fr:s("aH"),e5:s("aI"),g:s("B"),aU:s("a0<@>"),e:s("z"),cl:s("m<h>"),u:s("m<B>"),ew:s("m<e>"),a:s("m<j>"),j:s("m<@>"),L:s("m<c>"),fs:s("cZ"),w:s("T<j,@>"),eO:s("at<@,@>"),bm:s("aW"),P:s("H"),K:s("e"),p:s("d7"),q:s("aL<e>"),gT:s("mg"),bQ:s("+()"),bJ:s("c0<j>"),l:s("ak"),N:s("j"),dm:s("t"),eK:s("aw"),h7:s("eX"),bv:s("eY"),go:s("eZ"),gc:s("f_"),ak:s("c9"),aQ:s("N"),x:s("ay<h>"),h:s("ay<~>"),ev:s("D"),et:s("q<h>"),_:s("q<@>"),U:s("q<~>"),J:s("bl<e?,e?>"),aj:s("cr<~>"),y:s("A"),al:s("A(e)"),i:s("r"),z:s("@"),fO:s("@()"),v:s("@(e)"),Q:s("@(e,ak)"),S:s("c"),eH:s("L<H>?"),W:s("L<@>?"),r:s("o<e?>?"),A:s("h?"),X:s("e?"),dk:s("j?"),F:s("az<@,@>?"),fQ:s("A?"),cD:s("r?"),h6:s("c?"),cg:s("b7?"),o:s("b7"),H:s("~"),M:s("~()")}})();(function constants(){var s=hunkHelpers.makeConstList
B.al=J.cT.prototype
B.a=J.o.prototype
B.R=J.bG.prototype
B.b=J.bI.prototype
B.ao=J.bK.prototype
B.e=J.ba.prototype
B.aq=J.B.prototype
B.ar=J.z.prototype
B.az=A.bT.prototype
B.aA=A.aW.prototype
B.Z=J.da.prototype
B.M=J.c9.prototype
B.a4=new A.b8("invalid hex bytes",null)
B.a5=new A.b8("Hex input string must be divisible by two",null)
B.a6=new A.b8("Incorrect characters for hex decoding",null)
B.a7=new A.dC(!1)
B.w=new A.bv("bitcoin")
B.a9=new A.cE()
B.aa=new A.dD()
B.N=new A.cP()
B.ab=new A.bC(A.aD("bC<0&>"))
B.aP=new A.dP()
B.x=new A.cS()
B.O=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.ac=function() {
  var toStringFunction = Object.prototype.toString;
  function getTag(o) {
    var s = toStringFunction.call(o);
    return s.substring(8, s.length - 1);
  }
  function getUnknownTag(object, tag) {
    if (/^HTML[A-Z].*Element$/.test(tag)) {
      var name = toStringFunction.call(object);
      if (name == "[object Object]") return null;
      return "HTMLElement";
    }
  }
  function getUnknownTagGenericBrowser(object, tag) {
    if (object instanceof HTMLElement) return "HTMLElement";
    return getUnknownTag(object, tag);
  }
  function prototypeForTag(tag) {
    if (typeof window == "undefined") return null;
    if (typeof window[tag] == "undefined") return null;
    var constructor = window[tag];
    if (typeof constructor != "function") return null;
    return constructor.prototype;
  }
  function discriminator(tag) { return null; }
  var isBrowser = typeof HTMLElement == "function";
  return {
    getTag: getTag,
    getUnknownTag: isBrowser ? getUnknownTagGenericBrowser : getUnknownTag,
    prototypeForTag: prototypeForTag,
    discriminator: discriminator };
}
B.ah=function(getTagFallback) {
  return function(hooks) {
    if (typeof navigator != "object") return hooks;
    var userAgent = navigator.userAgent;
    if (typeof userAgent != "string") return hooks;
    if (userAgent.indexOf("DumpRenderTree") >= 0) return hooks;
    if (userAgent.indexOf("Chrome") >= 0) {
      function confirm(p) {
        return typeof window == "object" && window[p] && window[p].name == p;
      }
      if (confirm("Window") && confirm("HTMLElement")) return hooks;
    }
    hooks.getTag = getTagFallback;
  };
}
B.ad=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.ag=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Firefox") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "GeoGeolocation": "Geolocation",
    "Location": "!Location",
    "WorkerMessageEvent": "MessageEvent",
    "XMLDocument": "!Document"};
  function getTagFirefox(o) {
    var tag = getTag(o);
    return quickMap[tag] || tag;
  }
  hooks.getTag = getTagFirefox;
}
B.af=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Trident/") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "HTMLDDElement": "HTMLElement",
    "HTMLDTElement": "HTMLElement",
    "HTMLPhraseElement": "HTMLElement",
    "Position": "Geoposition"
  };
  function getTagIE(o) {
    var tag = getTag(o);
    var newTag = quickMap[tag];
    if (newTag) return newTag;
    if (tag == "Object") {
      if (window.DataView && (o instanceof window.DataView)) return "DataView";
    }
    return tag;
  }
  function prototypeForTagIE(tag) {
    var constructor = window[tag];
    if (constructor == null) return null;
    return constructor.prototype;
  }
  hooks.getTag = getTagIE;
  hooks.prototypeForTag = prototypeForTagIE;
}
B.ae=function(hooks) {
  var getTag = hooks.getTag;
  var prototypeForTag = hooks.prototypeForTag;
  function getTagFixed(o) {
    var tag = getTag(o);
    if (tag == "Document") {
      if (!!o.xmlVersion) return "!Document";
      return "!HTMLDocument";
    }
    return tag;
  }
  function prototypeForTagFixed(tag) {
    if (tag == "Document") return null;
    return prototypeForTag(tag);
  }
  hooks.getTag = getTagFixed;
  hooks.prototypeForTag = prototypeForTagFixed;
}
B.P=function(hooks) { return hooks; }

B.ai=new A.d6()
B.o=new A.eJ()
B.aj=new A.f0()
B.Q=new A.fu()
B.h=new A.dp()
B.p=new A.dr()
B.ak=new A.dN("SHA256: can't update because hash was finished.",null)
B.q=new A.aG("Rejected","rejected")
B.y=new A.J("Aptos","aptos")
B.z=new A.J("Bitcoin","bitcoin")
B.A=new A.J("Cosmos","cosmos")
B.B=new A.J("Ethereum","ethereum")
B.C=new A.J("Solana","solana")
B.D=new A.J("Stellar","stellar")
B.E=new A.J("Substrate","substrate")
B.F=new A.J("Sui","sui")
B.G=new A.J("TON","ton")
B.H=new A.J("Tron","tron")
B.f=new A.a4("accountsChanged")
B.i=new A.a4("chainChanged")
B.c=new A.a4("message")
B.k=new A.a4("connect")
B.m=new A.a4("disconnect")
B.d=new A.a4("change")
B.I=new A.R("networkAccountsChanged")
B.S=new A.R("change")
B.r=new A.R("defaultChainChanged")
B.t=new A.R("defaultAccountChanged")
B.J=new A.R("message")
B.T=new A.aH("response")
B.U=new A.aI("success")
B.K=new A.aI("failed")
B.u=A.b(s(["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"]),t.s)
B.V=A.b(s([256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,0,1,2,3,4,5,6,7,8,9,256,256,256,256,256,256,256,10,11,12,13,14,15,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,10,11,12,13,14,15,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256]),t.t)
B.W=A.b(s([B.f,B.i,B.c,B.k,B.m,B.d]),A.aD("o<a4>"))
B.as=A.b(s([1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298]),t.b)
B.ap=new A.aH("event")
B.at=A.b(s([B.T,B.ap]),A.aD("o<aH>"))
B.an=new A.J("","global")
B.au=A.b(s([B.an,B.B,B.H,B.C,B.G,B.D,B.E,B.y,B.F,B.z,B.A]),A.aD("o<J>"))
B.av=A.b(s([B.I,B.S,B.r,B.t,B.J]),A.aD("o<R>"))
B.am=new A.aG("Approved","approved")
B.aw=A.b(s([B.am,B.q]),A.aD("o<aG>"))
B.ax=A.b(s([B.U,B.K]),A.aD("o<aI>"))
B.X=new A.cZ("one")
B.a8=new A.bv("ripple")
B.Y=new A.bF([B.w,"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz",B.a8,"rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz"],A.aD("bF<bv,j>"))
B.ay=new A.ey("Invalid character in Base58 string",null)
B.n=new A.d9("walletStandard")
B.j=new A.d9("eip1993")
B.a_=new A.av("ascii")
B.L=new A.av("utf8")
B.v=new A.av("base64")
B.a0=new A.av("base64UrlSafe")
B.a1=new A.av("base58")
B.a2=new A.av("base58Check")
B.a3=new A.av("hex")
B.aB=A.ah("cH")
B.aC=A.ah("h9")
B.aD=A.ah("dS")
B.aE=A.ah("dT")
B.aF=A.ah("dZ")
B.aG=A.ah("e_")
B.aH=A.ah("e0")
B.aI=A.ah("e")
B.aJ=A.ah("eX")
B.aK=A.ah("eY")
B.aL=A.ah("eZ")
B.aM=A.ah("f_")
B.aN=new A.di(!1)
B.aO=new A.di(!0)
B.l=new A.cb("An error occurred during the request",-32603)})();(function staticFields(){$.fw=null
$.a2=A.b([],t.f)
$.ii=null
$.i_=null
$.hZ=null
$.j9=null
$.j4=null
$.jd=null
$.fS=null
$.fX=null
$.hM=null
$.mD=A.b([],A.aD("o<m<e>?>"))
$.bn=null
$.cy=null
$.cz=null
$.hG=!1
$.u=B.h
$.iy=null
$.iz=null
$.iA=null
$.iB=null
$.hs=A.fg("_lastQuoRemDigits")
$.ht=A.fg("_lastQuoRemUsed")
$.cg=A.fg("_lastRemUsed")
$.hu=A.fg("_lastRem_nsh")})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal
s($,"mc","bs",()=>A.m_("_$dart_dartClosure"))
s($,"ml","jm",()=>A.ax(A.eU({
toString:function(){return"$receiver$"}})))
s($,"mm","jn",()=>A.ax(A.eU({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"mn","jo",()=>A.ax(A.eU(null)))
s($,"mo","jp",()=>A.ax(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"mr","js",()=>A.ax(A.eU(void 0)))
s($,"ms","jt",()=>A.ax(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"mq","jr",()=>A.ax(A.it(null)))
s($,"mp","jq",()=>A.ax(function(){try{null.$method$}catch(r){return r.message}}()))
s($,"mu","jv",()=>A.ax(A.it(void 0)))
s($,"mt","ju",()=>A.ax(function(){try{(void 0).$method$}catch(r){return r.message}}()))
s($,"mv","hS",()=>A.kF())
s($,"mG","jB",()=>A.ie(4096))
s($,"mE","jz",()=>new A.fF().$0())
s($,"mF","jA",()=>new A.fE().$0())
s($,"mC","P",()=>A.dk(0))
s($,"mA","aE",()=>A.dk(1))
s($,"mB","jy",()=>A.dk(2))
s($,"mz","hT",()=>$.aE().Z(0))
s($,"mx","jw",()=>A.dk(1e4))
s($,"my","jx",()=>A.ie(8))
s($,"mH","h4",()=>A.dw(B.aI))
s($,"mI","jC",()=>Symbol("jsBoxedDartObjectProperty"))
s($,"mf","ji",()=>{var r=new A.fv(new DataView(new ArrayBuffer(A.li(8))))
r.ck()
return r})
s($,"mw","h3",()=>new A.fa().$0())
s($,"mj","jk",()=>A.ky("^(0x|0X)?([0-9A-Fa-f]{2})+$"))
s($,"me","hR",()=>({message:"this feature disabled by wallet provider."}))
s($,"md","jh",()=>({uuid:"466aef37-e077-42d1-b26b-801ff1af4a36",name:"OnChain",icon:u.f,rdns:"com.mrtnetwork.wallet"}))
s($,"mh","jj",()=>A.kh(A.b(["legacy",0],t.f),t.K))
s($,"mk","jl",()=>({message:"Invalid Sui transaction. The transaction must include transactionBlock with the blockData property for v1, or transaction with the toJSON property for v2."}))})();(function nativeSupport(){!function(){var s=function(a){var m={}
m[a]=1
return Object.keys(hunkHelpers.convertToFastObject(m))[0]}
v.getIsolateTag=function(a){return s("___dart_"+a+v.isolateTag)}
var r="___dart_isolate_tags_"
var q=Object[r]||(Object[r]=Object.create(null))
var p="_ZxYxX"
for(var o=0;;o++){var n=s(p+"_"+o+"_")
if(!(n in q)){q[n]=1
v.isolateTag=n
break}}v.dispatchPropertyName=v.getIsolateTag("dispatch_record")}()
hunkHelpers.setOrUpdateInterceptorsByTag({ArrayBuffer:A.bS,ArrayBufferView:A.bW,DataView:A.bT,Float32Array:A.d_,Float64Array:A.d0,Int16Array:A.d1,Int32Array:A.d2,Int8Array:A.d3,Uint16Array:A.d4,Uint32Array:A.d5,Uint8ClampedArray:A.bX,CanvasPixelArray:A.bX,Uint8Array:A.aW})
hunkHelpers.setOrUpdateLeafTags({ArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.bd.$nativeSuperclassTag="ArrayBufferView"
A.cl.$nativeSuperclassTag="ArrayBufferView"
A.cm.$nativeSuperclassTag="ArrayBufferView"
A.bU.$nativeSuperclassTag="ArrayBufferView"
A.cn.$nativeSuperclassTag="ArrayBufferView"
A.co.$nativeSuperclassTag="ArrayBufferView"
A.bV.$nativeSuperclassTag="ArrayBufferView"})()
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$0=function(){return this()}
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$1$1=function(a){return this(a)}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var s=document.scripts
function onLoad(b){for(var q=0;q<s.length;++q){s[q].removeEventListener("load",onLoad,false)}a(b.target)}for(var r=0;r<s.length;++r){s[r].addEventListener("load",onLoad,false)}})(function(a){v.currentScript=a
var s=function(b){return A.hO(A.lV(b))}
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()