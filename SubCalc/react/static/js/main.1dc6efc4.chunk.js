(window.webpackJsonp=window.webpackJsonp||[]).push([[0],{25:function(e,t,n){e.exports=n(60)},52:function(e,t,n){},58:function(e,t,n){},60:function(e,t,n){"use strict";n.r(t);var a,r=n(0),o=n(12),i=n(24),s=n(4),u=n(6),c=n(9),l=n(8),d=n(10),m=n(3),h=n(1),p=n(20),g=n(21);n(46),n(48),n(50),n(52);function f(e){if(b()){for(var t,n=arguments.length,a=new Array(n>1?n-1:0),r=1;r<n;r++)a[r-1]=arguments[r];(t=console).log.apply(t,[e].concat(a))}}function v(e){a?a(e.message):alert(e.message);for(var t=arguments.length,n=new Array(t>1?t-1:0),r=1;r<t;r++)n[r-1]=arguments[r];f.apply(void 0,[e].concat(n))}function b(){return"yes"===w("debug")}function w(e){for(var t=window.location.search.substring(1).split("&"),n=0;n<t.length;n++){var a=t[n].split("=");if(decodeURIComponent(a[0])==e)return decodeURIComponent(a[1])}}function y(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"";return void 0==e?t:e}function S(){return Math.floor(1e6*Math.random())}String.prototype.trim=function(){for(var e=this.replace(/^\s+/,""),t=e.length-1;t>=0;t--)if(/\S/.test(e.charAt(t))){e=e.substring(0,t+1);break}return e},String.prototype.hashCode=function(){var e=0;if(0===this.length)return e;for(var t=0;t<this.length;t++){e=(e<<5)-e+this.charCodeAt(t),e|=0}return e},String.prototype.toDate=function(){return new Date(String(this))},Number.prototype.toCommaString=function(){return this.toString().replace(/\B(?=(\d{3})+(?!\d))/g,",")},Number.prototype.singularPlural=function(e,t){return"".concat(this," ").concat(1==this?e:t)},Number.prototype.comparisonValue=function(){return this<0?-1:this>0?1:0},Array.prototype.pushUnique=function(e){return-1===this.indexOf(e)&&this.push(e),this},Array.prototype.max=function(){return this.reduce(function(e,t){return Math.max(e,t)})},Date.prototype.toTimestampString=function(){return this.toJSON()};var E,C,N=n(11),k=function e(t,n){var a=this;Object(s.a)(this,e),this.id=void 0,this.name=void 0,this.count=void 0,this.delegates=void 0,this.toJSON=function(){return{name:a.name,count:a.count}},void 0===n&&(n={}),this.id=t,this.name=n.name?String(n.name):"",this.count=n.count?Number(n.count):0,this.delegates=n.delegates?Number(n.delegates):0},D=function(){function e(){var t=this;Object(s.a)(this,e),this.version=2,this.author=0,this.currentMeetingKey="",this.meetings=new m.TSMap,this.meetingPrefix="sc-meeting",this.meetingKey=function(e,n){return n=n||t.author,"".concat(e," ").concat(n)},this.newMeeting=function(){var e=(new Date).toTimestampString();t.currentMeetingKey=t.meetingKey(e);var n=t.emptyMeetingSnapshot(e);return t.meetings.set(t.currentMeetingKey,{key:t.currentMeetingKey,author:t.author,created:e,current:n,snapshots:new m.TSMap}),t.writeMeetingSnapshot(n),n},this.emptyMeetingSnapshot=function(e){void 0===e&&(e=(new Date).toTimestampString());var t=1,n=new m.TSMap;return n.set(t,new k(t++)),n.set(t,new k(t++)),n.set(t,new k(t++)),{created:e,revised:"",revision:"",name:"",allowed:0,seed:S(),currentSubcaucusID:t,subcaucuses:n}},this.writeMeeting=function(e){var n={v:t.version,author:t.author,current:e.key};try{var a=JSON.stringify(n);f("storing subcalc2",a),localStorage.setItem("subcalc2",a)}catch(s){return void v(new Error("Failed to save subcalc2 to local storage"),s)}var r={v:t.version,created:e.created,author:e.author,current:t.meetingSnapshotToJSON(e.current),snapshots:e.snapshots.map(function(e){return t.meetingSnapshotToJSON(e)})},o="".concat(t.meetingPrefix," ").concat(e.key);try{var i=JSON.stringify(r);f("storing ".concat(o),i),localStorage.setItem("".concat(o),i)}catch(s){return void v(new Error("Error saving ".concat(o," to local storage")),s)}},this.meetingSnapshotToJSON=function(e){return Object(N.a)({},e,{created:void 0,currentSubcaucusID:void 0})},this.importSubCalc1Data=function(){},this.importSubCalc2Data=function(){var e=JSON.parse(localStorage.getItem("subcalc2")||"false");if(e)if(t.author=Number(e.author)||0,t.author){t.currentMeetingKey=String(e.current)||"";var n=localStorage.length;t.meetings=new m.TSMap;for(var a=0;a<n;a++){var r=localStorage.key(a);if(!r)break;if(r.startsWith(t.meetingPrefix)){var o=t.getMeetingFromLocalStorage(r);o&&t.meetings.set(o.key,o)}}}else f(new Error("No author in subcalc2"),e)},this.getMeetingFromLocalStorage=function(e){var n;e=e||"".concat(t.meetingPrefix," ").concat(t.currentMeetingKey);try{n=JSON.parse(localStorage.getItem(e)||"false")}catch(s){return void f(s)}if(n){var a=Number(n.author),r=String(n.created);if(a&&r){var o=t.jsonToMeetingSnapshot(n.current,r);if(o){if(Array.isArray(n.snapshots)){var i=new m.TSMap;return n.snapshots.forEach(function(e){var n=t.jsonToMeetingSnapshot(e,r);n&&i.set(n.revised,n)}),{key:t.meetingKey(r,a),author:a,created:r,current:o,snapshots:i}}f(new Error('No "snapshots" array in '.concat(e)),n)}else f(new Error("Could not find current snapshot in ".concat(e)),n)}else f(new Error("Missing author or created in ".concat(e)),n)}else f(new Error("Could not retreive ".concat(e)))},this.jsonToMeetingSnapshot=function(e,n){var a=String(e.revised||""),r=String(e.revision||""),o=String(e.name||""),i=Number(e.allowed||0),s=Number(e.seed);if(s){var u=e.subcaucuses;if("object"==typeof u){var c=0,l=new m.TSMap;return Object.keys(u).forEach(function(e){e=Number(e);var n=t.jsonToSubcaucus(u[e],e);n&&(c=Math.max(c,e),l.set(e,n))}),f("currentSubcaucusID",++c),{created:n,revised:a,revision:r,name:o,allowed:i,seed:s,currentSubcaucusID:c,subcaucuses:l}}f(new Error("Non-object subcaucuses"),e)}else f(new Error("Seed missing in snapshot"),e)},this.jsonToSubcaucus=function(e,t){if("object"==typeof e)return new k(t,{name:e.name,count:e.count});f(new Error("Non-object subcaucus ".concat(t)),e)},this.getSnapshot=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"",n=arguments.length>1?arguments[1]:void 0,a=t.currentMeetingKey,r=t.meetings;if(""===e){if(!a)return void v(new Error("No current meeting data"));e=a}var o=r[e];if(void 0!==o){if(void 0===n)return t.currentMeetingKey=e,o.current;var i=o.snapshots[n];if(void 0!==i)return t.currentMeetingKey=e,i;v(new Error("No data for meeting ".concat(a," snapshot ").concat(n)))}else v(new Error("No data for meeting ".concat(e)))},this.importSubCalc2Data(),this.author||(this.importSubCalc1Data(),this.author||(this.author=S(),this.newMeeting()))}return Object(u.a)(e,[{key:"writeMeetingSnapshot",value:function(e){var t=this.meetingKey(e.created),n=""==e.revision,a=this.meetings.get(t);a?(n?this.meetings.get(t).current=e:this.meetings.get(t).snapshots[e.revised]=e,this.writeMeeting(a)):v(new Error("Meeting not found for ".concat(t)))}}]),e}(),O=n(13),T=n(22),M=function(e){function t(e){var n;Object(s.a)(this,t),(n=Object(c.a)(this,Object(l.a)(t).call(this,e))).handleName=function(){return function(e){var t=e.currentTarget.value;n.setState({name:t}),n.props.exchange(n.props.id,Object(N.a)({},n.state,{name:t}))}},n.handleCount=function(){return function(e){var t=Number(e.currentTarget.value);t<0&&(t=0),n.setState({count:t})}},n.notify=function(){return function(e){n.props.exchange(n.props.id,Object(N.a)({},n.state))}},n.handleKey=function(){return function(e){"Enter"!==e.key&&"Tab"!==e.key||n.props.exchange(n.props.id,"enter")}},n.focusOnWholeText=function(){return function(e){var t=e.currentTarget;setTimeout(function(){return t.setSelectionRange(0,9999)},0)}},n.idPlus=function(e){return"subcaucus-".concat(n.props.id,"-").concat(e)},n.state={name:"",count:0,delegates:0};var a=n.props.exchange(n.props.id,"sync");return a&&(n.state={name:a.name,count:a.count,delegates:a.delegates}),n}return Object(d.a)(t,e),Object(u.a)(t,[{key:"render",value:function(){f("render row",this.props.id,this.state);var e=this.state,t=e.name,n=e.count,a=e.delegates;return r.createElement("div",{id:this.idPlus("row"),className:"subcaucus-row ".concat(a>0?"has-delegates":n>0?"no-delegates":"")},b?r.createElement("div",{className:"subcaucus-id"},this.props.id):"",r.createElement(T.InputTextarea,{id:this.idPlus("row-name"),className:"subcaucus-field subcaucus-name",autoComplete:"off",type:"text",value:t,rows:1,cols:1,placeholder:"Subcaucus ".concat(this.props.id),onChange:this.handleName(),onKeyUp:this.handleKey()}),r.createElement(O.InputText,{id:this.idPlus("row-count"),className:"subcaucus-field subcaucus-count",autoComplete:"off",keyfilter:"pint",type:"text",pattern:"\\d*",value:n||"",placeholder:"\u2014",onChange:this.handleCount(),onBlur:this.notify(),onKeyUp:this.handleKey()}),r.createElement(h.Button,{id:this.idPlus("row-delegates"),className:"subcaucus-delegates-button ".concat(a>0?"p-button-success":"p-button-secondary"),label:a?"".concat(a):void 0,icon:a?void 0:n?"pi pi-ban":"pi"}))}}]),t}(r.Component),A=n(23),x=function(e){function t(e){var n;Object(s.a)(this,t),(n=Object(c.a)(this,Object(l.a)(t).call(this,e))).isPositiveInteger=!1,n.originalValue=function(){return y(n.props.value)},n.defaultValue=function(){return y(n.props.defaultValue)},n.handleChange=function(){return function(e){if(f("change",e.currentTarget.value),n.isPositiveInteger){var t=Number(e.currentTarget.value);t<0&&(t=0),n.setState({value:String(t)})}else n.setState({value:e.currentTarget.value})}},n.handleKey=function(){return function(e){"Enter"===e.key&&n.props.onSave&&n.props.onSave(n.state.value.trim())}},n.focusOnWholeText=function(){return function(e){var t=e.currentTarget;setTimeout(function(){return t.setSelectionRange(0,9999)},0)}},n.isEmpty=function(e){var t=""===e||void 0===e;return n.isPositiveInteger&&(t=t||"0"===e),t},n.save=function(e){return function(t){n.props.onSave&&(void 0===e?n.props.onSave():n.isEmpty(e)&&!n.props.allowEmpty?n.isEmpty(n.props.defaultValue)||n.props.onSave(n.props.defaultValue):n.props.onSave(e.trim()))}},n.idPlus=function(e){return n.props.id?"".concat(n.props.id,"-").concat(e):void 0},n.isPositiveInteger="positive integer"===n.props.type;var a=y(n.props.value);return!n.props.allowEmpty&&n.isEmpty(a)&&(a=y(n.props.defaultValue)),n.state={value:a},n}return Object(d.a)(t,e),Object(u.a)(t,[{key:"render",value:function(){var e=this.state.value,t=this.isPositiveInteger,n=r.createElement(r.Fragment,null);if(void 0==this.props.footer){var a=this.isEmpty(e)&&this.isEmpty(this.defaultValue())&&!1===this.props.allowEmpty,o=this.isEmpty(this.originalValue())&&!1===this.props.allowEmpty,i=this.props.onSave?void 0!=this.props.value?r.createElement(h.Button,{id:this.idPlus("save-button"),label:"Save",icon:"pi pi-check",disabled:a,onClick:this.save(y(e,this.defaultValue()))}):r.createElement(h.Button,{id:this.idPlus("close-button"),label:"Close",icon:"pi pi-times",onClick:this.save()}):r.createElement(r.Fragment,null),s=o||void 0===this.props.value?"":r.createElement(h.Button,{id:this.idPlus("cancel-button"),label:"Cancel",icon:"pi pi-times",className:"p-button-secondary",onClick:this.save()});n=r.createElement(r.Fragment,null,i,this.props.extraButtons,s)}else n=this.props.footer;return r.createElement("div",{className:"valuecard-wrapper"},r.createElement("div",{className:"background-blocker"}),r.createElement(A.Card,{id:this.idPlus("valuecard"),className:"valuecard ".concat(this.idPlus("valuecard")),title:this.props.title,header:this.props.image?r.createElement("div",{id:this.idPlus("picture-container"),className:"picture-container"},r.createElement("img",{alt:"".concat(this.props.alt),src:"".concat(this.props.image)}),this.props.onSave?r.createElement(r.Fragment,null):r.createElement(h.Button,{id:this.idPlus("picture-close-button"),icon:"pi pi-times",onClick:this.save()})):void 0,footer:n},this.props.children?r.createElement("div",{id:this.idPlus("valuecard-children"),className:"valuecard-children"},this.props.children):"",this.props.description?r.createElement("div",{id:this.idPlus("valuecard-description"),className:"valuecard-description"},r.createElement("p",null,this.props.description)):"",void 0!=this.props.value?r.createElement(O.InputText,{id:this.idPlus("card-field"),className:t?"number":"text",autoComplete:"off",keyfilter:t?"pint":"",type:"text",pattern:t?"\\d*":void 0,value:t&&"0"===e?"":e,placeholder:this.props.defaultValue,onChange:this.handleChange(),onKeyUp:this.handleKey(),autoFocus:!0}):""))}}]),t}(r.Component);!function(e){e[e.Descending=-1]="Descending",e[e.None=0]="None",e[e.Ascending=1]="Ascending"}(E||(E={})),function(e){e[e.WelcomeAndSetName=0]="WelcomeAndSetName",e[e.ChangingName=1]="ChangingName",e[e.ChangingDelegates=2]="ChangingDelegates",e[e.RemovingEmpties=3]="RemovingEmpties",e[e.ShowingAbout=4]="ShowingAbout",e[e.ShowingBy=5]="ShowingBy",e[e.ShowingInstructions=6]="ShowingInstructions",e[e.ShowingSecurity=7]="ShowingSecurity"}(C||(C={}));var j=function(e){function t(e){var n,o;Object(s.a)(this,t),(n=Object(c.a)(this,Object(l.a)(t).call(this,e))).storage=new D,n.subcaucuses=new m.TSMap,n.subcaucusesChanged=!1,n.snapshotRevised="",n.revised="",n.currentSubcaucusID=1,n.keySuffix=String(Math.random()),n.initialCardState=[C.WelcomeAndSetName,C.ChangingDelegates,C.ShowingInstructions],n.growl=null,n.refreshAppFromSnapshot=function(e){return n.keySuffix=String(Math.random()),n.subcaucuses=e.subcaucuses,n.snapshotRevised=e.revised,n.revised=e.revised,n.currentSubcaucusID=e.currentSubcaucusID,n.stateFromSnapshot(e)},n.stateFromSnapshot=function(e){var t=e.allowed;return{created:e.created,snapshot:e.revision,name:e.name,allowed:t,seed:e.seed,cards:t?[]:n.initialCardState,sortName:E.None,sortCount:E.None,summary:void 0}},n.snapshotFromState=function(){return{created:n.state.created,revised:n.revised,revision:n.state.snapshot,name:n.state.name,allowed:n.state.allowed,seed:n.state.seed,currentSubcaucusID:n.currentSubcaucusID,subcaucuses:n.subcaucuses}},n.componentDidUpdate=function(e,t){(n.subcaucusesChanged||n.state.name!=t.name||n.state.allowed!=t.allowed||n.state.seed!=t.seed)&&(n.revised=(new Date).toTimestampString(),n.subcaucusesChanged=!1,n.storage.writeMeetingSnapshot(n.snapshotFromState()))},n.newMeeting=function(){var e=n.storage.newMeeting();n.setState(n.refreshAppFromSnapshot(e))},n.nextSubcaucusID=function(){return n.currentSubcaucusID++},n.addSubcaucus=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"",t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0,a=arguments.length>2&&void 0!==arguments[2]?arguments[2]:0,r=new k(n.nextSubcaucusID(),{name:e,count:t,delegates:a});n.subcaucuses.set(r.id,r),n.state&&n.forceSubcaucusesUpdate()},n.defaultName=function(){return"Meeting on "+n.state.created.toDate().toLocaleDateString("en-US")},n.allowedString=function(){return"".concat(n.state.allowed," delegates to be elected")},n.addCard=function(e,t){return void 0===t&&(t=n.state.cards),[].concat(Object(i.a)(t),[e])},n.addCardState=function(e){n.setState({cards:n.addCard(e)})},n.removeCard=function(e,t){return void 0===t&&(t=n.state.cards),t.filter(function(t){return t!=e})},n.removeCardState=function(e){n.setState({cards:n.removeCard(e)})},n.switchCardState=function(e,t){var a=n.removeCard(e);a=n.addCard(t,a),n.setState({cards:a})},n.showingCard=function(e){return n.state.cards.indexOf(e)>-1},n.handleChange=function(e){return function(t){switch(e){case"allowed":var a=Number(t.currentTarget.value);a<0&&(a=0),n.setState({allowed:a});break;case"name":n.setState({name:t.currentTarget.value})}}},n.focusOnWholeText=function(){return function(e){var t=e.currentTarget;setTimeout(function(){return t.setSelectionRange(0,9999)},0)}},n.forceSubcaucusesUpdate=function(){n.subcaucusesChanged=!0,n.revised=(new Date).toTimestampString(),n.forceUpdate()},n.handleSubcaucusChange=function(e,t){switch(f("subcaucus changed",e,t),t){case"remove":return n.subcaucuses.filter(function(t,n){return n!=e}),void n.forceSubcaucusesUpdate();case"enter":return;case"sync":return n.subcaucuses.get(e);default:var a=n.subcaucuses.get(e);return void(a.name==t.name&&a.count==t.count||(a.name=t.name,a.count=t.count,n.forceSubcaucusesUpdate()))}},n.removeEmpties=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"all";"all"==e&&n.subcaucuses.filter(function(e,t){return e.count>0}),"unnamed"==e&&n.subcaucuses.filter(function(e,t,n){return f("remove?",e.id,e.count,e.name,e.count>0||""!=e.name,"key",t,"index",n),e.count>0||""!=e.name}),n.removeCardState(C.RemovingEmpties)},n.sortOrderIcon=function(e){return["pi pi-chevron-circle-down","pi pi-circle-off","pi pi-chevron-circle-up"][e+1]},n.nextSortOrder=function(e){var t=(e+(arguments.length>1&&void 0!==arguments[1]?arguments[1]:1)+1)%3;return t<0&&(t+=3),t-1},n.renderMenu=function(){var e=[{label:"About",icon:"pi pi-fw pi-info-circle",items:[{label:"Minnesota DFL Subcaucus Calculator",command:function(){return n.addCardState(C.ShowingAbout)}},{label:"Instructions",command:function(){return n.addCardState(C.ShowingInstructions)}},{label:"Data Security",command:function(){return n.addCardState(C.ShowingSecurity)}}]},{label:"Meetings",icon:"pi pi-fw pi-calendar",items:[{label:"Save snapshot",icon:"pi pi-fw pi-clock",command:function(){return n.growlAlert("Save snapshot.","warn","TODO")}},{label:"New meeting",icon:"pi pi-fw pi-calendar-plus",command:function(){return n.newMeeting()}},{label:"Duplicate meeting",icon:"pi pi-fw pi-clone",command:function(){return n.growlAlert("Duplicate meeting.","warn","TODO")}},{label:"Load meeting",icon:"pi pi-fw pi-folder-open",command:function(){return n.growlAlert("Load meeting.","warn","TODO")}},{label:"Flip the coin",icon:"pi pi-fw pi-refresh",command:function(){return n.growlAlert("Coin flip.","warn","TODO")}}]},{label:"Share",icon:"pi pi-fw pi-share-alt",items:[{label:"Email report",icon:"pi pi-fw pi-envelope",command:function(){return n.growlAlert("Email report.","warn","TODO")}},{label:"Download text",icon:"pi pi-fw pi-align-left",command:function(){return n.growlAlert("Download text.","warn","TODO")}},{label:"Download CSV",icon:"pi pi-fw pi-table",command:function(){return n.growlAlert("Download csv.","warn","TODO")}},{label:"Download code",icon:"pi pi-fw pi-save",command:function(){return n.growlAlert("Download code.","warn","TODO")}}]}];return r.createElement(p.Menubar,{model:e,id:"app-main-menu"})},n.renderAbout=function(){return r.createElement(x,{key:"about-card",id:"about-card",title:"Minnesota DFL Subcaucus Calculator",image:"dfl.jpg",onSave:function(){return n.removeCardState(C.ShowingAbout)},extraButtons:r.createElement(h.Button,{id:"show-credits-button",label:"Credits",icon:"pi pi-user",className:"p-button-secondary",onClick:function(){return n.switchCardState(C.ShowingAbout,C.ShowingBy)}})},r.createElement("p",null,"Originally written for ",r.createElement("a",{href:"http://sd64dfl.org"},"SD64 DFL"),", this app assists convenors of precinct caucuses and conventions in Minnesota. The Minnesota Democratic Farmer Labor (DFL) party uses a wonderful, but bit arcane, \u201cwalking subcaucus\u201d process that is simple enough to do, but rather difficult to tabulate."),r.createElement("p",null,"Given the number of delegates your meeting or caucus is allowed to send forward and the number of people in each subcaucus, this calculator determines how many of those delegates each subcaucus will elect. The rules it follows appeared on page 4 of the ",r.createElement("a",{href:"http://www.sd64dfl.org/more/caucus2014printing/2014-Official-Call.pdf"},"DFL 2014 Official Call"),", including the proper treatment of remainders. It makes the math involved in a walking subcaucus disappear."),r.createElement("p",null,"The app could be used to facilitate a \u201cwalking subcaucus\u201d or \u201c",r.createElement("a",{href:"https://en.wikipedia.org/wiki/Proportional_representation"},"proportional representation"),"\u201d system for any group."))},n.renderInstructions=function(){return r.createElement(x,{key:"instructions-card",id:"instructions-card",title:"Fill in the subcaucuses",image:"walking.jpg",onSave:function(){return n.removeCardState(C.ShowingInstructions)}},r.createElement("p",null,"Now it is time to fill in the subcaucus information. Just add each subcaucus name and the count of participants. Usually a convention or cacucus will solicit the names of subcaucuses first, feel free to enter them right away without a count. Then people will be encouraged to walk around the room and congregate with the subcaucus that most closely represents their views. When each subcacus reports how many people they attracted, you can enter that as the count for that subcaucus."),r.createElement("p",null,"As soon as you start entering subcaucus counts, the calculator will go to work determining how many delegates each subcaucus will be assigned. You can ignore those numbers until you have finished entering and confirming all the subcaucus counts. When you are done, the delegate numbers can be reported to the chair of your convention or caucus."),r.createElement("p",null,'Since most conventions or caucuses will go through more than one round of "walking", you can just keep reusing your subcaucus list for each round. However, you might want to consider these steps at the end of each round:'),r.createElement("ul",null,r.createElement("li",null,'Use the "Meetings" menu at the top to save a snapshot after each round of caucusing. This will give you a good record of the whole process.'),r.createElement("li",null,'Use the "Share" menu to email a report about each round to the chair of the meeting just so they also have a clear record of the process.')),r.createElement("p",null,'You can always get these instructions back under the "About" menu at the top. Have fun!'))},n.renderSecurity=function(){return r.createElement(x,{key:"security-card",id:"security-card",title:"Data security",image:"security.jpg",extraButtons:r.createElement(h.Button,{id:"clear-data -button",label:"Clear All Data",icon:"pi pi-exclamation-triangle",className:"p-button-danger",onClick:function(){return n.growlAlert("Clear data.","warn","TODO")}}),onSave:function(){return n.removeCardState(C.ShowingSecurity)}},r.createElement("p",null,'The subcaucus calculator stores all of the data you enter on your own device. It uses a feature of web browsers called "local storage" to save all your meeting information within your web browser. None of your data gets off your device unless you choose to share it.'),r.createElement("p",null,"Do note that this app is running on a web server, though, and that server will keep all the logs typical of web servers. This includes logs of your IP address and the documents you retrieve from the server. None of these logs will include your specific meeting information."),r.createElement("p",null,'One thing to be aware of is that anyone using this same browser on this same device will be able to see your meeting information, including saved snapshots and past meetings, when they come to this web site. If this is a public device and you want to clear out all the data the calculator has stored, click the "Clear All Data" button.'),r.createElement("p",null,"Since the data is stored with your browser on this device, also be aware that you will not be able to see your meeting information from any other browser. This means that even you won't be able to get at this data unless you use the sharing features.")," ",r.createElement("p",null,'You can use the "Share" menu to get data off your device when you need to do so. Once you share your meeting information this calculator is no longer in control of that data. Make good choices about sharing.'),r.createElement("p",null,"The good news is that there really isn't any private information in the calculator in the first place. Most meetings that use the walking subcacus process are public meetings and the data you store in this calculator is not sensitive. Still, we thought you'd like to know we treat it as ",r.createElement("em",null,"your")," data and do not share it unless you ask us to."))},n.renderBy=function(){return r.createElement(x,{key:"by-card",id:"by-card",title:"Brought to you by Tenseg LLC",image:"tenseg.jpg",onSave:function(){return n.removeCardState(C.ShowingBy)}},r.createElement("p",null,"We love the walking subcaucus process and it makes us a bit sad that the squirrelly math required to calculate who gets how many delegate discourages meetings and caucuses from using the process. We hope this calculator makes it easier for you to get to know your neighbors as you work together to change the world!"),r.createElement("p",null,"Please check us out at ",r.createElement("a",{href:"https://tenseg.net"},"tenseg.net")," if you need help building a website or making appropriate use of technology."))},n.renderWelcomeAndSetName=function(){return r.createElement(x,{key:"welcome-card",id:"welcome-card",title:"Welcome to the Minnesota DFL Subcacus Calculator",image:"dfl.jpg",description:'Please start by specifying the name of your meeting here. Most meetings have a name, like the "Ward 4 Precinct 7 Caucus" or the "Saint Paul City Convention".',value:n.state.name,defaultValue:n.defaultName(),allowEmpty:!1,onSave:function(e){void 0==e?n.removeCardState(C.WelcomeAndSetName):n.setState({name:e,cards:n.removeCard(C.WelcomeAndSetName)})}})},n.renderChangingName=function(){return r.createElement(x,{key:"name-value",id:"name-value",title:"Meeting name?",value:n.state.name,defaultValue:n.defaultName(),allowEmpty:!1,extraButtons:n.state.name?r.createElement(h.Button,{id:"new-meeting-button",label:"New meeting",icon:"pi pi-calendar-plus",className:"p-button-secondary",onClick:function(){return n.growlAlert("New meeting.","warn","TODO")}}):r.createElement(r.Fragment,null),onSave:function(e){void 0==e?n.removeCardState(C.ChangingName):n.setState({name:e,cards:n.removeCard(C.ChangingName)})}},r.createElement("p",null,"You can save a new name for this meeting or, if this is really a new event, you may want to start a new meeting altogether."))},n.renderChangingDelegates=function(){return r.createElement(x,{key:"delegate-value",id:"delegate-value",title:"Number of delegates allowed?",type:"positive integer",value:n.state.allowed.toString(),allowEmpty:!1,extraButtons:n.state.allowed?r.createElement(h.Button,{id:"new-meeting-button",label:"New meeting",icon:"pi pi-calendar-plus",className:"p-button-secondary",onClick:function(){return n.growlAlert("New meeting.","warn","TODO")}}):r.createElement(r.Fragment,null),onSave:function(e){void 0==e?n.removeCardState(C.ChangingDelegates):n.setState({allowed:Number(e),cards:n.removeCard(C.ChangingDelegates)})}},r.createElement("p",null,"Specify the number of delegates that your meeting or caucus is allowed to send on to the next level. This is the number of delegates to be elected by your meeting.",n.state.allowed?r.createElement("span",null," If this is actually a new event, you may want to start a new meeting instead"):r.createElement(r.Fragment,null)))},n.renderRemovingEmpties=function(){return r.createElement(x,{key:"remove-empties-card",id:"remove-empties-card",title:"Remove empty subcaucuses",footer:r.createElement(r.Fragment,null,r.createElement(h.Button,{id:"remove-all-empties-button",label:"Remove All Empties",icon:"pi pi-trash",onClick:function(){return n.removeEmpties()}}),r.createElement(h.Button,{id:"remove-some-empties-button",label:"Remove Only Unnamed",icon:"pi pi-trash",className:"p-button-warning",onClick:function(){return n.removeEmpties("unnamed")}}),r.createElement(h.Button,{id:"cancel-remove-button",label:"Cancel",icon:"pi pi-times",className:"p-button-secondary",onClick:function(){return n.removeCardState(C.RemovingEmpties)}}))},r.createElement("p",null,'An "empty" subcaucus is one with no participants \u2014 a zero count.'),r.createElement("p",null,"You can choose to remove all empty subcaucuses, or only those which also have no names."))},n.renderNextCard=function(){return n.state.cards.sort(function(e,t){return t-e}).reduce(function(e,t){switch(f("filtering cards",e,t),t){case C.WelcomeAndSetName:return n.renderWelcomeAndSetName();case C.ShowingInstructions:return n.renderInstructions();case C.ShowingAbout:return n.renderAbout();case C.ShowingBy:return n.renderBy();case C.ChangingName:return n.renderChangingName();case C.ChangingDelegates:return n.renderChangingDelegates();case C.RemovingEmpties:return n.renderRemovingEmpties();case C.ShowingSecurity:return n.renderSecurity()}return e},r.createElement(r.Fragment,null))},n.sortBySubcaucusName=function(e,t){var a=e.id-t.id,r=e.name?e.name.toUpperCase():"SUBCAUCUS ".concat(e.id),o=t.name?t.name.toUpperCase():"SUBCAUCUS ".concat(t.id);return r<o&&(a=-1),r>o&&(a=1),a*n.state.sortName},n.sortBySubcaucusCounts=function(e,t){var a=.1*(e.delegates-t.delegates).comparisonValue()+((e.count?e.count:n.state.sortCount*(1/0))-(t.count?t.count:n.state.sortCount*(1/0))).comparisonValue();return 0==a&&(a=n.sortBySubcaucusName(e,t)*n.state.sortName*-1),a*n.state.sortCount},n.renderSubcaucusRows=function(){var e=function(e,t){return e.id-t.id};return n.state.sortName!=E.None&&(e=n.sortBySubcaucusName),n.state.sortCount!=E.None&&(e=n.sortBySubcaucusCounts),n.subcaucuses.values().sort(e).map(function(e){return r.createElement(M,{key:"".concat(e.id," ").concat(n.keySuffix),id:e.id,exchange:n.handleSubcaucusChange})})},n.renderSummary=function(){var e=n.state.summary;return e?r.createElement("div",{id:"summary-container"},r.createElement("div",{className:"summary-row"},r.createElement("div",{className:"summary-label"},"Total participants and delegates elected"),r.createElement("div",{className:"summary-count"},r.createElement("strong",null,e.count.toCommaString())),r.createElement("div",{className:"summary-delegates"},e.delegates.toCommaString())),r.createElement("div",{className:"summary-row"},r.createElement("div",{className:"summary-label"},"Minimum of ",r.createElement("strong",null,e.minimumCountForViability.singularPlural("person","people"))," needed to make a subcaucus viable")),r.createElement("div",{className:"summary-row"},r.createElement("div",{className:"summary-label"},"Viability number"),r.createElement("div",{className:"summary-count"},r.createElement("strong",null,Math.round(1e3*e.viability)/1e3))),e.nonViableCount?r.createElement("div",{className:"summary-row clickable",onClick:function(){return n.growlAlert("Explain viability in more detail.","warn","TODO")}},r.createElement("div",{className:"summary-label"},"Recalculated viability number (",e.nonViableCount.singularPlural("person","people")," in non-viable subcaucuses)"),r.createElement("div",{className:"summary-count"},Math.round(1e3*e.revisedViability)/1e3)):""):r.createElement("div",{id:"summary-container"},r.createElement("div",{className:"summary-row"},r.createElement("div",{className:"summary-label"},'To get a "viability number" just put the count of all the people in the room into a single subcaucus.')))},n.growlAlert=function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"error",a=arguments.length>2&&void 0!==arguments[2]?arguments[2]:"";!a&&e&&(a=e,e=""),n.growl?n.growl.show({severity:t,summary:a,closable:!1,detail:e}):alert(e)},o=n.growlAlert,a=o;var u=n.storage.getMeetingFromLocalStorage();if(b()){n.subcaucuses=new m.TSMap;var d=(new Date).toTimestampString();n.addSubcaucus("C",10,0),n.addSubcaucus("A",0,0),n.addSubcaucus("B",100,5),n.addSubcaucus("D",1,0),n.addSubcaucus(),n.snapshotRevised=d,n.revised=d,n.state={created:d,snapshot:"Revised",name:"Debugging",allowed:10,cards:[],seed:42,sortName:E.None,sortCount:E.None,summary:{count:1234,delegates:256,viability:2.124132,revisedViability:1.92123,minimumCountForViability:3,nonViableCount:3}}}else if(u)n.state=n.refreshAppFromSnapshot(u.current);else{v(new Error("Could not read or write local storage.")),n.subcaucuses=new m.TSMap;var g=(new Date).toTimestampString();n.snapshotRevised=g,n.revised=g,n.state={created:g,snapshot:"",name:"Could not read local storage!",allowed:1,seed:1,cards:[],sortName:E.None,sortCount:E.None}}return n}return Object(d.a)(t,e),Object(u.a)(t,[{key:"render",value:function(){var e=this;f("rendering",this.subcaucuses);var t=this.renderMenu(),n=this.renderSubcaucusRows(),a=this.renderSummary(),o=this.renderNextCard(),i=this.state,s=i.name,u=i.snapshot,c=i.sortName,l=i.sortCount;return r.createElement("div",{id:"app"},r.createElement("div",{id:"app-content"},t,r.createElement(g.Growl,{ref:function(t){return e.growl=t}}),r.createElement("div",{id:"meeting-info"},r.createElement("div",{id:"meeting-name",className:"button",onClick:function(){return e.addCardState(C.ChangingName)}},s||this.defaultName(),this.revised===this.snapshotRevised&&""!=u?r.createElement("span",{className:"snapshot"},u):""),r.createElement("div",{id:"delegates-allowed",className:"button",onClick:function(){return e.addCardState(C.ChangingDelegates)}},this.allowedString())),r.createElement("div",{id:"subcaucus-container"},r.createElement("div",{id:"subcaucus-header"},r.createElement(h.Button,{id:"subcaucus-name-head",label:"Subcaucus",icon:this.sortOrderIcon(c),onClick:function(){return e.setState({sortName:e.state.sortName?E.None:E.Ascending,sortCount:E.None})}}),r.createElement(h.Button,{id:"subcaucus-count-head",label:"Count",iconPos:"right",icon:this.sortOrderIcon(l),onClick:function(){return e.setState({sortName:E.None,sortCount:e.nextSortOrder(l,-1)})}}),r.createElement(h.Button,{id:"subcaucus-delegate-head",label:"Dels"})),r.createElement("div",{id:"subcaucus-list"},n),r.createElement("div",{id:"subcaucus-footer"},r.createElement(h.Button,{id:"add-subcaucus-button",label:"Add a Subcaucus",icon:"pi pi-plus",onClick:function(){return e.addSubcaucus()}}),r.createElement(h.Button,{id:"remove-empty-subcaucuses-button",label:"Remove Empties",icon:"pi pi-trash",onClick:function(){return e.addCardState(C.RemovingEmpties)}}))),a,r.createElement(h.Button,{id:"app-byline",label:"Brought to you by Tenseg LLC",href:"https://tenseg.net",onClick:function(){return e.addCardState(C.ShowingBy)}}),o),b()?r.createElement("div",{className:"debugging"},r.createElement("p",null,"This is debugging info for ",r.createElement("a",{href:"https://grand.clst.org:3000/tenseg/subcalc-pr/issues",target:"_repository"},"subcalc-pr")," (with ",r.createElement("a",{href:"https://reactjs.org/docs/react-component.html",target:"_react"},"ReactJS"),", ",r.createElement("a",{href:"https://www.primefaces.org/primereact/",target:"_primereact"},"PrimeReact"),", ",r.createElement("a",{href:"https://www.primefaces.org/primeng/#/icons",target:"_primeicons"},"PrimeIcons"),") derrived from ",r.createElement("a",{href:"https://bitbucket.org/tenseg/subcalc-js/src",target:"_bitbucket"},"subcalc-js"),"."),r.createElement("pre",null,"rendered App "+(new Date).toLocaleTimeString()),r.createElement("pre",null,"this.state is "+JSON.stringify(this.state,null,2)),r.createElement("pre",null,"this.subcaucuses is "+JSON.stringify(this.subcaucuses,null,2))):r.createElement(r.Fragment,null))}}]),t}(r.Component),B=Boolean("localhost"===window.location.hostname||"[::1]"===window.location.hostname||window.location.hostname.match(/^127(?:\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$/));function I(e){navigator.serviceWorker.register(e).then(function(e){e.onupdatefound=function(){var t=e.installing;t&&(t.onstatechange=function(){"installed"===t.state&&(navigator.serviceWorker.controller?console.log("New content is available; please refresh."):console.log("Content is cached for offline use."))})}}).catch(function(e){console.error("Error during service worker registration:",e)})}n(58);o.render(r.createElement(j,null),document.getElementById("root")),function(){if("serviceWorker"in navigator){if(new URL(".",window.location.toString()).origin!==window.location.origin)return;window.addEventListener("load",function(){var e="".concat(".","/service-worker.js");B?function(e){fetch(e).then(function(t){404===t.status||-1===t.headers.get("content-type").indexOf("javascript")?navigator.serviceWorker.ready.then(function(e){e.unregister().then(function(){window.location.reload()})}):I(e)}).catch(function(){console.log("No internet connection found. App is running in offline mode.")})}(e):I(e)})}}()}},[[25,2,1]]]);
//# sourceMappingURL=main.1dc6efc4.chunk.js.map