$(document).ready(function(){

        initField( "#cron", "Enter a crontab line to test and press enter" );
        initField( "#time", "Start time (Optional)" );

        function postCronLine() {
            var cron = $("#cron").val();
            var time = $("#time").val();
            if ( time == "Start time (Optional)" ) {
                time = "";
            }

            $("#info").html("Processing your request...").show();
            $("#results").hide();
            $("#error").hide();
            $.ajax({
                    url: "/cron",
                        dataType: "json",
                        data: { cron: cron, time: time },
                        type: "POST",
                        success: displayNextCrons,
                        error: displayErrorMessage
                        });
        }
        
        function displayErrorMessage() {
            $("#error").html("Something wrong happened").show();
            $("#results").hide();
            $("#info").hide();
        }

        function displayNextCrons( data ) {
            if (data.error) {
                $("#error").html(data.error).show();
                $("#info").hide();
                $("#results").hide();
            } else {
                $("#error").hide();
                $("#info").html("Starting at <b>"+data.start_time+"</b>, the command <b>"+data.cmd+"</b> will run at:");
                if ( data.custom_time == true ) {
                    $("#time").val( data.start_time );
                }

                var results = $("#results").html("");
                for (var i in data.times) {
                    results.append("<div>"+data.times[i]+"</div>");
                }
                results.show();
            }
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
                        postCronLine();
                    }
                });
        }
});
