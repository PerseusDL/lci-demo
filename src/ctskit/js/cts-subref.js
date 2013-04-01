function toggle_highlight(a_elem,a_tokenSets,a_on,a_classes) {  
    $.each(a_tokenSets,
      function() { 
        var set = this;
        
          $.each(a_classes,
            function(i,a_class) {
              if (a_on) {
                $(set[0]).addClass(a_class);
              } else {
                $(set[0]).removeClass(a_class);
              }
            }
          );
          var sibs = $(set[0]).nextAll();
          var done = false;
          if (set[0] != set[1]) {
            for (var i=0; i<sibs.length; i++) {
              if (done) {
                break;
              }
              $.each(a_classes,
                function(j,a_class) {
                  if (a_on) {
                    $(sibs[i]).addClass(a_class);
                  } else {
                    $(sibs[i]).removeClass(a_class);
                  }
                  if (sibs[i] == set[1]) {
                    done = true;
                  }
                }
              ); // end class iterator
            }  // end loop through siblings
          } // end test on set length
      } // end function on token set
    ); // end iterator on token sets
}

function select_tokens(a_html,a_target_uris) {
    var tokens = [];
    $.each(a_target_uris,
      function() {
        var uri = this;
        var u_match = uri.match(/^.*?urn:cts:(.*)$/)
        if (u_match != null) {
          var parts = u_match[1].split(/:/);
          if (parts.length == 3) {
            var r_match = parts[2].match(/^.*?#(.*)$/);
            var r_start;
            var r_end;
            if (r_match != null) {
              var r_parts = r_match[1].split(/-/);
              if (r_parts.length > 0) {
                r_start = r_parts[0].replace(/[\[\]]/g,'');
                r_end = r_parts[1].replace(/[\[\]]/g,'');
              } else {
                r_start = r_parts;
                r_end = r_parts;
              }
              // TODO externalize token class
              var start_token = $(".token.text[data-ref=" + r_start + "]",a_html);
              var end_token = $(".token.text[data-ref=" + r_end + "]",a_html);
              // highlight the tokens if able to find them
              if (start_token != null && end_token != null && start_token.length == 1 && end_token.length == 1) {
                tokens.push([start_token[0],end_token[0]]);
              }
            }
          }
        }
      }
    );
    toggle_highlight(a_html,tokens,true,['highlighted']);
  }