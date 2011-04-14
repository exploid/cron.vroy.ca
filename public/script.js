$(document).ready(function(){
  
        $("#test").click(function() {
                var cron = $("#cron").val();
                
                $.ajax({
                        url: "/cron",
                            dataType: "json",
                            data: { cron: cron },
                            type: "POST",
                            success: displayNextCrons
                            });
            });
        
        function displayNextCrons( data ) {
            $("#results").html("");
            for (var i in data) {
                var time = data[i].time;
                var cmd = data[i].cmd;
                $("#results").append("<span class='time'>"+time+"</span>: "+cmd+"<br/>");
            }
        }
});
