$(document).ready(function(){
        var idle_value = "Enter a crontab line to test and press enter";
        
        $("#cron").val(idle_value).attr("title", idle_value);

        $("#cron").focus(function() {
                if ( $(this).val() == idle_value ) {
                    $(this).val("");
                }
            });

        $("#cron").blur(function() {
                if ( $(this).val() == "" ) {
                    $(this).val(idle_value);
                }
            });
        
        $("#cron").keyup(function(e) {
                if ( e.keyCode == 13 ) {
                    postCronLine();
                }
            });
        
        function postCronLine() {
            var cron = $("#cron").val();
            $("#info").html("Processing your request...").show();
            $("#results").hide();
            $("#error").hide();
            $.ajax({
                    url: "/cron",
                        dataType: "json",
                        data: { cron: cron },
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
            
                var results = $("#results").html("");

                $("#info").html("Starting at <b>"+data.start_time+"</b>, the command <b>"+data.cmd+"</b> will run at:");
                
                for (var i in data.times) {
                    results.append("<div>"+data.times[i]+"</div>");
                }
                $("#results").show();
            }
        }
});
