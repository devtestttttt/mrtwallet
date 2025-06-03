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
if(a[b]!==s){A.c_(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a){a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.fr(b)
return new s(c,this)}:function(){if(s===null)s=A.fr(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.fr(a).prototype
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
fy(a,b,c,d){return{i:a,p:b,e:c,x:d}},
eP(a){var s,r,q,p,o,n=a[v.dispatchPropertyName]
if(n==null)if($.fu==null){A.jZ()
n=a[v.dispatchPropertyName]}if(n!=null){s=n.p
if(!1===s)return n.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return n.i
if(n.e===r)throw A.f(A.fe("Return interceptor for "+A.u(s(a,n))))}q=a.constructor
if(q==null)p=null
else{o=$.ey
if(o==null)o=$.ey=v.getIsolateTag("_$dart_js")
p=q[o]}if(p!=null)return p
p=A.k2(a)
if(p!=null)return p
if(typeof a=="function")return B.a0
s=Object.getPrototypeOf(a)
if(s==null)return B.P
if(s===Object.prototype)return B.P
if(typeof q=="function"){o=$.ey
if(o==null)o=$.ey=v.getIsolateTag("_$dart_js")
Object.defineProperty(q,o,{value:B.H,enumerable:false,writable:true,configurable:true})
return B.H}return B.H},
ih(a,b){if(a<0||a>4294967295)throw A.f(A.aD(a,0,4294967295,"length",null))
return J.ii(new Array(a),b)},
fL(a,b){if(a<0)throw A.f(A.aa("Length must be a non-negative integer: "+a,null))
return A.a(new Array(a),b.h("n<0>"))},
ii(a,b){var s=A.a(a,b.h("n<0>"))
s.$flags=1
return s},
aK(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.bg.prototype
return J.cd.prototype}if(typeof a=="string")return J.aO.prototype
if(a==null)return J.bh.prototype
if(typeof a=="boolean")return J.cc.prototype
if(Array.isArray(a))return J.n.prototype
if(typeof a!="object"){if(typeof a=="function")return J.y.prototype
if(typeof a=="symbol")return J.aQ.prototype
if(typeof a=="bigint")return J.aP.prototype
return a}if(a instanceof A.c)return a
return J.eP(a)},
hy(a){if(typeof a=="string")return J.aO.prototype
if(a==null)return a
if(Array.isArray(a))return J.n.prototype
if(typeof a!="object"){if(typeof a=="function")return J.y.prototype
if(typeof a=="symbol")return J.aQ.prototype
if(typeof a=="bigint")return J.aP.prototype
return a}if(a instanceof A.c)return a
return J.eP(a)},
bZ(a){if(a==null)return a
if(Array.isArray(a))return J.n.prototype
if(typeof a!="object"){if(typeof a=="function")return J.y.prototype
if(typeof a=="symbol")return J.aQ.prototype
if(typeof a=="bigint")return J.aP.prototype
return a}if(a instanceof A.c)return a
return J.eP(a)},
jU(a){if(a==null)return a
if(typeof a!="object"){if(typeof a=="function")return J.y.prototype
if(typeof a=="symbol")return J.aQ.prototype
if(typeof a=="bigint")return J.aP.prototype
return a}if(a instanceof A.c)return a
return J.eP(a)},
f0(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.aK(a).S(a,b)},
hU(a,b){if(typeof b==="number")if(Array.isArray(a)||A.k1(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.bZ(a).j(a,b)},
hV(a,b,c){return J.jU(a).bk(a,b,c)},
fB(a,b){return J.bZ(a).P(a,b)},
a2(a){return J.aK(a).gq(a)},
b5(a){return J.bZ(a).gB(a)},
cO(a){return J.hy(a).gn(a)},
hW(a){return J.aK(a).gu(a)},
cP(a,b,c){return J.bZ(a).ao(a,b,c)},
b6(a){return J.aK(a).i(a)},
cb:function cb(){},
cc:function cc(){},
bh:function bh(){},
x:function x(){},
ap:function ap(){},
cv:function cv(){},
bC:function bC(){},
y:function y(){},
aP:function aP(){},
aQ:function aQ(){},
n:function n(a){this.$ti=a},
dv:function dv(a){this.$ti=a},
b8:function b8(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
ce:function ce(){},
bg:function bg(){},
cd:function cd(){},
aO:function aO(){}},A={f7:function f7(){},
ip(a){return new A.ch("Field '"+a+"' has been assigned during initialization.")},
at(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
fc(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
eL(a,b,c){return a},
fv(a){var s,r
for(s=$.S.length,r=0;r<s;++r)if(a===$.S[r])return!0
return!1},
it(a,b,c,d){if(t.V.b(a))return new A.bc(a,b,c.h("@<0>").p(d).h("bc<1,2>"))
return new A.aC(a,b,c.h("@<0>").p(d).h("aC<1,2>"))},
ia(){return new A.aV("No element")},
aW:function aW(){},
ba:function ba(a,b){this.a=a
this.$ti=b},
bG:function bG(){},
ab:function ab(a,b){this.a=a
this.$ti=b},
ch:function ch(a){this.a=a},
dO:function dO(){},
j:function j(){},
F:function F(){},
aB:function aB(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aC:function aC(a,b,c){this.a=a
this.b=b
this.$ti=c},
bc:function bc(a,b,c){this.a=a
this.b=b
this.$ti=c},
bn:function bn(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
L:function L(a,b,c){this.a=a
this.b=b
this.$ti=c},
I:function I(){},
bV:function bV(){},
hE(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
k1(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.da.b(a)},
u(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.b6(a)
return s},
cw(a){var s,r=$.fV
if(r==null)r=$.fV=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
dJ(a){var s,r,q,p
if(a instanceof A.c)return A.M(A.b2(a),null)
s=J.aK(a)
if(s===B.X||s===B.a1||t.cr.b(a)){r=B.J(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.M(A.b2(a),null)},
iE(a){if(a==null||typeof a=="number"||A.eH(a))return J.b6(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.ak)return a.i(0)
if(a instanceof A.cG)return a.dE(!0)
return"Instance of '"+A.dJ(a)+"'"},
aT(a){if(a.date===void 0)a.date=new Date(a.a)
return a.date},
iD(a){var s=A.aT(a).getUTCFullYear()+0
return s},
iB(a){var s=A.aT(a).getUTCMonth()+1
return s},
ix(a){var s=A.aT(a).getUTCDate()+0
return s},
iy(a){var s=A.aT(a).getUTCHours()+0
return s},
iA(a){var s=A.aT(a).getUTCMinutes()+0
return s},
iC(a){var s=A.aT(a).getUTCSeconds()+0
return s},
iz(a){var s=A.aT(a).getUTCMilliseconds()+0
return s},
iw(a){var s=a.$thrownJsError
if(s==null)return null
return A.aw(s)},
fW(a,b){var s
if(a.$thrownJsError==null){s=new Error()
A.D(a,s)
a.$thrownJsError=s
s.stack=b.i(0)}},
H(a,b){if(a==null)J.cO(a)
throw A.f(A.eN(a,b))},
eN(a,b){var s,r="index"
if(!A.hn(b))return new A.a9(!0,b,r,null)
s=J.cO(a)
if(b<0||b>=s)return A.fJ(b,s,a,r)
return new A.aU(null,null,!0,b,r,"Value not in range")},
f(a){return A.D(a,new Error())},
D(a,b){var s
if(a==null)a=new A.ad()
b.dartException=a
s=A.k6
if("defineProperty" in Object){Object.defineProperty(b,"message",{get:s})
b.name=""}else b.toString=s
return b},
k6(){return J.b6(this.dartException)},
a8(a,b){throw A.D(a,b==null?new Error():b)},
cN(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.a8(A.jg(a,b,c),s)},
jg(a,b,c){var s,r,q,p,o,n,m,l,k
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
return new A.bD("'"+s+"': Cannot "+o+" "+l+k+n)},
aj(a){throw A.f(A.al(a))},
ae(a){var s,r,q,p,o,n
a=A.k5(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.a([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.e0(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
e1(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
h2(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
f8(a,b){var s=b==null,r=s?null:b.method
return new A.cg(a,r,s?null:b.receiver)},
ay(a){var s
if(a==null)return new A.dI(a)
if(a instanceof A.be){s=a.a
return A.ax(a,s==null?t.K.a(s):s)}if(typeof a!=="object")return a
if("dartException" in a)return A.ax(a,a.dartException)
return A.jK(a)},
ax(a,b){if(t.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
jK(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.f.cH(r,16)&8191)===10)switch(q){case 438:return A.ax(a,A.f8(A.u(s)+" (Error "+q+")",null))
case 445:case 5007:A.u(s)
return A.ax(a,new A.bu())}}if(a instanceof TypeError){p=$.hJ()
o=$.hK()
n=$.hL()
m=$.hM()
l=$.hP()
k=$.hQ()
j=$.hO()
$.hN()
i=$.hS()
h=$.hR()
g=p.N(s)
if(g!=null)return A.ax(a,A.f8(A.h(s),g))
else{g=o.N(s)
if(g!=null){g.method="call"
return A.ax(a,A.f8(A.h(s),g))}else if(n.N(s)!=null||m.N(s)!=null||l.N(s)!=null||k.N(s)!=null||j.N(s)!=null||m.N(s)!=null||i.N(s)!=null||h.N(s)!=null){A.h(s)
return A.ax(a,new A.bu())}}return A.ax(a,new A.cC(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.bw()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.ax(a,new A.a9(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.bw()
return a},
aw(a){var s
if(a instanceof A.be)return a.b
if(a==null)return new A.bO(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.bO(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
eX(a){if(a==null)return J.a2(a)
if(typeof a=="object")return A.cw(a)
return J.a2(a)},
jT(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.C(0,a[s],a[r])}return b},
jq(a,b,c,d,e,f){t.Z.a(a)
switch(A.W(b)){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.f(new A.ei("Unsupported number of arguments for wrapped closure"))},
bY(a,b){var s=a.$identity
if(!!s)return s
s=A.jP(a,b)
a.$identity=s
return s},
jP(a,b){var s
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
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.jq)},
i2(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.cy().constructor.prototype):Object.create(new A.aN(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.fG(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.hZ(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.fG(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
hZ(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.f("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.hX)}throw A.f("Error in functionType of tearoff")},
i_(a,b,c,d){var s=A.fF
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
fG(a,b,c,d){if(c)return A.i1(a,b,d)
return A.i_(b.length,d,a,b)},
i0(a,b,c,d){var s=A.fF,r=A.hY
switch(b?-1:a){case 0:throw A.f(new A.cx("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
i1(a,b,c){var s,r
if($.fD==null)$.fD=A.fC("interceptor")
if($.fE==null)$.fE=A.fC("receiver")
s=b.length
r=A.i0(s,c,a,b)
return r},
fr(a){return A.i2(a)},
hX(a,b){return A.bT(v.typeUniverse,A.b2(a.a),b)},
fF(a){return a.a},
hY(a){return a.b},
fC(a){var s,r,q,p=new A.aN("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.f(A.aa("Field name "+a+" not found.",null))},
jV(a){return v.getIsolateTag(a)},
jQ(a){var s,r=A.a([],t.s)
if(a==null)return r
if(Array.isArray(a)){for(s=0;s<a.length;++s)r.push(String(a[s]))
return r}r.push(String(a))
return r},
kt(a,b,c){Object.defineProperty(a,b,{value:c,enumerable:false,writable:true,configurable:true})},
k2(a){var s,r,q,p,o,n=A.h($.hz.$1(a)),m=$.eO[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.eT[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=A.a6($.hv.$2(a,n))
if(q!=null){m=$.eO[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.eT[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.eW(s)
$.eO[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.eT[n]=s
return s}if(p==="-"){o=A.eW(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.hB(a,s)
if(p==="*")throw A.f(A.fe(n))
if(v.leafTags[n]===true){o=A.eW(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.hB(a,s)},
hB(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.fy(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
eW(a){return J.fy(a,!1,null,!!a.$iQ)},
k4(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.eW(s)
else return J.fy(s,c,null,null)},
jZ(){if(!0===$.fu)return
$.fu=!0
A.k_()},
k_(){var s,r,q,p,o,n,m,l
$.eO=Object.create(null)
$.eT=Object.create(null)
A.jY()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.hD.$1(o)
if(n!=null){m=A.k4(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
jY(){var s,r,q,p,o,n,m=B.Q()
m=A.b1(B.R,A.b1(B.S,A.b1(B.K,A.b1(B.K,A.b1(B.T,A.b1(B.U,A.b1(B.V(B.J),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.hz=new A.eQ(p)
$.hv=new A.eR(o)
$.hD=new A.eS(n)},
b1(a,b){return a(b)||b},
jR(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
k5(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
e0:function e0(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
bu:function bu(){},
cg:function cg(a,b,c){this.a=a
this.b=b
this.c=c},
cC:function cC(a){this.a=a},
dI:function dI(a){this.a=a},
be:function be(a,b){this.a=a
this.b=b},
bO:function bO(a){this.a=a
this.b=null},
ak:function ak(){},
c3:function c3(){},
c4:function c4(){},
cA:function cA(){},
cy:function cy(){},
aN:function aN(a,b){this.a=a
this.b=b},
cx:function cx(a){this.a=a},
aA:function aA(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
dF:function dF(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
bm:function bm(a,b){this.a=a
this.$ti=b},
bl:function bl(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
bj:function bj(a,b){this.a=a
this.$ti=b},
bk:function bk(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
eQ:function eQ(a){this.a=a},
eR:function eR(a){this.a=a},
eS:function eS(a){this.a=a},
cG:function cG(){},
iu(a,b,c){var s=new Uint8Array(a,b,c)
return s},
aG(a,b,c){if(a>>>0!==a||a>=c)throw A.f(A.eN(b,a))},
bo:function bo(){},
bs:function bs(){},
cK:function cK(a){this.a=a},
bp:function bp(){},
aR:function aR(){},
bq:function bq(){},
br:function br(){},
cj:function cj(){},
ck:function ck(){},
cl:function cl(){},
cm:function cm(){},
cn:function cn(){},
co:function co(){},
cp:function cp(){},
bt:function bt(){},
cq:function cq(){},
bK:function bK(){},
bL:function bL(){},
bM:function bM(){},
bN:function bN(){},
fa(a,b){var s=b.c
return s==null?b.c=A.bR(a,"J",[b.x]):s},
fY(a){var s=a.w
if(s===6||s===7)return A.fY(a.x)
return s===11||s===12},
iI(a){return a.as},
aJ(a){return A.eD(v.typeUniverse,a,!1)},
aH(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.aH(a1,s,a3,a4)
if(r===s)return a2
return A.hd(a1,r,!0)
case 7:s=a2.x
r=A.aH(a1,s,a3,a4)
if(r===s)return a2
return A.hc(a1,r,!0)
case 8:q=a2.y
p=A.b0(a1,q,a3,a4)
if(p===q)return a2
return A.bR(a1,a2.x,p)
case 9:o=a2.x
n=A.aH(a1,o,a3,a4)
m=a2.y
l=A.b0(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.fj(a1,n,l)
case 10:k=a2.x
j=a2.y
i=A.b0(a1,j,a3,a4)
if(i===j)return a2
return A.he(a1,k,i)
case 11:h=a2.x
g=A.aH(a1,h,a3,a4)
f=a2.y
e=A.jH(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.hb(a1,g,e)
case 12:d=a2.y
a4+=d.length
c=A.b0(a1,d,a3,a4)
o=a2.x
n=A.aH(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.fk(a1,n,c,!0)
case 13:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.f(A.c1("Attempted to substitute unexpected RTI kind "+a0))}},
b0(a,b,c,d){var s,r,q,p,o=b.length,n=A.eE(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.aH(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
jI(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.eE(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.aH(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
jH(a,b,c,d){var s,r=b.a,q=A.b0(a,r,c,d),p=b.b,o=A.b0(a,p,c,d),n=b.c,m=A.jI(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.cF()
s.a=q
s.b=o
s.c=m
return s},
a(a,b){a[v.arrayRti]=b
return a},
hx(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.jX(s)
return a.$S()}return null},
k0(a,b){var s
if(A.fY(b))if(a instanceof A.ak){s=A.hx(a)
if(s!=null)return s}return A.b2(a)},
b2(a){if(a instanceof A.c)return A.av(a)
if(Array.isArray(a))return A.P(a)
return A.fn(J.aK(a))},
P(a){var s=a[v.arrayRti],r=t.b
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
av(a){var s=a.$ti
return s!=null?s:A.fn(a)},
fn(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.jn(a,s)},
jn(a,b){var s=a instanceof A.ak?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.j2(v.typeUniverse,s.name)
b.$ccache=r
return r},
jX(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.eD(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
ft(a){return A.aI(A.av(a))},
fq(a){var s
if(a instanceof A.cG)return A.jS(a.$r,a.dD())
s=a instanceof A.ak?A.hx(a):null
if(s!=null)return s
if(t.bW.b(a))return J.hW(a).a
if(Array.isArray(a))return A.P(a)
return A.b2(a)},
aI(a){var s=a.r
return s==null?a.r=new A.eC(a):s},
jS(a,b){var s,r,q=b,p=q.length
if(p===0)return t.cD
if(0>=p)return A.H(q,0)
s=A.bT(v.typeUniverse,A.fq(q[0]),"@<0>")
for(r=1;r<p;++r){if(!(r<q.length))return A.H(q,r)
s=A.hf(v.typeUniverse,s,A.fq(q[r]))}return A.bT(v.typeUniverse,s,a)},
a1(a){return A.aI(A.eD(v.typeUniverse,a,!1))},
jm(a){var s,r,q,p,o=this
if(o===t.K)return A.ai(o,a,A.jv)
if(A.aL(o))return A.ai(o,a,A.jz)
s=o.w
if(s===6)return A.ai(o,a,A.jk)
if(s===1)return A.ai(o,a,A.ho)
if(s===7)return A.ai(o,a,A.jr)
if(o===t.S)r=A.hn
else if(o===t.i||o===t.o)r=A.ju
else if(o===t.N)r=A.jx
else r=o===t.y?A.eH:null
if(r!=null)return A.ai(o,a,r)
if(s===8){q=o.x
if(o.y.every(A.aL)){o.f="$i"+q
if(q==="l")return A.ai(o,a,A.jt)
return A.ai(o,a,A.jy)}}else if(s===10){p=A.jR(o.x,o.y)
return A.ai(o,a,p==null?A.ho:p)}return A.ai(o,a,A.ji)},
ai(a,b,c){a.b=c
return a.b(b)},
jl(a){var s=this,r=A.jh
if(A.aL(s))r=A.j9
else if(s===t.K)r=A.j8
else if(A.b3(s))r=A.jj
if(s===t.S)r=A.W
else if(s===t.a3)r=A.j6
else if(s===t.N)r=A.h
else if(s===t.aD)r=A.a6
else if(s===t.y)r=A.hi
else if(s===t.cG)r=A.ah
else if(s===t.o)r=A.j7
else if(s===t.ae)r=A.hj
else if(s===t.i)r=A.j4
else if(s===t.dd)r=A.j5
s.a=r
return s.a(a)},
ji(a){var s=this
if(a==null)return A.b3(s)
return A.hA(v.typeUniverse,A.k0(a,s),s)},
jk(a){if(a==null)return!0
return this.x.b(a)},
jy(a){var s,r=this
if(a==null)return A.b3(r)
s=r.f
if(a instanceof A.c)return!!a[s]
return!!J.aK(a)[s]},
jt(a){var s,r=this
if(a==null)return A.b3(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.c)return!!a[s]
return!!J.aK(a)[s]},
jh(a){var s=this
if(a==null){if(A.b3(s))return a}else if(s.b(a))return a
throw A.D(A.hk(a,s),new Error())},
jj(a){var s=this
if(a==null||s.b(a))return a
throw A.D(A.hk(a,s),new Error())},
hk(a,b){return new A.aZ("TypeError: "+A.h4(a,A.M(b,null)))},
jO(a,b,c,d){if(A.hA(v.typeUniverse,a,b))return a
throw A.D(A.iV("The type argument '"+A.M(a,null)+"' is not a subtype of the type variable bound '"+A.M(b,null)+"' of type variable '"+c+"' in '"+d+"'."),new Error())},
h4(a,b){return A.cZ(a)+": type '"+A.M(A.fq(a),null)+"' is not a subtype of type '"+b+"'"},
iV(a){return new A.aZ("TypeError: "+a)},
a5(a,b){return new A.aZ("TypeError: "+A.h4(a,b))},
jr(a){var s=this
return s.x.b(a)||A.fa(v.typeUniverse,s).b(a)},
jv(a){return a!=null},
j8(a){if(a!=null)return a
throw A.D(A.a5(a,"Object"),new Error())},
jz(a){return!0},
j9(a){return a},
ho(a){return!1},
eH(a){return!0===a||!1===a},
hi(a){if(!0===a)return!0
if(!1===a)return!1
throw A.D(A.a5(a,"bool"),new Error())},
ah(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.D(A.a5(a,"bool?"),new Error())},
j4(a){if(typeof a=="number")return a
throw A.D(A.a5(a,"double"),new Error())},
j5(a){if(typeof a=="number")return a
if(a==null)return a
throw A.D(A.a5(a,"double?"),new Error())},
hn(a){return typeof a=="number"&&Math.floor(a)===a},
W(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.D(A.a5(a,"int"),new Error())},
j6(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.D(A.a5(a,"int?"),new Error())},
ju(a){return typeof a=="number"},
j7(a){if(typeof a=="number")return a
throw A.D(A.a5(a,"num"),new Error())},
hj(a){if(typeof a=="number")return a
if(a==null)return a
throw A.D(A.a5(a,"num?"),new Error())},
jx(a){return typeof a=="string"},
h(a){if(typeof a=="string")return a
throw A.D(A.a5(a,"String"),new Error())},
a6(a){if(typeof a=="string")return a
if(a==null)return a
throw A.D(A.a5(a,"String?"),new Error())},
ht(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.M(a[q],b)
return s},
jC(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.ht(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.M(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
hl(a3,a4,a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1=", ",a2=null
if(a5!=null){s=a5.length
if(a4==null)a4=A.a([],t.s)
else a2=a4.length
r=a4.length
for(q=s;q>0;--q)B.a.t(a4,"T"+(r+q))
for(p=t.X,o="<",n="",q=0;q<s;++q,n=a1){m=a4.length
l=m-1-q
if(!(l>=0))return A.H(a4,l)
o=o+n+a4[l]
k=a5[q]
j=k.w
if(!(j===2||j===3||j===4||j===5||k===p))o+=" extends "+A.M(k,a4)}o+=">"}else o=""
p=a3.x
i=a3.y
h=i.a
g=h.length
f=i.b
e=f.length
d=i.c
c=d.length
b=A.M(p,a4)
for(a="",a0="",q=0;q<g;++q,a0=a1)a+=a0+A.M(h[q],a4)
if(e>0){a+=a0+"["
for(a0="",q=0;q<e;++q,a0=a1)a+=a0+A.M(f[q],a4)
a+="]"}if(c>0){a+=a0+"{"
for(a0="",q=0;q<c;q+=3,a0=a1){a+=a0
if(d[q+1])a+="required "
a+=A.M(d[q+2],a4)+" "+d[q]}a+="}"}if(a2!=null){a4.toString
a4.length=a2}return o+"("+a+") => "+b},
M(a,b){var s,r,q,p,o,n,m,l=a.w
if(l===5)return"erased"
if(l===2)return"dynamic"
if(l===3)return"void"
if(l===1)return"Never"
if(l===4)return"any"
if(l===6){s=a.x
r=A.M(s,b)
q=s.w
return(q===11||q===12?"("+r+")":r)+"?"}if(l===7)return"FutureOr<"+A.M(a.x,b)+">"
if(l===8){p=A.jJ(a.x)
o=a.y
return o.length>0?p+("<"+A.ht(o,b)+">"):p}if(l===10)return A.jC(a,b)
if(l===11)return A.hl(a,b,null)
if(l===12)return A.hl(a.x,b,a.y)
if(l===13){n=a.x
m=b.length
n=m-1-n
if(!(n>=0&&n<m))return A.H(b,n)
return b[n]}return"?"},
jJ(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
j3(a,b){var s=a.tR[b]
for(;typeof s=="string";)s=a.tR[s]
return s},
j2(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.eD(a,b,!1)
else if(typeof m=="number"){s=m
r=A.bS(a,5,"#")
q=A.eE(s)
for(p=0;p<s;++p)q[p]=r
o=A.bR(a,b,q)
n[b]=o
return o}else return m},
j1(a,b){return A.hg(a.tR,b)},
j0(a,b){return A.hg(a.eT,b)},
eD(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.h9(A.h7(a,null,b,!1))
r.set(b,s)
return s},
bT(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.h9(A.h7(a,b,c,!0))
q.set(c,r)
return r},
hf(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.fj(a,b,c.w===9?c.y:[c])
p.set(s,q)
return q},
au(a,b){b.a=A.jl
b.b=A.jm
return b},
bS(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.V(null,null)
s.w=b
s.as=c
r=A.au(a,s)
a.eC.set(c,r)
return r},
hd(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.iZ(a,b,r,c)
a.eC.set(r,s)
return s},
iZ(a,b,c,d){var s,r,q
if(d){s=b.w
r=!0
if(!A.aL(b))if(!(b===t.P||b===t.T))if(s!==6)r=s===7&&A.b3(b.x)
if(r)return b
else if(s===1)return t.P}q=new A.V(null,null)
q.w=6
q.x=b
q.as=c
return A.au(a,q)},
hc(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.iX(a,b,r,c)
a.eC.set(r,s)
return s},
iX(a,b,c,d){var s,r
if(d){s=b.w
if(A.aL(b)||b===t.K)return b
else if(s===1)return A.bR(a,"J",[b])
else if(b===t.P||b===t.T)return t.bc}r=new A.V(null,null)
r.w=7
r.x=b
r.as=c
return A.au(a,r)},
j_(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.V(null,null)
s.w=13
s.x=b
s.as=q
r=A.au(a,s)
a.eC.set(q,r)
return r},
bQ(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
iW(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
bR(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.bQ(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.V(null,null)
r.w=8
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.au(a,r)
a.eC.set(p,q)
return q},
fj(a,b,c){var s,r,q,p,o,n
if(b.w===9){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.bQ(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.V(null,null)
o.w=9
o.x=s
o.y=r
o.as=q
n=A.au(a,o)
a.eC.set(q,n)
return n},
he(a,b,c){var s,r,q="+"+(b+"("+A.bQ(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.V(null,null)
s.w=10
s.x=b
s.y=c
s.as=q
r=A.au(a,s)
a.eC.set(q,r)
return r},
hb(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.bQ(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.bQ(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.iW(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.V(null,null)
p.w=11
p.x=b
p.y=c
p.as=r
o=A.au(a,p)
a.eC.set(r,o)
return o},
fk(a,b,c,d){var s,r=b.as+("<"+A.bQ(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.iY(a,b,c,r,d)
a.eC.set(r,s)
return s},
iY(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.eE(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.aH(a,b,r,0)
m=A.b0(a,c,r,0)
return A.fk(a,n,m,c!==m)}}l=new A.V(null,null)
l.w=12
l.x=b
l.y=c
l.as=d
return A.au(a,l)},
h7(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
h9(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.iP(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.h8(a,r,l,k,!1)
else if(q===46)r=A.h8(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.aF(a.u,a.e,k.pop()))
break
case 94:k.push(A.j_(a.u,k.pop()))
break
case 35:k.push(A.bS(a.u,5,"#"))
break
case 64:k.push(A.bS(a.u,2,"@"))
break
case 126:k.push(A.bS(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.iR(a,k)
break
case 38:A.iQ(a,k)
break
case 63:p=a.u
k.push(A.hd(p,A.aF(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.hc(p,A.aF(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.iO(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.ha(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.iT(a.u,a.e,o)
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
return A.aF(a.u,a.e,m)},
iP(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
h8(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===9)o=o.x
n=A.j3(s,o.x)[p]
if(n==null)A.a8('No "'+p+'" in "'+A.iI(o)+'"')
d.push(A.bT(s,o,n))}else d.push(p)
return m},
iR(a,b){var s,r=a.u,q=A.h6(a,b),p=b.pop()
if(typeof p=="string")b.push(A.bR(r,p,q))
else{s=A.aF(r,a.e,p)
switch(s.w){case 11:b.push(A.fk(r,s,q,a.n))
break
default:b.push(A.fj(r,s,q))
break}}},
iO(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.h6(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.aF(p,a.e,o)
q=new A.cF()
q.a=s
q.b=n
q.c=m
b.push(A.hb(p,r,q))
return
case-4:b.push(A.he(p,b.pop(),s))
return
default:throw A.f(A.c1("Unexpected state under `()`: "+A.u(o)))}},
iQ(a,b){var s=b.pop()
if(0===s){b.push(A.bS(a.u,1,"0&"))
return}if(1===s){b.push(A.bS(a.u,4,"1&"))
return}throw A.f(A.c1("Unexpected extended operation "+A.u(s)))},
h6(a,b){var s=b.splice(a.p)
A.ha(a.u,a.e,s)
a.p=b.pop()
return s},
aF(a,b,c){if(typeof c=="string")return A.bR(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.iS(a,b,c)}else return c},
ha(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.aF(a,b,c[s])},
iT(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.aF(a,b,c[s])},
iS(a,b,c){var s,r,q=b.w
if(q===9){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==8)throw A.f(A.c1("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.f(A.c1("Bad index "+c+" for "+b.i(0)))},
hA(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.C(a,b,null,c,null)
r.set(c,s)}return s},
C(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(A.aL(d))return!0
s=b.w
if(s===4)return!0
if(A.aL(b))return!1
if(b.w===1)return!0
r=s===13
if(r)if(A.C(a,c[b.x],c,d,e))return!0
q=d.w
p=t.P
if(b===p||b===t.T){if(q===7)return A.C(a,b,c,d.x,e)
return d===p||d===t.T||q===6}if(d===t.K){if(s===7)return A.C(a,b.x,c,d,e)
return s!==6}if(s===7){if(!A.C(a,b.x,c,d,e))return!1
return A.C(a,A.fa(a,b),c,d,e)}if(s===6)return A.C(a,p,c,d,e)&&A.C(a,b.x,c,d,e)
if(q===7){if(A.C(a,b,c,d.x,e))return!0
return A.C(a,b,c,A.fa(a,d),e)}if(q===6)return A.C(a,b,c,p,e)||A.C(a,b,c,d.x,e)
if(r)return!1
p=s!==11
if((!p||s===12)&&d===t.Z)return!0
o=s===10
if(o&&d===t.L)return!0
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
if(!A.C(a,j,c,i,e)||!A.C(a,i,e,j,c))return!1}return A.hm(a,b.x,c,d.x,e)}if(q===11){if(b===t.g)return!0
if(p)return!1
return A.hm(a,b,c,d,e)}if(s===8){if(q!==8)return!1
return A.js(a,b,c,d,e)}if(o&&q===10)return A.jw(a,b,c,d,e)
return!1},
hm(a3,a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.C(a3,a4.x,a5,a6.x,a7))return!1
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
if(!A.C(a3,p[h],a7,g,a5))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.C(a3,p[o+h],a7,g,a5))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.C(a3,k[h],a7,g,a5))return!1}f=s.c
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
if(!A.C(a3,e[a+2],a7,g,a5))return!1
break}}for(;b<d;){if(f[b+1])return!1
b+=3}return!0},
js(a,b,c,d,e){var s,r,q,p,o,n=b.x,m=d.x
for(;n!==m;){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.bT(a,b,r[o])
return A.hh(a,p,null,c,d.y,e)}return A.hh(a,b.y,null,c,d.y,e)},
hh(a,b,c,d,e,f){var s,r=b.length
for(s=0;s<r;++s)if(!A.C(a,b[s],d,e[s],f))return!1
return!0},
jw(a,b,c,d,e){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.C(a,r[s],c,q[s],e))return!1
return!0},
b3(a){var s=a.w,r=!0
if(!(a===t.P||a===t.T))if(!A.aL(a))if(s!==6)r=s===7&&A.b3(a.x)
return r},
aL(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.X},
hg(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
eE(a){return a>0?new Array(a):v.typeUniverse.sEA},
V:function V(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
cF:function cF(){this.c=this.b=this.a=null},
eC:function eC(a){this.a=a},
cE:function cE(){},
aZ:function aZ(a){this.a=a},
iK(){var s,r,q
if(self.scheduleImmediate!=null)return A.jL()
if(self.MutationObserver!=null&&self.document!=null){s={}
r=self.document.createElement("div")
q=self.document.createElement("span")
s.a=null
new self.MutationObserver(A.bY(new A.ee(s),1)).observe(r,{childList:true})
return new A.ed(s,r,q)}else if(self.setImmediate!=null)return A.jM()
return A.jN()},
iL(a){self.scheduleImmediate(A.bY(new A.ef(t.M.a(a)),0))},
iM(a){self.setImmediate(A.bY(new A.eg(t.M.a(a)),0))},
iN(a){A.fd(B.I,t.M.a(a))},
fd(a,b){return A.iU(0,b)},
iU(a,b){var s=new A.eA()
s.bF(a,b)
return s},
a_(a){return new A.bF(new A.m($.o,a.h("m<0>")),a.h("bF<0>"))},
Z(a,b){a.$2(0,null)
b.b=!0
return b.a},
a7(a,b){b.toString
A.ja(a,b)},
Y(a,b){b.V(a)},
X(a,b){b.aM(A.ay(a),A.aw(a))},
ja(a,b){var s,r,q=new A.eF(b),p=new A.eG(b)
if(a instanceof A.m)a.bh(q,p,t.z)
else{s=t.z
if(a instanceof A.m)a.a_(q,p,s)
else{r=new A.m($.o,t._)
r.a=8
r.c=a
r.bh(q,p,s)}}},
a0(a){var s=function(b,c){return function(d,e){while(true){try{b(d,e)
break}catch(r){e=r
d=c}}}}(a,1)
return $.o.bp(new A.eJ(s),t.H,t.S,t.z)},
f2(a){var s
if(t.C.b(a)){s=a.ga1()
if(s!=null)return s}return B.o},
i9(a,b){var s
if(!b.b(null))throw A.f(A.f1(null,"computation","The type parameter is not nullable"))
s=new A.m($.o,b.h("m<0>"))
A.h0(a,new A.d4(null,s,b))
return s},
jo(a,b){if($.o===B.e)return null
return null},
jp(a,b){if($.o!==B.e)A.jo(a,b)
if(b==null)if(t.C.b(a)){b=a.ga1()
if(b==null){A.fW(a,B.o)
b=B.o}}else b=B.o
else if(t.C.b(a))A.fW(a,b)
return new A.N(a,b)},
ff(a,b){var s=new A.m($.o,b.h("m<0>"))
b.a(a)
s.a=8
s.c=a
return s},
em(a,b,c){var s,r,q,p,o={},n=o.a=a
for(s=t._;r=n.a,(r&4)!==0;n=a){a=s.a(n.c)
o.a=a}if(n===b){s=A.fZ()
b.aA(new A.N(new A.a9(!0,n,null,"Cannot complete a future with itself"),s))
return}q=b.a&1
s=n.a=r|q
if((s&24)===0){p=t.F.a(b.c)
b.a=b.a&1|4
b.c=n
n.bc(p)
return}if(!c)if(b.c==null)n=(s&16)===0||q!==0
else n=!1
else n=!0
if(n){p=b.a8()
b.ag(o.a)
A.aE(b,p)
return}b.a^=2
A.cM(null,null,b.b,t.M.a(new A.en(o,b)))},
aE(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d={},c=d.a=a
for(s=t.n,r=t.F;!0;){q={}
p=c.a
o=(p&16)===0
n=!o
if(b==null){if(n&&(p&1)===0){m=s.a(c.c)
A.fp(m.a,m.b)}return}q.a=b
l=b.a
for(c=b;l!=null;c=l,l=k){c.a=null
A.aE(d.a,c)
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
A.fp(j.a,j.b)
return}g=$.o
if(g!==h)$.o=h
else g=null
c=c.c
if((c&15)===8)new A.er(q,d,n).$0()
else if(o){if((c&1)!==0)new A.eq(q,j).$0()}else if((c&2)!==0)new A.ep(d,q).$0()
if(g!=null)$.o=g
c=q.c
if(c instanceof A.m){p=q.a.$ti
p=p.h("J<2>").b(c)||!p.y[1].b(c)}else p=!1
if(p){f=q.a.b
if((c.a&24)!==0){e=r.a(f.c)
f.c=null
b=f.ak(e)
f.a=c.a&30|f.a&1
f.c=c.c
d.a=c
continue}else A.em(c,f,!0)
return}}f=q.a.b
e=r.a(f.c)
f.c=null
b=f.ak(e)
c=q.b
p=q.c
if(!c){f.$ti.c.a(p)
f.a=8
f.c=p}else{s.a(p)
f.a=f.a&1|16
f.c=p}d.a=f
c=f}},
hr(a,b){var s
if(t.Q.b(a))return b.bp(a,t.z,t.K,t.l)
s=t.v
if(s.b(a))return s.a(a)
throw A.f(A.f1(a,"onError",u.c))},
jB(){var s,r
for(s=$.b_;s!=null;s=$.b_){$.bX=null
r=s.b
$.b_=r
if(r==null)$.bW=null
s.a.$0()}},
jG(){$.fo=!0
try{A.jB()}finally{$.bX=null
$.fo=!1
if($.b_!=null)$.fA().$1(A.hw())}},
hu(a){var s=new A.cD(a),r=$.bW
if(r==null){$.b_=$.bW=s
if(!$.fo)$.fA().$1(A.hw())}else $.bW=r.b=s},
jF(a){var s,r,q,p=$.b_
if(p==null){A.hu(a)
$.bX=$.bW
return}s=new A.cD(a)
r=$.bX
if(r==null){s.b=p
$.b_=$.bX=s}else{q=r.b
s.b=q
$.bX=r.b=s
if(q==null)$.bW=s}},
kd(a,b){A.eL(a,"stream",t.K)
return new A.cI(b.h("cI<0>"))},
h0(a,b){var s=$.o
if(s===B.e)return A.fd(a,t.M.a(b))
return A.fd(a,t.M.a(s.bl(b)))},
fp(a,b){A.jF(new A.eI(a,b))},
hs(a,b,c,d,e){var s,r=$.o
if(r===c)return d.$0()
$.o=c
s=r
try{r=d.$0()
return r}finally{$.o=s}},
jE(a,b,c,d,e,f,g){var s,r=$.o
if(r===c)return d.$1(e)
$.o=c
s=r
try{r=d.$1(e)
return r}finally{$.o=s}},
jD(a,b,c,d,e,f,g,h,i){var s,r=$.o
if(r===c)return d.$2(e,f)
$.o=c
s=r
try{r=d.$2(e,f)
return r}finally{$.o=s}},
cM(a,b,c,d){t.M.a(d)
if(B.e!==c)d=c.bl(d)
A.hu(d)},
ee:function ee(a){this.a=a},
ed:function ed(a,b,c){this.a=a
this.b=b
this.c=c},
ef:function ef(a){this.a=a},
eg:function eg(a){this.a=a},
eA:function eA(){this.b=null},
eB:function eB(a,b){this.a=a
this.b=b},
bF:function bF(a,b){this.a=a
this.b=!1
this.$ti=b},
eF:function eF(a){this.a=a},
eG:function eG(a){this.a=a},
eJ:function eJ(a){this.a=a},
N:function N(a,b){this.a=a
this.b=b},
d4:function d4(a,b,c){this.a=a
this.b=b
this.c=c},
dX:function dX(a,b){this.a=a
this.b=b},
aX:function aX(){},
af:function af(a,b){this.a=a
this.$ti=b},
bP:function bP(a,b){this.a=a
this.$ti=b},
ag:function ag(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
m:function m(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
ej:function ej(a,b){this.a=a
this.b=b},
eo:function eo(a,b){this.a=a
this.b=b},
en:function en(a,b){this.a=a
this.b=b},
el:function el(a,b){this.a=a
this.b=b},
ek:function ek(a,b){this.a=a
this.b=b},
er:function er(a,b,c){this.a=a
this.b=b
this.c=c},
es:function es(a,b){this.a=a
this.b=b},
et:function et(a){this.a=a},
eq:function eq(a,b){this.a=a
this.b=b},
ep:function ep(a,b){this.a=a
this.b=b},
eu:function eu(a,b){this.a=a
this.b=b},
ev:function ev(a,b,c){this.a=a
this.b=b
this.c=c},
ew:function ew(a,b){this.a=a
this.b=b},
cD:function cD(a){this.a=a
this.b=null},
cI:function cI(a){this.$ti=a},
bU:function bU(){},
eI:function eI(a,b){this.a=a
this.b=b},
cH:function cH(){},
ez:function ez(a,b){this.a=a
this.b=b},
h5(a,b){var s=a[b]
return s===a?null:s},
fh(a,b,c){if(c==null)a[b]=a
else a[b]=c},
fg(){var s=Object.create(null)
A.fh(s,"<non-identifier-key>",s)
delete s["<non-identifier-key>"]
return s},
B(a,b,c){return b.h("@<0>").p(c).h("fQ<1,2>").a(A.jT(a,new A.aA(b.h("@<0>").p(c).h("aA<1,2>"))))},
f9(a,b){return new A.aA(a.h("@<0>").p(b).h("aA<1,2>"))},
fS(a){var s,r
if(A.fv(a))return"{...}"
s=new A.cz("")
try{r={}
B.a.t($.S,a)
s.a+="{"
r.a=!0
a.aN(0,new A.dG(r,s))
s.a+="}"}finally{if(0>=$.S.length)return A.H($.S,-1)
$.S.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
bH:function bH(){},
aY:function aY(a){var _=this
_.a=0
_.e=_.d=_.c=_.b=null
_.$ti=a},
bI:function bI(a,b){this.a=a
this.$ti=b},
bJ:function bJ(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
q:function q(){},
aq:function aq(){},
dG:function dG(a,b){this.a=a
this.b=b},
i6(a,b){a=A.D(a,new Error())
if(a==null)a=t.K.a(a)
a.stack=b.i(0)
throw a},
fR(a,b,c,d){var s,r=c?J.fL(a,d):J.ih(a,d)
if(a!==0&&b!=null)for(s=0;s<r.length;++s)r[s]=b
return r},
ir(a,b,c){var s,r=A.a([],c.h("n<0>"))
for(s=J.b5(a);s.l();)B.a.t(r,c.a(s.gm()))
if(b)return r
r.$flags=1
return r},
ac(a,b){var s,r
if(Array.isArray(a))return A.a(a.slice(0),b.h("n<0>"))
s=A.a([],b.h("n<0>"))
for(r=J.b5(a);r.l();)B.a.t(s,r.gm())
return s},
is(a,b,c){var s,r=J.fL(a,c)
for(s=0;s<a;++s)B.a.C(r,s,b.$1(s))
return r},
h_(a,b,c){var s=J.b5(b)
if(!s.l())return a
if(c.length===0){do a+=A.u(s.gm())
while(s.l())}else{a+=A.u(s.gm())
for(;s.l();)a=a+c+A.u(s.gm())}return a},
fZ(){return A.aw(new Error())},
i4(a){var s=Math.abs(a),r=a<0?"-":""
if(s>=1000)return""+a
if(s>=100)return r+"0"+s
if(s>=10)return r+"00"+s
return r+"000"+s},
fH(a){if(a>=100)return""+a
if(a>=10)return"0"+a
return"00"+a},
c8(a){if(a>=10)return""+a
return"0"+a},
cZ(a){if(typeof a=="number"||A.eH(a)||a==null)return J.b6(a)
if(typeof a=="string")return JSON.stringify(a)
return A.iE(a)},
i7(a,b){A.eL(a,"error",t.K)
A.eL(b,"stackTrace",t.l)
A.i6(a,b)},
c1(a){return new A.c0(a)},
aa(a,b){return new A.a9(!1,null,b,a)},
f1(a,b,c){return new A.a9(!0,a,b,c)},
aD(a,b,c,d,e){return new A.aU(b,c,!0,a,d,"Invalid value")},
iH(a,b,c){if(0>a||a>c)throw A.f(A.aD(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.f(A.aD(b,a,c,"end",null))
return b}return c},
iG(a,b){if(a<0)throw A.f(A.aD(a,0,null,b,null))
return a},
fJ(a,b,c,d){return new A.ca(b,!0,a,d,"Index out of range")},
e8(a){return new A.bD(a)},
fe(a){return new A.cB(a)},
fb(a){return new A.aV(a)},
al(a){return new A.c6(a)},
ib(a,b,c){var s,r
if(A.fv(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.a([],t.s)
B.a.t($.S,a)
try{A.jA(a,s)}finally{if(0>=$.S.length)return A.H($.S,-1)
$.S.pop()}r=A.h_(b,t.R.a(s),", ")+c
return r.charCodeAt(0)==0?r:r},
fK(a,b,c){var s,r
if(A.fv(a))return b+"..."+c
s=new A.cz(b)
B.a.t($.S,a)
try{r=s
r.a=A.h_(r.a,a,", ")}finally{if(0>=$.S.length)return A.H($.S,-1)
$.S.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
jA(a,b){var s,r,q,p,o,n,m,l=a.gB(a),k=0,j=0
while(!0){if(!(k<80||j<3))break
if(!l.l())return
s=A.u(l.gm())
B.a.t(b,s)
k+=s.length+2;++j}if(!l.l()){if(j<=5)return
if(0>=b.length)return A.H(b,-1)
r=b.pop()
if(0>=b.length)return A.H(b,-1)
q=b.pop()}else{p=l.gm();++j
if(!l.l()){if(j<=4){B.a.t(b,A.u(p))
return}r=A.u(p)
if(0>=b.length)return A.H(b,-1)
q=b.pop()
k+=r.length+2}else{o=l.gm();++j
for(;l.l();p=o,o=n){n=l.gm();++j
if(j>100){while(!0){if(!(k>75&&j>3))break
if(0>=b.length)return A.H(b,-1)
k-=b.pop().length+2;--j}B.a.t(b,"...")
return}}q=A.u(p)
r=A.u(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
while(!0){if(!(k>80&&b.length>3))break
if(0>=b.length)return A.H(b,-1)
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)B.a.t(b,m)
B.a.t(b,q)
B.a.t(b,r)},
iv(a,b,c,d){var s
if(B.n===c){s=B.f.gq(a)
b=J.a2(b)
return A.fc(A.at(A.at($.f_(),s),b))}if(B.n===d){s=B.f.gq(a)
b=J.a2(b)
c=J.a2(c)
return A.fc(A.at(A.at(A.at($.f_(),s),b),c))}s=B.f.gq(a)
b=J.a2(b)
c=J.a2(c)
d=J.a2(d)
d=A.fc(A.at(A.at(A.at(A.at($.f_(),s),b),c),d))
return d},
c7:function c7(a,b,c){this.a=a
this.b=b
this.c=c},
c9:function c9(){},
eh:function eh(){},
w:function w(){},
c0:function c0(a){this.a=a},
ad:function ad(){},
a9:function a9(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
aU:function aU(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
ca:function ca(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
bD:function bD(a){this.a=a},
cB:function cB(a){this.a=a},
aV:function aV(a){this.a=a},
c6:function c6(a){this.a=a},
cr:function cr(){},
bw:function bw(){},
ei:function ei(a){this.a=a},
i:function i(){},
ar:function ar(a,b,c){this.a=a
this.b=b
this.$ti=c},
z:function z(){},
c:function c(){},
cJ:function cJ(){},
cz:function cz(a){this.a=a},
iq(a,b){return a},
ic(a,b){var s,r,q,p,o,n
if(b.length===0)return!1
s=b.split(".")
r=v.G
for(q=s.length,p=t.A,o=0;o<q;++o){n=s[o]
r=p.a(r[n])
if(r==null)return!1}return a instanceof t.g.a(r)},
i8(a){return t.m.a(new v.G.Promise(A.v(new A.d3(a))))},
d3:function d3(a){this.a=a},
d1:function d1(a){this.a=a},
d2:function d2(a){this.a=a},
t(a){var s
if(typeof a=="function")throw A.f(A.aa("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(){return b(c)}}(A.jb,a)
s[$.b4()]=a
return s},
d(a){var s
if(typeof a=="function")throw A.f(A.aa("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d){return b(c,d,arguments.length)}}(A.jc,a)
s[$.b4()]=a
return s},
v(a){var s
if(typeof a=="function")throw A.f(A.aa("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e){return b(c,d,e,arguments.length)}}(A.jd,a)
s[$.b4()]=a
return s},
fl(a){var s
if(typeof a=="function")throw A.f(A.aa("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e,f){return b(c,d,e,f,arguments.length)}}(A.je,a)
s[$.b4()]=a
return s},
fm(a){var s
if(typeof a=="function")throw A.f(A.aa("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e,f,g){return b(c,d,e,f,g,arguments.length)}}(A.jf,a)
s[$.b4()]=a
return s},
jb(a){return t.Z.a(a).$0()},
jc(a,b,c){t.Z.a(a)
if(A.W(c)>=1)return a.$1(b)
return a.$0()},
jd(a,b,c,d){t.Z.a(a)
A.W(d)
if(d>=2)return a.$2(b,c)
if(d===1)return a.$1(b)
return a.$0()},
je(a,b,c,d,e){t.Z.a(a)
A.W(e)
if(e>=3)return a.$3(b,c,d)
if(e===2)return a.$2(b,c)
if(e===1)return a.$1(b)
return a.$0()},
jf(a,b,c,d,e,f){t.Z.a(a)
A.W(f)
if(f>=4)return a.$4(b,c,d,e)
if(f===3)return a.$3(b,c,d)
if(f===2)return a.$2(b,c)
if(f===1)return a.$1(b)
return a.$0()},
hq(a){return a==null||A.eH(a)||typeof a=="number"||typeof a=="string"||t.t.b(a)||t.bX.b(a)||t.ca.b(a)||t.d.b(a)||t.c0.b(a)||t.k.b(a)||t.bk.b(a)||t.E.b(a)||t.W.b(a)||t.B.b(a)||t.Y.b(a)},
fw(a){if(A.hq(a))return a
return new A.eU(new A.aY(t.J)).$1(a)},
jW(a,b,c){return c.a(a[b])},
eK(a,b,c){var s,r
if(b==null)return c.a(new a())
if(b instanceof Array)switch(b.length){case 0:return c.a(new a())
case 1:return c.a(new a(b[0]))
case 2:return c.a(new a(b[0],b[1]))
case 3:return c.a(new a(b[0],b[1],b[2]))
case 4:return c.a(new a(b[0],b[1],b[2],b[3]))}s=[null]
B.a.bj(s,b)
r=a.bind.apply(a,s)
String(r)
return c.a(new r())},
hC(a,b){var s=new A.m($.o,b.h("m<0>")),r=new A.af(s,b.h("af<0>"))
a.then(A.bY(new A.eY(r,b),1),A.bY(new A.eZ(r),1))
return s},
hp(a){return a==null||typeof a==="boolean"||typeof a==="number"||typeof a==="string"||a instanceof Int8Array||a instanceof Uint8Array||a instanceof Uint8ClampedArray||a instanceof Int16Array||a instanceof Uint16Array||a instanceof Int32Array||a instanceof Uint32Array||a instanceof Float32Array||a instanceof Float64Array||a instanceof ArrayBuffer||a instanceof DataView},
fs(a){if(A.hp(a))return a
return new A.eM(new A.aY(t.J)).$1(a)},
eU:function eU(a){this.a=a},
eY:function eY(a,b){this.a=a
this.b=b},
eZ:function eZ(a){this.a=a},
eM:function eM(a){this.a=a},
dH:function dH(a){this.a=a},
ex:function ex(a){this.a=a},
iJ(){var s,r,q,p=A.is(16,new A.e2($.hG()),t.S)
B.a.C(p,6,p[6]&15|64)
B.a.C(p,8,p[8]&63|128)
s=A.P(p)
r=s.h("L<1,k>")
q=A.ac(new A.L(p,s.h("k(1)").a(new A.e3()),r),r.h("F.E"))
return B.a.ab(B.a.a2(q,0,4),"")+"-"+B.a.ab(B.a.a2(q,4,6),"")+"-"+B.a.ab(B.a.a2(q,6,8),"")+"-"+B.a.ab(B.a.a2(q,8,10),"")+"-"+B.a.ab(B.a.bz(q,10),"")},
e2:function e2(a){this.a=a},
e3:function e3(){},
il(a){var s=t.r.a(v.G.Object.keys(a))
if(s==null)s=null
else{s=t.a.b(s)?s:new A.ab(s,A.P(s).h("ab<1,k>"))
s=J.cP(s,new A.dp(),t.N)
s=A.ac(s,s.$ti.h("F.E"))}return s},
dp:function dp(){},
cY:function cY(){},
dU:function dU(){this.a=null},
dW:function dW(a,b){this.a=a
this.b=b},
dV:function dV(a){this.a=a},
bE:function bE(a,b){this.a=a
this.b=b},
cL:function cL(){},
ig(a){var s,r,q,p
try{r=A.il(a)
r=r==null?null:B.a.df(r,"secondarySignerAddresses")
s=r===!0
q={}
q.data=t.K.a(a.bcsToBytes())
q.isMultiAgent=s
return q}catch(p){throw A.f(new A.bE("Invalid method parameters: Invalid Aptos transaction. The transaction must be a valid Aptos transaction and include a method like bcsToBytes.",-32602))}},
id(a){return new A.dc(a)},
ie(a){return new A.db(a)},
f4(a){a.bcsToBytes=A.t(new A.d8(a))
a.serialize=A.d(new A.d9(a))
a.bcsToHex=A.t(new A.da(a))
a.toStringWithoutPrefix=A.t(A.ie(a))
a.toString=A.t(A.id(a))},
f5(a){return B.a.W(B.a5,new A.dd(a),new A.de())},
f6(a,b){var s={}
s.status="Approved"
s.args=a
return s},
dc:function dc(a){this.a=a},
db:function db(a){this.a=a},
d8:function d8(a){this.a=a},
d9:function d9(a){this.a=a},
da:function da(a){this.a=a},
am:function am(a,b){this.c=a
this.b=b},
dd:function dd(a){this.a=a},
de:function de(){},
cs:function cs(a,b){this.a=a
this.b=b},
i5(a){var s=v.G,r=t.m,q=r.a(new s.CustomEvent("eip6963:announceProvider",{bubbles:!0,cancelable:!1,detail:t.K.a(s.Object.freeze({info:$.hF(),provider:a}))}))
r.a(s.window).addEventListener("eip6963:requestProvider",A.d(new A.cX(q)))
r.a(s.window).dispatchEvent(q)},
as:function as(a,b,c){this.a=a
this.b=b
this.$ti=c},
cX:function cX(a){this.a=a},
R(a,b){return t.m.a(new v.G.Promise(A.v(new A.ec(a))))},
O(a,b){return A.eK(v.G.Proxy,[a,new A.dN(new A.as(null,a,b.h("as<0>"))).$0()],t.m)},
fX(a){var s=A.P(a),r=s.h("L<1,k>")
s=A.ac(new A.L(a,s.h("k(1)").a(new A.dK()),r),r.h("F.E"))
return s},
ec:function ec(a){this.a=a},
e9:function e9(a){this.a=a},
ea:function ea(a){this.a=a},
eb:function eb(a,b){this.a=a
this.b=b},
dL:function dL(a){this.a=a},
dM:function dM(a){this.a=a},
dN:function dN(a){this.a=a},
dK:function dK(){},
fx(a){return A.k3(a)},
k3(a){var s=0,r=A.a_(t.H),q,p,o
var $async$fx=A.a0(function(b,c){if(b===1)return A.X(c,r)
while(true)switch(s){case 0:p={}
o=new A.cf(new A.dU(),new A.af(new A.m($.o,t.U),t.h))
o.c9()
q=v.G
q.onChain={}
p.a=!1
t.m.a(q.window).addEventListener("WALLET_ACTIVATION",A.d(new A.eV(p,o)))
return A.Y(null,r)}})
return A.Z($async$fx,r)},
eV:function eV(a,b){this.a=a
this.b=b},
io(a){return B.a.W(B.a2,new A.dx(a),new A.dy())},
ik(a){return B.a.W(B.a4,new A.dm(a),new A.dn())},
ij(a){return B.a.W(B.O,new A.dk(a),new A.dl())},
bf(a){return A.iF(B.O,new A.dj(a),t.G)},
fP(a){return B.a.W(B.a6,new A.dC(a),new A.dD())},
fM(a){return B.a.W(B.a3,new A.dh(a),new A.di())},
fT(a,b){var s=a==null?null:a.b
return{data:b,requestId:"event",client:s}},
aS(a){return{type:"event",event:a.b,data:null,providerType:"walletStandard"}},
an:function an(a){this.b=a},
dx:function dx(a){this.a=a},
dy:function dy(){},
K:function K(a){this.b=a},
dm:function dm(a){this.a=a},
dn:function dn(){},
U:function U(a){this.b=a},
dk:function dk(a){this.a=a},
dl:function dl(){},
dj:function dj(a){this.a=a},
ao:function ao(a){this.b=a},
dC:function dC(a){this.a=a},
dD:function dD(){},
E:function E(a,b){this.c=a
this.b=b},
dh:function dh(a){this.a=a},
di:function di(){},
cu:function cu(a){this.b=a},
fi(a){var s
if(a!=null&&typeof a==="string"){s=A.h(a).length
if(s===64||s===66)throw A.f({message:"Please use static method `TronWeb.TRX.sign` for signing with own private key"})}},
df:function df(){},
dg:function dg(a){this.a=a},
cf:function cf(a,b){var _=this
_.b=_.a=$
_.c=a
_.d=b
_.e=$
_.f=null},
bi:function bi(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
dt:function dt(a,b){this.a=a
this.b=b},
dq:function dq(a,b){this.a=a
this.b=b},
dr:function dr(a){this.a=a},
ds:function ds(a){this.a=a},
G:function G(){},
ct:function ct(a,b){this.a=a
this.b=b},
b7:function b7(a,b,c){this.c=a
this.a=b
this.b=c},
cR:function cR(){},
cS:function cS(){},
cQ:function cQ(){},
b9:function b9(a,b){this.a=a
this.b=b},
bb:function bb(a,b){var _=this
_.d=_.c=null
_.a=a
_.b=b},
cV:function cV(a,b){this.a=a
this.b=b},
cW:function cW(a,b,c){this.a=a
this.b=b
this.c=c},
cT:function cT(a,b){this.a=a
this.b=b},
cU:function cU(a,b,c){this.a=a
this.b=b
this.c=c},
bd:function bd(a,b,c){var _=this
_.c=null
_.d=a
_.a=b
_.b=c},
bv:function bv(a,b){this.a=a
this.b=b},
bx:function bx(a,b){this.a=a
this.b=b},
by:function by(a,b,c){var _=this
_.c=a
_.e=_.d=null
_.a=b
_.b=c},
dR:function dR(a){this.a=a},
dS:function dS(a){this.a=a},
dT:function dT(a){this.a=a},
dP:function dP(){},
dQ:function dQ(a){this.a=a},
bz:function bz(a,b){this.a=a
this.b=b},
bA:function bA(a,b){this.a=a
this.b=b},
bB:function bB(a,b,c,d){var _=this
_.d=_.c=null
_.e=a
_.f=b
_.a=c
_.b=d},
dY:function dY(a){this.a=a},
dZ:function dZ(a){this.a=a},
e_:function e_(a){this.a=a},
a3(a){var s={}
s.on=a
s.version="1.0.0"
return s},
dz(a){var s,r,q=t.c.a(a.types)
q=t.a.b(q)?q:new A.ab(q,A.P(q).h("ab<1,k>"))
q=J.cP(q,new A.dA(),t.N)
s=q.$ti
r=s.h("L<F.E,K>")
q=A.ac(new A.L(q,s.h("K(F.E)").a(new A.dB()),r),r.h("F.E"))
return q},
fO(a){var s=t.c.a(a.accounts)
s=t.cx.b(s)?s:new A.ab(s,A.P(s).h("ab<1,e>"))
s=J.cP(s,new A.dw(),t.N)
s=A.ac(s,s.$ti.h("F.E"))
return s},
dA:function dA(){},
dB:function dB(){},
dw:function dw(){},
c_(a){throw A.D(A.ip(a),new Error())},
i3(a,b,c){var s,r,q
if(a===b)return!0
for(s=0;s<2;++s){r=a[s]
q=b[s]
if(r!==q)return!1}return!0},
fI(a){var s,r,q,p
for(s=J.b5(a),r=t.R,q=12;s.l();){p=s.gm()
q=r.b(p)?(q^A.fI(p))>>>0:(q^J.a2(p))>>>0}return q},
iF(a,b,c){var s,r,q=null
try{s=B.a.dg(a,b)
return s}catch(r){if(A.ay(r) instanceof A.aV){s=q
s=s==null?null:s.$0()
return s}else throw r}},
fN(a){var s={}
s.showBalanceChanges=A.ah(a.showBalanceChanges)
s.showEffects=A.ah(a.showEffects)
s.showEvents=A.ah(a.showEvents)
s.showInput=A.ah(a.showInput)
s.showObjectChanges=A.ah(a.showObjectChanges)
s.showRawEffects=A.ah(a.showRawEffects)
s.showRawInput=A.ah(a.showRawInput)
return s},
du(a){return A.im(a)},
im(a){var s=0,r=A.a_(t.K),q,p=2,o=[],n,m,l,k,j,i
var $async$du=A.a0(function(b,c){if(b===1){o.push(c)
s=p}while(true)switch(s){case 0:p=4
s=a.transaction!=null?7:8
break
case 7:l=t.m
s=9
return A.a7(A.hC(l.a(a.transaction.toJSON()),t.N),$async$du)
case 9:n=c
k={}
k.chain=A.h(a.chain)
k.account=A.h(l.a(a.account).address)
k.transaction=n
k.requestType=A.a6(a.requestType)
l=a.options
l=l==null?null:A.fN(l)
k.options=l
q=k
s=1
break
case 8:if(a.transactionBlock!=null){m=t.K.a(a.transactionBlock.blockData)
k={}
k.chain=A.h(a.chain)
l=t.m
k.account=A.h(l.a(a.account).address)
k.transaction=A.h(l.a(v.G.JSON).stringify(m))
k.requestType=A.a6(a.requestType)
l=a.options
l=l==null?null:A.fN(l)
k.options=l
q=k
s=1
break}p=2
s=6
break
case 4:p=3
i=o.pop()
s=6
break
case 3:s=2
break
case 6:throw A.f($.hI())
case 1:return A.Y(q,r)
case 2:return A.X(o.at(-1),r)}})
return A.Z($async$du,r)},
h1(a){var s={}
s.signTransaction=a
s.version="1.0.0"
return s},
dE(a){var s=[],r=A.ic(a,"Array")
if(r){t.c.a(a)
s=a}else s.push(a)
return A.ir(s,!0,t.K)}},B={}
var w=[A,J,B]
var $={}
A.f7.prototype={}
J.cb.prototype={
S(a,b){return a===b},
gq(a){return A.cw(a)},
i(a){return"Instance of '"+A.dJ(a)+"'"},
gu(a){return A.aI(A.fn(this))}}
J.cc.prototype={
i(a){return String(a)},
gq(a){return a?519018:218159},
gu(a){return A.aI(t.y)},
$ir:1,
$iA:1}
J.bh.prototype={
S(a,b){return null==b},
i(a){return"null"},
gq(a){return 0},
$ir:1,
$iz:1}
J.x.prototype={$ie:1}
J.ap.prototype={
gq(a){return 0},
i(a){return String(a)}}
J.cv.prototype={}
J.bC.prototype={}
J.y.prototype={
i(a){var s=a[$.b4()]
if(s==null)return this.bC(a)
return"JavaScript function for "+J.b6(s)},
$iaz:1}
J.aP.prototype={
gq(a){return 0},
i(a){return String(a)}}
J.aQ.prototype={
gq(a){return 0},
i(a){return String(a)}}
J.n.prototype={
t(a,b){A.P(a).c.a(b)
a.$flags&1&&A.cN(a,29)
a.push(b)},
ad(a,b){var s
a.$flags&1&&A.cN(a,"remove",1)
for(s=0;s<a.length;++s)if(J.f0(a[s],b)){a.splice(s,1)
return!0}return!1},
bj(a,b){var s
A.P(a).h("i<1>").a(b)
a.$flags&1&&A.cN(a,"addAll",2)
if(Array.isArray(b)){this.bG(a,b)
return}for(s=J.b5(b);s.l();)a.push(s.gm())},
bG(a,b){var s,r
t.b.a(b)
s=b.length
if(s===0)return
if(a===b)throw A.f(A.al(a))
for(r=0;r<s;++r)a.push(b[r])},
ao(a,b,c){var s=A.P(a)
return new A.L(a,s.p(c).h("1(2)").a(b),s.h("@<1>").p(c).h("L<1,2>"))},
ab(a,b){var s,r=A.fR(a.length,"",!1,t.N)
for(s=0;s<a.length;++s)this.C(r,s,A.u(a[s]))
return r.join(b)},
W(a,b,c){var s,r,q,p=A.P(a)
p.h("A(1)").a(b)
p.h("1()?").a(c)
s=a.length
for(r=0;r<s;++r){q=a[r]
if(b.$1(q))return q
if(a.length!==s)throw A.f(A.al(a))}if(c!=null)return c.$0()
throw A.f(A.ia())},
dg(a,b){b.toString
return this.W(a,b,null)},
P(a,b){if(!(b>=0&&b<a.length))return A.H(a,b)
return a[b]},
a2(a,b,c){var s=a.length
if(b>s)throw A.f(A.aD(b,0,s,"start",null))
if(c==null)c=s
else if(c<b||c>s)throw A.f(A.aD(c,b,s,"end",null))
if(b===c)return A.a([],A.P(a))
return A.a(a.slice(b,c),A.P(a))},
bz(a,b){return this.a2(a,b,null)},
df(a,b){var s
for(s=0;s<a.length;++s)if(J.f0(a[s],b))return!0
return!1},
i(a){return A.fK(a,"[","]")},
gB(a){return new J.b8(a,a.length,A.P(a).h("b8<1>"))},
gq(a){return A.cw(a)},
gn(a){return a.length},
j(a,b){if(!(b>=0&&b<a.length))throw A.f(A.eN(a,b))
return a[b]},
C(a,b,c){A.P(a).c.a(c)
a.$flags&2&&A.cN(a)
if(!(b>=0&&b<a.length))throw A.f(A.eN(a,b))
a[b]=c},
$ij:1,
$ii:1,
$il:1}
J.dv.prototype={}
J.b8.prototype={
gm(){var s=this.d
return s==null?this.$ti.c.a(s):s},
l(){var s,r=this,q=r.a,p=q.length
if(r.b!==p){q=A.aj(q)
throw A.f(q)}s=r.c
if(s>=p){r.d=null
return!1}r.d=q[s]
r.c=s+1
return!0},
$iT:1}
J.ce.prototype={
du(a,b){var s,r,q,p,o
if(b<2||b>36)throw A.f(A.aD(b,2,36,"radix",null))
s=a.toString(b)
r=s.length
q=r-1
if(!(q>=0))return A.H(s,q)
if(s.charCodeAt(q)!==41)return s
p=/^([\da-z]+)(?:\.([\da-z]+))?\(e\+(\d+)\)$/.exec(s)
if(p==null)A.a8(A.e8("Unexpected toString result: "+s))
r=p.length
if(1>=r)return A.H(p,1)
s=p[1]
if(3>=r)return A.H(p,3)
o=+p[3]
r=p[2]
if(r!=null){s+=r
o-=r.length}return s+B.l.aS("0",o)},
i(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gq(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
cH(a,b){var s
if(a>0)s=this.cG(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
cG(a,b){return b>31?0:a>>>b},
gu(a){return A.aI(t.o)},
$ip:1,
$iaM:1}
J.bg.prototype={
gu(a){return A.aI(t.S)},
$ir:1,
$ib:1}
J.cd.prototype={
gu(a){return A.aI(t.i)},
$ir:1}
J.aO.prototype={
by(a,b){var s=b.length
if(s>a.length)return!1
return b===a.substring(0,s)},
bB(a,b,c){return a.substring(b,A.iH(b,c,a.length))},
bA(a,b){return this.bB(a,b,null)},
aS(a,b){var s,r
if(0>=b)return""
if(b===1||a.length===0)return a
if(b!==b>>>0)throw A.f(B.W)
for(s=a,r="";!0;){if((b&1)===1)r=s+r
b=b>>>1
if(b===0)break
s+=s}return r},
bn(a,b,c){var s=b-a.length
if(s<=0)return a
return this.aS(c,s)+a},
i(a){return a},
gq(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
gu(a){return A.aI(t.N)},
gn(a){return a.length},
$ir:1,
$ifU:1,
$ik:1}
A.aW.prototype={
gB(a){return new A.ba(J.b5(this.gal()),A.av(this).h("ba<1,2>"))},
gn(a){return J.cO(this.gal())},
P(a,b){return A.av(this).y[1].a(J.fB(this.gal(),b))},
i(a){return J.b6(this.gal())}}
A.ba.prototype={
l(){return this.a.l()},
gm(){return this.$ti.y[1].a(this.a.gm())},
$iT:1}
A.bG.prototype={
j(a,b){return this.$ti.y[1].a(J.hU(this.a,b))},
$ij:1,
$il:1}
A.ab.prototype={
gal(){return this.a}}
A.ch.prototype={
i(a){return"LateInitializationError: "+this.a}}
A.dO.prototype={}
A.j.prototype={}
A.F.prototype={
gB(a){var s=this
return new A.aB(s,s.gn(s),A.av(s).h("aB<F.E>"))},
ao(a,b,c){var s=A.av(this)
return new A.L(this,s.p(c).h("1(F.E)").a(b),s.h("@<F.E>").p(c).h("L<1,2>"))}}
A.aB.prototype={
gm(){var s=this.d
return s==null?this.$ti.c.a(s):s},
l(){var s,r=this,q=r.a,p=J.hy(q),o=p.gn(q)
if(r.b!==o)throw A.f(A.al(q))
s=r.c
if(s>=o){r.d=null
return!1}r.d=p.P(q,s);++r.c
return!0},
$iT:1}
A.aC.prototype={
gB(a){var s=this.a
return new A.bn(s.gB(s),this.b,A.av(this).h("bn<1,2>"))},
gn(a){var s=this.a
return s.gn(s)},
P(a,b){var s=this.a
return this.b.$1(s.P(s,b))}}
A.bc.prototype={$ij:1}
A.bn.prototype={
l(){var s=this,r=s.b
if(r.l()){s.a=s.c.$1(r.gm())
return!0}s.a=null
return!1},
gm(){var s=this.a
return s==null?this.$ti.y[1].a(s):s},
$iT:1}
A.L.prototype={
gn(a){return J.cO(this.a)},
P(a,b){return this.b.$1(J.fB(this.a,b))}}
A.I.prototype={}
A.bV.prototype={}
A.e0.prototype={
N(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
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
A.bu.prototype={
i(a){return"Null check operator used on a null value"}}
A.cg.prototype={
i(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.cC.prototype={
i(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.dI.prototype={
i(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.be.prototype={}
A.bO.prototype={
i(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$ia4:1}
A.ak.prototype={
i(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.hE(r==null?"unknown":r)+"'"},
$iaz:1,
gdC(){return this},
$C:"$1",
$R:1,
$D:null}
A.c3.prototype={$C:"$0",$R:0}
A.c4.prototype={$C:"$2",$R:2}
A.cA.prototype={}
A.cy.prototype={
i(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.hE(s)+"'"}}
A.aN.prototype={
S(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.aN))return!1
return this.$_target===b.$_target&&this.a===b.a},
gq(a){return(A.eX(this.a)^A.cw(this.$_target))>>>0},
i(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.dJ(this.a)+"'")}}
A.cx.prototype={
i(a){return"RuntimeError: "+this.a}}
A.aA.prototype={
gn(a){return this.a},
gan(){return new A.bm(this,this.$ti.h("bm<1>"))},
Z(a){var s=this.dk(a)
return s},
dk(a){var s=this.d
if(s==null)return!1
return this.aO(s[a.gq(0)&1073741823],a)>=0},
j(a,b){var s,r,q,p,o=null
if(typeof b=="string"){s=this.b
if(s==null)return o
r=s[b]
q=r==null?o:r.b
return q}else if(typeof b=="number"&&(b&0x3fffffff)===b){p=this.c
if(p==null)return o
r=p[b]
q=r==null?o:r.b
return q}else return this.dl(b)},
dl(a){var s,r,q=this.d
if(q==null)return null
s=q[J.a2(a)&1073741823]
r=this.aO(s,a)
if(r<0)return null
return s[r].b},
C(a,b,c){var s,r,q,p,o,n,m=this,l=m.$ti
l.c.a(b)
l.y[1].a(c)
if(typeof b=="string"){s=m.b
m.aV(s==null?m.b=m.aG():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=m.c
m.aV(r==null?m.c=m.aG():r,b,c)}else{q=m.d
if(q==null)q=m.d=m.aG()
p=J.a2(b)&1073741823
o=q[p]
if(o==null)q[p]=[m.aH(b,c)]
else{n=m.aO(o,b)
if(n>=0)o[n].b=c
else o.push(m.aH(b,c))}}},
ad(a,b){var s=this.cw(this.b,b)
return s},
aN(a,b){var s,r,q=this
q.$ti.h("~(1,2)").a(b)
s=q.e
r=q.r
for(;s!=null;){b.$2(s.a,s.b)
if(r!==q.r)throw A.f(A.al(q))
s=s.c}},
aV(a,b,c){var s,r=this.$ti
r.c.a(b)
r.y[1].a(c)
s=a[b]
if(s==null)a[b]=this.aH(b,c)
else s.b=c},
cw(a,b){var s
if(a==null)return null
s=a[b]
if(s==null)return null
this.da(s)
delete a[b]
return s.b},
b9(){this.r=this.r+1&1073741823},
aH(a,b){var s=this,r=s.$ti,q=new A.dF(r.c.a(a),r.y[1].a(b))
if(s.e==null)s.e=s.f=q
else{r=s.f
r.toString
q.d=r
s.f=r.c=q}++s.a
s.b9()
return q},
da(a){var s=this,r=a.d,q=a.c
if(r==null)s.e=q
else r.c=q
if(q==null)s.f=r
else q.d=r;--s.a
s.b9()},
aO(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.f0(a[r].a,b))return r
return-1},
i(a){return A.fS(this)},
aG(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
$ifQ:1}
A.dF.prototype={}
A.bm.prototype={
gn(a){return this.a.a},
gB(a){var s=this.a
return new A.bl(s,s.r,s.e,this.$ti.h("bl<1>"))}}
A.bl.prototype={
gm(){return this.d},
l(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.f(A.al(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.a
r.c=s.c
return!0}},
$iT:1}
A.bj.prototype={
gn(a){return this.a.a},
gB(a){var s=this.a
return new A.bk(s,s.r,s.e,this.$ti.h("bk<1,2>"))}}
A.bk.prototype={
gm(){var s=this.d
s.toString
return s},
l(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.f(A.al(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=new A.ar(s.a,s.b,r.$ti.h("ar<1,2>"))
r.c=s.c
return!0}},
$iT:1}
A.eQ.prototype={
$1(a){return this.a(a)},
$S:24}
A.eR.prototype={
$2(a,b){return this.a(a,b)},
$S:55}
A.eS.prototype={
$1(a){return this.a(A.h(a))},
$S:43}
A.cG.prototype={}
A.bo.prototype={
gu(a){return B.a8},
bk(a,b,c){var s=new Uint8Array(a,b,c)
return s},
$ir:1,
$ibo:1,
$ic2:1}
A.bs.prototype={
gdc(a){if(((a.$flags|0)&2)!==0)return new A.cK(a.buffer)
else return a.buffer}}
A.cK.prototype={
bk(a,b,c){var s=A.iu(this.a,b,c)
s.$flags=3
return s},
$ic2:1}
A.bp.prototype={
gu(a){return B.a9},
$ir:1,
$if3:1}
A.aR.prototype={
gn(a){return a.length},
$iQ:1}
A.bq.prototype={
j(a,b){A.aG(b,a,a.length)
return a[b]},
$ij:1,
$ii:1,
$il:1}
A.br.prototype={$ij:1,$ii:1,$il:1}
A.cj.prototype={
gu(a){return B.aa},
$ir:1,
$id_:1}
A.ck.prototype={
gu(a){return B.ab},
$ir:1,
$id0:1}
A.cl.prototype={
gu(a){return B.ac},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$ir:1,
$id5:1}
A.cm.prototype={
gu(a){return B.ad},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$ir:1,
$id6:1}
A.cn.prototype={
gu(a){return B.ae},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$ir:1,
$id7:1}
A.co.prototype={
gu(a){return B.ag},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$ir:1,
$ie4:1}
A.cp.prototype={
gu(a){return B.ah},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$ir:1,
$ie5:1}
A.bt.prototype={
gu(a){return B.ai},
gn(a){return a.length},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$ir:1,
$ie6:1}
A.cq.prototype={
gu(a){return B.aj},
gn(a){return a.length},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$ir:1,
$ie7:1}
A.bK.prototype={}
A.bL.prototype={}
A.bM.prototype={}
A.bN.prototype={}
A.V.prototype={
h(a){return A.bT(v.typeUniverse,this,a)},
p(a){return A.hf(v.typeUniverse,this,a)}}
A.cF.prototype={}
A.eC.prototype={
i(a){return A.M(this.a,null)}}
A.cE.prototype={
i(a){return this.a}}
A.aZ.prototype={$iad:1}
A.ee.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:15}
A.ed.prototype={
$1(a){var s,r
this.a.a=t.M.a(a)
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:29}
A.ef.prototype={
$0(){this.a.$0()},
$S:26}
A.eg.prototype={
$0(){this.a.$0()},
$S:26}
A.eA.prototype={
bF(a,b){if(self.setTimeout!=null)this.b=self.setTimeout(A.bY(new A.eB(this,b),0),a)
else throw A.f(A.e8("`setTimeout()` not found."))},
bm(){if(self.setTimeout!=null){var s=this.b
if(s==null)return
self.clearTimeout(s)
this.b=null}else throw A.f(A.e8("Canceling a timer."))}}
A.eB.prototype={
$0(){this.a.b=null
this.b.$0()},
$S:2}
A.bF.prototype={
V(a){var s,r=this,q=r.$ti
q.h("1/?").a(a)
if(a==null)a=q.c.a(a)
if(!r.b)r.a.az(a)
else{s=r.a
if(q.h("J<1>").b(a))s.aX(a)
else s.aB(a)}},
aM(a,b){var s=this.a
if(this.b)s.O(new A.N(a,b))
else s.aA(new A.N(a,b))},
$ic5:1}
A.eF.prototype={
$1(a){return this.a.$2(0,a)},
$S:18}
A.eG.prototype={
$2(a,b){this.a.$2(1,new A.be(a,t.l.a(b)))},
$S:46}
A.eJ.prototype={
$2(a,b){this.a(A.W(a),b)},
$S:49}
A.N.prototype={
i(a){return A.u(this.a)},
$iw:1,
ga1(){return this.b}}
A.d4.prototype={
$0(){this.c.a(null)
this.b.aY(null)},
$S:2}
A.dX.prototype={
i(a){var s=A.u(this.b)
return"TimeoutException after "+s+": "+this.a}}
A.aX.prototype={
aM(a,b){if((this.a.a&30)!==0)throw A.f(A.fb("Future already completed"))
this.O(A.jp(a,b))},
aL(a){return this.aM(a,null)},
$ic5:1}
A.af.prototype={
V(a){var s,r=this.$ti
r.h("1/?").a(a)
s=this.a
if((s.a&30)!==0)throw A.f(A.fb("Future already completed"))
s.az(r.h("1/").a(a))},
aK(){return this.V(null)},
O(a){this.a.aA(a)}}
A.bP.prototype={
V(a){var s,r=this.$ti
r.h("1/?").a(a)
s=this.a
if((s.a&30)!==0)throw A.f(A.fb("Future already completed"))
s.aY(r.h("1/").a(a))},
aK(){return this.V(null)},
O(a){this.a.O(a)}}
A.ag.prototype={
dm(a){if((this.c&15)!==6)return!0
return this.b.b.aR(t.bG.a(this.d),a.a,t.y,t.K)},
dh(a){var s,r=this,q=r.e,p=null,o=t.z,n=t.K,m=a.a,l=r.b.b
if(t.Q.b(q))p=l.dr(q,m,a.b,o,n,t.l)
else p=l.aR(t.v.a(q),m,o,n)
try{o=r.$ti.h("2/").a(p)
return o}catch(s){if(t.b7.b(A.ay(s))){if((r.c&1)!==0)throw A.f(A.aa("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.f(A.aa("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.m.prototype={
a_(a,b,c){var s,r,q,p=this.$ti
p.p(c).h("1/(2)").a(a)
s=$.o
if(s===B.e){if(b!=null&&!t.Q.b(b)&&!t.v.b(b))throw A.f(A.f1(b,"onError",u.c))}else{c.h("@<0/>").p(p.c).h("1(2)").a(a)
if(b!=null)b=A.hr(b,s)}r=new A.m(s,c.h("m<0>"))
q=b==null?1:3
this.af(new A.ag(r,q,a,b,p.h("@<1>").p(c).h("ag<1,2>")))
return r},
ae(a,b){a.toString
return this.a_(a,null,b)},
bh(a,b,c){var s,r=this.$ti
r.p(c).h("1/(2)").a(a)
s=new A.m($.o,c.h("m<0>"))
this.af(new A.ag(s,19,a,b,r.h("@<1>").p(c).h("ag<1,2>")))
return s},
cF(a){this.a=this.a&1|16
this.c=a},
ag(a){this.a=a.a&30|this.a&1
this.c=a.c},
af(a){var s,r=this,q=r.a
if(q<=3){a.a=t.F.a(r.c)
r.c=a}else{if((q&4)!==0){s=t._.a(r.c)
if((s.a&24)===0){s.af(a)
return}r.ag(s)}A.cM(null,null,r.b,t.M.a(new A.ej(r,a)))}},
bc(a){var s,r,q,p,o,n,m=this,l={}
l.a=a
if(a==null)return
s=m.a
if(s<=3){r=t.F.a(m.c)
m.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){n=t._.a(m.c)
if((n.a&24)===0){n.bc(a)
return}m.ag(n)}l.a=m.ak(a)
A.cM(null,null,m.b,t.M.a(new A.eo(l,m)))}},
a8(){var s=t.F.a(this.c)
this.c=null
return this.ak(s)},
ak(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
aY(a){var s,r=this,q=r.$ti
q.h("1/").a(a)
if(q.h("J<1>").b(a))A.em(a,r,!0)
else{s=r.a8()
q.c.a(a)
r.a=8
r.c=a
A.aE(r,s)}},
aB(a){var s,r=this
r.$ti.c.a(a)
s=r.a8()
r.a=8
r.c=a
A.aE(r,s)},
bU(a){var s,r,q=this
if((a.a&16)!==0){s=q.b===a.b
s=!(s||s)}else s=!1
if(s)return
r=q.a8()
q.ag(a)
A.aE(q,r)},
O(a){var s=this.a8()
this.cF(a)
A.aE(this,s)},
az(a){var s=this.$ti
s.h("1/").a(a)
if(s.h("J<1>").b(a)){this.aX(a)
return}this.bL(a)},
bL(a){var s=this
s.$ti.c.a(a)
s.a^=2
A.cM(null,null,s.b,t.M.a(new A.el(s,a)))},
aX(a){A.em(this.$ti.h("J<1>").a(a),this,!1)
return},
aA(a){this.a^=2
A.cM(null,null,this.b,t.M.a(new A.ek(this,a)))},
dt(a){var s,r=this,q={}
if((r.a&24)!==0){q=new A.m($.o,r.$ti)
q.az(r)
return q}s=new A.m($.o,r.$ti)
q.a=null
q.a=A.h0(a,new A.eu(s,a))
r.a_(new A.ev(q,r,s),new A.ew(q,s),t.P)
return s},
$iJ:1}
A.ej.prototype={
$0(){A.aE(this.a,this.b)},
$S:2}
A.eo.prototype={
$0(){A.aE(this.b,this.a.a)},
$S:2}
A.en.prototype={
$0(){A.em(this.a.a,this.b,!0)},
$S:2}
A.el.prototype={
$0(){this.a.aB(this.b)},
$S:2}
A.ek.prototype={
$0(){this.a.O(this.b)},
$S:2}
A.er.prototype={
$0(){var s,r,q,p,o,n,m,l,k=this,j=null
try{q=k.a.a
j=q.b.b.dq(t.bd.a(q.d),t.z)}catch(p){s=A.ay(p)
r=A.aw(p)
if(k.c&&t.n.a(k.b.a.c).a===s){q=k.a
q.c=t.n.a(k.b.a.c)}else{q=s
o=r
if(o==null)o=A.f2(q)
n=k.a
n.c=new A.N(q,o)
q=n}q.b=!0
return}if(j instanceof A.m&&(j.a&24)!==0){if((j.a&16)!==0){q=k.a
q.c=t.n.a(j.c)
q.b=!0}return}if(j instanceof A.m){m=k.b.a
l=new A.m(m.b,m.$ti)
j.a_(new A.es(l,m),new A.et(l),t.H)
q=k.a
q.c=l
q.b=!1}},
$S:2}
A.es.prototype={
$1(a){this.a.bU(this.b)},
$S:15}
A.et.prototype={
$2(a,b){t.K.a(a)
t.l.a(b)
this.a.O(new A.N(a,b))},
$S:10}
A.eq.prototype={
$0(){var s,r,q,p,o,n,m,l
try{q=this.a
p=q.a
o=p.$ti
n=o.c
m=n.a(this.b)
q.c=p.b.b.aR(o.h("2/(1)").a(p.d),m,o.h("2/"),n)}catch(l){s=A.ay(l)
r=A.aw(l)
q=s
p=r
if(p==null)p=A.f2(q)
o=this.a
o.c=new A.N(q,p)
o.b=!0}},
$S:2}
A.ep.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=t.n.a(l.a.a.c)
p=l.b
if(p.a.dm(s)&&p.a.e!=null){p.c=p.a.dh(s)
p.b=!1}}catch(o){r=A.ay(o)
q=A.aw(o)
p=t.n.a(l.a.a.c)
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.f2(p)
m=l.b
m.c=new A.N(p,n)
p=m}p.b=!0}},
$S:2}
A.eu.prototype={
$0(){var s=A.fZ()
this.a.O(new A.N(new A.dX("Future not completed",this.b),s))},
$S:2}
A.ev.prototype={
$1(a){var s
this.b.$ti.c.a(a)
s=this.a.a
if(s.b!=null){s.bm()
this.c.aB(a)}},
$S(){return this.b.$ti.h("z(1)")}}
A.ew.prototype={
$2(a,b){var s
t.K.a(a)
t.l.a(b)
s=this.a.a
if(s.b!=null){s.bm()
this.b.O(new A.N(a,b))}},
$S:10}
A.cD.prototype={}
A.cI.prototype={}
A.bU.prototype={$ih3:1}
A.eI.prototype={
$0(){A.i7(this.a,this.b)},
$S:2}
A.cH.prototype={
ds(a){var s,r,q
t.M.a(a)
try{if(B.e===$.o){a.$0()
return}A.hs(null,null,this,a,t.H)}catch(q){s=A.ay(q)
r=A.aw(q)
A.fp(t.K.a(s),t.l.a(r))}},
bl(a){return new A.ez(this,t.M.a(a))},
dq(a,b){b.h("0()").a(a)
if($.o===B.e)return a.$0()
return A.hs(null,null,this,a,b)},
aR(a,b,c,d){c.h("@<0>").p(d).h("1(2)").a(a)
d.a(b)
if($.o===B.e)return a.$1(b)
return A.jE(null,null,this,a,b,c,d)},
dr(a,b,c,d,e,f){d.h("@<0>").p(e).p(f).h("1(2,3)").a(a)
e.a(b)
f.a(c)
if($.o===B.e)return a.$2(b,c)
return A.jD(null,null,this,a,b,c,d,e,f)},
bp(a,b,c,d){return b.h("@<0>").p(c).p(d).h("1(2,3)").a(a)}}
A.ez.prototype={
$0(){return this.a.ds(this.b)},
$S:2}
A.bH.prototype={
gn(a){return this.a},
gan(){return new A.bI(this,this.$ti.h("bI<1>"))},
Z(a){var s,r
if(typeof a=="string"&&a!=="__proto__"){s=this.b
return s==null?!1:s[a]!=null}else if(typeof a=="number"&&(a&1073741823)===a){r=this.c
return r==null?!1:r[a]!=null}else return this.bZ(a)},
bZ(a){var s=this.d
if(s==null)return!1
return this.aF(this.b0(s,a),a)>=0},
j(a,b){var s,r,q
if(typeof b=="string"&&b!=="__proto__"){s=this.b
r=s==null?null:A.h5(s,b)
return r}else if(typeof b=="number"&&(b&1073741823)===b){q=this.c
r=q==null?null:A.h5(q,b)
return r}else return this.c6(b)},
c6(a){var s,r,q=this.d
if(q==null)return null
s=this.b0(q,a)
r=this.aF(s,a)
return r<0?null:s[r+1]},
C(a,b,c){var s,r,q,p,o,n,m=this,l=m.$ti
l.c.a(b)
l.y[1].a(c)
if(typeof b=="string"&&b!=="__proto__"){s=m.b
m.aW(s==null?m.b=A.fg():s,b,c)}else if(typeof b=="number"&&(b&1073741823)===b){r=m.c
m.aW(r==null?m.c=A.fg():r,b,c)}else{q=m.d
if(q==null)q=m.d=A.fg()
p=A.eX(b)&1073741823
o=q[p]
if(o==null){A.fh(q,p,[b,c]);++m.a
m.e=null}else{n=m.aF(o,b)
if(n>=0)o[n+1]=c
else{o.push(b,c);++m.a
m.e=null}}}},
aN(a,b){var s,r,q,p,o,n,m=this,l=m.$ti
l.h("~(1,2)").a(b)
s=m.aZ()
for(r=s.length,q=l.c,l=l.y[1],p=0;p<r;++p){o=s[p]
q.a(o)
n=m.j(0,o)
b.$2(o,n==null?l.a(n):n)
if(s!==m.e)throw A.f(A.al(m))}},
aZ(){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.e
if(h!=null)return h
h=A.fR(i.a,null,!1,t.z)
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
aW(a,b,c){var s=this.$ti
s.c.a(b)
s.y[1].a(c)
if(a[b]==null){++this.a
this.e=null}A.fh(a,b,c)},
b0(a,b){return a[A.eX(b)&1073741823]}}
A.aY.prototype={
aF(a,b){var s,r,q
if(a==null)return-1
s=a.length
for(r=0;r<s;r+=2){q=a[r]
if(q==null?b==null:q===b)return r}return-1}}
A.bI.prototype={
gn(a){return this.a.a},
gB(a){var s=this.a
return new A.bJ(s,s.aZ(),this.$ti.h("bJ<1>"))}}
A.bJ.prototype={
gm(){var s=this.d
return s==null?this.$ti.c.a(s):s},
l(){var s=this,r=s.b,q=s.c,p=s.a
if(r!==p.e)throw A.f(A.al(p))
else if(q>=r.length){s.d=null
return!1}else{s.d=r[q]
s.c=q+1
return!0}},
$iT:1}
A.q.prototype={
gB(a){return new A.aB(a,this.gn(a),A.b2(a).h("aB<q.E>"))},
P(a,b){return this.j(a,b)},
ao(a,b,c){var s=A.b2(a)
return new A.L(a,s.p(c).h("1(q.E)").a(b),s.h("@<q.E>").p(c).h("L<1,2>"))},
i(a){return A.fK(a,"[","]")}}
A.aq.prototype={
aN(a,b){var s,r,q,p=A.av(this)
p.h("~(1,2)").a(b)
for(s=this.gan(),s=s.gB(s),p=p.y[1];s.l();){r=s.gm()
q=this.j(0,r)
b.$2(r,q==null?p.a(q):q)}},
gn(a){var s=this.gan()
return s.gn(s)},
i(a){return A.fS(this)},
$ici:1}
A.dG.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.u(a)
r.a=(r.a+=s)+": "
s=A.u(b)
r.a+=s},
$S:45}
A.c7.prototype={
S(a,b){var s
if(b==null)return!1
s=!1
if(b instanceof A.c7)if(this.a===b.a)s=this.b===b.b
return s},
gq(a){return A.iv(this.a,this.b,B.n,B.n)},
i(a){var s=this,r=A.i4(A.iD(s)),q=A.c8(A.iB(s)),p=A.c8(A.ix(s)),o=A.c8(A.iy(s)),n=A.c8(A.iA(s)),m=A.c8(A.iC(s)),l=A.fH(A.iz(s)),k=s.b,j=k===0?"":A.fH(k)
return r+"-"+q+"-"+p+" "+o+":"+n+":"+m+"."+l+j+"Z"}}
A.c9.prototype={
S(a,b){if(b==null)return!1
return b instanceof A.c9},
gq(a){return B.f.gq(0)},
i(a){return"0:00:00."+B.l.bn(B.f.i(0),6,"0")}}
A.eh.prototype={
i(a){return this.T()}}
A.w.prototype={
ga1(){return A.iw(this)}}
A.c0.prototype={
i(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.cZ(s)
return"Assertion failed"}}
A.ad.prototype={}
A.a9.prototype={
gaE(){return"Invalid argument"+(!this.a?"(s)":"")},
gaD(){return""},
i(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+p,n=s.gaE()+q+o
if(!s.a)return n
return n+s.gaD()+": "+A.cZ(s.gaP())},
gaP(){return this.b}}
A.aU.prototype={
gaP(){return A.hj(this.b)},
gaE(){return"RangeError"},
gaD(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.u(q):""
else if(q==null)s=": Not greater than or equal to "+A.u(r)
else if(q>r)s=": Not in inclusive range "+A.u(r)+".."+A.u(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.u(r)
return s}}
A.ca.prototype={
gaP(){return A.W(this.b)},
gaE(){return"RangeError"},
gaD(){if(A.W(this.b)<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gn(a){return this.f}}
A.bD.prototype={
i(a){return"Unsupported operation: "+this.a}}
A.cB.prototype={
i(a){var s=this.a
return s!=null?"UnimplementedError: "+s:"UnimplementedError"}}
A.aV.prototype={
i(a){return"Bad state: "+this.a}}
A.c6.prototype={
i(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.cZ(s)+"."}}
A.cr.prototype={
i(a){return"Out of Memory"},
ga1(){return null},
$iw:1}
A.bw.prototype={
i(a){return"Stack Overflow"},
ga1(){return null},
$iw:1}
A.ei.prototype={
i(a){return"Exception: "+this.a}}
A.i.prototype={
ao(a,b,c){var s=A.av(this)
return A.it(this,s.p(c).h("1(i.E)").a(b),s.h("i.E"),c)},
gn(a){var s,r=this.gB(this)
for(s=0;r.l();)++s
return s},
P(a,b){var s,r
A.iG(b,"index")
s=this.gB(this)
for(r=b;s.l();){if(r===0)return s.gm();--r}throw A.f(A.fJ(b,b-r,this,"index"))},
i(a){return A.ib(this,"(",")")}}
A.ar.prototype={
i(a){return"MapEntry("+A.u(this.a)+": "+A.u(this.b)+")"}}
A.z.prototype={
gq(a){return A.c.prototype.gq.call(this,0)},
i(a){return"null"}}
A.c.prototype={$ic:1,
S(a,b){return this===b},
gq(a){return A.cw(this)},
i(a){return"Instance of '"+A.dJ(this)+"'"},
gu(a){return A.ft(this)},
toString(){return this.i(this)}}
A.cJ.prototype={
i(a){return""},
$ia4:1}
A.cz.prototype={
gn(a){return this.a.length},
i(a){var s=this.a
return s.charCodeAt(0)==0?s:s}}
A.d3.prototype={
$2(a,b){var s=t.g
this.a.a_(new A.d1(s.a(a)),new A.d2(s.a(b)),t.X)},
$S:23}
A.d1.prototype={
$1(a){var s=this.a
return s.call(s)},
$S:40}
A.d2.prototype={
$2(a,b){var s,r,q,p
t.K.a(a)
t.l.a(b)
s=t.g.a(v.G.Error)
r=["Dart exception thrown from converted Future. Use the properties 'error' to fetch the boxed error and 'stack' to recover the stack trace."]
r=A.eK(s,r,t.m)
if(t.e.b(a))A.a8("Attempting to box non-Dart object.")
q={}
q[$.hT()]=a
r.error=q
r.stack=b.i(0)
p=this.a
p.call(p,r)},
$S:10}
A.eU.prototype={
$1(a){var s,r,q,p
if(A.hq(a))return a
s=this.a
if(s.Z(a))return s.j(0,a)
if(a instanceof A.aq){r={}
s.C(0,a,r)
for(s=a.gan(),s=s.gB(s);s.l();){q=s.gm()
r[q]=this.$1(a.j(0,q))}return r}else if(t.R.b(a)){p=[]
s.C(0,a,p)
B.a.bj(p,J.cP(a,this,t.z))
return p}else return a},
$S:11}
A.eY.prototype={
$1(a){return this.a.V(this.b.h("0/?").a(a))},
$S:18}
A.eZ.prototype={
$1(a){if(a==null)return this.a.aL(new A.dH(a===undefined))
return this.a.aL(a)},
$S:18}
A.eM.prototype={
$1(a){var s,r,q,p,o,n,m,l,k,j,i,h
if(A.hp(a))return a
s=this.a
a.toString
if(s.Z(a))return s.j(0,a)
if(a instanceof Date){r=a.getTime()
if(r<-864e13||r>864e13)A.a8(A.aD(r,-864e13,864e13,"millisecondsSinceEpoch",null))
A.eL(!0,"isUtc",t.y)
return new A.c7(r,0,!0)}if(a instanceof RegExp)throw A.f(A.aa("structured clone of RegExp",null))
if(typeof Promise!="undefined"&&a instanceof Promise)return A.hC(a,t.X)
q=Object.getPrototypeOf(a)
if(q===Object.prototype||q===null){p=t.X
o=A.f9(p,p)
s.C(0,a,o)
n=Object.keys(a)
m=[]
for(s=J.bZ(n),p=s.gB(n);p.l();)m.push(A.fs(p.gm()))
for(l=0;l<s.gn(n);++l){k=s.j(n,l)
if(!(l<m.length))return A.H(m,l)
j=m[l]
if(k!=null)o.C(0,j,this.$1(a[k]))}return o}if(a instanceof Array){i=a
o=[]
s.C(0,a,o)
h=A.W(a.length)
for(s=J.bZ(i),l=0;l<h;++l)o.push(this.$1(s.j(i,l)))
return o}return a},
$S:11}
A.dH.prototype={
i(a){return"Promise was rejected with a value of `"+(this.a?"undefined":"null")+"`."}}
A.ex.prototype={
bE(){var s=self.crypto
if(s!=null)if(s.getRandomValues!=null)return
throw A.f(A.e8("No source of cryptographically secure random numbers available."))},
aQ(a){var s,r,q,p,o,n,m,l,k=null
if(a<=0||a>4294967296)throw A.f(new A.aU(k,k,!1,k,k,"max must be in range 0 < max \u2264 2^32, was "+a))
if(a>255)if(a>65535)s=a>16777215?4:3
else s=2
else s=1
r=this.a
r.$flags&2&&A.cN(r,11)
r.setUint32(0,0,!1)
q=4-s
p=A.W(Math.pow(256,s))
for(o=a-1,n=(a&o)===0;!0;){crypto.getRandomValues(J.hV(B.a7.gdc(r),q,s))
m=r.getUint32(0,!1)
if(n)return(m&o)>>>0
l=m%a
if(m-l+a<p)return l}}}
A.e2.prototype={
$1(a){var s
if(a===6)return this.a.aQ(16)&15|64
else{s=this.a
if(a===8)return s.aQ(4)&3|8
else return s.aQ(256)}},
$S:31}
A.e3.prototype={
$1(a){return B.l.bn(B.f.du(A.W(a),16),2,"0")},
$S:37}
A.dp.prototype={
$1(a){return A.h(a)},
$S:12}
A.cY.prototype={
S(a,b){var s=this
if(b==null)return!1
if(s===b)return!0
if(!(b instanceof A.bE))return!1
if(A.ft(b)!==A.ft(s))return!1
return A.i3([s.b,s.a],[b.b,b.a],t.z)},
gq(a){return A.fI([this.b,this.a])}}
A.dU.prototype={
X(a,b){var s=null
return this.bD(b.h("0/()").a(a),b,b)},
bD(a,b,c){var s=0,r=A.a_(c),q,p=2,o=[],n=[],m=this,l,k,j,i,h,g
var $async$X=A.a0(function(d,e){if(d===1){o.push(e)
s=p}while(true)switch(s){case 0:i=null
h=m.a
g=new A.bP(new A.m($.o,t.U),t.b5)
m.a=g.a
p=3
s=h!=null?6:7
break
case 6:s=i!=null?8:10
break
case 8:s=11
return A.a7(h.dt(i),$async$X)
case 11:s=9
break
case 10:s=12
return A.a7(h,$async$X)
case 12:case 9:case 7:l=a.$0()
s=l instanceof A.m?13:15
break
case 13:j=l
s=16
return A.a7(b.h("J<0>").b(j)?j:A.ff(b.a(j),b),$async$X)
case 16:j=e
q=j
n=[1]
s=4
break
s=14
break
case 15:q=l
n=[1]
s=4
break
case 14:n.push(5)
s=4
break
case 3:n=[2]
case 4:p=2
k=new A.dW(m,g)
if(h!=null&&i!=null)h.ae(new A.dV(k),t.P)
else k.$0()
s=n.pop()
break
case 5:case 1:return A.Y(q,r)
case 2:return A.X(o.at(-1),r)}})
return A.Z($async$X,r)}}
A.dW.prototype={
$0(){var s=this.a,r=this.b
if(s.a===r.a)s.a=null
r.aK()},
$S:2}
A.dV.prototype={
$1(a){this.a.$0()},
$S:15}
A.bE.prototype={
i(a){return this.a}}
A.cL.prototype={}
A.dc.prototype={
$0(){return A.h(this.a.dataHex)},
$S:13}
A.db.prototype={
$0(){return B.l.bA(A.h(this.a.dataHex),2)},
$S:13}
A.d8.prototype={
$0(){return t.K.a(this.a.data)},
$S:6}
A.d9.prototype={
$1(a){var s=t.K
s.a(a).serializeFixedBytes(s.a(this.a.data))},
$S:14}
A.da.prototype={
$0(){return A.h(this.a.dataHex)},
$S:13}
A.am.prototype={
T(){return"JSAptosWalletStandardUserResponseStatus."+this.b}}
A.dd.prototype={
$1(a){return t.w.a(a).c===this.a},
$S:38}
A.de.prototype={
$0(){return A.a8(B.j)},
$S:4}
A.cs.prototype={}
A.as.prototype={
bv(a,b,c,d){var s,r,q
t.K.a(a)
try{r=v.G
s=r.Reflect.get(a,b,d)
if(typeof s==="undefined"){r=A.hi(r.Reflect.set(a,b,c,d))
return r}return!1}catch(q){return!1}},
bu(a,b,c){var s,r,q
t.K.a(a)
s=b==null
r=!s||null
if(r===!0)if(!s&&typeof b==="string")if(B.l.by(A.h(A.fs(b)),"is")){q=v.G.Reflect.get(a,b,c)
if(q!=null)return q
return!0}return v.G.Reflect.get(a,b,c)}}
A.cX.prototype={
$1(a){var s,r=t.m
r.a(a)
s=v.G
r.a(s.window).dispatchEvent(this.a)
r.a(s.window).removeEventListener("eip6963:requestProvider",A.d(this))},
$S:7}
A.ec.prototype={
$2(a,b){var s,r,q,p=t.g
p.a(a)
p.a(b)
p=this.a.a_(new A.e9(a),new A.ea(b),t.X)
s=new A.eb(b,a)
r=p.$ti
q=$.o
if(q!==B.e)s=A.hr(s,q)
p.af(new A.ag(new A.m(q,r),2,null,s,r.h("ag<1,1>")))},
$S:23}
A.e9.prototype={
$1(a){var s=this.a
s.call(s,a)
return a},
$S:11}
A.ea.prototype={
$2(a,b){var s
t.K.a(a)
a.stack=t.l.a(b).i(0)
s=this.a
s.call(s,a)
return a},
$S:44}
A.eb.prototype={
$1(a){this.a.call(this.b,a)
return a},
$S:24}
A.dL.prototype={
$0(){return this.a.a},
$S:16}
A.dM.prototype={
$0(){return this.a.b},
$S:8}
A.dN.prototype={
$0(){var s,r,q=this.a,p=v.G,o=t.m,n=o.a(p.Object),m=o.a(n.create.apply(n,[null]))
m.set=A.fm(q.gar())
m.get=A.fl(q.gaq())
n=o.a(p.Object)
s=o.a(n.create.apply(n,[null]))
s.get=A.t(new A.dL(q))
n=o.a(p.Object)
n.defineProperty.apply(n,[m,"debugKey",s])
n=o.a(p.Object)
r=o.a(n.create.apply(n,[null]))
r.get=A.t(new A.dM(q))
p=o.a(p.Object)
p.defineProperty.apply(p,[m,"object",r])
return m},
$S:6}
A.dK.prototype={
$1(a){return A.h(a)},
$S:12}
A.eV.prototype={
$1(a){var s,r,q=this,p=t.m
p.a(a)
s=q.a
if(s.a)return
r=p.a(p.a(a.detail).data)
if(A.fP(A.h(r.status))===B.G){s=r.data
if(s==null)s=t.K.a(s)
if(A.a6(s.message)!=null)p.a(v.G.console).error(A.a6(s.message))
p=q.b.d
if(p!=null)p.aL(s)
return}s.a=!0
p.a(v.G.window).addEventListener("WALLET_ACTIVATION",A.d(q))
p=r.data
q.b.dj(A.h(p==null?null:A.fs(p)))},
$S:7}
A.an.prototype={
T(){return"JSWalletMessageType."+this.b}}
A.dx.prototype={
$1(a){return t.cP.a(a).b===this.a},
$S:53}
A.dy.prototype={
$0(){return A.a8(B.j)},
$S:4}
A.K.prototype={
T(){return"JSNetworkEventType."+this.b}}
A.dm.prototype={
$1(a){return t.cA.a(a).b===this.a},
$S:30}
A.dn.prototype={
$0(){return A.a8(B.j)},
$S:4}
A.U.prototype={
T(){return"JSEventType."+this.b}}
A.dk.prototype={
$1(a){return t.G.a(a).b===this.a},
$S:25}
A.dl.prototype={
$0(){return A.a8(B.j)},
$S:4}
A.dj.prototype={
$1(a){return t.G.a(a).b===this.a},
$S:25}
A.ao.prototype={
T(){return"JSWalletResponseType."+this.b}}
A.dC.prototype={
$1(a){return t.c9.a(a).b===this.a},
$S:32}
A.dD.prototype={
$0(){return A.a8(B.j)},
$S:4}
A.E.prototype={
T(){return"JSClientType."+this.b}}
A.dh.prototype={
$1(a){return t.D.a(a).b===this.a},
$S:33}
A.di.prototype={
$0(){return A.a8(B.j)},
$S:4}
A.cu.prototype={
T(){return"PageRequestType."+this.b}}
A.df.prototype={
gH(){var s=this.a
if(s===$){s!==$&&A.c_("requestController")
s=this.a=new A.ct(this.gbo(),A.f9(t.N,t.p))}return s},
gbi(){var s,r,q=this,p=q.b
if(p===$){s=q.gH()
r=A.a([],t.I)
q.b!==$&&A.c_("_walletStandardController")
p=q.b=new A.bi(s,{},{},r)}return p},
am(){var s=0,r=A.a_(t.H),q,p=this,o
var $async$am=A.a0(function(a,b){if(a===1)return A.X(b,r)
while(true)switch(s){case 0:o=p.c
o=o==null?null:o.X(new A.dg(p),t.H)
s=3
return A.a7(o instanceof A.m?o:A.ff(o,t.H),$async$am)
case 3:q=b
s=1
break
case 1:return A.Y(q,r)}})
return A.Z($async$am,r)},
gbb(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=this,a3=a2.e
if(a3===$){s=a2.gH()
r=t.I
q=t.G
p=t.u
o=A.B([B.b,A.a([],r),B.c,A.a([],r),B.i,A.a([],r),B.q,A.a([],r),B.k,A.a([],r)],q,p)
n=A.B([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
m=a2.gH()
l={base58:!1,hex:!1}
k=A.B([B.b,A.a([],r),B.c,A.a([],r),B.i,A.a([],r),B.k,A.a([],r)],q,p)
j=A.B([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
i=a2.gH()
h=A.B([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
g=a2.gH()
f=A.B([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
e=a2.gH()
d=A.B([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
c=a2.gH()
b=A.B([B.b,A.a([],r)],q,p)
a=A.B([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
a0=a2.gH()
a1=A.B([B.x,new A.bd(o,s,n),B.D,new A.bB(l,k,m,j),B.y,new A.bv(i,h),B.C,new A.bA(g,f),B.z,new A.bx(e,d),B.A,new A.by(b,c,a),B.u,new A.b7(A.B([B.b,A.a([],r),B.c,A.a([],r)],q,p),a0,A.B([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)),B.B,new A.bz(a2.gH(),A.B([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)),B.w,new A.bb(a2.gH(),A.B([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)),B.v,new A.b9(a2.gH(),A.B([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p))],t.D,t.d5)
a2.e!==$&&A.c_("_networks")
a2.e=a1
a3=a1}return a3},
c9(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b="Initializing wallet failed: "
try{for(m=c.gbb(),m=new A.bj(m,m.$ti.h("bj<1,2>")).gB(0),l=t.m,k=v.G,j=t.I,i=c.gbo(),h=t.N,g=t.p;m.l();){f=m.d
f.toString
s=f
try{r=s.b
e=c.b
if(e===$){e=c.a
if(e===$){e!==$&&A.c_("requestController")
e=c.a=new A.ct(i,A.f9(h,g))}f=A.a([],j)
c.b!==$&&A.c_("_walletStandardController")
e=c.b=new A.bi(e,{},{},f)}r.M(e.c)}catch(d){q=A.ay(d)
p=A.aw(d)
l.a(k.console).error(b+s.a.c+" "+A.u(q)+" "+A.u(p))}}c.gbi().a7()}catch(d){o=A.ay(d)
n=A.aw(d)
t.m.a(v.G.console).error(b+A.u(o)+" "+A.u(n))}},
di(a){var s,r,q,p,o,n=t.m
if(A.io(A.h(n.a(a.data).type))===B.M){s=this.gH().b.j(0,A.h(a.requestId))
if(s!=null){n=n.a(a.data)
s.b.V(n)}return}r=n.a(a.data)
if((A.a6(a.client)==null?null:A.fM(A.a6(a.client)))==null){s=this.gbi()
r=n.a(r.data)
q=t.r
if(q.a(r.accounts)!=null){p=q.a(r.accounts)
p.toString
s.b.accounts=p}if(q.a(r.chains)!=null){p=q.a(r.chains)
p.toString
s.b.chains=p}o={}
o.change=A.O(r,n)
o.accounts=q.a(r.accounts)
o.chains=q.a(r.chains)
s.c2(A.O(o,n))
return}n=this.gbb()
n=n.j(0,A.a6(a.client)==null?null:A.fM(A.a6(a.client)))
if(n!=null)n.ac(r)}}
A.dg.prototype={
$0(){var s=0,r=A.a_(t.H),q,p=2,o=[],n=[],m=this,l
var $async$$0=A.a0(function(a,b){if(a===1){o.push(b)
s=p}while(true)switch(s){case 0:p=3
l=m.a.d
l=l==null?null:l.a
s=6
return A.a7(l instanceof A.m?l:A.ff(l,t.H),$async$$0)
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
case 5:case 1:return A.Y(q,r)
case 2:return A.X(o.at(-1),r)}})
return A.Z($async$$0,r)},
$S:34}
A.cf.prototype={
ap(a){return this.dn(a)},
dn(a){var s=0,r=A.a_(t.H),q=this,p,o,n
var $async$ap=A.a0(function(b,c){if(b===1)return A.X(c,r)
while(true)switch(s){case 0:s=2
return A.a7(q.am(),$async$ap)
case 2:p=q.f
o=v.G
n=t.m
p=n.a(new o.CustomEvent(p,{bubbles:!0,cancelable:!1,detail:a,data:null}))
n.a(o.window).dispatchEvent(p)
return A.Y(null,r)}})
return A.Z($async$ap,r)},
cr(a){var s=t.m
this.di(s.a(s.a(a).detail))},
dj(a){var s,r=this
if(r.f!=null)return
r.f="WALLET_"+a
t.m.a(v.G.window).addEventListener("ETH_"+a,A.d(r.gcq()))
s=r.d
if(s!=null)s.aK()}}
A.bi.prototype={
aI(a,b){var s
A.h(a)
t.g.a(b)
s=A.bf(a)
if(s!==B.d)return null
if(s!=null)B.a.t(this.d,b)
this.a.a.$1(A.fT(null,A.aS(B.d)))
return A.t(new A.dt(this,b))},
c2(a){var s,r,q,p=A.ac(this.d,t.g)
for(s=p.length,r=0;r<p.length;p.length===s||(0,A.aj)(p),++r){q=p[r]
q.call(q,a)}},
a3(a){return A.R(new A.dq(this,t.A.a(a)).$0(),t.m)},
A(){return this.a3(null)},
a7(){var s,r,q,p=this,o=p.c
o["standard:events"]=A.a3(A.v(p.gG()))
s={}
s.connect=A.d(p.gv())
s.version="1.0.0"
o["standard:connect"]=s
r=p.b
r.features=o
r.name="OnChain"
r.version="1.0.0"
r.icon=u.f
r.accounts=A.a([],t.O)
r=v.G
o=t.m
q=o.a(new r.CustomEvent("wallet-standard:register-wallet",{bubbles:!1,cancelable:!1,detail:A.d(new A.dr(p))}))
o.a(r.window).addEventListener("wallet-standard:app-ready",A.d(new A.ds(q)))
o.a(r.window).dispatchEvent(q)}}
A.dt.prototype={
$0(){B.a.ad(this.a.d,this.b)},
$S:2}
A.dq.prototype={
$0(){var s=0,r=A.a_(t.m),q,p=this,o,n,m
var $async$$0=A.a0(function(a,b){if(a===1)return A.X(b,r)
while(true)switch(s){case 0:m=p.b
if(m!=null){m=A.ah(m.silent)
o=m===!0}else o=!1
m=p.a
s=3
return A.a7(m.a.K("connect",A.a([o],t.bx),t.m),$async$$0)
case 3:n=b
m.b.accounts=t.c.a(n.accounts)
q=n
s=1
break
case 1:return A.Y(q,r)}})
return A.Z($async$$0,r)},
$S:56}
A.dr.prototype={
$1(a){t.K.a(a).register(this.a.b)},
$S:14}
A.ds.prototype={
$1(a){t.K.a(a)
t.m.a(v.G.window).dispatchEvent(this.a)},
$S:14}
A.G.prototype={
R(a,b,c,d){return this.a.bt(this.gD(),a,b,c,d)},
k(a,b,c){return this.R(a,b,B.m,c)},
L(a,b){return this.R(a,null,B.m,b)},
bs(a,b,c){return this.R(a,null,b,c)},
K(a,b,c){return this.dA(a,b,c,c)},
br(a,b){return this.K(a,null,b)},
dA(a,b,c,d){var s=0,r=A.a_(d),q,p=this
var $async$K=A.a0(function(e,f){if(e===1)return A.X(f,r)
while(true)switch(s){case 0:q=p.a.a0(p.gD(),a,b,B.m,c)
s=1
break
case 1:return A.Y(q,r)}})
return A.Z($async$K,r)},
c1(){return this.a.dB(this.gD(),"disconnect",t.X)},
Y(a){var s=A.ij(A.h(a.event))
if(!(s===B.b||s===B.c||s===B.i||s===B.d))return
this.a.a.$1(A.fT(this.gD(),a))},
aI(a,b){var s,r
A.h(a)
t.g.a(b)
s=A.bf(a)
if(s!=null){r=this.b.j(0,s)
r.toString
B.a.t(r,b)
this.Y(A.aS(s))}},
ah(a,b){var s,r,q,p=A.ac(t.u.a(a),t.g)
for(s=p.length,r=0;r<p.length;p.length===s||(0,A.aj)(p),++r){q=p[r]
q.call(q,b)}},
c5(a,b){var s=this.b
if(!s.Z(a))return
s=s.j(0,a)
s.toString
this.ah(s,b)},
ac(a){var s,r,q,p=t.m.a(a.data),o=A.dz(p)
for(s=o.length,r=t.A,q=0;q<o.length;o.length===s||(0,A.aj)(o),++q)switch(o[q]){case B.L:this.c5(B.d,r.a(p.change))
break}}}
A.ct.prototype={
ai(a,b){return this.c8(a,b)},
c8(a,b){var s=0,r=A.a_(t.m),q,p=2,o=[],n=[],m=this,l,k,j,i
var $async$ai=A.a0(function(c,d){if(c===1){o.push(d)
s=p}while(true)switch(s){case 0:i=new A.cs(A.iJ(),new A.af(new A.m($.o,t.aX),t.x))
p=3
k=i.a
j=a==null?null:a.b
l={data:b,requestId:k,client:j}
m.a.$1(l)
j=m.b
k=i.a
if(j.j(0,k)==null)j.C(0,k,i)
s=6
return A.a7(i.b.a,$async$ai)
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
m.b.ad(0,i.a)
s=n.pop()
break
case 5:case 1:return A.Y(q,r)
case 2:return A.X(o.at(-1),r)}})
return A.Z($async$ai,r)},
bt(a,b,c,d,e){return A.R(this.a0(a,b,c,d,e),e)},
dB(a,b,c){return this.bt(a,b,null,B.m,c)},
a0(a,b,c,d,e){return this.dz(a,b,c,d,e,e)},
K(a,b,c){return this.a0(null,a,b,B.m,c)},
dz(a,b,c,d,e,f){var s=0,r=A.a_(f),q,p=this,o,n
var $async$a0=A.a0(function(g,h){if(g===1)return A.X(h,r)
while(true)$async$outer:switch(s){case 0:s=3
return A.a7(p.ai(a,{type:"request",method:b,params:c,providerType:d.b}),$async$a0)
case 3:n=h
switch(A.fP(A.h(n.status))){case B.N:q=e.a(n.data)
s=1
break $async$outer
case B.G:o=A.jW(n,"data",t.X)
throw A.f(o==null?t.K.a(o):o)}case 1:return A.Y(q,r)}})
return A.Z($async$a0,r)}}
A.b7.prototype={
bT(a){var s=t.K
return this.k("wallet_switchAptosChain",A.a([s.a(a)],t.f),s)},
F(a){var s=t.K
return A.R(this.K("aptos_signMessage",A.a([s.a(a)],t.f),s).ae(new A.cR(),s),s)},
J(a){var s=t.K
return A.R(this.K("aptos_signTransaction",A.a([A.ig(s.a(a))],t.f),s).ae(new A.cS(),s),s)},
cE(){var s=t.K
return A.R(this.br("aptos_requestAccounts",s).ae(new A.cQ(),s),s)},
cl(){return this.L("aptos_network",t.K)},
cn(a){var s
t.g.a(a)
s=this.c.j(0,B.b)
s.toString
B.a.t(s,a)
this.Y(A.aS(B.b))},
cp(a){var s
t.g.a(a)
s=this.c.j(0,B.c)
s.toString
B.a.t(s,a)
this.Y(A.aS(B.c))},
ah(a,b){var s,r,q=A.ac(t.u.a(a),t.g)
for(s=q.length,r=0;r<q.length;q.length===s||(0,A.aj)(q),++r)q[r].call(null,b)},
ac(a){var s,r,q,p,o,n,m,l,k=this
k.au(a)
s=t.m.a(a.data)
r=A.dz(s)
for(q=r.length,p=k.c,o=t.A,n=0;n<r.length;r.length===q||(0,A.aj)(r),++n)switch(r[n]){case B.t:m=p.j(0,B.b)
m.toString
k.ah(m,o.a(s.account))
break
case B.r:l=s.chainChanged
if(l!=null){m=p.j(0,B.c)
m.toString
k.ah(m,l)}break}},
gD(){return B.u},
M(a){var s=this,r=s.gcD(),q={}
q.connect=A.t(r)
q.version="1.0.0"
a["aptos:connect"]=q
q={}
q.signTransaction=A.d(s.gI())
q.version="1.0.0"
a["aptos:signTransaction"]=q
q={}
q.signMessage=A.d(s.gE())
q.version="1.0.0"
a["aptos:signMessage"]=q
q={}
q.account=A.t(r)
q.version="1.0.0"
a["aptos:account"]=q
q={}
q.onNetworkChange=A.d(s.gco())
q.version="1.0.0"
a["aptos:onNetworkChange"]=q
q={}
q.network=A.t(s.gck())
q.version="1.0.0"
a["aptos:network"]=q
q={}
q.onAccountChange=A.d(s.gcm())
q.version="1.0.0"
a["aptos:onAccountChange"]=q
q={}
q.disconnect=A.t(s.ga4())
q.version="1.0.0"
a["aptos:disconnect"]=q
q={}
q.changeNetwork=A.d(s.gbS())
q.version="1.0.0"
a["aptos:changeNetwork"]=q
a["aptos:events"]=A.a3(A.v(s.gG()))}}
A.cR.prototype={
$1(a){var s,r=t.K
r.a(a)
if(A.f5(A.h(a.status))===B.p)return a
s=r.a(a.args)
A.f4(s)
return A.f6(s,r)},
$S:20}
A.cS.prototype={
$1(a){var s,r=t.K
r.a(a)
if(A.f5(A.h(a.status))===B.p)return a
s=r.a(a.args)
A.f4(s)
return A.f6(s,r)},
$S:20}
A.cQ.prototype={
$1(a){var s,r,q=t.K
q.a(a)
if(A.f5(A.h(a.status))===B.p)return a
s=t.m
r=s.a(q.a(a.args))
A.f4(s.a(r.publicKey))
r.publicKey=A.O(s.a(r.publicKey),s)
return A.f6(r,s)},
$S:20}
A.b9.prototype={
M(a){var s=this,r={}
r.connect=A.t(s.gv())
r.version="1.0.0"
a["bitcoin:connect"]=r
r={}
r.signPersonalMessage=A.d(s.gbO())
r.version="1.0.0"
a["bitcoin:signPersonalMessage"]=r
r={}
r.signTransaction=A.d(s.gbQ())
r.version="1.0.0"
a["bitcoin:signTransaction"]=r
r={}
r.sendTransaction=A.d(s.gbM())
r.version="1.0.0"
a["bitcoin:sendTransaction"]=r
r={}
r.disconnect=A.t(s.ga4())
r.version="1.0.0"
a["bitcoin:disconnect"]=r
a["bitcoin:events"]=A.a3(A.v(s.gG()))},
A(){return this.L("bitcoin_requestAccounts",t.m)},
bP(a){var s=t.K
return this.k("bitcoin_signPersonalMessage",A.a([s.a(a)],t.f),s)},
bR(a){var s=t.K
return this.k("bitcoin_signTransaction",A.a([s.a(a)],t.f),s)},
bN(a){var s=t.K
return this.k("bitcoin_sendTransaction",A.a([s.a(a)],t.f),s)},
gD(){return B.v}}
A.bb.prototype={
de(){return this.L("cosmos_requestAccounts",t.m)},
F(a){var s=t.K
return this.k("cosmos_signMessage",A.a([s.a(a)],t.f),s)},
b3(a,b){var s,r,q
A.h(a)
s=A.t(new A.cV(this,a))
r=A.v(new A.cW(this,a,b))
q={}
q.getAccounts=s
q.signDirect=r
return A.O(q,t.K)},
b2(a){return this.b3(a,null)},
b7(a,b){var s,r,q
A.h(a)
s=A.t(new A.cT(this,a))
r=A.v(new A.cU(this,a,b))
q={}
q.getAccounts=s
q.signAmino=r
return A.O(q,t.K)},
b6(a){return this.b7(a,null)},
bg(a,b){var s,r
A.h(a)
s=this.b2(a)
r={}
r.amino=this.b6(a)
r.direct=s
return A.O(r,t.K)},
d9(a){return this.bg(a,null)},
c7(a){A.h(a)
throw A.f(A.fe(null))},
gD(){return B.w},
aw(a){return this.k("cosmos_addNewChain",A.a([t.K.a(a)],t.f),t.y)},
J(a){var s=t.K
return this.k("cosmos_signTransaction",A.a([s.a(a)],t.f),s)},
M(a){var s,r,q=this
if(q.c==null){s={}
s.getOfflineSigner=A.v(q.gb1())
s.getOfflineSignerOnlyAmino=A.v(q.gb5())
s.getOfflineSignerAuto=A.d(q.gb4())
r=A.O(s,t.m)
q.c=s
q.d=r}r=v.G
r.keplr=q.d
r.getOfflineSigner=A.v(q.gb1())
r.getOfflineSignerOnlyAmino=A.v(q.gb5())
r.getOfflineSignerAuto=A.d(q.gb4())
s={}
s.connect=A.t(q.gdd())
s.version="1.0.0"
a["cosmos:connect"]=s
a["cosmos:events"]=A.a3(A.v(q.gG()))
s={}
s.signer=A.v(q.gd8())
s.version="1.0.0"
a["cosmos:signer"]=s
s={}
s.addNewChain=A.d(q.gav())
s.version="1.0.0"
a["cosmos:addNewChain"]=s
s={}
s.signMessage=A.d(q.gE())
s.version="1.0.0"
a["cosmos:signMessage"]=s
s={}
s.signTransaction=A.d(q.gI())
s.version="1.0.0"
a["cosmos:signTransaction"]=s}}
A.cV.prototype={
$0(){return this.a.k("cosmos_requestAccounts",A.fX(A.a([this.b],t.s)),t.c)},
$S:3}
A.cW.prototype={
$2(a,b){var s,r
A.h(a)
s=t.K
r={}
r.signDoc=s.a(b)
r.signerAddress=a
r.chainId=this.b
r.signOption=this.c
return this.a.k("cosmos_signTransactionDirect",A.a([r],t.f),s)},
$S:28}
A.cT.prototype={
$0(){return this.a.k("cosmos_requestAccounts",A.fX(A.a([this.b],t.s)),t.c)},
$S:3}
A.cU.prototype={
$2(a,b){var s,r
A.h(a)
s=t.K
s.a(b)
r={}
r.signDoc=A.h(t.m.a(v.G.JSON).stringify(b))
r.signerAddress=a
r.chainId=this.b
r.signOption=this.c
return this.a.k("cosmos_signTransactionAmino",A.a([r],t.f),s)},
$S:28}
A.bd.prototype={
aJ(a){t.m.a(a)
return this.R(A.h(a.method),t.r.a(a.params),B.h,t.X)},
a7(){var s,r,q,p,o,n,m,l,k=this,j=k.c
if(j==null){j=A.t(k.gbV())
r=A.d(k.gaj())
q=A.v(k.gbH())
p=A.v(k.gcu())
o=A.t(k.ga4())
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
m=A.O(j,r)
s=m
try{v.G.ethereum=s}catch(l){r.a(v.G.console).error("failed to set ethereum ")}A.i5(s)},
bW(){return this.bs("eth_requestAccounts",B.h,t.c)},
A(){return this.L("eth_requestAccounts",t.m)},
aw(a){return this.k("wallet_addEthereumChain",A.a([t.m.a(a)],t.O),t.N)},
d3(a){var s=t.m
return this.k("eth_signTypedData",A.a([s.a(a)],t.O),s)},
d5(a){var s=t.m
return this.k("eth_signTypedData_v3",A.a([s.a(a)],t.O),s)},
d7(a){var s=t.m
return this.k("eth_signTypedData_v4",A.a([s.a(a)],t.O),s)},
ct(a){var s=t.m
return this.k("personal_sign",A.a([s.a(a)],t.O),s)},
aa(a){var s=t.m
return this.k("eth_sendTransaction",A.a([s.a(a)],t.O),s)},
M(a){var s,r=this
r.a7()
s={}
s.connect=A.t(r.gv())
s.version="1.0.0"
a["ethereum:connect"]=s
s={}
s.addNewChain=A.d(r.gav())
s.version="1.0.0"
a["ethereum:addNewChain"]=s
s={}
s.signTypedData=A.d(r.gd2())
s.version="1.0.0"
a["ethereum:signTypedData"]=s
s={}
s.signTypedDataV3=A.d(r.gd4())
s.version="1.0.0"
a["ethereum:signTypedDataV3"]=s
s={}
s.signTypedDataV4=A.d(r.gd6())
s.version="1.0.0"
a["ethereum:signTypedDataV4"]=s
s={}
s.personalSign=A.d(r.gcs())
s.version="1.0.0"
a["ethereum:personalSign"]=s
s={}
s.sendTransaction=A.d(r.ga9())
s.version="1.0.0"
a["ethereum:sendTransaction"]=s
s={}
s.request=A.d(r.gaj())
s.version="1.0.0"
a["ethereum:request"]=s
a["ethereum:events"]=A.a3(A.v(r.gG()))},
ac(a){var s,r,q,p,o,n,m,l,k=this,j=null
k.au(a)
s=t.m.a(a.data)
r=A.dz(s)
for(q=r.length,p=t.A,o=0;o<r.length;r.length===q||(0,A.aj)(r),++o)switch(r[o]){case B.t:n=k.c
if(n!=null){m=p.a(s.account)
m=m==null?j:A.h(m.address)
n.selectedAddress=m}break
case B.F:k.a5(B.q,s.message)
break
case B.E:n=p.a(s.networkAccounts)
k.a5(B.b,n==null?j:A.fO(n))
break
case B.r:l=p.a(s.chainChanged)
n=k.c
if(n!=null){m=l==null?j:A.h(l.chainId)
n.chainId=m}n=k.c
if(n!=null){m=l==null?j:A.h(l.netVersion)
n.networkVersion=m}if(s.disconnect!=null)k.a5(B.k,s.disconnect)
if(l!=null){if(s.disconnect==null)k.a5(B.i,l)
k.a5(B.c,A.h(l.chainId))}break}},
a5(a,b){var s,r,q
if(b==null||!this.d.Z(a))return
s=this.d.j(0,a)
s.toString
s=A.ac(s,t.g)
for(r=s.length,q=0;q<s.length;s.length===r||(0,A.aj)(s),++q)s[q].call(null,b)},
bI(a,b){var s,r
A.h(a)
t.g.a(b)
s=A.bf(a)
if(s==null)return
r=this.d.j(0,s)
if(r!=null)B.a.t(r,b)
this.Y(A.aS(s))},
cv(a,b){var s
A.h(a)
t.g.a(b)
s=this.d.j(0,A.bf(a))
if(s!=null)B.a.ad(s,b)},
gD(){return B.x}}
A.bv.prototype={
M(a){var s=this,r=A.d(s.gcO()),q=A.d(s.gcW()),p=A.d(s.gE()),o=$.hH(),n={}
n.signTransaction=q
n.version="1.0.0"
n.supportedTransactionVersions=o
a["solana:signTransaction"]=n
n={}
n.signAndSendTransaction=r
n.version="1.0.0"
n.supportedTransactionVersions=o
a["solana:signAndSendTransaction"]=n
n={}
n.signMessage=p
n.version="1.0.0"
a["solana:signMessage"]=n
n={}
n.signAndSendAllTransactions=A.v(s.gcM())
n.version="1.0.0"
n.supportedTransactionVersions=o
a["solana:signAndSendAllTransactions"]=n
a["solana:events"]=A.a3(A.v(s.gG()))
n={}
n.connect=A.t(s.gv())
n.version="1.0.0"
a["solana:connect"]=n
n={}
n.signIn=A.d(s.gcQ())
n.version="1.0.0"
a["solana:signIn"]=n},
A(){return this.L("solana_requestAccounts",t.m)},
cR(a){var s=t.m
return A.R(this.K("solana_signIn",A.dE(s.a(a)),s),s)},
F(a){var s=t.c
return A.R(this.K("solana_signMessage",A.dE(t.m.a(a)),s),s)},
cX(a){var s=t.c
return A.R(this.K("solana_signTransaction",A.dE(t.K.a(a)),s),s)},
cP(a){return this.k("solana_signAndSendTransaction",A.dE(t.m.a(a)),t.c)},
bd(a,b){var s,r=t.c
r.a(a)
t.A.a(b)
s=A.a([a],t.f)
if(b!=null)s.push(b)
return this.k("solana_signAndSendAllTransactions",s,r)},
cN(a){return this.bd(a,null)},
gD(){return B.y}}
A.bx.prototype={
M(a){var s=this,r={}
r.signAndSendTransaction=A.d(s.ga9())
r.version="1.0.0"
a["stellar:signAndSendTransaction"]=r
r={}
r.signTransaction=A.d(s.gI())
r.version="1.0.0"
a["stellar:signTransaction"]=r
r={}
r.signMessage=A.d(s.gE())
r.version="1.0.0"
a["stellar:signMessage"]=r
r={}
r.connect=A.t(s.gv())
r.version="1.0.0"
a["stellar:connect"]=r
a["stellar:events"]=A.a3(A.v(s.gG()))},
A(){return this.L("stellar_requestAccounts",t.m)},
J(a){var s=t.K
return this.k("stellar_signTransaction",A.a([s.a(a)],t.f),s)},
aa(a){var s=t.K
return this.k("stellar_sendTransaction",A.a([s.a(a)],t.f),s)},
F(a){return this.k("stellar_signMessage",A.a([t.m.a(a)],t.O),t.K)},
gD(){return B.z}}
A.by.prototype={
M(a){var s,r=this
r.ca()
s={}
s.signTransaction=A.d(r.gaU())
s.version="1.0.0"
a["substrate:signTransaction"]=s
s={}
s.signMessage=A.d(r.gaT())
s.version="1.0.0"
a["substrate:signMessage"]=s
s={}
s.connect=A.d(r.gv())
s.version="1.0.0"
a["substrate:connect"]=s
a["substrate:events"]=A.a3(A.v(r.gG()))},
ca(){var s,r,q,p,o=this,n=o.d
if(n==null){s={}
r={}
q={}
p={}
q.signPayload=A.d(o.gaU())
q.signRaw=A.d(o.gaT())
q.update=A.d(o.gdv())
s.get=A.d(o.gcb())
s.provide=A.d(o.gcf())
r.get=A.d(o.gbX())
r.subscribe=A.d(o.gcd())
n=t.m
p.metadata=A.O(s,n)
p.accounts=A.O(r,n)
p.signer=A.O(q,n)
n=o.gaC()
p.connect=A.d(n)
p.enable=A.d(n)
p.name="OnChain"
p.version="0.4.0"
n=o.d=new A.as(null,p,t.q)}if(o.e==null)o.e=A.eK(v.G.Proxy,[n.b,new A.dT(o).$0()],t.m)
n=v.G
if(t.A.a(n.injectedWeb3)==null)n.injectedWeb3={}
t.m.a(n.injectedWeb3)["0"]=o.e
n.substrate=o.e},
b8(a){A.ah(a)
return this.L("substrate_knownMetadata",t.m)},
cc(){return this.b8(null)},
cg(a){return this.k("wallet_addSubstrateChain",A.a([t.m.a(a)],t.O),t.y)},
bx(a){var s=t.m
return this.k("substrate_signTransaction",A.a([s.a(a)],t.O),s)},
bw(a){var s=t.m
return this.k("substrate_signMessage",A.a([s.a(a)],t.O),s)},
a3(a){return this.L("substrate_requestAccounts",t.m)},
A(){return this.a3(null)},
b_(a){var s=t.c
return A.R(this.br("substrate_requestAccounts",t.m).ae(new A.dP(),s),s)},
bY(){return this.b_(null)},
bq(a){throw A.f($.fz())},
dw(){return this.bq(null)},
c4(a){A.h(a)
return A.R(new A.dQ(this).$0(),t.A)},
ce(a){var s
t.g.a(a)
s=this.c.j(0,B.b)
s.toString
B.a.t(s,a)
this.Y(A.aS(B.b))},
gD(){return B.A}}
A.dR.prototype={
$0(){return this.a.a},
$S:16}
A.dS.prototype={
$0(){return this.a.b},
$S:8}
A.dT.prototype={
$0(){var s,r,q,p,o,n,m=this.a.d
m.toString
s=v.G
r=t.m
q=r.a(s.Object)
p=r.a(q.create.apply(q,[null]))
p.set=A.fm(m.gar())
p.get=A.fl(m.gaq())
q=r.a(s.Object)
o=r.a(q.create.apply(q,[null]))
o.get=A.t(new A.dR(m))
q=r.a(s.Object)
q.defineProperty.apply(q,[p,"debugKey",o])
q=r.a(s.Object)
n=r.a(q.create.apply(q,[null]))
n.get=A.t(new A.dS(m))
s=r.a(s.Object)
s.defineProperty.apply(s,[p,"object",n])
return p},
$S:6}
A.dP.prototype={
$1(a){return t.c.a(t.m.a(a).accounts)},
$S:50}
A.dQ.prototype={
$0(){var s=0,r=A.a_(t.A),q,p=this
var $async$$0=A.a0(function(a,b){if(a===1)return A.X(b,r)
while(true)switch(s){case 0:q=p.a.e
s=1
break
case 1:return A.Y(q,r)}})
return A.Z($async$$0,r)},
$S:51}
A.bz.prototype={
F(a){var s=t.K
return this.k("sui_signMessage",A.a([s.a(a)],t.f),s)},
cV(a){var s=t.K
return this.k("sui_signPersonalMessage",A.a([s.a(a)],t.f),s)},
U(a,b,c){A.jO(c,t.K,"T","_signTransction_")
return this.d1(a,b,c,c)},
d1(a,b,c,d){var s=0,r=A.a_(d),q,p=this,o,n
var $async$U=A.a0(function(e,f){if(e===1)return A.X(f,r)
while(true)switch(s){case 0:o=a
n=A
s=3
return A.a7(A.du(b),$async$U)
case 3:q=p.K(o,n.a([f],t.f),c)
s=1
break
case 1:return A.Y(q,r)}})
return A.Z($async$U,r)},
J(a){var s=t.K
return A.R(this.U("sui_signTransaction",s.a(a),s),s)},
cL(a){var s=t.K
return A.R(this.U("sui_signAndExecuteTransaction",s.a(a),s),s)},
cJ(a){var s=t.K
return A.R(this.U("sui_signAndExecuteTransactionBlock",s.a(a),s),s)},
cZ(a){var s=t.K
return A.R(this.U("sui_signTransactionBlock",s.a(a),s),s)},
cC(a){t.K.a(a)
return A.i8(A.i9(B.I,t.z))},
gD(){return B.B},
A(){return this.L("sui_requestAccounts",t.m)},
M(a){var s=this,r={}
r.signTransaction=A.d(s.gI())
r.version="1.0.0"
a["sui:signTransaction"]=r
r={}
r.connect=A.t(s.gv())
r.version="1.0.0"
a["sui:connect"]=r
r={}
r.signTransactionBlock=A.d(s.gcY())
r.version="1.0.0"
a["sui:signTransactionBlock"]=r
r={}
r.signAndExecuteTransactionBlock=A.d(s.gcI())
r.version="1.0.0"
a["sui:signAndExecuteTransactionBlock"]=r
r={}
r.signAndExecuteTransaction=A.d(s.gcK())
r.version="2.0.0"
a["sui:signAndExecuteTransaction"]=r
r={}
r.signPersonalMessage=A.d(s.gcU())
r.version="1.0.0"
a["sui:signPersonalMessage"]=r
r={}
r.signMessage=A.d(s.gE())
r.version="1.0.0"
a["sui:signMessage"]=r
r={}
r.reportTransactionEffects=A.d(s.gcB())
r.version="1.0.0"
a["sui:reportTransactionEffects"]=r
r={}
r.disconnect=A.t(s.ga4())
r.version="1.0.0"
a["sui:disconnect"]=r
a["sui:events"]=A.a3(A.v(s.gG()))}}
A.bA.prototype={
M(a){var s=this,r={}
r.signAndSendTransaction=A.d(s.ga9())
r.version="1.0.0"
a["ton:signAndSendTransaction"]=r
r={}
r.signTransaction=A.d(s.gI())
r.version="1.0.0"
a["ton:signTransaction"]=r
r={}
r.signMessage=A.d(s.gE())
r.version="1.0.0"
a["ton:signMessage"]=r
r={}
r.connect=A.t(s.gv())
r.version="1.0.0"
a["ton:connect"]=r
a["ton:events"]=A.a3(A.v(s.gG()))},
A(){return this.L("ton_requestAccounts",t.m)},
J(a){return this.k("ton_signTransaction",A.a([t.m.a(a)],t.O),t.K)},
aa(a){return this.k("ton_sendTransaction",A.a([t.m.a(a)],t.O),t.K)},
F(a){return this.k("ton_signMessage",A.a([t.m.a(a)],t.O),t.K)},
gD(){return B.C}}
A.bB.prototype={
a7(){var s,r,q,p,o,n,m,l,k=this,j=v.G,i=new j.TronWeb("https://api.shasta.trongrid.io","https://api.shasta.trongrid.io","https://api.shasta.trongrid.io"),h=k.e,g=t.m,f=A.eK(j.Proxy,[h,new A.e_(new A.as(null,h,t.q)).$0()],g)
g.a(i.trx).sign=A.v(k.gd_())
g.a(i.trx).signMessageV2=A.v(k.gcS())
g.a(i.trx).multiSign=A.v(k.gci())
h=k.gc_()
i.setPrivateKey=A.d(h)
i.setAddress=A.d(h)
i.setFullNode=A.d(h)
i.setSolidityNode=A.d(h)
i.setHeader=A.d(h)
i.setFullNodeHeader=A.d(h)
i.setDefaultBlock=A.d(h)
i.defaultPrivateKey=""
i.defaultAddress=f
h=t.K
s=A.O(i,h)
r=A.d(k.gaj())
q=A.v(k.gbJ())
p=A.t(k.gaC())
o=A.v(k.gcz())
A.t(k.ga4())
n={}
n.dappIcon=""
n.dappName=""
n.openTronLinkAppOnMobile=!0
n.openUrlWhenWalletNotFound=!0
m={}
m.config=n
m.request=r
m.on=q
m.removeListener=o
m.tronWeb=s
m.enable=p
m.connect=p
m.ready=!0
l=g.a(j.Object.freeze(m))
j.tronLink=A.O(l,g)
j.tronWeb=A.O(i,h)
j.tron=A.O(l,g)
k.c=l
k.d=i},
c0(a){throw A.f($.fz())},
be(a,b){t.K.a(a)
if(b!=null)A.fi(b)
return this.R("tron_signMessageV2",A.a([a],t.f),B.h,t.N)},
cT(a){return this.be(a,null)},
bf(a,b){t.K.a(a)
if(b!=null)A.fi(b)
return this.R("tron_signTransaction",A.a([a],t.f),B.h,t.m)},
d0(a){return this.bf(a,null)},
ba(a,b){t.K.a(a)
if(b!=null)A.fi(b)
return this.R("tron_signTransaction",A.a([a],t.f),B.h,t.X)},
cj(a){return this.ba(a,null)},
a6(a,b){var s,r,q
if(b==null||!this.f.Z(a))return
s=this.f.j(0,a)
s.toString
s=A.ac(s,t.g)
for(r=s.length,q=0;q<s.length;s.length===r||(0,A.aj)(s),++q)s[q].call(null,b)},
bK(a,b){var s,r
A.h(a)
t.g.a(b)
s=A.bf(a)
if(s==null)return
r=this.f.j(0,s)
if(r!=null)B.a.t(r,b)
this.Y(A.aS(s))},
cA(a,b){var s
A.h(a)
t.g.a(b)
s=this.f.j(0,A.bf(a))
if(s!=null)B.a.ad(s,b)},
c3(){return this.bs("tron_requestAccounts",B.h,t.c)},
aJ(a){t.m.a(a)
return this.R(A.h(a.method),t.r.a(a.params),B.h,t.X)},
gD(){return B.D},
ac(a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=this,a=null
b.au(a0)
s=t.m
r=s.a(a0.data)
q=A.dz(r)
for(p=q.length,o=t.A,n=v.G,m=t.N,l=t.X,k=t.z,j=b.e,i=0;i<q.length;q.length===p||(0,A.aj)(q),++i)switch(q[i]){case B.t:h=o.a(r.account)
g=b.c
f=g==null
e=f?a:A.a6(g.selectedAddress)
d=h==null
if(e!=(d?a:A.h(h.address))){if(!f){f=d?a:A.h(h.address)
g.selectedAddress=f}g=d?a:A.h(h.address)
if(g==null)g=!1
j.base58=g
g=d?a:A.h(h.hex)
if(g==null)g=!1
j.hex=g
s.a(n.window).postMessage(A.fw(A.B(["message",A.B(["action","accountsChanged","data",h],m,l),"source","contentScript"],m,k)))}break
case B.F:b.a6(B.q,r.message)
break
case B.E:g=o.a(r.networkAccounts)
b.a6(B.b,g==null?a:A.fO(g))
break
case B.r:c=o.a(r.chainChanged)
g=b.c
if(g!=null){f=c==null?a:A.h(c.chainId)
g.chainId=f}g=b.c
if(g!=null){f=c==null?a:A.h(c.netVersion)
g.networkVersion=f}if(r.disconnect!=null)b.a6(B.k,r.disconnect)
if(c!=null){if(r.disconnect==null){b.a6(B.i,c)
s.a(n.window).postMessage(A.fw(A.B(["message",A.B(["action","connect","data",null],m,l),"source","contentScript"],m,k)))}g=A.h(c.fullNode)
f=b.d
if(f!=null)f.fullNode=new n.TronWeb.providers.HttpProvider(g)
f=b.d
if(f!=null)f.solidityNode=new n.TronWeb.providers.HttpProvider(g)
f=b.d
if(f!=null)f.setEventServer(new n.TronWeb.providers.HttpProvider(g))
b.a6(B.c,A.h(c.chainId))
s.a(n.window).postMessage(A.fw(A.B(["message",A.B(["action","setNode","data",A.B(["node",c],m,o)],m,l),"source","contentScript"],m,k)))}break}},
A(){return this.L("tron_requestAccounts",t.m)},
F(a){var s=t.m
return this.k("tron_signMessageV2",A.a([s.a(a)],t.O),s)},
J(a){var s=t.m
return this.k("tron_signTransaction",A.a([s.a(a)],t.O),s)},
M(a){var s,r,q=this
q.a7()
s={}
s.connect=A.t(q.gv())
s.version="1.0.0"
a["tron:connect"]=s
s={}
s.signMessage=A.d(q.gE())
s.version="1.0.0"
a["tron:signMessage"]=s
r=q.gI()
a["tron:signTransaction"]=A.h1(A.d(r))
a["tron:signTransaction"]=A.h1(A.d(r))
a["tron:events"]=A.a3(A.v(q.gG()))}}
A.dY.prototype={
$0(){return this.a.a},
$S:16}
A.dZ.prototype={
$0(){return this.a.b},
$S:8}
A.e_.prototype={
$0(){var s,r,q=this.a,p=v.G,o=t.m,n=o.a(p.Object),m=o.a(n.create.apply(n,[null]))
m.set=A.fm(q.gar())
m.get=A.fl(q.gaq())
n=o.a(p.Object)
s=o.a(n.create.apply(n,[null]))
s.get=A.t(new A.dY(q))
n=o.a(p.Object)
n.defineProperty.apply(n,[m,"debugKey",s])
n=o.a(p.Object)
r=o.a(n.create.apply(n,[null]))
r.get=A.t(new A.dZ(q))
p=o.a(p.Object)
p.defineProperty.apply(p,[m,"object",r])
return m},
$S:6}
A.dA.prototype={
$1(a){return A.h(a)},
$S:12}
A.dB.prototype={
$1(a){return A.ik(A.h(a))},
$S:54}
A.dw.prototype={
$1(a){return A.h(t.m.a(a).address)},
$S:39};(function aliases(){var s=J.ap.prototype
s.bC=s.i
s=A.G.prototype
s.au=s.ac})();(function installTearOffs(){var s=hunkHelpers._static_1,r=hunkHelpers._static_0,q=hunkHelpers.installInstanceTearOff,p=hunkHelpers._instance_1u,o=hunkHelpers._instance_2u,n=hunkHelpers._instance_0u
s(A,"jL","iL",17)
s(A,"jM","iM",17)
s(A,"jN","iN",17)
r(A,"hw","jG",2)
var m
q(m=A.as.prototype,"gar",0,4,null,["$4"],["bv"],41,0,0)
q(m,"gaq",0,3,null,["$3"],["bu"],42,0,0)
p(m=A.cf.prototype,"gbo","ap",7)
p(m,"gcq","cr",7)
o(m=A.bi.prototype,"gG","aI",35)
q(m,"gv",0,0,null,["$1","$0"],["a3","A"],36,0,0)
n(m=A.G.prototype,"ga4","c1",3)
o(m,"gG","aI",5)
p(m=A.b7.prototype,"gbS","bT",1)
p(m,"gE","F",1)
p(m,"gI","J",1)
n(m,"gcD","cE",3)
n(m,"gck","cl",3)
p(m,"gcm","cn",19)
p(m,"gco","cp",19)
n(m=A.b9.prototype,"gv","A",3)
p(m,"gbO","bP",1)
p(m,"gbQ","bR",1)
p(m,"gbM","bN",1)
n(m=A.bb.prototype,"gdd","de",3)
p(m,"gE","F",1)
q(m,"gb1",0,1,null,["$2","$1"],["b3","b2"],21,0,0)
q(m,"gb5",0,1,null,["$2","$1"],["b7","b6"],21,0,0)
q(m,"gd8",0,1,null,["$2","$1"],["bg","d9"],21,0,0)
p(m,"gb4","c7",27)
p(m,"gav","aw",1)
p(m,"gI","J",1)
p(m=A.bd.prototype,"gaj","aJ",0)
n(m,"gbV","bW",3)
n(m,"gv","A",3)
p(m,"gav","aw",0)
p(m,"gd2","d3",0)
p(m,"gd4","d5",0)
p(m,"gd6","d7",0)
p(m,"gcs","ct",0)
p(m,"ga9","aa",0)
o(m,"gbH","bI",5)
o(m,"gcu","cv",5)
n(m=A.bv.prototype,"gv","A",3)
p(m,"gcQ","cR",0)
p(m,"gE","F",0)
p(m,"gcW","cX",1)
p(m,"gcO","cP",0)
q(m,"gcM",0,1,null,["$2","$1"],["bd","cN"],47,0,0)
n(m=A.bx.prototype,"gv","A",3)
p(m,"gI","J",1)
p(m,"ga9","aa",1)
p(m,"gE","F",0)
q(m=A.by.prototype,"gcb",0,0,null,["$1","$0"],["b8","cc"],48,0,0)
p(m,"gcf","cg",0)
p(m,"gaU","bx",0)
p(m,"gaT","bw",0)
q(m,"gv",0,0,null,["$1","$0"],["a3","A"],22,0,0)
q(m,"gbX",0,0,null,["$1","$0"],["b_","bY"],22,0,0)
q(m,"gdv",0,0,null,["$1","$0"],["bq","dw"],22,0,0)
p(m,"gaC","c4",27)
p(m,"gcd","ce",19)
p(m=A.bz.prototype,"gE","F",1)
p(m,"gcU","cV",1)
p(m,"gI","J",1)
p(m,"gcK","cL",1)
p(m,"gcI","cJ",1)
p(m,"gcY","cZ",1)
p(m,"gcB","cC",1)
n(m,"gv","A",3)
n(m=A.bA.prototype,"gv","A",3)
p(m,"gI","J",0)
p(m,"ga9","aa",0)
p(m,"gE","F",0)
p(m=A.bB.prototype,"gc_","c0",52)
q(m,"gcS",0,1,null,["$2","$1"],["be","cT"],9,0,0)
q(m,"gd_",0,1,null,["$2","$1"],["bf","d0"],9,0,0)
q(m,"gci",0,1,null,["$2","$1"],["ba","cj"],9,0,0)
o(m,"gbJ","bK",5)
o(m,"gcz","cA",5)
n(m,"gaC","c3",3)
p(m,"gaj","aJ",0)
n(m,"gv","A",3)
p(m,"gE","F",0)
p(m,"gI","J",0)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.c,null)
q(A.c,[A.f7,J.cb,J.b8,A.i,A.ba,A.w,A.dO,A.aB,A.bn,A.I,A.e0,A.dI,A.be,A.bO,A.ak,A.aq,A.dF,A.bl,A.bk,A.cG,A.cK,A.V,A.cF,A.eC,A.eA,A.bF,A.N,A.dX,A.aX,A.ag,A.m,A.cD,A.cI,A.bU,A.bJ,A.q,A.c7,A.c9,A.eh,A.cr,A.bw,A.ei,A.ar,A.z,A.cJ,A.cz,A.dH,A.ex,A.cY,A.dU,A.cL,A.cs,A.as,A.df,A.bi,A.G,A.ct])
q(J.cb,[J.cc,J.bh,J.x,J.aP,J.aQ,J.ce,J.aO])
q(J.x,[J.ap,J.n,A.bo,A.bs])
q(J.ap,[J.cv,J.bC,J.y])
r(J.dv,J.n)
q(J.ce,[J.bg,J.cd])
q(A.i,[A.aW,A.j,A.aC])
r(A.bV,A.aW)
r(A.bG,A.bV)
r(A.ab,A.bG)
q(A.w,[A.ch,A.ad,A.cg,A.cC,A.cx,A.cE,A.c0,A.a9,A.bD,A.cB,A.aV,A.c6])
q(A.j,[A.F,A.bm,A.bj,A.bI])
r(A.bc,A.aC)
r(A.L,A.F)
r(A.bu,A.ad)
q(A.ak,[A.c3,A.c4,A.cA,A.eQ,A.eS,A.ee,A.ed,A.eF,A.es,A.ev,A.d1,A.eU,A.eY,A.eZ,A.eM,A.e2,A.e3,A.dp,A.dV,A.d9,A.dd,A.cX,A.e9,A.eb,A.dK,A.eV,A.dx,A.dm,A.dk,A.dj,A.dC,A.dh,A.dr,A.ds,A.cR,A.cS,A.cQ,A.dP,A.dA,A.dB,A.dw])
q(A.cA,[A.cy,A.aN])
q(A.aq,[A.aA,A.bH])
q(A.c4,[A.eR,A.eG,A.eJ,A.et,A.ew,A.dG,A.d3,A.d2,A.ec,A.ea,A.cW,A.cU])
q(A.bs,[A.bp,A.aR])
q(A.aR,[A.bK,A.bM])
r(A.bL,A.bK)
r(A.bq,A.bL)
r(A.bN,A.bM)
r(A.br,A.bN)
q(A.bq,[A.cj,A.ck])
q(A.br,[A.cl,A.cm,A.cn,A.co,A.cp,A.bt,A.cq])
r(A.aZ,A.cE)
q(A.c3,[A.ef,A.eg,A.eB,A.d4,A.ej,A.eo,A.en,A.el,A.ek,A.er,A.eq,A.ep,A.eu,A.eI,A.ez,A.dW,A.dc,A.db,A.d8,A.da,A.de,A.dL,A.dM,A.dN,A.dy,A.dn,A.dl,A.dD,A.di,A.dg,A.dt,A.dq,A.cV,A.cT,A.dR,A.dS,A.dT,A.dQ,A.dY,A.dZ,A.e_])
q(A.aX,[A.af,A.bP])
r(A.cH,A.bU)
r(A.aY,A.bH)
q(A.a9,[A.aU,A.ca])
r(A.bE,A.cL)
q(A.eh,[A.am,A.an,A.K,A.U,A.ao,A.E,A.cu])
r(A.cf,A.df)
q(A.G,[A.b7,A.b9,A.bb,A.bd,A.bv,A.bx,A.by,A.bz,A.bA,A.bB])
s(A.bV,A.q)
s(A.bK,A.q)
s(A.bL,A.I)
s(A.bM,A.q)
s(A.bN,A.I)
s(A.cL,A.cY)})()
var v={G:typeof self!="undefined"?self:globalThis,typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{b:"int",p:"double",aM:"num",k:"String",A:"bool",z:"Null",l:"List",c:"Object",ci:"Map"},mangledNames:{},types:["e(e)","e(c)","~()","e()","0&()","~(k,y)","c()","~(e)","c?()","e(c[c?])","z(c,a4)","c?(c?)","k(k)","k()","z(c)","z(@)","k?()","~(~())","~(@)","~(y)","c(c)","e(k[c?])","e([c?])","z(y,y)","@(@)","A(U)","z()","e(k)","e(k,c)","z(~())","A(K)","b(b)","A(ao)","A(E)","J<~>()","y?(k,y)","e([e?])","k(b)","A(am)","k(e)","c?(~)","A(c,c?,c?,c?)","c?(c,c?,c?)","@(k)","c(c,a4)","~(c?,c?)","z(@,a4)","e(n<c?>[e?])","e([A?])","~(b,@)","n<c?>(e)","J<e?>()","~(c?)","A(an)","K(k)","@(@,k)","J<e>()"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti"),rttc:{}}
A.j1(v.typeUniverse,JSON.parse('{"y":"ap","cv":"ap","bC":"ap","n":{"l":["1"],"x":[],"j":["1"],"e":[],"i":["1"]},"cc":{"A":[],"r":[]},"bh":{"z":[],"r":[]},"x":{"e":[]},"ap":{"x":[],"e":[]},"dv":{"n":["1"],"l":["1"],"x":[],"j":["1"],"e":[],"i":["1"]},"b8":{"T":["1"]},"ce":{"p":[],"aM":[]},"bg":{"p":[],"b":[],"aM":[],"r":[]},"cd":{"p":[],"aM":[],"r":[]},"aO":{"k":[],"fU":[],"r":[]},"aW":{"i":["2"]},"ba":{"T":["2"]},"bG":{"q":["2"],"l":["2"],"aW":["1","2"],"j":["2"],"i":["2"]},"ab":{"bG":["1","2"],"q":["2"],"l":["2"],"aW":["1","2"],"j":["2"],"i":["2"],"q.E":"2","i.E":"2"},"ch":{"w":[]},"j":{"i":["1"]},"F":{"j":["1"],"i":["1"]},"aB":{"T":["1"]},"aC":{"i":["2"],"i.E":"2"},"bc":{"aC":["1","2"],"j":["2"],"i":["2"],"i.E":"2"},"bn":{"T":["2"]},"L":{"F":["2"],"j":["2"],"i":["2"],"F.E":"2","i.E":"2"},"bu":{"ad":[],"w":[]},"cg":{"w":[]},"cC":{"w":[]},"bO":{"a4":[]},"ak":{"az":[]},"c3":{"az":[]},"c4":{"az":[]},"cA":{"az":[]},"cy":{"az":[]},"aN":{"az":[]},"cx":{"w":[]},"aA":{"aq":["1","2"],"fQ":["1","2"],"ci":["1","2"]},"bm":{"j":["1"],"i":["1"],"i.E":"1"},"bl":{"T":["1"]},"bj":{"j":["ar<1,2>"],"i":["ar<1,2>"],"i.E":"ar<1,2>"},"bk":{"T":["ar<1,2>"]},"bo":{"x":[],"e":[],"c2":[],"r":[]},"bs":{"x":[],"e":[]},"cK":{"c2":[]},"bp":{"x":[],"f3":[],"e":[],"r":[]},"aR":{"Q":["1"],"x":[],"e":[]},"bq":{"q":["p"],"l":["p"],"Q":["p"],"x":[],"j":["p"],"e":[],"i":["p"],"I":["p"]},"br":{"q":["b"],"l":["b"],"Q":["b"],"x":[],"j":["b"],"e":[],"i":["b"],"I":["b"]},"cj":{"d_":[],"q":["p"],"l":["p"],"Q":["p"],"x":[],"j":["p"],"e":[],"i":["p"],"I":["p"],"r":[],"q.E":"p"},"ck":{"d0":[],"q":["p"],"l":["p"],"Q":["p"],"x":[],"j":["p"],"e":[],"i":["p"],"I":["p"],"r":[],"q.E":"p"},"cl":{"d5":[],"q":["b"],"l":["b"],"Q":["b"],"x":[],"j":["b"],"e":[],"i":["b"],"I":["b"],"r":[],"q.E":"b"},"cm":{"d6":[],"q":["b"],"l":["b"],"Q":["b"],"x":[],"j":["b"],"e":[],"i":["b"],"I":["b"],"r":[],"q.E":"b"},"cn":{"d7":[],"q":["b"],"l":["b"],"Q":["b"],"x":[],"j":["b"],"e":[],"i":["b"],"I":["b"],"r":[],"q.E":"b"},"co":{"e4":[],"q":["b"],"l":["b"],"Q":["b"],"x":[],"j":["b"],"e":[],"i":["b"],"I":["b"],"r":[],"q.E":"b"},"cp":{"e5":[],"q":["b"],"l":["b"],"Q":["b"],"x":[],"j":["b"],"e":[],"i":["b"],"I":["b"],"r":[],"q.E":"b"},"bt":{"e6":[],"q":["b"],"l":["b"],"Q":["b"],"x":[],"j":["b"],"e":[],"i":["b"],"I":["b"],"r":[],"q.E":"b"},"cq":{"e7":[],"q":["b"],"l":["b"],"Q":["b"],"x":[],"j":["b"],"e":[],"i":["b"],"I":["b"],"r":[],"q.E":"b"},"cE":{"w":[]},"aZ":{"ad":[],"w":[]},"bF":{"c5":["1"]},"N":{"w":[]},"aX":{"c5":["1"]},"af":{"aX":["1"],"c5":["1"]},"bP":{"aX":["1"],"c5":["1"]},"m":{"J":["1"]},"bU":{"h3":[]},"cH":{"bU":[],"h3":[]},"bH":{"aq":["1","2"],"ci":["1","2"]},"aY":{"bH":["1","2"],"aq":["1","2"],"ci":["1","2"]},"bI":{"j":["1"],"i":["1"],"i.E":"1"},"bJ":{"T":["1"]},"aq":{"ci":["1","2"]},"p":{"aM":[]},"b":{"aM":[]},"l":{"j":["1"],"i":["1"]},"k":{"fU":[]},"c0":{"w":[]},"ad":{"w":[]},"a9":{"w":[]},"aU":{"w":[]},"ca":{"w":[]},"bD":{"w":[]},"cB":{"w":[]},"aV":{"w":[]},"c6":{"w":[]},"cr":{"w":[]},"bw":{"w":[]},"cJ":{"a4":[]},"b7":{"G":[]},"b9":{"G":[]},"bb":{"G":[]},"bd":{"G":[]},"bv":{"G":[]},"bx":{"G":[]},"by":{"G":[]},"bz":{"G":[]},"bA":{"G":[]},"bB":{"G":[]},"d7":{"l":["b"],"j":["b"],"i":["b"]},"e7":{"l":["b"],"j":["b"],"i":["b"]},"e6":{"l":["b"],"j":["b"],"i":["b"]},"d5":{"l":["b"],"j":["b"],"i":["b"]},"e4":{"l":["b"],"j":["b"],"i":["b"]},"d6":{"l":["b"],"j":["b"],"i":["b"]},"e5":{"l":["b"],"j":["b"],"i":["b"]},"d_":{"l":["p"],"j":["p"],"i":["p"]},"d0":{"l":["p"],"j":["p"],"i":["p"]}}'))
A.j0(v.typeUniverse,JSON.parse('{"bV":2,"aR":1}'))
var u={c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type",f:"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAhGVYSWZNTQAqAAAACAAFARIAAwAAAAEAAQAAARoABQAAAAEAAABKARsABQAAAAEAAABSASgAAwAAAAEAAgAAh2kABAAAAAEAAABaAAAAAAAAAEgAAAABAAAASAAAAAEAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAIKADAAQAAAABAAAAIAAAAABfvA/wAAAACXBIWXMAAAsTAAALEwEAmpwYAAACyGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNi4wLjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgICAgICAgICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iPgogICAgICAgICA8dGlmZjpZUmVzb2x1dGlvbj43MjwvdGlmZjpZUmVzb2x1dGlvbj4KICAgICAgICAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+MjwvdGlmZjpSZXNvbHV0aW9uVW5pdD4KICAgICAgICAgPHRpZmY6WFJlc29sdXRpb24+NzI8L3RpZmY6WFJlc29sdXRpb24+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWERpbWVuc2lvbj41MDwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOkNvbG9yU3BhY2U+MTwvZXhpZjpDb2xvclNwYWNlPgogICAgICAgICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+NTA8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KZxgR6QAAB6lJREFUWAnlVmlsXFcZPfe9ecvsYzt2SihSk1SQBUWCqKUJSEkQyw+qSqXEKhKFssROLSTU0MQJAtUI0WYtKkJpYtqoqBJLDAXyB4kSakUlZSkCEtwQoRYqJXU2e+zxvHnztns5903sOBlH6o9KCHGleXPX7zvfud9ygf/3Jm5CgIDiil6d/W/1brJ9wem3Q8aCgudPaog3M2L+vpv22w8rJbB7oAJlGAhtBTsUCFWARw96VKUwNGQAowYeHU3SsRat2BvZbODV1XpdckZgaCAPWzhzMoSU2HlwCkJoTufafAC6TwEPVuDaJyDUOyHRgGE6sIwAnrcR3/jBa3Mn9z2Qzwb5ih6XnMLUxe37vbm1x7+wDLYzili5kEkAAzkocR7K3IBdT1W5r6WLnczcodmOk+VisgSm2QkTnem0lIOp8r4+C8vFRii5AgngZ2So1wM1bWf3PkQ9yVmvjBfRP/w6DvR/F4bYRzktyTEPKI/sXd/aAWCaG3MNwOyiokkk8b3Y+cwJ7N6ynuOPIjFPIxONdKNUtExVqFgWlIrrZ86Nz6CQXWcju8vcu/W4/9VD+7G77/fIGD+nwYu4qQHXuo5+DaUNUYrPJO3a/RPMKt9CCtchmD6QyVpTrlF80i26v+ypVH5V4e8dXYuPfWLN+568f9XaWnj6Fwf8RN7p7u3vw87hlxDLe6mcmgwHzUhTn4pO//lpBxAUAphGk0uD2Hn4BB7bsoW+0ISTPyhyHc/GGfN4T6nQ223ZK0UcL+4yrMXvLvesqJRLvaZj/ubT9ww+N/TetYebSeTNgTCM7bBMH5aiXLYWjBu76bj1GaITDR15Hfv619GR1iPAU8gbLxuuvUb6UXRnpVvcVu4ywjgQPbkibNNQkYxlV66opo3Eqk3X/r7cdj8wdPqVrdmM+Qd/x6HfYVbmPDW6e9VDbpgd/UuV4ZSBWXsQgfU95NWzcJ1Nqu43y5btCEijk3+3FMuiaLlCCIjufMlwbNv0/EbTzueWnPfqK0+/9MzXjZ73fCZZtvYkDjw9cYOWdNh+BWmccy07voEXNIZifAds61Oo+xFj2E3jh3dqCh7l1dJyFJ0s8vzpccYw3LjeiEzH+uT99+y4KwzD03kdObrNyk4HrU87gFVjVx1FrkIkTiJSfVowf0LTVZMJOqnMtR36l8Qlr4bxmUl4QRN2JoOsaSOKY6YdiZlm0IfEO0mGVrTUjbbpa7+Co2NAuZZl+L0fInmD1n8FUvYYUmkcwjZMLCt1IWfZCKIA9cAnC0x+ZMU2LW5VqPp1eGEomioxGD3PX46S23s+vmrM+9qxEN9sQZn9tiFKU6XvVchxyKsuMJl0IpEMBCUUre+2s5zOoBGFDBYLHXRCl4oNXkkjJKCwiZkwEF4QoCFlpysyBYk4nJFWmd6vuZwXAwtlwllokjVBN202f0Uzg9hQyLkuM5/Em14dJgEtrXSjSFAhWfB9D5ONGVQ1K2SkQfO8KGJEU4LOBQu0dgZ0McrmWTSk5Vhihrl8suQ4eFdHj7qtczHLgonppod/1qp4g1T/7cp5XKLSehzhvJ6bmUI9itS0jDAdBpMXkrDOYHMaRjSt/ahl0jUk7QBGeg1s+46vGQ8iFqNInqrT8su1qozjmDfEmKOkDEU1mN/HSfUEHbBGSyXB1QhkIgzkJFm60vBPBQhoBH1k+3NeWjGv6U577QB0SU2bOMMw/BAy5jD9Cpf8umrS6bR3K9J5a2URlhQruCVfhk9QV+gT434D50n/lShQlzmuy2gYifVB3uE/UpFzslsa9LcdQKueA0snR3lwJWT4ZxWGP3E6ylYpV2henKmiQYuTpPUcsDMm7z9OPf/s1GWm+7DpOaaVNPyfwpv4I+laDf/WF1OVs7Kv6V8AgF781ueWo3eEGtSvyetWjFc/Hzb8v/47nHEbcRyVcsV4oj4tz05cUOeql9WFqQn5WvVSzKQUiULOhd88BWvys3A6+hkqLzABxanMeYpnu/PzQMvrH3kgj47CK/jYHQ52HP4xPrJ2BfLualyobgtt83bpWGtCFRuTUUBnEKIpE+FDCuU6hiAdvKcRZCbvRljezPiJMTh8DPsHdjCfHML6pcMYfVW/IVq62Gm/gq6CzSRkM/4ex7f7NmHX94+k+3rKX16EeIv0401TtdoPlRBjTH3jwrHGRSYzhiD4kWqGH4YKv4ioY4BPOhu7hp9mNd0AyD2IKTPIssyzXfUy3V34QSJzLMkkxzJ+RhD3UdAR7PnSXVeU+TCFncllzUca9YTPrKSkXIZIIuuQpoeMpMNxjxAvYPDwy9hL5Yb5fGqw5Luy++qDZM7+BQGUuZ/CNUxDdMAxf4snBnZh28HdOLr5T/hX58ZGqO6DTfaUGSBh3lAsABkmS5hn0Dj7GIZGYxx4aJAidmsrW9lM5NDkA/eG1s6AYN6FOsdKo7NXgynZoVUDdKIR9KaP0uOUcRxPPJyFTtn6OnXi0rljtunaDwwwZi+SnYCM5LjtTYg8ZV/f2hBRqcCe/hKtMuD6Ck0+UgO+bIeG+U5k0yVVV8zNRyUFt25Tn9EJ7NqznPv6cmTPmZOhDRs8XJs7cz2O/96onYEWloXm5/nuWwL8dsh4S4r+tzf9Bwpfgk0+0buPAAAAAElFTkSuQmCC"}
var t=(function rtii(){var s=A.aJ
return{n:s("N"),B:s("c2"),Y:s("f3"),V:s("j<@>"),C:s("w"),E:s("d_"),W:s("d0"),Z:s("az"),d:s("d5"),k:s("d6"),t:s("d7"),R:s("i<@>"),w:s("am"),O:s("n<e>"),I:s("n<y>"),f:s("n<c>"),s:s("n<k>"),bx:s("n<A>"),b:s("n<@>"),c:s("n<c?>"),D:s("E"),G:s("U"),cA:s("K"),T:s("bh"),m:s("e"),cP:s("an"),c9:s("ao"),g:s("y"),da:s("Q<@>"),e:s("x"),cx:s("l<e>"),u:s("l<y>"),a:s("l<k>"),j:s("l<@>"),P:s("z"),K:s("c"),p:s("cs"),q:s("as<c>"),L:s("kb"),cD:s("+()"),l:s("a4"),N:s("k"),bW:s("r"),b7:s("ad"),c0:s("e4"),bk:s("e5"),ca:s("e6"),bX:s("e7"),cr:s("bC"),d5:s("G"),x:s("af<e>"),h:s("af<~>"),aX:s("m<e>"),_:s("m<@>"),U:s("m<~>"),J:s("aY<c?,c?>"),b5:s("bP<~>"),y:s("A"),bG:s("A(c)"),i:s("p"),z:s("@"),bd:s("@()"),v:s("@(c)"),Q:s("@(c,a4)"),S:s("b"),bc:s("J<z>?"),r:s("n<c?>?"),A:s("e?"),X:s("c?"),aD:s("k?"),F:s("ag<@,@>?"),cG:s("A?"),dd:s("p?"),a3:s("b?"),ae:s("aM?"),o:s("aM"),H:s("~"),M:s("~()")}})();(function constants(){var s=hunkHelpers.makeConstList
B.X=J.cb.prototype
B.a=J.n.prototype
B.f=J.bg.prototype
B.l=J.aO.prototype
B.a0=J.y.prototype
B.a1=J.x.prototype
B.a7=A.bp.prototype
B.P=J.cv.prototype
B.H=J.bC.prototype
B.I=new A.c9()
B.J=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.Q=function() {
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
B.V=function(getTagFallback) {
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
B.R=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.U=function(hooks) {
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
B.T=function(hooks) {
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
B.S=function(hooks) {
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
B.K=function(hooks) { return hooks; }

B.W=new A.cr()
B.n=new A.dO()
B.e=new A.cH()
B.o=new A.cJ()
B.p=new A.am("Rejected","rejected")
B.u=new A.E("Aptos","aptos")
B.v=new A.E("Bitcoin","bitcoin")
B.w=new A.E("Cosmos","cosmos")
B.x=new A.E("Ethereum","ethereum")
B.y=new A.E("Solana","solana")
B.z=new A.E("Stellar","stellar")
B.A=new A.E("Substrate","substrate")
B.B=new A.E("Sui","sui")
B.C=new A.E("TON","ton")
B.D=new A.E("Tron","tron")
B.b=new A.U("accountsChanged")
B.c=new A.U("chainChanged")
B.q=new A.U("message")
B.i=new A.U("connect")
B.k=new A.U("disconnect")
B.d=new A.U("change")
B.E=new A.K("networkAccountsChanged")
B.L=new A.K("change")
B.r=new A.K("defaultChainChanged")
B.t=new A.K("defaultAccountChanged")
B.F=new A.K("message")
B.M=new A.an("response")
B.N=new A.ao("success")
B.G=new A.ao("failed")
B.O=A.a(s([B.b,B.c,B.q,B.i,B.k,B.d]),A.aJ("n<U>"))
B.a_=new A.an("event")
B.a2=A.a(s([B.M,B.a_]),A.aJ("n<an>"))
B.Z=new A.E("","global")
B.a3=A.a(s([B.Z,B.x,B.D,B.y,B.C,B.z,B.A,B.u,B.B,B.v,B.w]),A.aJ("n<E>"))
B.a4=A.a(s([B.E,B.L,B.r,B.t,B.F]),A.aJ("n<K>"))
B.Y=new A.am("Approved","approved")
B.a5=A.a(s([B.Y,B.p]),A.aJ("n<am>"))
B.a6=A.a(s([B.N,B.G]),A.aJ("n<ao>"))
B.m=new A.cu("walletStandard")
B.h=new A.cu("eip1993")
B.a8=A.a1("c2")
B.a9=A.a1("f3")
B.aa=A.a1("d_")
B.ab=A.a1("d0")
B.ac=A.a1("d5")
B.ad=A.a1("d6")
B.ae=A.a1("d7")
B.af=A.a1("c")
B.ag=A.a1("e4")
B.ah=A.a1("e5")
B.ai=A.a1("e6")
B.aj=A.a1("e7")
B.j=new A.bE("An error occurred during the request",-32603)})();(function staticFields(){$.ey=null
$.S=A.a([],t.f)
$.fV=null
$.fE=null
$.fD=null
$.hz=null
$.hv=null
$.hD=null
$.eO=null
$.eT=null
$.fu=null
$.kq=A.a([],A.aJ("n<l<c>?>"))
$.b_=null
$.bW=null
$.bX=null
$.fo=!1
$.o=B.e})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal
s($,"k7","b4",()=>A.jV("_$dart_dartClosure"))
s($,"kf","hJ",()=>A.ae(A.e1({
toString:function(){return"$receiver$"}})))
s($,"kg","hK",()=>A.ae(A.e1({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"kh","hL",()=>A.ae(A.e1(null)))
s($,"ki","hM",()=>A.ae(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kl","hP",()=>A.ae(A.e1(void 0)))
s($,"km","hQ",()=>A.ae(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kk","hO",()=>A.ae(A.h2(null)))
s($,"kj","hN",()=>A.ae(function(){try{null.$method$}catch(r){return r.message}}()))
s($,"ko","hS",()=>A.ae(A.h2(void 0)))
s($,"kn","hR",()=>A.ae(function(){try{(void 0).$method$}catch(r){return r.message}}()))
s($,"kp","fA",()=>A.iK())
s($,"kr","f_",()=>A.eX(B.af))
s($,"ks","hT",()=>Symbol("jsBoxedDartObjectProperty"))
s($,"ka","hG",()=>{var r=new A.ex(new DataView(new ArrayBuffer(8)))
r.bE()
return r})
s($,"k9","fz",()=>({message:"this feature disabled by wallet provider."}))
s($,"k8","hF",()=>({uuid:"466aef37-e077-42d1-b26b-801ff1af4a36",name:"OnChain",icon:u.f,rdns:"com.mrtnetwork.wallet"}))
s($,"kc","hH",()=>A.iq(A.a(["legacy",0],t.f),t.K))
s($,"ke","hI",()=>({message:"Invalid Sui transaction. The transaction must include transactionBlock with the blockData property for v1, or transaction with the toJSON property for v2."}))})();(function nativeSupport(){!function(){var s=function(a){var m={}
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
hunkHelpers.setOrUpdateInterceptorsByTag({ArrayBuffer:A.bo,ArrayBufferView:A.bs,DataView:A.bp,Float32Array:A.cj,Float64Array:A.ck,Int16Array:A.cl,Int32Array:A.cm,Int8Array:A.cn,Uint16Array:A.co,Uint32Array:A.cp,Uint8ClampedArray:A.bt,CanvasPixelArray:A.bt,Uint8Array:A.cq})
hunkHelpers.setOrUpdateLeafTags({ArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.aR.$nativeSuperclassTag="ArrayBufferView"
A.bK.$nativeSuperclassTag="ArrayBufferView"
A.bL.$nativeSuperclassTag="ArrayBufferView"
A.bq.$nativeSuperclassTag="ArrayBufferView"
A.bM.$nativeSuperclassTag="ArrayBufferView"
A.bN.$nativeSuperclassTag="ArrayBufferView"
A.br.$nativeSuperclassTag="ArrayBufferView"})()
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
var s=function(b){return A.fx(A.jQ(b))}
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()