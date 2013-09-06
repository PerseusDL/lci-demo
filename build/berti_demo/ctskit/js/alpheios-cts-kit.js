(function(window) {
    AlpheiosCtsKit = {
    		
    	/**
    	 * Text parsing helpers
    	 */
    	nontext: {
    		'grc' : '“”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\]\{\}\-',
    		'ara' : '“”—&quot;‘’,.:;?!\[\]\{\}\-&#x060C;&#x060D;',
    		'default' : '“”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\]()\{\}\-'
    	},
    		 
        /**
         * Map of language code to lexicon for lemma lookup
         **/
        lexicons: {
            'grc' : 'lsj',
            'lat' : 'ls',
            'ara' : 'lan'
        },
        
        /**
         * Map of language codes to morphology engine for form lookup
         */
        morphEngines: {
            'grc': 'morpheus',
            'lat': 'morpheus',
            'ara': 'aramorph'
        },
        
        /**
         * Url to morphology service
         */
        morphUrl : 'http://services-qa.projectbamboo.org/bsp/morphologyservice/analysis/word?word=WORD&lang=LANG&engine=ENGINE',
        
        /**
         * Url to lexicon service
         */
        lexiconUrl: 'http://repos1.alpheios.net/exist/rest/db/xq/lexi-get.xq?lx=LEXICON&lg=LANG&out=html&l=LEMMA',
        
        /**
         * jQuery document ready function
         */
        ready : function() {
            $('.cts-text').dblclick(AlpheiosCtsKit.getLemmas);
        },
        
        tokensToUrn: function(a_baseUrn,a_node) {
        	var text = $(a_node).text().trim();
        	var lang = AlpheiosCtsKit.getLanguageForElement(a_node);
        	if (lang == null || lang == '') {
        		lang = 'default';
        	}
        	var nontext = AlpheiosCtsKit.nontext[lang];
        	if (nontext != null) {
        		var regexp = new RegExp(nontext);
        		var tokens = text.split();
        		
        	}
        }
        
        /**
         * Use Morphology service to analyze form and identify lemma and lookup lemma in the lexicon service.
         */
        getLemmas : function(a_event) {
            $('#alpheios-lemmas').html('<div class="waiting">Loading lexicon....</div>');
            var lang = AlpheiosCtsKit.getLanguageForElement(this);
            if (lang != null && lang != '') {
                var url = AlpheiosCtsKit.morphUrl;
                url= url.replace('WORD',$(this).text()).replace('LANG',lang).replace('ENGINE',AlpheiosCtsKit.morphEngines[lang]);
                $.ajax(
                        url, {
                        type: 'GET',
                        dataType: 'json',
                        success: function(data,textStatus,xR) {
                            var parses = [];
                            var annotations = data.RDF.Annotation.Body;
                            var x = typeof annotations;
                            if (annotations[0] != null) 
                            {
                                for (var i in annotations) {
                                        parses[i] = annotations[i];
                                }
                            }
                            else {
                                parses[i] = annotations;
                            }
                            for (var i in parses) {
                                var entries = [];
                                var entry = parses[i].rest.entry;
                                if (entry[0] != null) {
                                    for (j in entry) {
                                        entries[j] = entry[j];
                                    }
                                }
                                else {
                                    entries[0] = entry;
                                }
                                for (var k in entries) {
                                    var lexUrl = AlpheiosCtsKit.lexiconUrl.replace('LEMMA',entries[k].dict.hdwd.$).replace('LEXICON',AlpheiosCtsKit.lexicons[lang]).replace('LANG',lang);
                                    $.ajax( lexUrl, {
                                       type: 'GET',
                                       dataType: 'html',
                                       success: function(data,textStatus,xR) {
                                        $("#alpheios-lemmas .waiting").remove();
                                        $("#alpheios-lemmas .error").remove();
                                        $('#alpheios-lemmas').append(data);
                                       },
                                       error: function() {
                                           $('#alpheios-lemmas .waiting').remove();
                                           $('#alpheios-lemmas').append('<div class="error">Lexicon lookup failed.</div>');
                                       }
                                    });
                                }
                            }
                            
                        },
                        error: function(xR,textstatus,error) {
                        	   $('#alpheios-lemmas .waiting').remove();
                               $('#alpheios-lemmas').append('<div class="error">Morphology lookup failed.</div>');                        }
                    });
                }
            },
            
            /**
             * get the language of the selected element (from the element itself or its nearest parent)
             */
            getLanguageForElement: function(a_elem) {
                var lang_key = null;
                var elem_lang = null;
                var checkSet = $(a_elem).add($(a_elem).parents());
                // iterate through the set of the element and its parents
                // taking the value of the first lang or xml:lang attribute found
                // order of parents added in checkSet is closest-first
                for (var i=0; i<checkSet.length; i++)
                {    
                    var elem = checkSet.eq(i)
                    elem_lang = elem.attr("lang") || elem.attr("xml:lang");
                    if (elem_lang)
                    {
                        break;
                    }
                }                       
                return elem_lang;
            }
    };
    window.AlpheiosCtsKit = AlpheiosCtsKit;
})(window);
