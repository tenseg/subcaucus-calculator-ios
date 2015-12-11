// subcalc.js
//
// include this script after the HTML at the footer of the page
//
// this script handles the caucus calculations, storage, and emailing
//
// great hints for iOS web apps at http://matt.might.net/articles/how-to-native-iphone-ipad-apps-in-javascript/
// generate icons and splashscreens at http://ticons.fokkezb.nl 
//
// created for SD64 DFL by Eric Celeste in January 2010
// 20150131 (efc) revised to add storage, email, and cleaner design
// 20150202 (efc) implemented a consistent cross-platform sort, allow for reseeding
// 20151210 (efc) fixing blurring bug (and many others)
// 20151211 (efc) unify the web and app versions of the script

"use strict"

// variables with "SC" at the front are SubCalc global variables

var scDebug = true; // should be false when shipping
var scApp = false; // should be true in the version inside our iPhone app
var scMessage;
var scData;
var scNumberOfSubcaucuses;
var SCRandomNumberGenerator;

//! Handle mobile responsiveness
// scroll the iPhone browser past the toolbar
if ( ! scApp ) addEventListener("load", function() { setTimeout(SCHideURLbar, 0); }, false);
function SCHideURLbar(){
	window.scrollTo(0,1);
}

SCNotify("Hello world.\n");

$(document).ready(SCReady); // tells us to call SCReady() once the doc is ready

//! Utility functions

// getQuerystring() facilitates the retrieval of a query string from JavaScript
// see http://www.bloggingdeveloper.com/post/JavaScript-QueryString-ParseGet-QueryString-with-Client-Side-JavaScript.aspx
function getQuerystring(key, default_) { 
	if (default_==null) default_=""; 
	key = key.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	var regex = new RegExp("[\\?&]"+key+"=([^&#]*)");
	var qs = regex.exec(window.location.href);
	if(qs == null)
		return default_;
	else
	return qs[1];
}

// SeedRandom(int,int) comes from http://stackoverflow.com/a/22313621/383737
// modified to accept strings and turn them into numbers
// we need it since the JavaScript RNG does not allow seeding
// note that it returns a function, the random number generator itself
/*
	The following is a PRNG that may be fed a custom seed. 
	Calling SeedRandom will return a random generator function. 
	SeedRandom can be called with no arguments in order to seed 
	the returned random function with the current time, or it can 
	be called with either 1 or 2 non-negative inters as arguments 
	in order to seed it with those integers. Due to float point 
	accuracy seeding with only 1 value will only allow the generator 
	to be initiated to one of 2^53 different states.

	The returned random generator function takes 1 integer argument 
	named limit, the limit must be in the range 1 to 4294965886, 
	the function will return a number in the range 0 to limit-1.
*/
function SeedRandom(state1,state2){
    var mod1=4294967087
    var mul1=65539
    var mod2=4294965887
    var mul2=65537
    state1 = Number(state1); // this was done to allow strings to be passed in as well
    state2 = Number(state2);
    if(isNaN(state1) || !state1){
        state1=+new Date()
    }
    if(isNaN(state2) || !state2){
        state2=state1
    }
    state1=state1%(mod1-1)+1
    state2=state2%(mod2-1)+1
    function random(limit){
        state1=(state1*mul1)%mod1
        state2=(state2*mul2)%mod2
        if(state1<limit && state2<limit && state1<mod1%limit && state2<mod2%limit){
            return random(limit)
        }
        return (state1+state2)%limit
    }
    return random
}

