$(document).ready(function(){

        initField( "#cron", "Enter a crontab line to test and press enter" );
        initField( "#time", "Start time (Optional)" );

        /* Highlight the text in the example input box on click */
        $("#example").click(function() { this.select(); });

        $("#showmore").hide();

        function postCronLine(callback, time) {
            var cron = $("#cron").val();

            if (time == undefined) {
                time = $("#time").val();
            }
            if ( time == "Start time (Optional)" ) {
                time = "";
            }
            

            if (callback == displayNextCrons) {
                resetResults();
                $("#info").html("Processing your request...").show();
            }

            $.ajax({
                    url: "/cron",
                        dataType: "json",
                        data: { cron: cron, time: time },
                        type: "POST",
                        success: callback,
                        error: displayErrorMessage
                        });
        }
        
        function displayErrorMessage() {
            resetResults();
            $("#error").html("Something wrong happened").show();
        }

        function displayNextCrons( data ) {
            resetResults();
            if (data.error) {
                $("#error").html("<div class='invalid_cron'>"+data.invalid_cron+"</div><div>"+data.error+"</div>").show();
            } else {
                $("#info").html( data.human_format ).show();

                if ( data.custom_time == true ) {
                    $("#time").val( data.start_time );
                }

                var results = $("#results").html("").show();
                appendResults( data );
                $("#showmore").show().focus();
            }
        }

        function appendResults( data ) {
            var results = $("#results");
            for (var i in data.times) {
                results.append("<div>"+data.times[i]+"</div>");
            }
            $("#showmore").focus();
        }

        function resetResults() {
            $("#results").html("").hide();
            $("#info").html("").hide();
            $("#error").html("").hide();
            $("#showmore").hide();
        }

        function initField(field_selector, value) {
            $(field_selector).val(value).attr("title", value);
            $(field_selector).focus(function() {
                    if ( $(this).val() == value ) {
                        $(this).val("");
                    }
                });

            $(field_selector).blur(function() {
                    if ( $(this).val() == "" ) {
                        $(this).val(value);
                    }
                });
        
            $(field_selector).keyup(function(e) {
                    if ( e.keyCode == 13 ) {
                        postCronLine( displayNextCrons );
                    }
                });
        }

        $("#showmore").click(function() {
                // Figure out the last date that was shown and increment it for a minute.
                var time = $("#results div:last").text().match(/(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/);
                var date = new Date(time[1], parseInt(time[2])-1, parseInt(time[3]), time[4], time[5], time[6], 0);
                date.setMinutes( date.getMinutes() + 1 );

                // prepare string time for post
                var strtime = date.getFullYear()+"-"+(date.getMonth()+1)+"-"+date.getDate()+" ";
                strtime = strtime + date.getHours()+":"+date.getMinutes()+":"+date.getSeconds();

                postCronLine( appendResults, strtime );
            });
});
