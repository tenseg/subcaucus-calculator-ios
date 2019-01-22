(window.webpackJsonp=window.webpackJsonp||[]).push([[0],{20:function(e,t,n){e.exports=n(45)},37:function(e,t,n){},43:function(e,t,n){},45:function(e,t,n){"use strict";n.r(t);var a=n(0),r=n(14),o=n(19),i=n(2),c=n(5),u=n(7),s=n(6),l=n(8),d=n(15),m=n(1),p=n(16);n(31),n(33),n(35),n(37);function h(){return!1}function g(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"";return void 0==e?t:e}String.prototype.trim=function(){for(var e=this.replace(/^\s+/,""),t=e.length-1;t>=0;t--)if(/\S/.test(e.charAt(t))){e=e.substring(0,t+1);break}return e},Number.prototype.toCommaString=function(){return this.toString().replace(/\B(?=(\d{3})+(?!\d))/g,",")},Number.prototype.singularPlural=function(e,t){return"".concat(this," ").concat(1==this?e:t)};var f,v,b=function e(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"",a=arguments.length>2&&void 0!==arguments[2]?arguments[2]:0,r=arguments.length>3&&void 0!==arguments[3]?arguments[3]:0;Object(i.a)(this,e),this.id=void 0,this.name=void 0,this.count=void 0,this.delegates=void 0,this.id=t,this.name=n,this.count=a,this.delegates=r},w=n(12),y=n(10),S=n(17),E=function(e){function t(e){var n;Object(i.a)(this,t),(n=Object(u.a)(this,Object(s.a)(t).call(this,e))).handleName=function(){return function(e){var t=e.currentTarget.value;n.setState({name:t}),n.props.exchange(n.props.id,Object(w.a)({},n.state,{name:t}))}},n.handleCount=function(){return function(e){var t=Number(e.currentTarget.value);t<0&&(t=0),n.setState({count:t})}},n.notify=function(){return function(e){n.props.exchange(n.props.id,Object(w.a)({},n.state))}},n.handleKey=function(){return function(e){"Enter"!==e.key&&"Tab"!==e.key||n.props.exchange(n.props.id,"enter")}},n.focusOnWholeText=function(){return function(e){var t=e.currentTarget;setTimeout(function(){return t.setSelectionRange(0,9999)},0)}},n.idPlus=function(e){return"subcaucus-".concat(n.props.id,"-").concat(e)},n.state={name:"",count:0,delegates:0};var a=n.props.exchange(n.props.id,"sync");return a&&(n.state={name:a.name,count:a.count,delegates:a.delegates}),n}return Object(l.a)(t,e),Object(c.a)(t,[{key:"render",value:function(){this.props.id,this.state;var e=this.state,t=e.name,n=e.count,r=e.delegates;return a.createElement("div",{id:this.idPlus("row"),className:"subcaucus-row ".concat(r>0?"has-delegates":n>0?"no-delegates":"")},h?a.createElement("div",{className:"subcaucus-id"},this.props.id):"",a.createElement(S.InputTextarea,{id:this.idPlus("row-name"),className:"subcaucus-field subcaucus-name",type:"text",value:t,rows:1,cols:1,placeholder:"Subcaucus ".concat(this.props.id),onChange:this.handleName(),onKeyUp:this.handleKey()}),a.createElement(y.InputText,{id:this.idPlus("row-count"),className:"subcaucus-field subcaucus-count",keyfilter:"pint",type:"text",pattern:"\\d*",value:n||"",placeholder:"\u2014",onChange:this.handleCount(),onBlur:this.notify(),onKeyUp:this.handleKey()}),a.createElement(m.Button,{id:this.idPlus("row-delegates"),className:"subcaucus-delegates-button ".concat(r>0?"p-button-success":"p-button-secondary"),label:"".concat(r||(n?"0":"\u2014"))}))}}]),t}(a.Component),C=n(18),N=function(e){function t(e){var n;Object(i.a)(this,t),(n=Object(u.a)(this,Object(s.a)(t).call(this,e))).isPositiveInteger=!1,n.originalValue=function(){return g(n.props.value)},n.defaultValue=function(){return g(n.props.defaultValue)},n.handleChange=function(){return function(e){if(e.currentTarget.value,n.isPositiveInteger){var t=Number(e.currentTarget.value);t<0&&(t=0),n.setState({value:String(t)})}else n.setState({value:e.currentTarget.value})}},n.handleKey=function(){return function(e){"Enter"===e.key&&n.props.onSave&&n.props.onSave(n.state.value.trim())}},n.focusOnWholeText=function(){return function(e){var t=e.currentTarget;setTimeout(function(){return t.setSelectionRange(0,9999)},0)}},n.isEmpty=function(e){var t=""===e||void 0===e;return n.isPositiveInteger&&(t=t||"0"===e),t},n.save=function(e){return function(t){n.props.onSave&&(void 0===e?n.props.onSave():n.isEmpty(e)&&!n.props.allowEmpty?n.isEmpty(n.props.defaultValue)||n.props.onSave(n.props.defaultValue):n.props.onSave(e.trim()))}},n.idPlus=function(e){return n.props.id?"".concat(n.props.id,"-").concat(e):void 0},n.isPositiveInteger="positive integer"===n.props.type;var a=g(n.props.value);return!n.props.allowEmpty&&n.isEmpty(a)&&(a=g(n.props.defaultValue)),n.state={value:a},n}return Object(l.a)(t,e),Object(c.a)(t,[{key:"render",value:function(){var e=this.state.value,t=this.isPositiveInteger,n=a.createElement(a.Fragment,null);if(void 0==this.props.footer){var r=this.isEmpty(e)&&this.isEmpty(this.defaultValue())&&!1===this.props.allowEmpty,o=this.isEmpty(this.originalValue())&&!1===this.props.allowEmpty,i=this.props.onSave?void 0!=this.props.value?a.createElement(m.Button,{id:this.idPlus("save-button"),label:"Save",icon:"pi pi-check",disabled:r,onClick:this.save(g(e,this.defaultValue()))}):a.createElement(m.Button,{id:this.idPlus("close-button"),label:"Close",icon:"pi pi-times",onClick:this.save()}):a.createElement(a.Fragment,null),c=o||void 0===this.props.value?"":a.createElement(m.Button,{id:this.idPlus("cancel-button"),label:"Cancel",icon:"pi pi-times",className:"p-button-secondary",onClick:this.save()});n=a.createElement(a.Fragment,null,i,this.props.extraButtons,c)}else n=this.props.footer;return a.createElement("div",{className:"valuecard-wrapper"},a.createElement("div",{className:"background-blocker"}),a.createElement(C.Card,{id:this.idPlus("valuecard"),className:"valuecard ".concat(this.idPlus("valuecard")),title:this.props.title,header:this.props.image?a.createElement("div",{id:this.idPlus("picture-container"),className:"picture-container"},a.createElement("img",{alt:"".concat(this.props.alt),src:"".concat(this.props.image)}),a.createElement(m.Button,{id:this.idPlus("picture-close-button"),icon:"pi pi-times",onClick:this.save()})):void 0,footer:n},this.props.children?a.createElement("div",{id:this.idPlus("valuecard-children"),className:"valuecard-children"},this.props.children):"",this.props.description?a.createElement("div",{id:this.idPlus("valuecard-description"),className:"valuecard-description"},a.createElement("p",null,this.props.description)):"",void 0!=this.props.value?a.createElement(y.InputText,{id:this.idPlus("card-field"),className:t?"number":"text",keyfilter:t?"pint":"",type:"text",pattern:t?"\\d*":void 0,value:t&&"0"===e?"":e,placeholder:this.props.defaultValue,onChange:this.handleChange(),onKeyUp:this.handleKey(),autoFocus:!0}):""))}}]),t}(a.Component);!function(e){e[e.None=0]="None",e[e.Ascending=1]="Ascending",e[e.Descending=2]="Descending"}(f||(f={})),function(e){e[e.WelcomeAndSetName=0]="WelcomeAndSetName",e[e.ChangingName=1]="ChangingName",e[e.ChangingDelegates=2]="ChangingDelegates",e[e.RemovingEmpties=3]="RemovingEmpties",e[e.ShowingAbout=4]="ShowingAbout",e[e.ShowingBy=5]="ShowingBy",e[e.ShowingInstructions=6]="ShowingInstructions"}(v||(v={}));var k=function(e){function t(e){var n;return Object(i.a)(this,t),(n=Object(u.a)(this,Object(s.a)(t).call(this,e))).subcaucuses=new d.TSMap,n.initialCardState=[v.WelcomeAndSetName,v.ChangingDelegates,v.ShowingInstructions],n._currentSubcaucusID=1,n.nextSubcaucusID=function(){return n._currentSubcaucusID++},n.addSubcaucus=function(){var e=!(arguments.length>0&&void 0!==arguments[0])||arguments[0],t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"",a=arguments.length>2&&void 0!==arguments[2]?arguments[2]:0,r=arguments.length>3&&void 0!==arguments[3]?arguments[3]:0,o=new b(n.nextSubcaucusID(),t,a,r);n.subcaucuses.set(o.id,o),e&&n.forceUpdate()},n.defaultName=function(){return"Meeting on "+n.state.dateCreated.toLocaleDateString("en-US")},n.allowedString=function(){return"".concat(n.state.allowed," delegates to be elected")},n.addCard=function(e,t){return void 0===t&&(t=n.state.cards),[].concat(Object(o.a)(t),[e])},n.addCardState=function(e){n.setState({cards:n.addCard(e)})},n.removeCard=function(e,t){return void 0===t&&(t=n.state.cards),t.filter(function(t){return t!=e})},n.removeCardState=function(e){n.setState({cards:n.removeCard(e)})},n.switchCardState=function(e,t){var a=n.removeCard(e);a=n.addCard(t,a),n.setState({cards:a})},n.showingCard=function(e){return n.state.cards.indexOf(e)>-1},n.handleChange=function(e){return function(t){switch(e){case"allowed":var a=Number(t.currentTarget.value);a<0&&(a=0),n.setState({allowed:a});break;case"name":n.setState({name:t.currentTarget.value})}}},n.focusOnWholeText=function(){return function(e){var t=e.currentTarget;setTimeout(function(){return t.setSelectionRange(0,9999)},0)}},n.handleSubcaucusChange=function(e,t){switch(t){case"remove":return n.subcaucuses.filter(function(t,n){return n!=e}),void n.forceUpdate();case"enter":return;case"sync":return n.subcaucuses.get(e);default:var a=n.subcaucuses.get(e);return a.name=t.name,a.count=t.count,void n.forceUpdate()}},n.removeEmpties=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"all";"all"==e&&n.subcaucuses.filter(function(e,t){return e.count>0}),"unnamed"==e&&n.subcaucuses.filter(function(e,t,n){return e.id,e.count,e.name,e.count>0||e.name,e.count>0||""!=e.name}),n.removeCardState(v.RemovingEmpties)},n.sortOrderIcon=function(e){return["pi pi-circle-off","pi pi-chevron-circle-up","pi pi-chevron-circle-down"][e]},n.nextSortOrder=function(e){var t=(e+(arguments.length>1&&void 0!==arguments[1]?arguments[1]:1))%3;return t<0&&(t+=3),t},n.renderMenu=function(){var e=[{label:"About",icon:"pi pi-fw pi-info-circle",items:[{label:"Minnesota DFL Subcaucus Calculator",command:function(){return n.addCardState(v.ShowingAbout)}},{label:"Instructions",command:function(){return n.addCardState(v.ShowingInstructions)}}]},{label:"Meetings",icon:"pi pi-fw pi-calendar",items:[{label:"Save revision",icon:"pi pi-fw pi-clock",command:function(){return alert("TODO: create save revision function.")}},{label:"New meeting",icon:"pi pi-fw pi-calendar-plus",command:function(){return alert("TODO: create new meeting function.")}},{label:"Duplicate meeting",icon:"pi pi-fw pi-clone",command:function(){return alert("TODO: create duplicate meeting function.")}},{label:"Load meeting",icon:"pi pi-fw pi-folder-open",command:function(){return alert("TODO: create load meeting function.")}},{label:"Flip the coin",icon:"pi pi-fw pi-refresh",command:function(){return alert("TODO: create coin flip function.")}}]},{label:"Share",icon:"pi pi-fw pi-share-alt",items:[{label:"Email report",icon:"pi pi-fw pi-envelope",command:function(){return alert("TODO: create email function.")}},{label:"Download text",icon:"pi pi-fw pi-align-left",command:function(){return alert("TODO: create download text function.")}},{label:"Download CSV",icon:"pi pi-fw pi-table",command:function(){return alert("TODO: create download csv function.")}},{label:"Download code",icon:"pi pi-fw pi-save",command:function(){return alert("TODO: create download code function.")}}]}];return a.createElement(p.Menubar,{model:e,id:"app-main-menu"})},n.renderAbout=function(){return a.createElement(N,{key:"about-card",id:"about-card",title:"Minnesota DFL Subcaucus Calculator",image:"dfl.jpg",onSave:function(){return n.removeCardState(v.ShowingAbout)},extraButtons:a.createElement(m.Button,{id:"show-credits-button",label:"Credits",icon:"pi pi-user",className:"p-button-secondary",onClick:function(){return n.switchCardState(v.ShowingAbout,v.ShowingBy)}})},a.createElement("p",null,"Originally written for ",a.createElement("a",{href:"http://sd64dfl.org"},"SD64 DFL"),", this app assists convenors of precinct caucuses and conventions in Minnesota. The Minnesota Democratic Farmer Labor (DFL) party uses a wonderful, but bit arcane, \u201cwalking subcaucus\u201d process that is simple enough to do, but rather difficult to tabulate."),a.createElement("p",null,"Given the number of delegates your meeting or caucus is allowed to send forward and the number of people in each subcaucus, this calculator determines how many of those delegates each subcaucus will elect. The rules it follows appeared on page 4 of the ",a.createElement("a",{href:"http://www.sd64dfl.org/more/caucus2014printing/2014-Official-Call.pdf"},"DFL 2014 Official Call"),", including the proper treatment of remainders. It makes the math involved in a walking subcaucus disappear."),a.createElement("p",null,"The app could be used to facilitate a \u201cwalking subcaucus\u201d or \u201c",a.createElement("a",{href:"https://en.wikipedia.org/wiki/Proportional_representation"},"proportional representation"),"\u201d system for any group."))},n.renderInstructions=function(){return a.createElement(N,{key:"instructions-card",id:"instructions-card",title:"Fill in the subcaucuses",image:"walking.jpg",onSave:function(){return n.removeCardState(v.ShowingInstructions)}},a.createElement("p",null,"Now it is time to fill in the subcaucus information. Just add each subcaucus name and the count of participants. Usually a convention or cacucus will solicit the names of subcaucuses first, feel free to enter them right away without a count. Then people will be encouraged to walk around the room and congregate with the subcaucus that most closely represents their views. When each subcacus reports how many people they attracted, you can enter that as the count for that subcaucus."),a.createElement("p",null,"As soon as you start entering subcaucus counts, the calculator will go to work determining how many delegates each subcaucus will be assigned. You can ignore those numbers until you have finished entering and confirming all the subcaucus counts. When you are done, the delegate numbers can be reported to the chair of your convention or caucus."),a.createElement("p",null,'Since most conventions or caucuses will go through more than one round of "walking", you can just keep reusing your subcaucus list for each round. However, you might want to consider these steps at the end of each round:'),a.createElement("ul",null,a.createElement("li",null,'Use the "Meetings" menu at the top to save a revision after each round of caucusing. This will give you a good record of the whole process.'),a.createElement("li",null,'Use the "Share" menu to email a report about each round to the chair of the meeting just so they also have a clear record of the process.')),a.createElement("p",null,'You can always get these instructions back under the "About" menu at the top. Have fun!'))},n.renderBy=function(){return a.createElement(N,{key:"by-card",id:"by-card",title:"Brought to you by Tenseg LLC",image:"tenseg.jpg",onSave:function(){return n.removeCardState(v.ShowingBy)}},a.createElement("p",null,"We love the walking subcaucus process and it makes us a bit sad that the squirrelly math required to calculate who gets how many delegate discourages meetings and caucuses from using the process. We hope this calculator makes it easier for you to get to know your neighbors as you work together to change the world!"),a.createElement("p",null,"Please check us out at ",a.createElement("a",{href:"https://tenseg.net"},"tenseg.net")," if you need help building a website or making appropriate use of technology."))},n.renderWelcomeAndSetName=function(){return a.createElement(N,{key:"name-value",id:"name-value",title:"Welcome to the Minnesota DFL Subcacus Calculator",image:"dfl.jpg",description:'Please start by specifying the name of your meeting here. Most meetings have a name, like the "Ward 4 Precinct 7 Caucus" or the "Saint Paul City Convention".',value:n.state.name,defaultValue:n.defaultName(),allowEmpty:!1,onSave:function(e){void 0==e?n.removeCardState(v.WelcomeAndSetName):n.setState({name:e,cards:n.removeCard(v.WelcomeAndSetName)})}})},n.renderChangingName=function(){return a.createElement(N,{key:"name-value",id:"name-value",title:"Meeting name?",value:n.state.name,defaultValue:n.defaultName(),allowEmpty:!1,extraButtons:n.state.name?a.createElement(m.Button,{id:"new-meeting-button",label:"New meeting",icon:"pi pi-calendar-plus",className:"p-button-secondary",onClick:function(){return alert("TODO: create new meeting function.")}}):a.createElement(a.Fragment,null),onSave:function(e){void 0==e?n.removeCardState(v.ChangingName):n.setState({name:e,cards:n.removeCard(v.ChangingName)})}},a.createElement("p",null,"You can save a new name for this meeting or, if this is really a new event, you may want to start a new meeting altogether."))},n.renderChangingDelegates=function(){return a.createElement(N,{key:"delegate-value",id:"delegate-value",title:"Number of delegates allowed?",type:"positive integer",value:n.state.allowed.toString(),allowEmpty:!1,extraButtons:n.state.allowed?a.createElement(m.Button,{id:"new-meeting-button",label:"New meeting",icon:"pi pi-calendar-plus",className:"p-button-secondary",onClick:function(){return alert("TODO: create new meeting function.")}}):a.createElement(a.Fragment,null),onSave:function(e){void 0==e?n.removeCardState(v.ChangingDelegates):n.setState({allowed:Number(e),cards:n.removeCard(v.ChangingDelegates)})}},a.createElement("p",null,"Specify the number of delegates that your meeting or caucus is allowed to send on to the next level. This is the number of delegates to be elected by your meeting.",n.state.allowed?a.createElement("span",null," If this is actually a new event, you may want to start a new meeting instead"):a.createElement(a.Fragment,null)))},n.renderRemovingEmpties=function(){return a.createElement(N,{key:"remove-empties-card",id:"remove-empties-card",title:"Remove empty subcaucuses",footer:a.createElement(a.Fragment,null,a.createElement(m.Button,{id:"remove-all-empties-button",label:"Remove All Empties",icon:"pi pi-trash",onClick:function(){return n.removeEmpties()}}),a.createElement(m.Button,{id:"remove-some-empties-button",label:"Remove Only Unnamed",icon:"pi pi-trash",className:"p-button-warning",onClick:function(){return n.removeEmpties("unnamed")}}),a.createElement(m.Button,{id:"cancel-remove-button",label:"Cancel",icon:"pi pi-times",className:"p-button-secondary",onClick:function(){return n.removeCardState(v.RemovingEmpties)}}))},a.createElement("p",null,'An "empty" subcaucus is one with no participants \u2014 a zero count.'),a.createElement("p",null,"You can choose to remove all empty subcaucuses, or only those which also have no names."))},n.renderNextCard=function(){return n.state.cards.sort(function(e,t){return t-e}).reduce(function(e,t){switch(t){case v.WelcomeAndSetName:return n.renderWelcomeAndSetName();case v.ShowingInstructions:return n.renderInstructions();case v.ShowingAbout:return n.renderAbout();case v.ShowingBy:return n.renderBy();case v.ChangingName:return n.renderChangingName();case v.ChangingDelegates:return n.renderChangingDelegates();case v.RemovingEmpties:return n.renderRemovingEmpties()}return e},a.createElement(a.Fragment,null))},n.renderSubcaucusRows=function(){var e=function(e,t){return e.id-t.id};return n.state.sortName!=f.None&&(e=function(e,t){var a=n.state.sortName==f.Ascending?1:-1,r=e.id-t.id,o=e.name?e.name.toUpperCase():"SUBCAUCUS ".concat(e.id),i=t.name?t.name.toUpperCase():"SUBCAUCUS ".concat(t.id);return o<i&&(r=-1),o>i&&(r=1),r*a}),n.state.sortCount!=f.None&&(e=function(e,t){var a=n.state.sortCount==f.Ascending?1:-1,r=e.id-t.id,o=e.name?e.name.toUpperCase():"SUBCAUCUS ".concat(e.id),i=t.name?t.name.toUpperCase():"SUBCAUCUS ".concat(t.id);o<i&&(r=-1),o>i&&(r=1);var c=e.delegates-t.delegates;return 0==c&&(c=e.count-t.count),0==c?r:c*a}),n.subcaucuses.values().sort(e).map(function(e){return a.createElement(E,{key:e.id,id:e.id,exchange:n.handleSubcaucusChange})})},n.renderSummary=function(){var e=n.state.summary;return e?a.createElement("div",{id:"summary-container"},a.createElement("div",{className:"summary-row"},a.createElement("div",{className:"summary-label"},"Total participants and delegates elected"),a.createElement("div",{className:"summary-count"},e.count.toCommaString()),a.createElement("div",{className:"summary-delegates"},e.delegates.toCommaString())),a.createElement("div",{className:"summary-row"},a.createElement("div",{className:"summary-label"},"Minimum of ",a.createElement("strong",null,e.minimumCountForViability.singularPlural("person","people"))," needed to make a subcaucus viable")),a.createElement("div",{className:"summary-row"},a.createElement("div",{className:"summary-label"},"Viability number"),a.createElement("div",{className:"summary-count"},Math.round(1e3*e.viability)/1e3)),e.nonViableCount?a.createElement("div",{className:"summary-row clickable",onClick:function(){return alert("TODO: explain viability in more detail.")}},a.createElement("div",{className:"summary-label"},"Recalculated viability number (",e.nonViableCount.singularPlural("person","people")," in non-viable subcaucuses)"),a.createElement("div",{className:"summary-count"},Math.round(1e3*e.revisedViability)/1e3)):""):a.createElement("div",{id:"summary-container"},a.createElement("div",{className:"summary-row"},a.createElement("div",{className:"summary-label"},'To get a "viability number" just put the count of all the people in the room into a single subcaucus.')))},n.state={dateCreated:new Date,name:"",allowed:0,cards:n.initialCardState,sortName:f.None,sortCount:f.None},n.addSubcaucus(!1),n.addSubcaucus(!1),n.addSubcaucus(!1),n}return Object(l.a)(t,e),Object(c.a)(t,[{key:"render",value:function(){var e=this;this.subcaucuses;var t=this.renderMenu(),n=this.renderSubcaucusRows(),r=this.renderSummary(),o=this.renderNextCard(),i=this.state,c=i.name,u=i.sortName,s=i.sortCount;return a.createElement("div",{id:"app"},a.createElement("div",{id:"app-content"},t,a.createElement("div",{id:"meeting-info"},a.createElement(m.Button,{id:"meeting-name",label:c||this.defaultName(),onClick:function(){return e.addCardState(v.ChangingName)}}),a.createElement(m.Button,{id:"delegates-allowed",label:this.allowedString(),onClick:function(){return e.addCardState(v.ChangingDelegates)}})),a.createElement("div",{id:"subcaucus-container"},a.createElement("div",{id:"subcaucus-header"},a.createElement(m.Button,{id:"subcaucus-name-head",label:"Subcaucus",icon:this.sortOrderIcon(u),onClick:function(){return e.setState({sortName:e.nextSortOrder(u),sortCount:f.None})}}),a.createElement(m.Button,{id:"subcaucus-count-head",label:"Count",iconPos:"right",icon:this.sortOrderIcon(s),onClick:function(){return e.setState({sortName:f.None,sortCount:e.nextSortOrder(s,-1)})}}),a.createElement(m.Button,{id:"subcaucus-delegate-head",label:"Dels"})),a.createElement("div",{id:"subcaucus-list"},n),a.createElement("div",{id:"subcaucus-footer"},a.createElement(m.Button,{id:"add-subcaucus-button",label:"Add a Subcaucus",icon:"pi pi-plus",onClick:function(){return e.addSubcaucus()}}),a.createElement(m.Button,{id:"remove-empty-subcaucuses-button",label:"Remove Empties",icon:"pi pi-trash",onClick:function(){return e.addCardState(v.RemovingEmpties)}}))),r,a.createElement(m.Button,{id:"app-byline",label:"Brought to you by Tenseg LLC",href:"https://tenseg.net",onClick:function(){return e.addCardState(v.ShowingBy)}}),o),a.createElement(a.Fragment,null))}}]),t}(a.Component),O=Boolean("localhost"===window.location.hostname||"[::1]"===window.location.hostname||window.location.hostname.match(/^127(?:\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$/));function T(e){navigator.serviceWorker.register(e).then(function(e){e.onupdatefound=function(){var t=e.installing;t&&(t.onstatechange=function(){"installed"===t.state&&(navigator.serviceWorker.controller?console.log("New content is available; please refresh."):console.log("Content is cached for offline use."))})}}).catch(function(e){console.error("Error during service worker registration:",e)})}n(43);r.render(a.createElement(k,null),document.getElementById("root")),function(){if("serviceWorker"in navigator){if(new URL(".",window.location.toString()).origin!==window.location.origin)return;window.addEventListener("load",function(){var e="".concat(".","/service-worker.js");O?function(e){fetch(e).then(function(t){404===t.status||-1===t.headers.get("content-type").indexOf("javascript")?navigator.serviceWorker.ready.then(function(e){e.unregister().then(function(){window.location.reload()})}):T(e)}).catch(function(){console.log("No internet connection found. App is running in offline mode.")})}(e):T(e)})}}()}},[[20,2,1]]]);
//# sourceMappingURL=main.528d934f.chunk.js.map