// SCSeedRandom(array) uses the array of numbers supplied plus other factors
// to seed the JavaScript random number generator in a predictable way
function SCSeedRandom(members) {
	/*
		todo: make sure that we "seed" this calculation in such a way that it always
		turns out the same for a given caucus, maybe based on that caucus starting time
		and the count of members for each delegation?
		
		Create the concept of a "coin flip" which is initiated when a new caucus
		is first created. This "coin flip" can simply be the timestamp of that event.
		If the caucus manager wants to reseed the generator, they can always "flip
		the coin" again to get a new seed timestamp.
		
		Then to randomize even further, always walk the array of subcaucus 
		member counts and generate random numbers in that order so that the one
		that counts (in SCRemainderRankDescendingHandler()) will be dependent not
		only on the timestamp, but also on the order of the member array.
	*/
	SCNotify("Seeding with "+scData['current']['seed']);
	SCRandomNumberGenerator = SeedRandom(scData['current']['seed']); // note this is a global (no var declaration)
}

// string.hashCode as seen at http://stackoverflow.com/a/7616484/383737
String.prototype.hashCode = function() {
	var hash = 0, i, chr, len;
	if (this.length == 0) return hash;
	for (i = 0, len = this.length; i < len; i++) {
		chr   = this.charCodeAt(i);
		hash  = ((hash << 5) - hash) + chr;
		hash |= 0; // Convert to 32bit integer
	}
	return hash;
};

// trim( string ) removes spaces from the front and back of the string
function trim(s) {
	return s.replace(/^\s+|\s+$/g,"");
}

// SCNotify( string ) appends the string to a message for later display
function SCNotify(note) {
	if ( ! scDebug ) return; // set scDebug to true above to debug
	console.log(note);
	if (typeof scMessage === 'undefined') {
		scMessage = ""; // scMessage is global
	}
	scMessage = scMessage + "\n" + note;
	$("#message").html("<pre>" + scMessage + "</pre>"); 
}

// SCValidCaucus() checks to see if what we have is really a
// caucus object... the testing is trivial for now
// todo: improve this test
function SCValidCaucus(caucus) {
	return (typeof caucus === 'object');
}

//! Setup functions

// SCReady() is called once the DOM is fully done loading
// this is where we start
function SCReady() {
	SCNotify("DOM ready.\n");
	SCGetData();
	//console.log(scData);
}

// SCNewPrecinct() simply returns an empty precinct
function SCNewPrecinct() {
	return {
		"precinct" : "",
		"allowed" : "",
		"names" : { "1": "", "2": "", "3": "" },
		"members" : { "1": "", "2": "", "3": "" },
		"seed" : Date.now()
	};
}

// SCNewPrecinct() simply returns an empty precinct
function SCReseed() {
	scData['current']['seed'] = Date.now();
	SCPopulateTable();
}

// SCEmptyNote() is just the HTML for an empty note in a row
function SCEmptyNote( row ) {
	return "<span id='scrow-" + row + "-delegates' class='note'></span>";
}

function SCInitializeViabilityStatement() {
	$("div#viability").html("<p>To generate an initial viability number, just enter the number of delegates you are allowed for the whole caucus, and put a count of all the people in the room in the first subcaucus.</p>");
}

