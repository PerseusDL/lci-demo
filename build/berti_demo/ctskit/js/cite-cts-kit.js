var subrefProcessor = null;

function loadUtilityXSL() {
    if (pathToSubrefXSLT) {
        $.ajax( {url: pathToSubrefXSLT, datatype: 'text/xml' } ).done(
            function(data) {
                subrefProcessor = new XSLTProcessor();
		        subrefProcessor.importStylesheet(data);
        });
    }
}

function loadXMLDoc(url, xsl, elemId, fullUrn, params){
	var ctsResponse;
	$.ajax(
	   {
	       url: url,
	       accepts: 'text/xml',
	       datatype: 'text/xml'
	   }).done(function(data) {
	          //putTextOntoPage("Finished loading text!", null, elemId,fullUrn); 
		      nowGetXSLT(data, xsl, elemId, fullUrn, params);
	       }
	);
}


function nowGetXSLT(ctsResponse, xsl, elemId, fullUrn, params){
	var myURL = xsl;
	
	var xslhttp = new XMLHttpRequest();  
	xslhttp.open("GET", xsl, true);
	xslhttp.send('');  
	
	xslhttp.onreadystatechange = function() {  
		if(xslhttp.readyState == 4) {
		  //putTextOntoPage("<p>Finished loading xslt!</p>", null, elemId,fullUrn);
		  xsltData = xslhttp.responseXML;   		
		  processXML(ctsResponse, xsltData, elemId, fullUrn, params);
  		}	
	}; 
}

function processXML(ctsResponse, xsltData, elemId, fullUrn, params){
		var processor = null;
		var tempData = null;
		var tempHTML = "";
		processor = new XSLTProcessor();
		processor.importStylesheet(xsltData);
		if (params != null) {
			var param_array = params.split(',');
			for (var i=0; i<param_array.length; i++) {
				var keypair = param_array[i].split('=');
				// TODO handle namespaced parameters
				processor.setParameter(null, keypair[0], keypair[1]);
			}
		}
		tempData = processor.transformToDocument(ctsResponse);
		tempHTML = new XMLSerializer().serializeToString(tempData);
		// if the target element is tagged with the subrefEnabledElementClass
		// run a 2nd transform on it which extracts the text so that subrefs can
		// be calculated without the markup
		tempText = null;
		if (subrefProcessor != null && fullUrn != null && fullUrn.indexOf("#") > 0) {
		    tempText = new XMLSerializer().serializeToString(subrefProcessor.transformToDocument(ctsResponse));
		}
		putTextOntoPage(tempHTML, tempText, elemId, fullUrn);
}



function putTextOntoPage(htmlText, tempText, elemId, fullUrn){
	document.getElementById(elemId).innerHTML = htmlText;
	if (tempText != null) {
	   $("#" + elemId).append('<div style="display:none;" class="' + subrefTextElementClass + '" cite="' + fullUrn + '">' +
	   '<div class="full_urn">' + fullUrn + '</div><div>' + tempText + '</div>');
	}
	$("#" + elemId).removeClass("waiting");
	documentCallback(elemId);
	
	// Catch any Markdown fields
	
	processMarkdown(elemId);
}

function processMarkdown(elemId){

	$(".md").each( function(i) {
		var mdText = $(this).html().trim();
		$(this).html(markdown.toHTML(mdText));
		//Remove class, so this doesn't get double-processed
		$(this).removeClass("md");

	});
	

	// if ( $("#" + elemId).find(".md").html() != null ) {
// 		var mdText = $("#" + elemId).find(".md").html().trim();
// 		console.log(mdText);
// 		$("#" + elemId).find(".md").html(markdown.toHTML(mdText));
// 	
// 	}
}

function assignIds(whichClass){
	$('.' + whichClass).each(function(index){
		$(this).addClass("waiting");
		$(this).html(" ");
		
		$(this).attr("id","cts_text_" + index);
		$(this).wrapInner("<a/>");
		if ( !($(this).hasClass("cts-clicked")) ){
				$(this).addClass("cts-clicked"); // prevent it from re-loading on every subsequent click
				var thisLink;
				var allCites = $(this).attr("cite");
				var thisCite;
				if (allCites.indexOf(' ') > 1) {
				    // don't retrieve the subreference
				    thisCite = allCites.split(' ')[0].replace('#.*$','');
				} else {
				    thisCite = allCites;
				}
				if (  thisCite.substring(0,7) == "http://"  ) {
					var tempPart = ( thisCite.substring(7,$(this).attr("cite").length) );
					thisLink = thisCite.replace('#.*$','');
				} else {
					thisLink = urlOfCTS + thisCite;
				}
				loadXMLDoc( thisLink, pathToXSLT, $(this).attr("id"), allCites, $(this).attr("data:xslt-params"));
			}
		
	});
}

function assignCiteIds(whichClass){
	$('.' + whichClass).each(function(index){
		$(this).addClass("waiting");
		$(this).html(" ");
		$(this).attr("id","cite_coll_" + index);
		$(this).wrapInner("<a/>");
		if ( !($(this).hasClass("cts-clicked")) ){
				$(this).addClass("cts-clicked"); // prevent it from re-loading on every subsequent click
				var thisCite = $(this).attr("cite");
				var thisLink;
				if (  thisCite.substring(0,7) == "http://"  ) {
					thisLink = thisCite;
					
				} else {
					thisLink = urlOfCite + thisCite;
				}
				loadXMLDoc( thisLink, pathToCiteXSLT, $(this).attr("id"),$(this).attr("cite"), $(this).attr("data:xslt-params"));
			}
		
	});
}

function fixImages(whichClass){
	$('.' + whichClass).each(function(index){
		tempAttr = $(this).attr("src");
		zoomTarget = $(this).attr("data:target");
		
		if ($(this).attr("src").substring(0,7) != "http://" ) {
			$(this).attr("src",urlOfImgService + tempAttr + "&w=" + imgSize + "&request=GetBinaryImage");
			var parts = $(this).attr("src").split(':');
			// if we don't have coordinates, specify the 0,0,0,0 point
			if (parts.length < 5 || parts[parts.length-1].match(/^\d,\d,\d,\d$/).lenth > 0) {
				tempAttr = tempAttr + ':0,0,0,0';
			}
			tempZoomUrl = urlOfImgService + tempAttr + "&request=GetIIPMooViewer";
			if (zoomTarget != null && zoomTarget != '') {
				zoomTarget = " target='" + zoomTarget + "'";
			}
			$(this).wrap("<a href='" + tempZoomUrl + "'" + zoomTarget + "/>");
		} else {
			var tempUrl = $(this).attr("src");
			console.log(tempUrl);
			$(this).replaceWith("<blockquote class='cite-img' id='citeimg_" + index + "'>" + tempUrl +  "</blockquote>");
			loadXMLDoc( tempUrl, pathToImgXSLT, "citeimg_" + index,$(this).attr("data:xslt-params"));
		}
	});
}

$(document).ready(function(){
   if (documentStartCallback != null) {    
        documentStartCallback.call();
   }
   loadUtilityXSL();
   processMarkdown("article");
   assignIds(textElementClass);	
   assignCiteIds(collectionElementClass);
   fixImages(imgElementClass);	   
});
