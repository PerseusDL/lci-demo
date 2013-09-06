var loaded_tabs = {
    'alltranslation': {},
    'allsyntax' : {},
    'alllinks' : {},
    'allalignment': {}
};

function documentCallback(a_elemId) {
    // load cite object: display urn and description
    // click on a cite -- 
    // (1) loads full CTS on right passage (dropping subref) on left:
    //  -- with next/prev links to explore context
    //  -- with highlight to see subref
    //  -- with link to view/download TEI/XML
    //  -- multiple tabs for multiple sources
    //  (2) updates commentary tab to show commentary for the cite
    //  (3) highlights selected CITE urn
    // when load CTS passage, update translation & annotations tab
    // top or bottom of page, separate tab for bibliography, credits
    var elem = $("#"+a_elemId);
    if (elem.hasClass(textElementClass)) {
        var quoteLink = "";
        if (elem.attr("cite").match(/urn:cts:.*?#/) != null) {
            quoteLink = '<a class="toggle_subref">Show Quote</a> | ';
        }
        $(elem).prepend('<div class="features">' + quoteLink + '<span class="links"><a href="#xml">TEI XML</a> | <a href="#source">Full Text</a></span></div>')
    }
    // $(".lciurn",elem).off("click");
    $(".toggle_subref",elem).off("toggle");
    $(".links a",elem).off("click");
    //$(".lciurn",elem).on("click",toggleSourceText);
    $(".toggle_subref",elem).toggle(showSubref,hideSubref);
    $(".links a", elem).on("click",openLink);
    
}

function onDocumentStart() {
    if (window.location.hash) {
        var cite_nover = window.location.hash.substr(1);
        var match_ver = cite_nover.match(/(urn:cite:.*?:.*?\..*?)\./);  
        if (match_ver != null) {
            cite_nover = match_ver[1];
        }
        $("#targetcite").attr("cite",cite_nover);
        $("#allcite ." + collectionElementClass).attr("cite",cite_nover);
    }
	var tabs = $(".tabs");
	if (tabs.length > 0) { tabs.tabs(); }
	getSources();
    getCommentary();
    getWitnesses();
    getParallel();
}

function toggleSourceText() {
    $(".lciurn").removeClass("highlight");
    $(this).parent('tr').toggleClass("highlight");
    $("#alledition").prevAll(".features").show();
    $("#alledition").toggle();
    
}

function showSubref() {
    var parent_block = $(this).parents("."+textElementClass).get(0);
    var uris = [];
    var textElem = $("."+subrefTextElementClass,parent_block);
    $('.toggle_subref',parent_block).text('Hide Quote');
    $(textElem).show();
    $(textElem).prev().hide();
    var cite = textElem.attr("cite");
    if (cite.indexOf(' ') > 0 ) {
        uris = cite.split(' ');
    } else {
        uris = [ cite ];
    }
    select_tokens(textElem,uris);
    return false;
}

function hideSubref() {
    var parent_block = $(this).parents("."+textElementClass).get(0);
    var textElem = $("."+subrefTextElementClass,parent_block);
    $(textElem).prev().show();
    $(textElem).hide();
    $('.toggle_subref',parent_block).text('Show Quote');

}

function openLink() {
   alert("Will open link in new browser window/tab");
   return false;
}


function getCommentary() {
    var current_lci = $('#targetcite').attr('cite');
    var regex = new RegExp(current_lci + "$");
    parseOACByTarget(annotations.commentary,regex,$("#allcommentary"),function() { disableTab("allcommentary")}); 
}

function getWitnesses() {
   var current_lci = $('#targetcite').attr('cite');
   var regex = new RegExp(current_lci + "$");
   parseOACByTarget(annotations.witness,regex,$("#allwitnesses"),function() { disableTab("allwitnesses")});
   
}

function getParallel() {
   var current_lci = $('#targetcite').attr('cite');
   var regex = new RegExp(current_lci + "$");
   parseOACByTarget(annotations.parallel,regex,$("#allparallel"),function() { disableTab("allparallel")});
   
}

function getSourceAnnotationType(a_annot,a_id,a_regex) {
    var current_source = $('#alleditions .' + textElementClass + ':visible').attr('cite');
    var state = 0;
    if (current_source) {
        var loaded = loaded_tabs[a_id][current_source];
        if (loaded != null) {
            toggleTab(a_id,loaded);
            return;
        } else {
            var match = current_source.match(a_regex);
            if (match  != null) {
                state = 1;
                var regex = new RegExp(match[1]);
                parseOACByTarget(a_annot,regex,$("#"+ a_id),
                    function() { 
                        state=0; 
                    });
            }
            loaded_tabs[a_id][current_source] = state;
        }
    }
    toggleTab(a_id,state);
}
/**
function getTreebank() {
    var current_source = $('#alleditions .' + textElementClass + ':visible').attr('cite');
    var state = 0;
    if (current_source) {
        var loaded = loaded_tabs.treebank[current_source];
        if (loaded != null) {
            toggleTab("allsyntax",loaded);
            return;
        } else {
            var match = current_source.match(/(urn:cts:.*?)[#$]/);
            if (match  != null) {
                var regex = new RegExp(match[1]);
                parseOACByTarget(annotations.treebank,regex,$("#allsyntax"),function() { disableTab("allsyntax")});
                state = 1;
            }
            loaded_tabs.treebank[current_source] = state;
        }
    }
    toggleTab("allsyntax",state);
}
*/
/**
function getAlignment() {
   var current_source = $('#alleditions .' + textElementClass + ':visible').attr('cite');
   if (current_source) {
    var match = current_source.match(/(urn:cts:.*?)$/);
    if (match  != null) {
         enableTab("allalignment");
         var regex = new RegExp(match[1]);
         parseOACByTarget(annotations.alignment,regex,$("#allalignment"),function() { disableTab("allalignment")});
    } else {
       disableTab("allalignment");
    }
   } else {
        disableTab("allalignment");
   }
    loaded_tabs.alignment[current_source] = true;
   
}
*/
function getTranslation() {
    var current_source = $('#alleditions .' + textElementClass + ':visible').attr('cite');
    var state = 0;
    if (current_source) {
        var loaded = loaded_tabs["alltranslation"][current_source];
        if (loaded != null) {
            toggleTab("alltranslation",loaded);
            return;
        } else {
            var match = current_source.match(/(urn:cts:.*?)[#$]/);
            if (match != null) {
                var parsed = [];
                var regex = new RegExp(match[1]);
                var elem = $("#alltranslation");
                //elem.empty();
                $.each(annotations.translation,
                    function(i,ann) {
                        if (ann.hasTarget.match(regex) != null) {
                            if (typeof ann.hasTarget == 'string') {
                                parsed.push({label:ann.label, hasBody:ann.hasBody, motivatedBy:ann.motivatedBy});
                            } else {
                                $.each(ann.hasTarget,function(j,boky) {
                                    parsed.push({label:ann.label, hasBody:body, motivatedBy:ann.motivatedBy});
                                });
                            }
                        }
                    });
                if (parsed.length > 1) {
                    elem.append('<div class="transtabs"><ul/><p/></div>');
                    $.each(parsed,function(i,ann){
                        $(".transtabs ul").append('<li><a href="#alttrans' + i + '">Translation ' + (i+1) + '</a></li>');
                        $(".transtabs p").append('<div id="alttrans' + i +'"><blockquote cite="' + ann.hasBody + '" data:xslt-params="blocktype=edition" class="' + textElementClass + '">Translation text will appear here.</blockquote></div>');
                    });
                    state = 1;
                    $(".transtabs").tabs();
                } else if (parsed.length == 1){
                    elem.append('<div id="alttrans1"><blockquote cite="' + parsed[0].hasBody + '" data:xslt-params="blocktype=edition" class="' + textElementClass + '">Translation text will appear here.</blockquote></div>');
                    state = 1 ;
                } 
            }
        }
        loaded_tabs.alltranslation[current_source] = state;
    }
    toggleTab("alltranslation",state);
}

function getSources() {
    var current_lci = $('#targetcite').attr('cite');
    var regex = new RegExp(current_lci + "$");
    var parsed = [];
    var elem = $("#alleditions");
    elem.empty();
    $.each(annotations.source,
        function(i,ann) {
            if (ann.hasBody.match(regex) != null) {
                if (typeof ann.hasTarget == 'string') {
                    parsed.push({label:ann.label, hasTarget:ann.hasTarget, motivatedBy:ann.motivatedBy});
                } else {
                    $.each(ann.hasTarget,function(j,target) {
                        parsed.push({label:ann.label, hasTarget:target, motivatedBy:ann.motivatedBy});
                    });
                }
            }
        });
    if (parsed.length > 1) {
        elem.append('<div class="sourcetabs"><ul/><p/></div>');
        $.each(parsed,function(i,ann){
            $(".sourcetabs ul").append('<li><a href="#altedition' + i + '">Edition ' + (i+1) + '</a></li>');
            $(".sourcetabs p").append('<div id="altedition' + i + '"><blockquote cite="' + ann.hasTarget + '" data:xslt-params="blocktype=edition" class="' + textElementClass + '">' 
                + 'Source text will appear here.</blockquote></div>');
        });
        $(".sourcetabs").tabs();
        $(".sourcetabs a").click(getSourceTextAnnotations);
    } else if (parsed.length == 1) {
        elem.append('<div id="altedition1"><blockquote cite="' + parsed[0].hasTarget + '" data:xslt-params="blocktype=edition" class="' + textElementClass + '">Source text will appear here.</blockquote></div>');
    } else {
         elem.append('<div class="source_notfound">Not Found</div>');
    }
    getSourceTextAnnotations();
}

function getSourceTextAnnotations() {
   getTranslation();
   getSourceAnnotationType(annotations.treebank,'allsyntax', new RegExp('(urn:cts:.*?)[#$]'));
   getSourceAnnotationType(annotations.otherlinks,'alllinks',new RegExp('(urn:cts:(.*?):(.*?)\.(.*?)\.(.*?))(:.*?)?[#$]'));
   getSourceAnnotationType(annotations.alignment,'allalignment',new RegExp('(urn:cts:.*?)$'));

}

function disableTab(a_id) {
    toggleTab(a_id,0);
}

function toggleTab(a_id,a_state) {
    if (a_state == 1) {
        $(".tabs").tabs("enable",a_id);
    } else {
       $(".tabs").tabs("disable",a_id);
    }
}

function parseOACByTarget(a_oac,a_targetRegex,a_fill,a_onNone) {
    //a_fill.empty();
    if ( a_oac == null || ! a_oac) {
        if (a_onNone) { 
            a_onNone(); 
        }
        else {
            a_fill.append('<div class="annotation_notfound">Not Found</div>');
        }
        return;
    }
    var parsed = [];
    $.each(a_oac,
        function(i,ann) {
            if (ann.hasTarget.match(a_targetRegex) != null) {
                if (typeof ann.hasBody == 'string') {
                    parsed.push({label:ann.label, hasBody:ann.hasBody, motivatedBy:ann.motivatedBy});
                } else {
                    $.each(ann.hasBody,function(j,body) {
                        parsed.push({label:ann.label, hasBody:body, motivatedBy:ann.motivatedBy});
                    });
                }
            }
        });
     if ( parsed.length == 0 ) {
        if (a_onNone) { 
            a_onNone(); 
        }
        else {
            a_fill.append('<div class="annotation_notfound">Not Found</div>');
        }
     }
     a_fill.append('<ul/>');
     $.each(parsed,function(i,ann) {  
        if (ann.hasBody.match(/urn:cite/) != null) {
            $('ul',a_fill).append('<li class="' + collectionElementClass + '" data:xslt-params="e_propfilter=commentary|author" cite="' + ann.hasBody + '"/>');
        } else if (ann.hasBody.match(/urn:cts/) != null) {
            $('ul',a_fill).append('<li class="' + textElementClass + '" cite="' + ann.hasBody + '"/>');
        } else if (ann.hasBody.match(/^http/) != null) {
            $('ul',a_fill).append('<li class="annotation_' + ann.motivatedBy + '">' + '<a target="_blank" href="' + ann.hasBody + '">' + ann.label + '</a></li>');
        } else {
            $('ul',a_fill).append('<li class="annotation_' + ann.motivatedBy + '">' + ann.hasBody + '</a></li>');
        }
    });
}