// SCPopulateTable() builds the subcaucus table and makes sure the right scripts are attached to its elements
function SCPopulateTable() {
	SCNotify("Populating table");
	// find out who has focus and remember so it can be reset
	var hasFocus = document.activeElement;
	
	var precinct = scData['current']['precinct'];
	var allowed = scData['current']['allowed'];
	var scNames = scData['current']['names'];
	var scCounts = scData['current']['members'];
	
	scNumberOfSubcaucuses = Object.keys(scNames).length;
	
	$("#precinct").val(precinct);
	if ( allowed > 0 ) {
		$("#delegatesallowed").val(allowed);
	} else {
		$("#delegatesallowed").val("");
	}
	
	var codeForTable = "<div class='row header'><div class='cell number'></div><div class='cell name'>Subcaucus name</div><div class='cell count'>Count</div><div class='cell note'><span id='scheader-note'></span></div></div>";
	for (var i=1; i <= scNumberOfSubcaucuses; i++) {
		var count = scCounts[i] ? scCounts[i] : ""; // replace 0 with empty string
		codeForTable += "<div id='scrow-"+i+"' class='row'>";
		codeForTable += "<div class='cell number'>"+i+"</div>";
		codeForTable += "<div class='cell name'><input id='scrow-"+i+"-name' class='scrow scrowname' type='text' tabindex='"+(scNumberOfSubcaucuses+i+2)+"' value='"+scNames[i]+"' placeholder='Subcaucus "+i+"' autocapitalize='on' /></div>";
		codeForTable += "<div class='cell count'><input id='scrow-"+i+"-count' class='scrow scrowcount numeric' type='tel' tabindex='"+(i+2)+"' value='"+count+"' placeholder='&mdash;' /></div>";
		codeForTable += "<div class='cell note' id='scrow-"+i+"-delcell'>" + SCEmptyNote(i) + "</div>";
		codeForTable += "<div class='cell popup' id='scrow-"+i+"-popcell'><span id='scrow-"+i+"-popup' class='popup'></span></div>";
		codeForTable += "</div>";
	}
	codeForTable += "<div class='row total' id='total-participants'><div class='cell number'></div><div class='cell name'>total participants</div><div class='cell count'><span id='sctotal'></span></div><div class='cell note fineprint'><span id='sctotal-note'></span></div></div>";
	codeForTable += "<div class='row total' id='total-viable'><div class='cell number'></div><div class='cell name'>in viable subcaucuses</div><div class='cell count'><span id='scviabletotal'></span></div><div class='cell note fineprint'><span id='scviabletotal-note'></span></div></div>";
	
	$("div#subcaucuses").html(codeForTable); // insert the code
	
	SCInitializeViabilityStatement();
	
	// modify the behavior of some of the newly inserted elements
	$('a#save').click( function() { SCSaveCaucus(); return false; } );
	$('a#new').click( function() { SCNewCaucus(); return false; } );
	$('a#reseed').click( function() { SCReseed(); return false; } );
	$("input").blur(SCBlur); // every input element will call SCBlur() when completed
	$("input.scrowcount").blur(SCBlurCount); // every count element will call a special blur
	$("input.scrow").focus(SCFocusSCRow); // every scrow input element will call SCFocus() when you enter it
	$("input.numeric").live('click', function() {
    	$(this).select();
		this.setSelectionRange(0, 9999);
	});
	$("div.cell.note").live('click', function() {
		SCNotify("Clicked delegate.");
		var idArray = $(this).attr('id').split("-");
		//console.log(idArray);
		var popup = "#scrow-"+idArray[1]+"-popup";
		var popcell = "#scrow-"+idArray[1]+"-popcell";
		var countInput = "#scrow-"+idArray[1]+"-count";
		//console.log(popup)
		var popcontent = $(popup).html();
		//console.log(popcontent);
		if (popcontent) { 
			// if there is popup content, show it
			$(popcell).show();
		} else {
			// if there is no popup conent,
			// focus on the count instead
			$(countInput).focus();
		}
	});
	$("div.cell.popup").live('click', function() {
		$(this).hide();
	});
	
	// insert creation time in the footer
	if ( scData['current']['seed'] )  {
		var m = moment(scData['current']['seed']);
		var then = m.calendar();
		$('#when').html("Caucus created "+then+".");
	} else {
		$('#when').html("");
	}
	
	if ( $(hasFocus).is("input") ) {
		$(hasFocus).focus(); // return focus to this id
	}
	
	// calculate delegations
	SCDistributeDelegates();
}

//! Interactions

