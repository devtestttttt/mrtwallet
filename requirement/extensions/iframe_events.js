window.addEventListener('message', function (e) {
    console.log("iframe message " + JSON.stringify(e))
    console.log("iframe message " +JSON.stringify(e.data))
    console.log("iframe message " +e.message)
    if(e.data===undefined)return
    if(e.data && e.data.source =="wallet" && e.data.message=="close_iframe"){
        this.window.close()
        console.log("close called!");
    }
});