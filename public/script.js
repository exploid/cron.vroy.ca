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
            $("#notice").html("Processing your request...").show();
            $("#results").html("");
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
            $("#results").html("<div></div>");
            $("#notice").hide();
        }

        function displayNextCrons( data ) {
            $("#error").html("").hide();
            
            var results = $("#results");
            var cmd = data[1].cmd;

            $("#notice").html("Run <b>"+cmd+"</b> at the following timestamps:").show();

            for (var i in data) {
                var time = data[i].time;
                results.append("<div>"+time+"</div>");
            }
        }
});