// SCBlur() is invoked whenever any input field loses focus
// check the value entered and then run calculations
function SCBlurInCommon( element ) {
	SCNotify("\nBlurInCommon " + element.id + " " + element.value + ".");
	var value = trim(element.value);
	$(element).val(value);
	if ($(element).hasClass("numeric")) { // validate the eligible item
		SCNotify("Numeric. ");
		if (! /^\d*$/.test(value)) { // is it not numeric or blank?
			SCNotify("Bad. ");
			$(element).val("");
			$(element).addClass("red");
			$("#"+element.id+"-note").html(" just a number, please");
			$("#"+element.id+"-note").addClass("red");
			return;
		} else {
			SCNotify("Good. ");
		}
	}

	// remember everything
	// this could be a bunch of if statements,
	// but I'm not sure that would speed anything up
	scData["current"]["precinct"] = $("#precinct").val();
	scData["current"]["allowed"] = parseInt($("#delegatesallowed").val());
	var members = new Object; // number of members in each subcaucus
	var names = new Object; // the name of each subcaucus
	for (var i=1; i <= scNumberOfSubcaucuses; i++) {
		names[i] = $("#scrow-"+i+"-name").val();
		members[i] = parseInt($("#scrow-"+i+"-count").val());
		if (isNaN(members[i])) members[i] = 0;
	}
	scData["current"]["names"] = names;
	scData["current"]["members"] = members;
	SCSetData();
	
	SCDistributeDelegates();
}


function SCBlur() {
	SCNotify("\nBlur " + this.id + " " + this.value + ".");
	SCBlurInCommon( this );
}

function SCBlurCount() {
	SCNotify("\nBluring a count " + this.id + " " + this.value + ".");
	if ( this.value == 0 || isNaN( this.value ) ) {
		// <div class='cell note' id='scrow-"+i+"-delcell'><span id='scrow-"+i+"-delegates' class='note'></span></div>
		// id is of the form scrow-2-count, we need the number from the middle
		var idArray = this.id.split("-");
		var row = idArray[1];
		$(this).val("");
	}
	SCBlurInCommon( this );
}

// SCFocusSCRow() should only get called when the user is entering
// one of the subcaucus row fields (the name or the count)
// here we make sure there is always another row to tab to
function SCFocusSCRow() {
	SCNotify("\nFocus " + this.id + " " + this.value + ".");
	var idArray = this.id.split("-");
	var row = idArray[1];
	if (row == scNumberOfSubcaucuses) { // if this is the last row
		scData['current']['names'][scNumberOfSubcaucuses+1] = '';
		scData['current']['members'][scNumberOfSubcaucuses+1] = '';
		SCPopulateTable();
		$("#"+this.id).focus(); // return focus to this id, which will no longer be last row
	}
}

//! Local Storage
/*	
	we are using HTML5 local storage to remember state 
	http://html5doctor.com/storing-data-the-simple-html5-way-and-a-few-tricks-you-might-not-have-known/
*/

// SCGetData() checks local storage for past data, if none is found, then default data is created
function SCGetData( data ) {
	var trySwift = scApp; // only try swift if we are in the iPhone app
	scData = false;
	
	//SCNotify("Checking data.");
	// if we got data, we assume it was from swift
	if ( data ) {
		trySwift = false; // because we just did
		SCNotify("Got Data\n"+JSON.stringify(data, undefined, 2));
		if (typeof data.current === 'object') {
			SCNotify("We remembered from incomming data!");
			scData = data; // scData is global
		}
	}
	
	//SCNotify("Checking local.");
	// then we try to find a local data store
	if ( ! scData && typeof localStorage.subcalc === 'string' ) {
		SCNotify("Local storage found.");
		var remembered = JSON.parse(localStorage.subcalc)	
		SCNotify(JSON.stringify(remembered, undefined, 2));
		if (typeof remembered.current === 'object') {
			SCNotify("We remember from local storage!");
			scData = remembered; // scData is global
		}
	}
	
	//SCNotify("Checking swift.");
	// next look for the data to be present in swift
	if ( ! scData && trySwift ) {
		// this calls back to SCGetData with data set
		window.location.href = "subcalc-extension://saved-caucuses";
		SCNotify("Swift will call back.");
		return;
	} 
	
	//SCNotify("Checking default.");
	if ( ! scData ) {
		// otherwise use default data
		SCNotify("Nothing to remember, assigning defaults.");
		scData = { "current" : SCNewPrecinct() };
	}
	
	// look for a ?caucus= component of the URI
	// and treats it as the current caucus no matter what
	var querystring = getQuerystring('caucus');
	if (querystring) {
		// more about quirks mode at http://stackoverflow.com/a/17307387/383737
		try {
			var caucus = JSON.parse(decodeURIComponent(querystring));
			if (SCValidCaucus(caucus)) {
				scData['current'] = caucus;
			}
		} catch(err) {
			// we just won't load it if it did not parse
		}
	}
	
	SCShowSavedList();
	SCPopulateTable();
	return;
}

// SCSetData() writes our data back to local storage
function SCSetData() {
	SCNotify("Setting: " + JSON.stringify(scData, undefined, 2));
	localStorage.subcalc = JSON.stringify(scData);
	if ( scApp ) {
    	window.location.href = "subcalc-extension://" + encodeURIComponent(JSON.stringify(scData));
    }
}

//! Saving and Loading

// SCSaveCaucus() saves the current caucus under the name of the precinct in our data
function SCSaveCaucus() {
	if (typeof scData['saved'] === 'undefined') {
		scData['saved'] = new Object;
	}
	scData['saved'][scData['current']['precinct'].hashCode()] = {
		'caucus': $.extend( {}, scData['current'] ), // using jQuery to copy the object
		'saved': Date.now()
	};
	SCSetData();
	SCShowSavedList();
}

function SCLoadSavedCaucus(caucusHash) {
	if ( scData['saved'][caucusHash]) {
		SCNotify("Loading caucus "+caucusHash);
		if ( ! scApp ) window.scrollTo(0,0);
		scData['current'] = $.extend( {}, scData['saved'][caucusHash]['caucus'] ); // using jQuery to copy the object
		SCPopulateTable();
	} else {
		SCNotify("Could not find caucus "+caucusHash);
	}
}

function SCShowSavedList() {
	if (scData['saved']) {
		var list = '<ul>';
		for (var h in scData['saved']) { // step through the hashes for each saved caucus
			var saved = scData['saved'][h];
			var caucus = scData['saved'][h]['caucus'];
			var then = moment(scData['saved'][h]['saved']).calendar();
			list += '<a href="#" onclick="SCLoadSavedCaucus('+h+')"><li>'+caucus['precinct']+' (saved '+then+')</li></a>';
		}
		list += '</ul>';
		$('div#savedlist').html(list);
	}
}

// SCNewCaucus() effectively clears out all the fields and starts fresh
function SCNewCaucus() {
	SCNotify("New caucus!");
	window.scrollTo(0,0);
	scData['current'] = SCNewPrecinct();
	SCPopulateTable();
}

//! Delegate Distribution Functions
/*
	For anyone concerned about the accuracy of this script,
	these are the functions to pay close attention to.
	
	Everything else just makes it look pretty.
*/

// SCRemainderRankObject() simply packages these objects to be easier 
// for the sorting function to use
function SCRemainderRankObject(subcaucus,remainder) {
	this.subcaucus = subcaucus;
	this.remainder = parseFloat(remainder);
	if (isNaN(this.remainder)) this.remainder = 0;
}

// SCRemainderRankDescendingHandler() is a special sorting function that compares two remainders
// and returns them in descending order, which is why the results are inverted
function SCRemainderRankDescendingHandler(thisObject,thatObject) {
	if (thisObject.remainder > thatObject.remainder)
	{
		return -1;
	}
	else if (thisObject.remainder < thatObject.remainder)
	{
		return 1;
	}
	/*	A special note about coin flips...
		
		In manual subcaucus distribution we use a coin flip to determine which of a set of caucuses
		should be priority in the case of a tie. But this would be a bit awkward in a script like
		this, so we essentially pre-flip the coin by assigning a "remainder rank" to each caucus.
		This way we can later just step through the rank until we run out of delegates.
		
		This really does amount to the same thing as the manual process. 
		
		However, since it is possible for this order to shift each time the calculation
		is run, it could be that the exact same set of counts for subcaucuses could result
		in slightly different delegate assignments from time to time.
	*/
	return (SCRandomNumberGenerator(2) ? -1 : 1); // generate a random 1 or -1
}

// SCSortRemainderRanks() is an inefficient, but simple, bubble sort algorithm
// that we can implement across platforms to keep sorting consistent
/*
	The sorting algorithm determines the number of calls to the
	random function, which we need to keep consistent so that
	the ranking results will match across platforms.
*/
function SCSortRemainderRanks(a)
{
    var swapped;
    do {
        swapped = false;
        for (var i=0; i < a.length-1; i++) {
            if (SCRemainderRankDescendingHandler(a[i],a[i+1])>0) {
                var temp = a[i];
                a[i] = a[i+1];
                a[i+1] = temp;
                swapped = true;
            }
        }
    } while (swapped);
}

// SCDisributeDelegates() handles the core function of this script
// distributes delegates based on the delegates allowed and subcaucus counts
/*
	The quotes in the comments below are from the instructions in the 
	2014-2015 Official Call of the Democratic-Farmer-Labor Party of Minnesota
	http://www.dfl.org/wp-content/uploads/2013/05/2014-Official-Call.pdf
	on page 4.
*/
function SCDistributeDelegates() {
	SCNotify("Distributing delegates");
	
	// first clear out all the delegate information
	for (var i=1; i <= scNumberOfSubcaucuses; i++) {
		$("#scrow-" + i + "-delcell").html(
			SCEmptyNote( i )
		);
	}
	$(".red").removeClass("red"); // clear all the red highlights
	$(".green").removeClass("green"); // clear all the green highlights
	$("#scviabletotal").html("");
	SCInitializeViabilityStatement();
	
	// prepare local copies of global info (just to make variable names shorter)
	var allowed = scData["current"]["allowed"];
	var members = scData["current"]["members"]; // number of members in each subcaucus
	var names = scData["current"]["names"]; // number of members in each subcaucus
	
	// "Step No. 1: Add up the total number of members of all the subcaucuses." (room)
	var room = 0;
	for (var i=1; i <= scNumberOfSubcaucuses; i++) {
		room += members[i];
	}
	if (room > 0) {
		$("#sctotal").html(room);
		SCNotify(room + " counted in the room.");
	}

	// Step No. 0
	// make sure we know the "number of delegates to be elected" (allowed)
	if ( allowed <= 0 || isNaN( allowed ) ) {
		if ( ! scApp ) window.scrollTo(0,0);
		// $("#delegatesallowed").focus();
		$("#delegatesallowed").addClass("red");
		$("#delegatesallowed-note").html(" enter the number allowed");
		$("#delegatesallowed-note").addClass("red");
		SCNotify("We don't yet know the number of delegates allowed.");
		return;
	}
	
	if (room == 0) {
		SCNotify("Nobody counted in the room yet.");
		return; // nothing else to do until some people are in the room
	}
	
	// calculate the viability number (viability)
	// "Step No. 2: Divide the result of Step No. 1" (room)
	// "by the total number of delegates to be elected," (allowed)
	// "round the result up to the next whole number." (wholeViability)
	// "This is the viability number." 
	// (this contradicts the example, which uses viability rather than wholeViability)
	var viabilityStatement = "";
	var viability = room / allowed;
	var wholeViability = Math.ceil(viability); // since people are not easily divided
	if (room <= allowed) { // can everyone be a delegate?
		viabilityStatement += "You are allowed enough delegates ("+allowed+") that anyone who wants to be a delegate can be a delegate. Just sign them up! ";
	} else { // we have to figure out the viability number
		viabilityStatement += "The viability number is <span id='viabilitynumber'>"+viability.toFixed(3)+"</span>, ";
		viabilityStatement += "so any subcaucus with fewer than <span id='wholeviability'>"+wholeViability+" people</span> is not viable. ";
	}
	$("#viability").html("<p>"+viabilityStatement+"</p>");
	
	// determine which subcaucuses are viable (viabilityScore >= 1)
	// and calculate the total number viable people in the room (viableRoom)
	var viabilityScore = new Object; // the raw score for the delegation
	var viableRoom = 0; // the total number of people in viable subcaucuses
	for (var i=1; i <= scNumberOfSubcaucuses; i++) {
		viabilityScore[i] = members[i] / viability;
		if (viabilityScore[i] >= 1) {
			viableRoom += members[i];
		}
	}
	if (viableRoom > 0) {
		$("#scviabletotal").html(viableRoom);
		SCNotify(viableRoom + " viable participants in the room.");
	} else {
		SCNotify("No viable participants in the room yet.");
		return; // no viable participants in the room yet
	}
	// calculate the viability number for the delegate allocation process
	var delegateViability = viableRoom / allowed;
	if (room != viableRoom) {
		viabilityStatement += "Because some people are counted in subcaucuses which are not viable, each delegate requires only "+delegateViability.toFixed(3)+" people in a viable subcaucus. You may want to consider another round of walking to allow everyone to join a viable subcaucus. ";
	}
	
	$("#viability").html("<p>"+viabilityStatement+"</p>");
	
	// calculate how many delegates each viable subcaucus gets
	var delegation = new Object; // the number of delegates they get
	var totalDelegation = 0;
	var remainder = new Object; // the remainder for use in allocating leftover delegates
	var remainderRank = new Array(); // will become a rank-order list of the remainders
	var delegateScore = new Object; // the raw score for the delegation
	for (var i=1; i <= scNumberOfSubcaucuses; i++) {
		if (viabilityScore[i] >= 1) { // this is a viable subcaucus
			delegateScore[i] = members[i] / delegateViability;
			delegation[i] = Math.floor(delegateScore[i]);
			remainder[i] = delegateScore[i] - delegation[i];
			remainderRank.push(new SCRemainderRankObject(i,remainder[i]));
			totalDelegation += delegation[i];
		}
	}
		
	// now sort and assign the remainders
	var ranked = new Object;
	var addon = new Object;
	SCSeedRandom(members);
	// remainderRank.sort(SCRemainderRankDescendingHandler);
	SCSortRemainderRanks(remainderRank);
	if (totalDelegation > 0) { // to deal with an empty form
		//while (totalDelegation < allowed) { // still some to distribute
			for(i=0; i < remainderRank.length; i++) {
				var sub = remainderRank[i].subcaucus;
				ranked[sub] = i+1; // recorded to view later
				if (isNaN(addon[sub])) { // dealing with js NaN issue
					addon[sub] = 0;
				}
				// if we still have delegates to be assigned
				if (totalDelegation < allowed) { 
					delegation[sub]++; // hand out one delegate
					addon[sub]++;
					totalDelegation++;
				}
			}
		//}
	}
	
	// post statements about the delegations
	totalDelegation = 0; // start a fresh count, now including remainders
	for (var i=1; i <= scNumberOfSubcaucuses; i++) {
		if (viabilityScore[i] >= 1) {
			if (viability > 1) {
				// var s = delegation[i] > 1 ? "s" : ""; // deal with plural
				var delegationStatement = "<span class='fineprint'>(" 
					+ delegateScore[i].toFixed(2);
				if (addon[i] != 0) delegationStatement += "+" + addon[i];
				delegationStatement += " r" + ranked[i] + ")</span> "
					+ "<span class='largeprint'>" + delegation[i] + "</span>";
				$("#scrow-"+i+"-popup").html(delegationStatement);
				$("#scrow-"+i+"-delegates").html("<span class='largeprint'>" + delegation[i] + "</span>");
				totalDelegation += delegation[i];
			} else {
				$("#scrow-"+i+"-delegates").html("<span class='largeprint'>" + members[i] + "</span>");
				$("#scrow-"+i+"-popup").html("<span class='fineprint'>(All!)</span> <span class='largeprint'>" + members[i] + "</span>");
				totalDelegation += members[i];
			}
			$("#scrow-"+i+"-delegates").addClass("green");
			$("#scrow-"+i+"-popup").parent().addClass("green");
		} else {
			if (members[i] > 0) { // only highlight subcaucuses with members
				$("#scrow-"+i+"-delegates").html("<span class='largeprint'>0<span>");
				$("#scrow-"+i+"-popup").html(
					"<span class='fineprint'>(" 
					+ viabilityScore[i].toFixed(2) 
					+ " not viable)</span> <span class='largeprint'>0</span>"
				);
				$("#scrow-"+i+"-delegates").addClass("red");
				$("#scrow-"+i+"-popup").parent().addClass("red");
			}
		}
	}
	$("#sctotal-note").html(totalDelegation + " delegates in all")
	
	if (totalDelegation < allowed) {
		$("#scheader-note").html("Dels");
	} else {
		$("#scheader-note").html("Dels");
	}
		
	var email = "Caucus";
	email += scData['current']['precinct'] ? ' "'+scData['current']['precinct']+'" ' : " ";
	email += "is allowed";
	email += scData['current']['allowed'] ? " "+scData['current']['allowed']+" " : " no ";
	email += "delegates. ";
	email += room + " people in are participating in the walking subcaucus process";
	if (room != viableRoom) {
		email += " (only "+ viableRoom + " are in viable subcaucuses)";
	}
	email += ".\n\n";
	if ( viability > 1 ) {
		email += "The viability number is "+viability.toFixed(3)+", ";
		email += "so any subcaucus with fewer than "+wholeViability+" people is not viable. ";
		if (room != viableRoom) {
			email += "Because some people are counted in subcaucuses which are not viable, each delegate requires only "+delegateViability.toFixed(3)+" people in a viable subcaucus.\n\n";
		}
		email += "These are the individual subcaucuses:\n\n";
		for (var i=1; i <= scNumberOfSubcaucuses; i++) {
			if ( names[i] || members[i] ) {
				email += names[i] ? names[i]+': ' : 'Subcaucus '+i+': ';
				email += members[i] + ( members[i] == 1 ? " person, " : " people, ");
				if ( viabilityScore[i] >= 1 ) {
					email += delegation[i] + ( delegation[i] == 1 ? " delegate " : " delegates ");
					email += "(" + delegateScore[i].toFixed(2);
					email += addon[i] ? "+" + addon[i] : "";
					email += " r" + ranked[i] + ").\n\n";
				} else {
					email += "no delegates ";
					email += "(" + viabilityScore[i].toFixed(2);
					email += " not viable).\n\n";
				}
			}
		}
	} else {
		email += "Since you have more delegate slots than people who want to be delegates, everyone gets to be a delegate. Just sign them all up!\n\n";
	}
	email += "This caucus report was first created "+moment(scData['current']['seed']).calendar()+".\n\n";
	
	var url = "http://sd64dfl.org/sub?caucus="+encodeURIComponent(JSON.stringify(scData['current']));
	
	email += "Open this caucus yourself by clicking on this very long and ugly link: "+url+"\n";
	
	var subject = "Subcaucus Report";
	subject += scData['current']['precinct'] ? ' for '+scData['current']['precinct'] : "";
	
	var mailto = "mailto:?subject="+encodeURIComponent(subject)+"&body="+encodeURIComponent(email);
	
	$('#email').attr('href', mailto);
	
}